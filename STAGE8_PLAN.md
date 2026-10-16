# Stage 8 Plan: Hardcore Mode and Android Launch

Source: `STAGES.md` (Stage 8) and `souls-task-tracker-design.md` (§ numbers below refer to it). Visual rules: `DESIGN.md`.
Method: TDD (see `STAGES.md`, Development method). Every step below lists its tests first, then the code. Server changes use Vitest against a real PostgreSQL, written before the code they cover. UI follows `STAGES.md`, "UI components": new widgets go in `lib/ui/` as `StatelessWidget`s, with state in thin containers in `lib/features/`.
Status: not started.

Prerequisites:
- **Stage 7 gate.** The two-phone merge gate (`STAGE7_PLAN.md` step 11 and step 12) passes. Stage 8 adds new ember event kinds that travel through sync, so sync must be stable first.
- **Stage 6 closed test.** Play requires the closed test (12+ testers opted in for 14 consecutive days, `STAGE6_PLAN.md` D12) before a personal account can apply for production. The requirement is on the account, not on one AAB. Step 9 cannot start until Play grants production access. Re-check the current rule in Play Console Help before step 9.
- Production API and database from `STAGE7_PLAN.md` step 12 are live and backed up.

---

## 1. Goal and gate

**Goal:** add the opt-in loss mechanic (§5.8, §5.12 death), with every softening rule, then ship the app to production on Google Play.

**Gate:** production release live. All of these are true:

1. `test/gates/hardcore_gate_test.dart` passes (in-memory Drift, fixed clock), scripting this story:
   - a player in hardcore mode, past the grace week, carries 20 embers and falls on a declared attempt: 10 drop at a bloodstain on that task (half, under the cap); the attempt's own earned embers are untouched;
   - they write a lesson: 2 embers come back at once (the lesson refund); the bloodstain now holds 8;
   - the next day, a Light strike on the same task recovers the 8; carried is back to 20 plus what the strike earned;
   - a second fall on the same boss before recovery: the older bloodstain is lost, the new one holds its own drop;
   - a day with a flask spent drops nothing on a fall: no stain row, no event;
   - in gentle mode, the same falls drop nothing: no stain row, no event, carried unchanged. The fallen screen shows a marker with no amount (UI only, D4);
   - in the grace week, health losses are halved and no embers drop;
   - a zero-drop fall on a boss that already has an active stain leaves that stain active.
2. `test/gates/trademark_gate_test.dart` passes: no banned term in any Dart string in `lib/`, in any ARB or copy asset file, in `docs/store-listing.md`, or in `docs/privacy-policy.md`; the scanner self-test passes.
3. The Stage 7 gate test still passes with drop, refund and recover events on both phones (`server` and `app` fixtures).
4. The app is live on the production track at 100% rollout, and for the 7 days after full rollout the halt conditions in D13 never fire: user-perceived crash rate and ANR rate stay under the D13 thresholds and no crash cluster reaches the D13 cluster threshold.

---

## 2. Where Stage 7 left us

| Area | State | Stage 8 change |
|---|---|---|
| Ember ledger | `EmberEvents` with `EmberKind { earn, bank }`; carried = earned - banked (`ember_dao.dart`) | New marker kinds `drop`, `refund`, `recover` whose amounts come from the stain (D2) |
| Bloodstains | Table, `BloodstainDao` (`drop`, `recover`, `active`, `settleBloodstains`), merge rules D11/D19, server index. Nothing writes one | A hardcore fall with a drop above 0 writes one through the single merge-upsert (D8); same-id conflicts split into winner fields and ranked status; "newer" has a deterministic key (D7); recovery on a later attempt (D6); recovered is terminal (D7) |
| Falls | `AttemptDao.fall` (declared), health death (`features/fallen/health_fall.dart`), missed day (`FallCause.missedDay`) | Each fall cause runs the drop rule with a deterministic stain id (D4, D8) |
| Mode | No setting; gentle behavior everywhere | `UserSettings.hardcore` (D1) |
| Grace week | `Settings.firstDay`, calm line only (Stage 4 D13) | Halves health losses and blocks drops (D9) |
| Store | Closed-test listing from Stage 6 | Production listing, trademark check (D12) |

---

## 3. Scope

### In Stage 8

| Item | Source |
|---|---|
| Hardcore setting with a clear opt-in and opt-out | §5.8 Modes |
| Drop on every fall cause, recovery by any attempt on that task | §5.8 steps 4 and 5, §5.12 Death |
| Softening rules: partial loss, cap, effort kept, flask protection, lesson refund | §5.8 Softening |
| Newcomer grace week reduces health losses | §5.12 Guardrails, Stage 4 D13 |
| Bloodstain marker on boss and task screens; recovery moment | §5.8, §8 |
| Sync protocol 2 for new ember kinds, with a compatibility window | Stage 7 D5 |
| Trademark audit of app strings, copy files and store listing | §4 |
| Production release on Google Play, staged rollout | §10.4 |

