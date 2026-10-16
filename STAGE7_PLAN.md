# Stage 7 Plan: Backend and Sync

Source: `STAGES.md` (Stage 7) and `souls-task-tracker-design.md` (§ numbers below refer to it). Visual rules: `DESIGN.md`.
Method: TDD (see `STAGES.md`, Development method). Every step below lists its tests first, then the code. This applies to the server too: Vitest tests against a real PostgreSQL, written before the route or rule they cover. UI follows `STAGES.md`, "UI components": new widgets go in `lib/ui/` as `StatelessWidget`s, with state in thin containers in `lib/features/`.
Status: not started.

Prerequisites:
- **Stage 6 gate.** `STAGES.md` says not to start the next stage until the gate passes, and Stage 6 steps 10 to 12 are still open. Steps 1 to 7 below touch no shipped build and can be written while the closed test runs, but nothing from Stage 7 is merged into a Play upload until the Stage 6 gate review (`STAGE6_RESULTS.md`) is done. Tuning changes from that review land first.
- Docker on the dev Mac (local PostgreSQL for server tests).
- A Google Cloud project with OAuth client IDs: one **Android** client (package `com.hearthrise.app` plus the SHA-1 of the upload key **and** of the Play app signing key) and one **Web** client (its ID is the `serverClientId` the app passes, and the audience the server checks). Needs the Play Console from Stage 6 step 10 for the app signing SHA-1.
- A hosting choice for the API and database (D12). Needed by step 12, not before.
- The Android SDK and a second phone (or emulator) for the step 12 manual checks. Steps 1 to 11 do not need it.

---

## 1. Goal and gate

**Goal:** optional cloud backup and multi-device use, with the phone still the source of truth for every write (§9.3). The app keeps working with no account and no network, exactly as in Stage 6.

**Gate:** offline edits on two devices merge without losing embers, health events or relics. All of these are true:
1. Scripted (step 11, real server, real PostgreSQL, two in-memory app databases): devices A and B sign in to one account and sync; both go offline; A strikes two tasks, banks at the bonfire and defeats a boss (relic); B strikes a different task, misses a deadline, falls on a missed day, and edits the boss title A just defeated; both sync in either order. Afterwards both databases are row-for-row equal on every synced table, and:
   - carried and banked embers equal the sum of both devices' ember events;
   - current health equals the result of every health event from both devices;
   - the relic exists once, unchanged except by its own inscription edit;
   - the missed day, seen by both devices, produced **one** fallen attempt per boss and **one** health loss per missed commitment, not two (D6);
   - the boss's attempt number counts every distinct fall from both devices (D7);
   - flasks equal the result of every flask event from both devices (D8);
   - both devices dropped a bloodstain on the same boss while offline (through `BloodstainDao`, since no screen drops one until Stage 8): after the merge exactly one is active (the newer), the other is lost (D11);
   - device A recovered a bloodstain while device B dropped a newer one on that boss: the recovery stands, and the newer one is the active one (D19).
2. Scripted: a record edited on both devices keeps the later `updatedAt`; a record deleted on one device and edited earlier on the other stays deleted; a record edited **after** the delete stays deleted too (D5), and its children are gone on both devices.
3. Scripted: a device that signs in with local data to an account that already has data merges both sets; nothing on either side is dropped.
4. Scripted: no account, no network: the full Stage 1 to 6 gate tests pass unchanged, and no HTTP request is made.
5. Server tests: an invalid, expired or wrong-audience Google ID token gets 401; one account cannot read or write another's rows; account deletion removes every row of that user.
6. Every Stage 1 to 6 gate test still passes; `flutter analyze` is clean and the full app suite passes; `npm test` in `server/` passes and `npm run lint` is clean.
7. Manual checks in step 12 pass on a release build against the hosted server.

---

## 2. Where Stage 6 left us

| Piece | Where | Stage 7 use |
|---|---|---|
| uuid v4 ids on every record | `core/ids.dart` | Good for user-made records. **Not** good for records two devices make for the same reason (D6) |
| `updatedAt` on `Bosses`, `Phases`, `Tasks`, `Commitments`, `Relics` | `data/tables.dart` | LWW key. Missing on `Settings`, `DayLogs`, `PlanPicks` (step 1) |
| Embers derived from `EmberEvents` (`EmberDao._sum`) | `data/ember_dao.dart` | Already event-derived; sync must only add events, never totals |
| Health derived from `HealthEvents` | `data/health_dao.dart` | Same |
| `Settings.flasks` is a **counter** | `data/day_dao.dart`, `data/commitment_dao.dart` | LWW would lose a spend or a restore. Becomes `FlaskEvents` (D8) |
| `Bosses.attemptNumber` is a **counter** (`failBoss` adds 1) | `data/attempt_dao.dart` | Two offline falls would count once. Re-derived after each pull (D7) |
| `DayLogs` keyed by (`day`, `kind`) | `data/tables.dart` | Natural key; two devices' bonfires on one day are one row |
| Cascade deletes (`deleteBoss`, `deleteTask`) | `data/boss_dao.dart` | Need tombstones so the delete reaches the other device (D5) |
| `Settings.lastResolvedDay`, `onboarded`, `firstDay` | `data/tables.dart` | Per-device; not synced (D9) |
| `Visits`, `SignalEvents` | `data/tables.dart` | Tester signals; stay local (D10) |
| No `INTERNET` permission, asserted by test | `test/release_config_test.dart` | Test changes: `INTERNET` allowed, nothing else new (step 10) |
| Privacy policy says "no account, no network" | `docs/privacy-policy.md` | Rewritten for optional sync (step 10) |
| Bloodstains | Not built; §5.8 and §9.1 define them | Table, DAO rule and sync rule built here (D11, D19); the drop on fall stays in Stage 8 |
| Schema v6 with step migrations | `data/database.dart` | Schema v7 (step 1) |

---

## 3. Scope

### In Stage 7

| Item | Design ref |
|---|---|
| Node.js + TypeScript API (Fastify) with PostgreSQL, tables mirroring the synced app tables | §10.2 |
| OpenAPI spec generated from the route schemas; Dart client generated from it | §10.2 |
| Google sign-in in the app; server verifies the ID token and issues its own session token | §10.1, §10.2 |
| Push (batch of changes) and pull (changes since a cursor) endpoints | §9.3, §10.2 |
| Change capture on the phone: every local write queues an outbox entry in the same transaction | §9.3 |
| Conflict rules: LWW by `updatedAt` for mutable records; insert-once for events; derived totals; tombstones | §9.2, §10.2 |
| `Bloodstains` table, `BloodstainDao` with the one-active-per-boss rule, and its merge on both sides | §9.1, §9.2, §10.2 |
| Sync on start, on resume and shortly after a write; quiet status in Settings | §9.3 |
| Sign out, and delete account (in the app and on a web page) | Play account deletion policy |
| Privacy policy, Data safety form and manifest updated for sign-in and sync | §10.4 |

### Not in Stage 7 (and where it lands)

| Item | Stage |
|---|---|
| Dropping a bloodstain on a fall, recovery by a small task, ember loss and softening rules | 8 (§5.8) |
| Server-side steadfast days, tiers, purchases | 9 |
| Sign in with Apple, iOS build | When iOS starts (§10.5) |
| Real-time push between devices (websockets, FCM) | Not planned; pull on start and resume is enough |
| Sharing, friends, any second user seeing data | §16.3 |
| End-to-end encryption of user text | Not planned for 7; see risks |
| AI planner key hosting | 11 (decided there; this server is a candidate) |

---

## 4. Decisions in this plan (confirm or change)