### Not in Stage 8 (and where it lands)

| Item | Stage |
|---|---|
| One bloodstain per user instead of per boss (§14 open question) | Revisit after launch data |
| Subscriptions, steadfast days | 9 |
| iOS | 10 |
| Crash reporting SDK | Not planned; Play vitals only (D14) |
| Server-enforced weekly ceiling | Not planned; see D4 |

---

## 4. Decisions in this plan (confirm or change)

| # | Decision | Choice | Why |
|---|---|---|---|
| D1 | Mode setting | `UserSettings.hardcore` bool, default `false`, synced as a normal LWW field. Turning it on shows a confirm dialog with the rules in plain words. It applies to falls from that moment on. Turning it off stops new drops; active bloodstains stay recoverable and are never lost by the switch. | §5.8: gentle is default, hardcore opt-in. Never taking embers away because of a settings change keeps trust. |
| D2 | Ledger | Add `EmberKind.drop`, `refund`, `recover`, appended at the end of the enum so stored indexes stay stable. Each has a deterministic id derived from the stain id (D8): `systemId(['drop', stainId])`, `systemId(['refund', stainId])`, `systemId(['recover', stainId])`. **These three kinds are markers.** The tally reads their amounts from the winning stain row, not from the event: drop = `stain.amount`, refund = `refundFor(stain.amount)`, recover = `stain.amount - refundFor(stain.amount)`. The event's own `amount` column is written for display but never trusted by the tally. Carried = earn - bank - drop + refund + recover. An event whose stain row has not arrived yet is ignored by the tally until it does (stains and events travel in the same pull payload). Markers exist only for stains with `amount > 0`; no marker is ever written without its stain row (D4). **The refund follows the winning amount; it is not frozen.** If a merge lowers a refunded stain across a rounding boundary (11 → 9: refund 3 → 2), the refund shown changes by 1, but the net held in the stain, `a - refundFor(a)`, never decreases as `a` grows, so a lower winning amount never leaves carried lower. Both phones converge on the same derived value and no event is rewritten. | Events are insert-once by id (Stage 7 D5), so two phones recovering the same bloodstain produce one recover event. Deriving amounts from the stain means only the stain payload can conflict between phones, and one merge rule (D8) settles the whole ledger. A frozen refund could exceed a lowered drop and would need a rewrite or a clamp. |
| D3 | Sync protocol | Protocol 2 adds kinds 2 to 4. The app sends `X-Sync-Protocol: 2`. **Compatibility window:** the server accepts protocol 1 and 2. For protocol 1, pulls omit ember events of kind 2 to 4 (an old app never decodes an unknown index) and pushes containing kind >= 2 are rejected with 400. A protocol-1 client of a user who also runs a protocol-2 phone may show carried too high until it updates; accepted because hardcore is opt-in and the window is short. **Cursor:** the server cursor runs over all events, filtered or not, so a protocol-1 client advances past events it never saw. To make the upgrade correct, the v7 → v8 app migration resets the local pull cursor to 0, so the first protocol-2 sync re-pulls everything. Events insert-once by id, so the re-pull is idempotent. **Retention guarantee:** `ember_events`, `bloodstains` and the other sync tables are never pruned or compacted; they are account data kept for the account's lifetime and removed only by account deletion. A pull from cursor 0 therefore returns the complete history. No retention job exists or is planned. If any is ever added, it must ship a snapshot/bootstrap path first. **Retirement:** server env `MIN_SYNC_PROTOCOL` defaults to 1. Raise it to 2 only after the protocol-2 app is at 100% rollout plus 30 days. Below the minimum, push and pull return `426` with a body the app shows as "Update Hearthrise to keep syncing." Old apps keep working offline either way. **Order:** deploy the server first (it is backward compatible), then ship the app. Release notes tell closed-test users to update. | An immediate cutoff strands old clients before they can install the fix. The filter avoids the enum crash with no cutoff. The cursor reset makes "until it updates" true, and the no-pruning guarantee makes the reset sufficient. The only protocol-1 clients today are closed testers. |
| D4 | Drop amount and zero drops | `drop = min(floor(carriedBefore * portion), capPerFall)`, with `portion = 0.5` and `capPerFall = 30`. `carriedBefore` excludes embers already sitting in other bloodstains (they are not carried). A rolling ceiling: total dropped in the last 7 days (summed from stain amounts) never exceeds 60 as seen by the device making the fall; a fall past it drops only what is left under the ceiling. **The ceiling is per device and best effort.** Each offline device can stay under 60 locally, so with N devices merged, a week's drops can reach N x 60. The overshoot is up to 60 per additional offline device between syncs. This is accepted: realistic N is 2, the per-fall cap of 30 is the hard guarantee, and every active stain stays recoverable. Embers are not destroyed by a drop; they are destroyed only when a stain is lost (D7). No server enforcement, no read-time clamp, no rewriting of merged events. **Zero drop writes nothing.** When the computed drop is 0 (gentle mode, grace week, flask day, floor, or ceiling used up), the fall writes no stain row, no drop event and no refund event, in either mode. A zero-drop fall also does not lose older active stains on the boss (D7 applies only when a new stain is written). A lesson on a zero-drop fall refunds nothing. The gentle-mode "bloodstain marker" on the fallen screen is UI only: derived from the existing fall record, with no amount and no recovery state. Constants live in `core/hardcore_rules.dart`. | §5.8 partial loss and ceiling. Embers per strike are 1, 3, 6, so a good day carries roughly 20 to 40; 30 per fall and 60 per week cap the worst stretch to about two good days. Rewriting merged events to enforce the ceiling would break offline-first for a softening rule. A zero-amount stain would be a real stain for the per-boss rule and would lose older real stains, breaking D1. Writing nothing cannot create an orphan event or a phantom stain. |
| D5 | Effort kept | The embers the failing attempt itself earned are never part of the drop: the fall computes `carriedBefore` before that attempt's earn event. A declared fall earns 0 anyway; this matters for a health death, where the final blow can follow a `tried` earn on the same task. | §5.8 "effort is always paid". |
| D6 | Recovery | Any strike or tried on the bloodstain's task recovers it, in the attempt's transaction: `BloodstainDao.recover` plus a `recover` marker event (amount derived per D2). If the task was deleted (`taskId` null), any strike or tried on the same boss recovers it. Late strikes count. | §5.8 "even a small version counts". Falling back to the boss keeps a stain from becoming unrecoverable through no fault of the player. |
| D7 | Lost embers, settling and "newer" | A lost bloodstain writes no event: the drop already left carried, and nothing comes back. The lost stain row is kept with its status, so its drop marker still counts. This is the one place embers are destroyed (§5.8). **The one-stain-per-boss rule counts active stains only.** A recovered stain is spent: it has nothing left to claim, is not shown as a marker, and does not count toward the limit. A lost stain is gone. So recovered S1 plus active S2 on one boss is one recoverable stain, and S1's recover payout is never clawed back. **Which stain is newer:** stains on one boss are ordered by the key `(droppedAt, id)`, compared in that order, with `id` as a string compare. The greatest key is the one kept; every older **active** stain on the boss is lost. `droppedAt` is deterministic per cause (D8), so one stain id never carries two `droppedAt` values, and arrival order, device clocks of the merging side and the server's receive time play no part. Ties on `droppedAt` fall to `id`. **Recovered is terminal:** settling only loses *active* stains, and status only moves up in rank (D8). A stain recovered on any phone stays recovered and its `recover` event stands, whatever order the merge sees a newer fall and the recovery. The ledger is never rewritten. Settling is run after every merge-upsert on the app and on the server, over the whole boss, so the result does not depend on the order rows arrived. Example: phone A recovers S1 while phone B falls on the same boss, creating S2. After merge S1 is recovered, S2 is active with its own drop, and the boss has exactly one active stain. | One source of truth: the ledger never needs a "lose" kind. Without terminal recovery, a recover event would pay out for a stain the merge declared lost. A total order on `(droppedAt, id)` plus monotonic status makes settling a pure function of the set of rows. |
| D8 | Fall causes, identity and the single merge-upsert | Every fall has a deterministic stain id: `systemId(['stain', cause, causeKey])`. **Declared fall:** causeKey is the attempt id; stain on the attempt's task; `droppedAt` is the attempt's timestamp. **Health death:** causeKey is the death itself, `(day, n)`, where `n` is this death's ordinal among the health deaths of that day (1 for the first, 2 after a rest and a second death). It is **not** the final-blow attempt id: two phones can disagree on which miss dealt the final blow, and keying on it gave two stains for one death, the older lost with its drop still counted, so the player paid twice. The stain sits on the final-blow task as this phone saw it, and `droppedAt` is that attempt's timestamp. **Missed day:** causeKey is the missed day's id; stain on the first unfinished plan pick of that day; `droppedAt` is the end of that day; with no picks, nothing drops. **One write path:** `BloodstainDao.upsertMerged(row)` is the only way a stain row is written, on the phone (local fall, pull) and on the server (push). If the id is new it inserts. If the id exists it merges field by field: `amount` and `taskId` come from the canonical winner (the lower `amount`, ties to the lower `taskId`); `droppedAt` is identical for one id by construction for declared falls and missed days; for a health death, where phones can disagree on the final blow, `bossId`, `taskId` and `droppedAt` all come from the canonical winner together with `amount` (this overrides Stage 7 D19's "`bossId` and `taskId` never change" for health-death stains only); `status` is not taken from the winner but is the highest rank across both rows, with rank recovered > lost > active. So a recovered row can never be rewritten to active by a lower-amount active copy, and the `recover` marker always has a recovered stain behind it. The merge is idempotent, commutative and associative, so any arrival order gives the same row. It is followed by the settle pass (D7). Because drop, refund and recover amounts derive from the merged row (D2), the whole ledger converges with no event rewriting. Preferring the smaller drop means a race never costs the player more. **Accepted consequence:** when two phones resolve the same missed day with different picks or balances, the merge keeps one stain at the lower amount on one task. The other phone's larger drop is simply not applied: those embers stay carried and nothing is destroyed. "Half, capped" is a per-device ceiling, and merge can only lower it. If two phones disagree on the health-death final blow, they write the **same** stain id; the merge keeps one stain at the canonical winner's amount, boss and task, with one drop marker, so one death drops once. | §5.8 step 4 names a task for each cause. A missed day with no plan has no honest place to attach a stain. Identity per cause removes the double-drop paths. One write path means a phone that already holds a row cannot ignore a better incoming one, so the phones and the server cannot diverge. |
| D9 | Grace week | For 7 days from `Settings.firstDay` (days 1 to 7 inclusive): health loss is halved, rounded up to the next half point (Light 2 → 1, Heavy 4 → 2, Boss-tier 6 → 3 half points), and no embers drop in either mode. The Stage 4 "beginner falls after five Heavy misses on day one" test is rewritten: on day one it now takes ten Heavy misses; the original five-miss case moves to day eight. | §5.12 newcomer grace. Stage 4 D13 deferred the reduced losses to this stage on purpose. |
| D10 | Flask protection | A fall on a day with a `skipDay` or `lightDay` flask spend drops nothing. Extension flasks do not count. | §5.8 "spending a flask on a bad day means nothing drops". An extension is not a bad-day flask. |
| D11 | Lesson refund | Writing a non-empty lesson for a fall that has a stain writes a `refund` marker at once (deterministic id, so once per stain); the tally pays `refundFor(stain.amount) = ceil(stain.amount * 0.2)` from the winning amount (D2). Recovery later returns the rest. A lesson edited or written later on the fallen screen still refunds, once. No stain, no refund (D4). | §5.8 "lessons recover some". Paying it immediately makes the lesson feel worth writing. |
| D12 | Trademarks | A banned-term list in `test/gates/banned_terms.txt` (for example: "You Died", "Estus", "Runes", "Dark Souls", "Elden", "FromSoftware", "Bonfire Lit"). The gate test scans, case-insensitive and whole word: `lib/**/*.dart` string literals, every `*.arb` and copy asset file under `app/` (step 8 first lists which exist), `docs/store-listing.md` and `docs/privacy-policy.md`. It fails if any configured glob matches zero files. A scanner self-test runs the same scanner over a temp directory holding a banned term and expects a failure. "Bloodstain" and "bonfire" are generic and allowed (§4 table). | §4 rule. A test catches regressions that a one-time review would miss. The zero-match guard stops a moved directory from passing silently. |
| D13 | Release and rollout thresholds | The Stage 7 and 8 build is a new AAB, built once from a tagged commit. It first goes to the **closed track for a 3-day soak** with hardcore on for the testers who opt in, plus a clean pre-launch report. That same AAB (no rebuild) is then promoted to production. The 14-day closed test of Stage 6 satisfies Play's account-level requirement; it is not re-run, and the rule is re-checked in Play Console Help first. Staged rollout 10% → 50% → 100%. **Who and where:** the owner checks Play Console Android vitals (crashes and ANRs, filtered to the new `versionCode`) and the server's 5xx rate on sync routes, and records each check in `STAGE8_RESULTS.md`. **Timing:** vitals lag about a day, so each step is held 2 days and read at the end of day 2. **Halt conditions (any one):** user-perceived crash rate above 1.09% or user-perceived ANR rate above 0.47% (Play's bad-behavior thresholds; re-verify the current numbers in Play Console Help before step 9); a single crash or ANR cluster affecting at least 3 distinct users or at least 2% of active users on that version; a regression of more than 2x over the previous release's rate with at least 3 affected users; a confirmed carried-balance or sync-divergence bug report; sync-route 5xx above 1% of requests over a day. **Advance condition:** no halt condition fired and the step has at least 50 installs with vitals data. **Thin data:** under 50 installs at the end of day 2, extend the hold up to 7 days. If still thin at day 7, advance only after the owner has run a manual smoke check (fall, recover, sync between two phones) on the production build; never advance on an empty dashboard alone. **On halt:** stop the rollout in Play Console, ship a fixed build with a higher `versionCode` (repeat the closed-track soak unless the fix is a one-line revert); the server keeps accepting protocols 1 and 2 throughout (D3). | An artifact cannot pass a test that predates it, so the soak build and the production build must be the same bytes. Play cannot roll back a version; halting stops new installs. Numeric thresholds and a minimum sample stop the rollout advancing on "looks fine" or stalling on an empty dashboard. |
| D14 | Crash data | Play vitals (crashes, ANRs) only. No third-party crash SDK. | Data safety form stays as in Stage 6; no new data leaves the phone. |

---

## 5. Data model

### App: schema v8

| Table | Change | Notes |
|---|---|---|
| `UserSettings` | `hardcore` bool, default `false` | D1; synced |
| `EmberEvents` | no column change; new `EmberKind` values, amounts of kinds 2 to 4 derived from the stain | D2 |
| `Bloodstains` | none | Already built in Stage 7; ids and `droppedAt` follow D8, writes go through `upsertMerged` |
| sync state | pull cursor reset to 0 in the migration | D3 |

Migration v7 → v8 adds the column and resets the pull cursor; `test/data/migration_v8_test.dart` covers it with the existing migration test pattern.

### Server

- `user_settings.hardcore boolean not null default false`.
- `ember_events.kind` accepts 0 to 4; a check constraint rejects anything else.
- Bloodstain upsert (same rule as the app's `upsertMerged`): on an id conflict, `amount` and `task_id` come from the row with the lower `amount` (then lower `task_id`), and `status` is the highest rank of the two (recovered > lost > active) (D8, D7). Settling orders by `(dropped_at, id)` and only loses active stains (D7).
- No pruning of sync tables (D3).
- Sync routes read `X-Sync-Protocol`. Protocol 1 and 2 are accepted; protocol 1 gets filtered pulls and rejected kind >= 2 pushes. Missing header counts as 1. Below `MIN_SYNC_PROTOCOL` returns `426` (D3). The cursor is computed over unfiltered events.
- OpenAPI spec and the generated Dart client regenerate from the routes.

---

## 6. Build order

One commit per step. Each step ends with `flutter analyze` clean and the full app suite green; server steps also run `npm test` in `server/`.

### Step 1: Hardcore rules (pure)

**Tests first** `test/core/hardcore_rules_test.dart`:
- `dropFor(carriedBefore, droppedLast7Days, mode, inGrace, flaskDay)`: gentle → 0; grace → 0; flask day → 0; 20 carried → 10; 100 carried → 30 (cap); 50 already dropped this week and 40 carried → 10 (ceiling); 60 already dropped → 0; 1 carried → 0 (floor);
- `refundFor(drop)`: 10 → 2, 1 → 1, 0 → 0; 11 → 3, 9 → 2;
- `heldFor(a) = a - refundFor(a)` is non-decreasing over a = 0..200 (D2: a lower winning amount never lowers carried);
- `graceHealthLoss(halfPoints)`: 2 → 1, 4 → 2, 6 → 3, 1 → 1;
- `inGraceWeek(firstDay, day)`: day 1 and day 7 true, day 8 false, null `firstDay` false;
- `stainId(cause, causeKey)`: same inputs give the same id; different cause or key gives a different id;
- `mergeStain(a, b)`: lower amount wins `amount`/`taskId`; equal amounts go to the lower `taskId`; status is the highest rank (recovered > lost > active) regardless of which row won; symmetric (`merge(a,b) == merge(b,a)`), idempotent (`merge(a,a) == a`) and associative; a recovered row with the higher amount merged with an active row with the lower amount gives recovered with the lower amount;
- `compareStains(a, b)` (D7 order): later `droppedAt` is greater; equal `droppedAt` falls to string compare of `id`; antisymmetric and total over a shuffled list.

**Code:** `core/hardcore_rules.dart`, pure functions and constants.

**Done when:** `hardcore_rules_test.dart` passes.

### Step 2: Schema v8 and ledger kinds (app)

**Tests first:**
- `test/data/migration_v8_test.dart`: v7 database upgrades with `hardcore = false`, data intact, and the pull cursor reset to 0 (D3).
- `test/data/ember_dao_test.dart` (added): carried = earn - bank - drop + refund + recover with amounts read from the stain; a drop/recover marker with a wrong stored `amount` still tallies from the stain; a marker whose stain row is absent is ignored until the stain arrives; inserting the same deterministic `recover` id twice changes nothing; `bank()` banks only carried, never embers in a bloodstain; refund regression: drop 11 with a refund marker, then the stain's winning amount becomes 9, carried goes up by 1 and is the same on a second DAO that applied the two rows in the other order (D2).

**Code:** `UserSettings.hardcore`, `EmberKind` values, `EmberDao.tally` update (join to stains for kinds 2 to 4), `SettingsDao.setHardcore`, cursor reset in the migration.

**Done when:** both files and the existing sync tests pass.

### Step 3: Drop on fall (app)

**Tests first** `test/data/hardcore_fall_test.dart` (in-memory Drift, fixed clock):
- declared fall in hardcore drops per D4 at a stain on that task; the drop marker and stain share the transaction;
- health death drops on the final-blow task, and excludes the final blow's own `tried` earn (D5); its stain id is `systemId(['stain', 'healthDeath', day, n])`, and a second death after a rest the same day gets `n = 2` (D8);
- missed day drops on the first unfinished pick; with no picks, nothing drops (D8);
- duplicate resolution, one case per cause (declared, health, missed day): resolving the same fall twice writes one stain and one drop marker (D8);
- `upsertMerged` with an incoming row for an id that already exists locally, **both orders** (local higher amount then incoming lower; local lower then incoming higher): both end on the lower amount, ties go to the lower `taskId`, and carried follows the winner (D8);
- `upsertMerged` with an incoming active row while the local row is recovered, and the reverse: the row ends recovered in both orders (D8, D7);
- second fall on the same boss that drops above 0: the older stain is lost, no event written for it (D7);
- two offline falls on one boss arriving in both orders: the greater `(droppedAt, id)` stays active and the other is lost, identical result in both orders; tied `droppedAt` falls to `id` (D7);
- recovered S1 plus a newer S2 on the same boss, S2 merged in after S1's recovery and also the reverse order: S1 stays recovered, S2 is active, the boss has exactly one active stain, S1's recover event still counts once (D7);
- zero-drop falls (gentle mode, grace week, flask day, 1 carried, ceiling used up): no stain row, no drop event, no refund event, carried unchanged; an older active stain on the same boss stays active (D4);
- `fall(bossId, lesson)` with a lesson on a dropping fall writes the refund marker in the same transaction; a later `addLesson` refunds once only; a lesson on a zero-drop fall writes no event (D11).

**Code:** `core/fall_drop.dart` (computes inputs), changes in `AttemptDao.fall`, `health_fall.dart`'s DAO path, the missed-day resolver, and `BloodstainDao.upsertMerged` (the only stain write path: insert-if-absent, `mergeStain` on conflict, then the settle pass ordered by `compareStains`). Early return before any write when the drop is 0.

**Done when:** `hardcore_fall_test.dart` and all existing fall tests pass.

### Step 4: Recovery (app)

**Tests first** `test/data/hardcore_recovery_test.dart`:
- a strike, a tried and a late strike on the stain's task each recover it, paying `amount - refundFor(amount)` via the marker;
- a strike on another task of the same boss does not recover; after the task is deleted it does (D6);
- recovering twice (two phones, merged) leaves one `recover` event and carried counts it once;
- switching to gentle keeps the stain recoverable (D1);
- a recovered stain is not lost by a later fall on the same boss; only active stains are settled (D7).

**Code:** recovery hook in the attempt write path (`AttemptDao`), `BloodstainDao.recover` returning the amount; settle pass skips recovered stains.

**Done when:** the file passes.

### Step 5: Grace week health (app)

**Tests first:**
- `test/data/health_dao_test.dart` (added): a miss in grace costs half (D9); on day 8 the full cost;
- `test/features/stage4_gate_test.dart` (rewritten per D9): day one now needs ten Heavy misses to fall; the five-miss fall happens on day eight.

**Code:** `HealthDao` loss computation reads `inGraceWeek`.

**Done when:** both files pass.

### Step 6: Sync protocol 2 (server, then app)

**First:** read `STAGE7_PLAN.md` and the server code for any pruning or retention job on sync tables. If one exists, exempt `ember_events` and `bloodstains` from it, test first (D3).

**Tests first:**
- `server/test/sync_protocol.test.ts`:
  - protocol 2 push and pull: drop/refund/recover events round-trip; `kind = 5` is rejected; `user_settings.hardcore` merges LWW;
  - protocol 1 (and missing header): pull omits kinds 2 to 4 and returns the rest unchanged; push of kind 0 or 1 is accepted; push of kind >= 2 returns 400;
  - cursor: a protocol-1 pull advances the cursor past filtered events; a protocol-2 pull from cursor 0 then returns the drop/refund/recover events (the upgrade path, D3);
  - retention: a protocol-2 pull from cursor 0 returns the oldest event of every kind, including events older than anything else in the table (D3);
  - stain upsert on the same id with different payloads: lower amount wins `amount`/`task_id`, tie goes to lower `task_id`, in both push orders;
  - stain upsert status rank: a recovered row pushed after or before an active row with a lower amount stays recovered with the lower amount, in both push orders; lost never overwrites recovered; active never overwrites lost;
  - settle order: two active stains on one boss pushed in both orders keep the greater `(dropped_at, id)`; tied `dropped_at` falls to `id`;
  - recovered S1 and a newer active S2 on one boss pushed in both orders: S1 stays recovered, S2 stays active, exactly one active stain on the boss (D7);
  - with `MIN_SYNC_PROTOCOL=2`: protocol 1 push and pull return `426` with the update body; protocol 2 still works.
- `server/test/fixtures/bloodstains.json` gains drop/recover cases, including:
  - two phones make distinct offline falls (two per device, on different bosses) whose local totals each stay under 60 and merge past 60, up to 60 over per extra device (documents the D4 bound; nothing is rewritten);
  - two phones resolve the same missed day with **different first unfinished picks and different carried balances**, merged in both arrival orders: one stain id, the lower-amount payload wins on both phones, one drop marker, the stain amount and task are the winner's on both phones, carried is identical on both phones, and the phone that had the higher amount ends with carried higher than before the merge (D8 accepted consequence);
  - two phones resolve the same missed day with equal amounts and different picks: the lower `taskId` wins on both phones;
  - phone A recovers S1 (amount 10) while phone B holds the same S1 active at amount 6, merged in both arrival orders: S1 is recovered with amount 6, one recover marker pays 6 minus its refund share, carried is identical on both phones (D8, D7);
  - a refunded stain whose winning amount changes across a rounding boundary (11 → 9), merged in both orders: carried identical on both phones and 1 higher than before the merge (D2);
  - two phones disagree on a health-death final blow, on the same boss and on different bosses, merged in both arrival orders: one stain id `(day, n)`, one drop marker, boss, task, amount and `droppedAt` are the canonical winner's on both phones, carried is identical on both phones and no lower than either phone showed alone (D8);
  - a rest and a second health death on the same day give two stain ids, `(day, 1)` and `(day, 2)`, and the per-boss rule applies between them (D7, D8);
  - phone A recovers S1 while phone B falls on the same boss (S2), merged in both arrival orders: S1 stays recovered, its recover event counts once, S2 stays active, one active stain on the boss (D7);
  - one phone has a zero-drop fall (gentle or grace) and the other a dropping fall on the same boss: the zero-drop phone contributes no rows, so merge leaves the dropping stain active.
  - `app/test/data/sync_service_test.dart` runs the same fixtures through `upsertMerged`; a `426` sets the sync status to "update needed" and stops retrying.
- `test/gates/stage7_gate_test.dart` (added case): both phones recover the same stain offline; after merge carried is counted once.

**Code:** server migration, bloodstain upsert merge rule (field winner plus status rank) and settle ordering by `(dropped_at, id)`, route header check and protocol-1 filter, `MIN_SYNC_PROTOCOL` config, OpenAPI regen, Dart client regen, `SyncService` sends the header, applies pulled stains through `upsertMerged`, and handles `426`. If the Stage 7 server settle code does not already treat recovered as terminal, change it here, test first.

**Done when:** server and app suites pass.

### Step 7: Hardcore UI

**`lib/ui/` widgets (tests first, one widget test each):**
- `BloodstainMark`: small marker with an amount, or no amount in gentle mode;
- `HardcoreConfirmSheet`: the rules in plain words, Confirm and Cancel callbacks;
- `FallenEmbersLine`: "Your embers lie where you fell. Return to claim them." with the amount, and the refund line after a lesson.

**Tests first** `test/features/settings_hardcore_test.dart`, `test/features/fallen_hardcore_test.dart`, `test/features/boss_bloodstain_test.dart`: the toggle opens the sheet and saves only on Confirm; the fallen screen shows the dropped amount and the refund (both read from the derived values); in gentle mode or on a zero-drop fall the fallen screen shows the marker with no amount and no claim line (derived from the fall record); the boss and task rows show the marker only for active stains (a boss with recovered S1 and active S2 shows one marker); recovery shows a calm line ("Reclaimed 8 embers.") with a light haptic through the container.

**Code:** containers in `features/settings`, `features/fallen`, `features/boss`; copy in Hearthrise vocabulary; no red text (§5.8 tone).

**Manual checks:** 200% text on the confirm sheet and the fallen screen; TalkBack reads the marker amount.

**Done when:** the widget and feature tests pass and the manual checks are ticked.

### Step 8: Scripted gates

**Tests first (these are the step):** `test/gates/hardcore_gate_test.dart` (gate item 1) and `test/gates/trademark_gate_test.dart` with `banned_terms.txt` (gate item 2, D12, including the scanner self-test and the zero-match guard). Both start red if anything above is missing. Before writing the trademark test, list which ARB and copy asset files exist under `app/` and put each location in the scanner's globs. No new code expected beyond fixes.

**Done when:** both pass in the full suite.

### Step 9: Soak and production release (manual, with automated pre-checks)

**Tests first:** `test/release_config_test.dart` (added): `versionCode` is higher than the Stage 6 closed-test build; release still refuses debug signing.

**Manual:**
- Deploy the protocol-2-capable server (still accepting protocol 1) before any app build reaches testers (D3).
- Re-check Play's current bad-behavior thresholds and write the numbers used into `STAGE8_RESULTS.md` (D13).
- Build the AAB once from a tagged commit; record the tag and `versionCode` in `STAGE8_RESULTS.md`.
- Closed-track soak, 3 days minimum, with hardcore on for opted-in testers. Pre-launch report has no crash. Release notes tell closed-test users to update for sync.
- Play Console: re-check the production-access rule; production access granted; production listing updated from `docs/store-listing.md`; screenshots retaken without any game art; Data safety unchanged and reviewed; content rating reviewed.
- Privacy policy (`docs/privacy-policy.md`) mentions the hardcore setting syncs with the account.
- Promote that same AAB to production. Staged rollout per D13: at the end of each 2-day hold, read vitals and sync 5xx, record the numbers, install count and decision (advance, extend, halt) in `STAGE8_RESULTS.md`.
- 30 days after 100% rollout: set `MIN_SYNC_PROTOCOL=2` on the server and note the date in `STAGE8_RESULTS.md`.

**Done when:** 100% rollout and 7 days with no D13 halt condition (gate item 4).

---

## 7. `lib/ui/` widgets

| Widget | Status | Used by |
|---|---|---|
| `BloodstainMark` | new | boss screen, task row, today |
| `HardcoreConfirmSheet` | new | settings |
| `FallenEmbersLine` | new | fallen screen |
| `SettingSwitchRow` | existing | settings hardcore toggle |
| `EmberTally` | existing, gains an "in bloodstains" value | home, bonfire |

---

## 8. Risks

| Risk | Likelihood | Handling |
|---|---|---|
| Players feel cheated and uninstall after a drop | Medium | Opt-in only, cap and weekly ceiling, lesson refund, grace week, calm copy; track hardcore opt-out rate in tester feedback |
| Old app versions crash on new ember kinds | Medium | Protocol-1 pulls filter kinds 2 to 4 (D3); 426 only after the retirement date |
| Upgraded app misses events that a protocol-1 pull skipped | Medium | Cursor reset in the v8 migration; no pruning of sync tables; server test of v1 pull then v2 pull and a cursor-0 pull of the oldest events (D3) |
| Old app shows carried too high next to a protocol-2 phone | Low | Accepted; short window, opt-in mode, release notes ask for the update |
| Double recovery or double drop from two phones inflates or deflates carried | Medium | Deterministic stain and event ids (D2, D8), gate cases in steps 3, 4 and 6 |
| Two phones write the same stain id with different payloads and diverge | Medium | Single `upsertMerged` write path on phones and server: field winner plus ranked status, ledger amounts derived from the stain (D2, D8); app and server tests in both arrival orders |
| Same missed day resolved on two phones applies only the lower drop | Low | Accepted (D8): embers stay carried, never destroyed; fixture asserts stain amount and carried on both phones |
| A same-id merge turns a recovered stain back to active | Medium | Status takes the highest rank, recovered > lost > active (D8, D7); server and app tests in both arrival orders |
| Recover event pays out for a stain the merge calls lost | Medium | Recovered is terminal in settling (D7); merge tests in both arrival orders |
| Recovered S1 plus newer S2 leaves the boss with two recoverable stains | Low | One-stain rule counts active stains only (D7); app and server tests assert exactly one active stain in both orders |
| "Newer stain" depends on arrival order and phones disagree on which is lost | Medium | Total order `(droppedAt, id)` with deterministic `droppedAt` per cause (D7, D8); tests with both orders and tied timestamps |
| Refund changes by 1 when a merge lowers the winning amount | Low | Derived and convergent; net held never decreases as amount grows, so carried never drops (D2); pure and fixture regression for 11 → 9 |
| Zero-drop fall leaves an orphan event or a phantom stain | Low | Zero drop writes nothing (D4); DAO tests per zero-drop cause and a gate case |
| Weekly ceiling exceeded after offline merge | Low | Accepted; up to 60 over per extra offline device (D4); fixture documents it |
| Stage 4 gate test changes meaning | Certain | Rewritten on purpose in step 5 (D9) |
| Play production access delayed | Medium | Steps 1 to 8 do not need it |
| Production build differs from the soaked build | Low | One tagged AAB, promoted not rebuilt (D13) |
| Rollout advances on weak signal or stalls on an empty dashboard | Medium | Numeric halt thresholds, 50-install minimum, 7-day cap on thin data followed by a manual smoke check (D13) |
| Trademark complaint on listing | Low | Gate test over code, copy files and docs, plus manual listing review |