| # | Question | Decision | Why |
|---|---|---|---|
| D1 | Is an account required? | **No.** Sync is opt-in from Settings ("Back up and sync"). Without it the app is exactly the Stage 6 app and makes no request. | §9.3 offline-first, and Stage 6 testers chose an app with no account. Keeps the free core working. |
| D2 | Server stack | **Fastify + TypeScript**, `@sinclair/typebox` route schemas, `@fastify/swagger` emits `openapi.json`. PostgreSQL 16 via `pg` and plain SQL migrations (`node-pg-migrate`). Tests: **Vitest** against a real PostgreSQL (Docker, one schema per test file). Code lives in `server/` at the repo root. | Fastify validates with the same schemas that produce the OpenAPI spec, so the spec cannot drift from the code. Real PostgreSQL catches constraint and transaction bugs an in-memory fake would hide. |
| D3 | Dart client | `openapi-generator-cli` (`dart-dio`) generates `app/packages/hearthrise_api/` from the committed `server/openapi.json`. A server test fails if the emitted spec differs from the committed one; an app test fails if the generated package is older than the spec (hash in a header comment). | §10.2 "models are not written twice". Both checks keep the three in step without a manual reminder. |
| D4 | Sign-in and sessions | `google_sign_in` on the phone with the Web client ID as `serverClientId`. `POST /v1/auth/google` verifies the ID token with `google-auth-library` (signature, `aud` = Web client ID, `iss`, `exp`, `email_verified`), finds or creates the user by Google `sub`, and returns an **opaque session token** (32 random bytes; only its SHA-256 is stored), valid 60 days, renewed on use. The phone keeps it in `flutter_secure_storage`. | Google ID tokens last about an hour; re-verifying each call would force silent re-sign-ins. An opaque token can be revoked by deleting one row, and a leaked database holds no usable tokens. |
| D5 | Change model | **Mutable records** (bosses, phases, tasks, commitments, relics, settings, day logs, plan picks): last-write-wins by the record's `updatedAt`, ties broken by device id. **Events** (attempts, ember, health, flask events): insert-once by id, never updated, never LWW. **Deletes**: a tombstone (`table`, `id`, `deletedAt`). A tombstone beats any edit of that id, earlier or later, and the server deletes the children the app would cascade. | §10.2. Events are facts; there is nothing to overwrite. "Delete wins" is the only rule where a merge cannot bring back something the user threw away. |
| D6 | Records two devices make for the same reason | System-made records get **deterministic ids** (uuid v5 over a fixed namespace) instead of v4: missed-day attempt = (`bossId`, `day`, `missedDay`); health loss for a missed commitment = (`commitmentId`, `miss`); bonfire restore = (`day`, `bonfireRestore`); rise restore = (attempt id, `rise`); ember earn for a strike = (`taskId`, strike period: the day for daily tasks, the open-from attempt for one-off tasks); flask restore = (`day`, `restore`). Insert-once by id then keeps one. User-made records (a declared fall, a typed lesson) stay v4. | Without this, both devices resolving the same missed day write two falls and two health losses, which the gate forbids. The rule also matches §9.2 "reopened tasks never pay embers twice". Step 2 lists every `newId()` call site and which kind it is. |
| D7 | Boss attempt number | Stays a column for reads, but after every pull it is **recomputed** from the attempts: 1 + the number of distinct fallen attempts on that boss (matching `failBoss`). `failBoss` keeps adding 1 locally for speed. A test checks the formula equals the counter on every existing gate scenario. | A counter merged by LWW loses a fall; a count of attempts cannot. Recomputing avoids changing every reader. |
| D8 | Flasks | New `FlaskEvents` table (`id`, `kind` spend or restore, `amount`, `reason`, `day`, `at`). Flasks left = start (3) + restores − spends, clamped to 0 and the cap **at each step in time order**. v7 migration writes one event that brings the sum to the current value. `Settings.flasks` is dropped. | Same reason as D7, and §9.1 already lists "Flask use" as an entity. Clamping per step keeps the cap rule. |
| D9 | Settings | One synced `UserSettings` record (tap mode, default reset, haptics, rollover hour, reminder on and time, sound), LWW per record. **Per-device** and never synced: `lastResolvedDay`, `onboarded`, notification schedule. `firstDay` syncs as the **earliest** value seen. | A second phone should not repeat onboarding answers but must run its own missed-day resolution and its own reminders. |
| D10 | Tester signals (`Visits`, `SignalEvents`) | **Local only**, not synced. | They are closed-test instruments with their own privacy promise (Stage 6 D1). Syncing them would widen the Data safety answer for no product value. |
| D11 | One active bloodstain per boss | The `Bloodstains` table and `BloodstainDao` are built **in this stage**, with no screen writing them yet (Stage 8 adds the drop on fall). `BloodstainDao.drop()` marks any older active bloodstain on that boss lost in the same transaction (§9.2). After every pull, and on the server after every push, `settleBloodstains(bossId)` keeps the **newest** active one (by `createdAt`, ties by id) and marks the rest lost with `lostAt` = the newest one's `createdAt`. The server also has a partial unique index on (`user_id`, `boss_id`) where `recovered_at` and `lost_at` are null and `deleted_at` is null, so a bug cannot store two. | Two offline devices can each drop one, and the rule must hold after any merge order. Building it with sync means Stage 8 only adds behavior, not schema or sync changes. Settling to a fixed answer (newest wins) makes both merge orders converge. |
| D12 | Hosting | **Fly.io** (one small machine, region near the testers) with **Neon** or Fly Postgres; TLS only; daily database backups kept 7 days. Final pick in step 12. | Cheap at this size, no lock-in: plain Node and PostgreSQL run anywhere. To confirm with cost at step 12. |
| D13 | Cursor and clocks | The server gives every stored change a `seq` (bigserial). Pull returns changes with `seq` greater than the device's cursor, oldest first, in pages of 500. LWW compares the **client** `updatedAt` (what the user did last), never the server receive time. A client time more than 24 h in the future is rejected with 422 for that record. | `seq` makes pull exact even when phone clocks disagree; the future-time guard stops one bad clock from winning every conflict forever. |
| D14 | Change capture | SQLite **triggers** on each synced table write an outbox row (`table`, `rowId`, `op`) on insert, update and delete, skipped while `SyncState.applying` is 1 (during a pull). The sync service reads the outbox, sends the current row (or a tombstone), and clears entries the server acknowledged. | One mechanism covers every DAO, including future ones, and it is in the same transaction as the write (§9.3 "never fails"). A forgotten "mark dirty" call is impossible. |
| D15 | When to sync | On app start, on `resumed`, and 5 s after the last local write (debounced). Failures back off 30 s, 2 min, 10 min, then wait for the next start or resume. No background job. | Matches how missed days are already resolved (on open). WorkManager adds a platform module for little gain. |
| D16 | First sign-in with local data | Upload everything local, then pull. Records with the same id merge by D5; different ids both stay. If the account already has bosses, a sheet says "This account has data from another phone. Both will be kept." with one button. | Gate item 3. Never ask the user to pick a side and lose the other. |
| D17 | Account deletion | Settings, "Delete account": confirm sheet, then `DELETE /v1/account` removes every row of the user and all sessions; the phone keeps its local data and returns to no-account mode. Same action on a small web page (sign in with Google, confirm). | Play requires in-app and web deletion for apps that create accounts. Keeping local data avoids surprise loss. |
| D18 | Sign out | Stops sync and forgets the session token. Local data stays. | Same reason as D17. |
| D19 | Bloodstain field merge | Bloodstains are **not** plain LWW. Fields merge one by one: `bossId`, `taskId`, `attemptId`, `amount`, `createdAt` never change after insert; `recoveredAt` = the earliest non-null value from either side; `lostAt` = the earliest non-null value, but **cleared if `recoveredAt` is set**. A recovery is never undone by a merge. Then D11 settling runs. | LWW on the whole row could let a later "lost" overwrite a recovery made offline, which would take back something the user earned. Field merge is order-independent, so A-then-B and B-then-A give the same row. |

---

## 5. Data model

### App: schema v7

One migration (`from6To7`). Dump the schema and generate step helpers, as for v6.

**New tables**

| Table | Columns | Notes |
|---|---|---|
| `FlaskEvents` | `id` text, `kind` int (`FlaskKind`), `amount` int, `reason` int (`FlaskReason`), `day` text, `at` datetime | D8 |
| `Bloodstains` | `id` text, `bossId` text (cascade), `taskId` text nullable (set null), `attemptId` text nullable (set null), `amount` int, `createdAt`, `recoveredAt` nullable, `lostAt` nullable, `updatedAt` datetime | D11, D19. Active = neither recovered nor lost |
| `UserSettings` | the synced columns from `Settings`, plus `updatedAt` | D9; single row, fixed id |
| `SyncOutbox` | `seq` int autoincrement, `tbl` text, `rowId` text, `op` int (`SyncOp`) | D14 |
| `SyncState` | `deviceId` text, `cursor` int, `applying` bool, `accountEmail` text nullable, `lastSyncAt` datetime nullable, `lastError` text nullable | Single row. Session token is in secure storage, not here |

**Changed tables**
- `Settings`: drops `flasks` and the columns moved to `UserSettings`; keeps the per-device ones.
- `DayLogs`, `PlanPicks`: add `updatedAt` (backfill with `at` or now).
- Composite keys (`DayLogs`, `PlanPicks`) get a synced id: `"$day:$kind"` and `"$day:$taskId"`, computed, so the server stores one text id for every table.

**Backfill:** one `FlaskEvents` restore or spend that makes the derived count equal the old `flasks`; `UserSettings` copied from `Settings`; `SyncState` with a new device id and cursor 0; **no outbox rows** (the first sign-in uploads everything, D16).

**Triggers:** insert, update and delete triggers on `Bosses`, `Phases`, `Tasks`, `Attempts`, `Commitments`, `HealthEvents`, `EmberEvents`, `FlaskEvents`, `Relics`, `Bloodstains`, `DayLogs`, `PlanPicks`, `UserSettings`, each `WHEN (SELECT applying FROM sync_state) = 0`.

**`enums.dart`** (append only): `FlaskKind { spend, restore }`, `FlaskReason { skipDay, lightDay, extension, bonfire }`, `SyncOp { upsert, delete }`.

### Server: PostgreSQL

- `users` (`id` uuid, `google_sub` unique, `email`, `created_at`), `sessions` (`token_hash` bytea pk, `user_id`, `expires_at`).
- One table per synced app table, same columns in snake_case, plus `user_id`, `updated_at` (client), `seq` bigint (global sequence, set on every write), `deleted_at` nullable (tombstone kept in place). Primary key (`user_id`, `id`).
- Event tables have no `updated_at`; insert uses `ON CONFLICT DO NOTHING`.
- `bloodstains` merges by D19, then settles by D11, in the push transaction; partial unique index `one_active_bloodstain` on (`user_id`, `boss_id`) where `recovered_at`, `lost_at` and `deleted_at` are null.
- Row-level scoping: every query filters on `user_id` from the session; a test proves cross-user access is impossible (gate item 5).

---

## 6. Build order

Each step: tests first (red), then code (green), then refactor. One commit per step. An app step is done when `flutter analyze` is clean and the full suite passes (run from `app/`); a server step when `npm test` and `npm run lint` pass (run from `server/`).

### Step 1: Schema v7 (app)

**Tests first**
- `test/drift/hearthrise/migration_v7_test.dart`: a v6 database with bosses, attempts, commitments, health, ember events, relics and `flasks = 1` upgrades with everything intact; derived flasks are still 1; `UserSettings` equals the old settings; `DayLogs` and `PlanPicks` have `updatedAt`; `SyncState` has a device id and cursor 0; the outbox is empty.
- `test/data/enums_test.dart` (added): new enums; existing indexes unchanged.
- `test/data/flask_test.dart`: spend and restore events give the same answers `day_dao_test.dart` expects today; clamping at 0 and at the cap happens per step in time order (D8).

**Code:** tables, enums, schema dump, `from6To7`; `DayDao` and `CommitmentDao` write `FlaskEvents` instead of the counter; readers of `Settings` synced columns move to `UserSettings`.

**Done when:** the three files pass, the v1 to v6 migration tests still pass, and `day_dao_test`, `commitment_dao_test`, `profile_dao_test` are green.

### Step 2: Deterministic ids for system-made records (app)

**Tests first**
- `test/core/ids_test.dart`: `systemId(parts)` is a uuid v5, the same for the same parts, different for different parts, and never equal to a v4.
- `test/data/system_ids_test.dart`: run the missed-day resolution, the bonfire, a rise, a missed commitment and a strike **twice from the same starting data in two databases**; the ids of the attempts, health, ember and flask events they write are equal across both (D6).
- `test/data/attempt_number_test.dart`: `recomputeAttemptNumbers()` gives the same value as the `failBoss` counter after every fall path (declared, health death, missed day) and after resets (D7).

**Code:** `systemId` in `core/ids.dart`; each call site listed in D6 uses it; `BossDao.recomputeAttemptNumbers()`.

**Done when:** the three files pass and every gate test from Stages 1 to 6 is green.

### Step 3: Bloodstains (app)

**Tests first** `test/data/bloodstain_dao_test.dart` (in-memory Drift, fixed clock):
- `drop()` on a boss with no active bloodstain creates an active one; a second `drop()` on the same boss marks the first lost with `lostAt` = the new one's `createdAt` (§9.2); a drop on another boss leaves the first boss's one active;
- `recover()` sets `recoveredAt`; a recovered one is never marked lost by a later drop;
- `active(bossId)` returns at most one;
- deleting the boss deletes its bloodstains; deleting the task or attempt keeps the bloodstain with the reference cleared;
- `mergeBloodstain(local, remote)` (pure, D19): every pair of field values gives the same row in both argument orders; a recovery on either side clears `lostAt`; immutable fields keep the local value;
- `settleBloodstains(bossId)` with two active rows (inserted while `applying = 1`, as a pull would) keeps the newer active and marks the older lost; with equal `createdAt` the larger id wins; running it twice changes nothing.

**Code:** `Bloodstains` table (in the v7 migration from step 1), `data/bloodstain_dao.dart` with `drop`, `recover`, `active`, `settleBloodstains`; `core/bloodstain_merge.dart` (pure). No screen uses it yet; gentle mode removes no embers (§9.2).

**Done when:** the file passes and `migration_v7_test.dart` also checks the empty `Bloodstains` table exists.

### Step 4: Change capture (app)

**Tests first** `test/data/sync_outbox_test.dart` (in-memory Drift):
- creating a boss with two phases and three tasks queues one upsert per row;
- editing a title queues an upsert; deleting a boss queues deletes for the boss and every cascaded child;
- with `applying = 1`, writes queue nothing;
- `Visits`, `SignalEvents`, `Settings` (per-device) and `SyncState` queue nothing (D9, D10);
- a write that throws inside a transaction leaves no outbox row.

**Code:** trigger SQL in `database.dart` (created in `from6To7` and `onCreate`); `SyncDao` with `pending()`, `ack(seqs)`, `setApplying()`.

**Done when:** the file passes.

### Step 5: Server skeleton, schema and auth (server)

**Tests first** (`server/test/`, Vitest, real PostgreSQL)
- `migrations.test.ts`: migrations run up on an empty database and every table, key and index in section 5 exists.
- `auth.test.ts` with a fake JWKS: a valid Google ID token creates a user and returns a session token; the same `sub` again finds the same user; bad signature, wrong `aud`, wrong `iss`, expired or unverified email give 401; a session token works, an expired or unknown one gives 401; the stored token is a hash.
- `health.test.ts`: `GET /v1/health` returns 200 and the version.

**Code:** `server/` (Fastify, TypeBox, `node-pg-migrate`), `docker-compose.yml` for local PostgreSQL, `POST /v1/auth/google`, `POST /v1/auth/logout`, session middleware, `.env.example`. No secrets in git.

**Done when:** the three files pass.

### Step 6: Push and pull with the merge rules (server)

**Tests first** `server/test/sync.test.ts`:
- push a batch of new rows; pull from cursor 0 returns them with increasing `seq`; pull from the last cursor returns nothing;
- LWW: an older `updatedAt` for an existing id is acknowledged but not applied; a newer one wins; equal times break on device id;
- events: the same event id pushed twice (two devices, D6) is stored once; an event push with changed fields is ignored, not applied;
- tombstone beats an earlier and a later edit; deleting a boss tombstones its phases, tasks, commitments and plan picks; relics keep the row with `boss_id` cleared;
- an `updatedAt` more than 24 h ahead is rejected for that record only (D13);
- a batch with one bad record applies the others and reports the bad one;
- user A's pull never contains user B's rows; A pushing an id B owns creates A's own row, not a write to B's;
- pages of 500 with a `hasMore` flag;
- bloodstains: two active ones on one boss pushed in either order end with the newer active and the older lost; a pushed recovery is kept when the server row is lost, and a pushed `lostAt` does not undo a stored recovery (D11, D19); the shared fixtures in `server/test/fixtures/bloodstains.json` give the same result as `bloodstain_dao_test.dart`;
- inserting a second active bloodstain directly in SQL fails on `one_active_bloodstain`.

**Code:** `POST /v1/sync/push`, `GET /v1/sync/pull?since=`; one transaction per batch.

**Done when:** `sync.test.ts` passes.

### Step 7: OpenAPI spec and Dart client

**Tests first**
- `server/test/openapi.test.ts`: the spec built from the routes equals the committed `server/openapi.json`; it validates as OpenAPI 3.1.
- `app/test/api/api_client_test.dart`: the generated package's spec hash matches `server/openapi.json`; a `ChangeDto` round-trips to and from JSON for one record of every synced table.

**Code:** `npm run openapi` writes the spec; `tool/gen_api_client.sh` runs `openapi-generator-cli` into `app/packages/hearthrise_api/`; app `pubspec.yaml` depends on it by path.

**Done when:** both files pass.

### Step 8: Sync service (app)

**Tests first** `test/data/sync_service_test.dart` against a `FakeSyncApi` that implements the step 6 rules in Dart, and checked against shared fixtures in `server/test/fixtures/*.json` so the fake cannot drift from the server:
- push sends outbox rows as current-row upserts or tombstones, then acks only what the server accepted;
- pull applies remote rows with `applying = 1` (nothing re-queued), follows `hasMore`, advances the cursor, and runs `recomputeAttemptNumbers()` (D7);
- pull applies LWW and tombstones locally the same way the server does (both directions converge);
- a pulled tombstone for a boss removes its children locally;
- a network error leaves the outbox and cursor unchanged and sets `lastError`; the next run retries;
- the debounce and back-off schedule (D15) with a fake clock;
- `firstDay` becomes the earliest of local and remote (D9);
- a pulled bloodstain is merged field by field (D19), then `settleBloodstains` runs for its boss; a bloodstain changed by settling is queued for the next push.

**Code:** `data/sync_service.dart`, `SyncApi` interface over the generated client, provider; `DayResolver` triggers a sync on start and resume after resolving the day.

**Done when:** the file passes and `visit_recorder_test`, `day_resolver` tests are still green.

### Step 9: Sign-in and Settings (app)

**Tests first**
- `test/ui/sync_status_row_test.dart`: renders "Back up and sync" (signed out), or the email and "Last synced 2 min ago" / "Waiting for a connection" (signed in) from given values; fires `onSignIn`, `onSignOut`, `onDelete`; 48 dp targets; no overflow at 320 x 568 and 200% text.
- `test/ui/confirm_sheet_test.dart` (or reuse the existing confirm widget if one fits): delete account copy, destructive button fires once.
- `test/features/settings_sync_test.dart` with a fake `AuthGateway` and `FakeSyncApi`: signing in stores the token and runs a first sync; with remote data the D16 sheet shows; sign out clears the token and keeps local data; delete account calls the API, clears the token and keeps local data; a failed sign-in shows a quiet line and changes nothing.

**Code:** `ui/sync_status_row.dart`; `features/settings/sync_section.dart` (thin container); `core/auth_gateway.dart` wrapping `google_sign_in` and `flutter_secure_storage`.

**Done when:** the three files pass and `settings_test.dart` is green.

### Step 10: Release config, privacy and account deletion page

**Tests first**
- `test/release_config_test.dart` (changed): the manifest asks for `INTERNET`, `POST_NOTIFICATIONS` and `RECEIVE_BOOT_COMPLETED` and nothing else; `usesCleartextTraffic` is not true; version is `0.7.0+N`.
- `server/test/delete_page.test.ts`: `GET /account/delete` serves the page; the delete flow with a valid session removes every user row (gate item 5).
- `test/features/no_account_test.dart`: with no session token, starting the app, striking, falling and opening the bonfire makes no call on the API (gate item 4).

**Code:** manifest; `pubspec.yaml` version; `docs/privacy-policy.md` rewritten (optional account; what syncs: boss, task, phase, attempt, lesson, relic and settings data, email and Google account id; what never leaves the phone: tester signals; where it is stored; deletion in app and on the web; contact); Data safety draft in `docs/data-safety.md` (collected: email, user id, app content; encrypted in transit; deletion available; not shared).

**Done when:** the three files pass.

### Step 11: Scripted gate

**Tests first** `test/gate_stage7_test.dart`, tagged `sync-gate`, run by `tool/gate_stage7.sh` (starts PostgreSQL in Docker and the server on a free port, runs the tagged test, stops both):
- the two-device script in gate item 1, run once A-then-B and once B-then-A, asserting every sub-item;
- gate items 2 and 3;
- both databases equal row for row on every synced table at the end.

Plus `server/test/gate_merge.test.ts`: the same two batches pushed directly, in both orders, give the same final rows.

**Code:** none expected; fix whatever the gate finds, test first.

**Done when:** `tool/gate_stage7.sh` passes, `gate_merge.test.ts` passes, and the Stage 1 to 6 gate tests pass.

### Step 12: Deploy and device checks (manual)

- Pick hosting (D12) with the monthly cost written down; create the database, run migrations, set secrets (Web client ID, database URL) in the host's secret store.
- Health check and TLS work from a phone on mobile data.
- Google Cloud OAuth: Android client with **both** SHA-1s (upload key and Play app signing); consent screen with the privacy policy URL.
- Play Console: Data safety updated from `docs/data-safety.md`; account deletion URL entered; privacy policy republished.
- Release build 0.7.0+1 to internal testing, then:
  - sign in on phone A, use it a day, sign in on phone B: B shows A's data;
  - both phones in airplane mode, edit on both, reconnect: both converge (spot-check the gate script by hand);
  - kill the app mid-sync; reopen: no duplicate, no loss;
  - sign out, delete account (in app and on the web page): rows gone on the server, local data kept;
  - no-account phone: works offline as before, no sign-in prompt anywhere except Settings;
  - cold start time on the small phone not worse than Stage 6 by more than 100 ms.

**Done when:** every check is ticked and `CHECKLIST.md` Stage 7 is ticked.

---

## 7. `lib/ui/` widgets

| Widget | Step | New or reused |
|---|---|---|
| `SyncStatusRow` | 8 | New |
| Confirm sheet (delete account, D16 merge notice) | 8 | Reused if the existing confirm sheet fits; otherwise new |
| `SettingValueRow`, section headers | 8 | Reused |

---

## 8. Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| Duplicate falls or health loss when two devices resolve the same day | High without D6 | Deterministic ids (D6), tested in step 2 and in the gate |
| A missed `newId()` call site keeps a v4 id for a system record | Medium | Step 2 lists every call site; `system_ids_test` runs every resolver twice |
| Fake sync API in Dart drifts from the server | Medium | Shared JSON fixtures (step 8) and the real-server gate (step 11) |
| Phone clock wrong, wins every conflict | Medium | Future-time guard (D13); `seq` for the cursor |
| Google sign-in fails on the Play build (SHA-1 of app signing key missing) | High (common) | Prerequisite and step 12 checklist name both SHA-1s |
| Sync changes the feel: spinners, prompts, "sync failed" anxiety | Medium | No spinner; one quiet status line in Settings; never block a write |
| Server holds user text (titles, lessons) in plain form | Medium | TLS, encrypted database storage at the host, minimal access, deletion; end-to-end encryption noted as a later option |
| Stage 6 gate review asks for changes that touch the same tables | Medium | Stage 6 tuning lands before step 1 merges (prerequisites) |
| Two active bloodstains on one boss after a merge | Medium | Order-independent field merge (D19), settling on both sides (D11), partial unique index on the server, fixtures shared by both test suites |
| Hosting cost grows | Low | One small machine; numbers checked in step 12 |
| Play policy on account deletion changes | Low | Verify in Play Console Help at step 12 |
