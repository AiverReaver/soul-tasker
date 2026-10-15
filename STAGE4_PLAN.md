# Stage 4 Plan: Commitments and Health (gentle mode)

Source: `STAGES.md` (Stage 4) and `souls-task-tracker-design.md` (§ numbers below refer to it). Visual rules: `DESIGN.md`.
Method: TDD (see `STAGES.md`, Development method). Every step below lists its tests first, then the code. UI follows `STAGES.md`, "UI components": new widgets go in `lib/ui/` as `StatelessWidget`s, with state in thin containers in `lib/features/`.
Status: not started.

Prerequisite: the Stage 3 gate (several real days on a phone) is still open, and so is the Stage 2 tester gate. Steps 1 to 12 do not depend on their outcome and can start now. Step 14 (the gate) must not start until Stage 3 closes, because it runs on top of the daily loop.

---

## 1. Goal and gate

**Goal:** turn the task list into a commitment system (§5.12). The user promises a task by a deadline. Kept promises are free, missed ones cost health, and at zero health the player falls. Planning accuracy shows the user learning to promise less and keep more.

**Gate:** the beginner's first-day example in §5.12 plays out exactly as written, and the resolver tests pass. All of these are true:
1. Scripted (step 12): nine commitments, six Heavy. Three are kept, then five Heavy deadlines are missed in a row. Health goes 10, 8, 6, 4, 2, 0. The player falls after the fifth miss, not before.
2. Only the boss of the task that dealt the final blow fails an attempt (`FallCause.healthDeath`). Other bosses are untouched.
3. The ninth commitment is frozen: its deadline passes with no health loss, and it can still be struck for embers.
4. The fallen screen reads "Nine promised, three kept." and asks the lesson question. No embers are lost (gentle mode).
5. The fallen screen and the bonfire both show daily and weekly accuracy. The next day starts at full health. Committing to five shows the previous day's accuracy (3 of 9) and the weekly trend on the bonfire.
6. `test/core/commitment_resolver_test.dart` and the full suite pass, and `flutter analyze` is clean.
7. Manual checks in step 13 pass on a device.

---

## 2. Where Stage 3 left us

| Piece | Where | Stage 4 use |
|---|---|---|
| Append-only ledger with a derived tally (`EmberEvents`, `EmberDao._sum`) | `data/ember_dao.dart` | Same pattern for `HealthEvents` (D4) |
| `EmberDao.amountFor(outcome, weight)`, Tried = half rounded up | `data/ember_dao.dart` | Late strike pays the Tried amount (D9) |
| `AttemptDao.failBoss(bossId, cause, lesson, onDay:)`; `FallCause.healthDeath` already exists. It stamps the row with `_clock()` | `data/attempt_dao.dart` | Health death fails the final-blow boss; gains an `at:` override (step 5) |
| `AttemptDao.strike` / `tried` in one transaction with the ember earn | `data/attempt_dao.dart` | Also close the task's commitment in the same transaction |
| `DayDao.rest` (bank, +1 flask, picks), `pending` / `resolve` for missed days, `Settings.flasks` | `data/day_dao.dart` | Rest restores health; rise is a shorter rest; second extension spends a flask |
| `dayOf(time, rolloverHour)`, `shiftDay` | `core/clock.dart`, `core/missed_days.dart` | Commitment day and deadline cap |
| `DayResolver` wraps Home, runs on start and resume | `features/ritual/day_resolver.dart` | Also resolves deadlines; adds a running timer and the away summary |
| `Reminders` interface with a fake | `core/reminders.dart`, `test/support/fake_reminders.dart` | Extended with one-shot deadline reminders |
| `FallenScreen.show` | `features/fallen/fallen_screen.dart` | Adds the optional "N promised, M kept" line and the weekly `AccuracyLine` |
| `BossHealthBar` (segmented boss bar) | `ui/boss_health_bar.dart` | Not reused: player health is a separate widget (step 7) |
| Schema v3 with step migrations and dumps in `test/drift/` | `data/database.dart` | Schema v4 (step 1) |

---

## 3. Scope

### In Stage 4

| Item | Design ref |
|---|---|
| Commit a task with a deadline (one hour, a few hours, tonight); open tasks stay as they are | §5.12 |
| Calm note when the day's promises look heavy | §5.12 |
| First extension free, each later one costs a flask | §5.12, §5.7 |
| Health from a ledger of events; loss by weight 1 / 2 / 3, Tried half | §5.12, §9.2 |
| Death at zero: failed attempt on the final-blow boss, remaining commitments frozen, fallen screen with "N promised, M kept" | §5.4, §5.5, §5.12 |
| Health refills at the bonfire rest and at rollover | §5.6 |
| Rest after a fall: rise the same day at the bonfire | §5.6 |
| Deadlines resolved on open, on resume and on a timer while running; "While you were away" summary; late strike | §5.12 |
| Waiting bosses exempt; daily tasks can carry a standing daily deadline | §5.12 |
| Opt-in per-task deadline reminder | §5.12 |
| Daily record and planning accuracy (daily and weekly) on the bonfire and the fallen screen | §5.12 |
| Newcomer grace week: a calm line only, no reduced losses (D13) | §5.12 |

### Not in Stage 4 (and where it lands)

| Item | Stage |
|---|---|
| Bloodstains and ember drops on death (hardcore) | 8 |
| Planning accuracy on the profile screen | 5 |
| Adjustable maximum health (fixed at 10 for now) | 5, with the profile, if testers ask |
| Standalone commitments (a task with no boss) | Later. Tasks need a boss today; making `bossId` nullable touches every view (D3) |
| Exact-alarm deadline reminders | Not planned. Inexact only; reminders are a convenience (§5.12) |
| Steadfast days | 9 |

---

## 4. Decisions in this plan (confirm or change)

| # | Question | Decision | Why |
|---|---|---|---|
| D1 | Where does a deadline live? | A new **`Commitments`** row per task per day, not a column on `Tasks`. Unique `(taskId, day)`. Holds the deadline, extensions used, outcome and resolved time. A task without an open commitment is an open task. | Daily tasks need a fresh commitment each day. Accuracy needs a history of promises. The task row stays as it is. |
| D2 | Deadline choices | Three presets: **in 1 hour**, **in 3 hours**, **tonight** (23:00 local). Every deadline is capped at the end of the ritual day (the next rollover). If 23:00 has passed, "tonight" means the rollover. No free time picker. | §5.12 lists these three. The cap keeps each commitment inside one day, so health and accuracy stay per day. |
| D3 | Commitments without a boss | **Not in Stage 4.** Every commitment belongs to a task, and every task to a boss. | `Tasks.bossId` is required across views, DAOs and the editor. Large ripple for a small gain. |
| D4 | Health storage | **`HealthEvents` ledger** in **half points** (int): `amount` (negative loss, positive restore), `reason`, `commitmentId`, `day`, `at`. Health for a day = start at max, then apply that day's events **in `at` order, clamping to 0..max after each one** (a fold, not a plain sum). Loss events store the full nominal amount, so "health lost" in the day record stays honest; a restore event stores the amount needed to reach max at that moment. Max is a constant `kMaxHealth = 10` (20 half points). | §9.2 "derived from events, not overwritten". Half points as ints avoid float drift. Clamping per event means an overkill loss before a Rise cannot leave the player below full after it. Per-day folds give the rollover refill for free, with no event to write (§5.6). |
| D5 | Loss amounts | Miss: Light 1, Heavy 2, Boss-tier 3 (added to `Weight` as `healthLoss`). Tried before the deadline: half (0.5, 1, 1.5). Kept or extended: 0. | §5.12 table. |
| D6 | When is the loss written? | **Miss:** when the resolver sees the deadline passed (on open, resume or timer). The event's `day` and `at` are the **commitment's** day and deadline, not the time it was noticed. **Tried:** at the moment it is marked. | Writing at the deadline time keeps the order of events right after the app was closed, so the final blow is the true one. |
| D7 | Death and freeze | Process due commitments in deadline order. When a loss brings the day's health to 0, write one `healthDeath` fall on that task's boss (via `failBoss`, `onDay` the commitment's day, `at` the deadline of the final blow, so dead-ness compares correctly against rises after a delayed resolve). While dead, later deadlines resolve as **frozen** (no loss). Dead = the day's last `healthDeath` fall is later than its last rise. Freeze is derived, not stored on the remaining rows until their deadline passes. **Commitments made while fallen** are allowed and follow the same rule: no health risk while the player is fallen (a deadline that passes then is `frozen`), at risk again after a Rise if their deadline has not passed (§5.6 "unfreezes commitments that are still before their deadline"). They count as made for accuracy. | §5.12. Deriving dead-ness from rows means rise "unfreezes" with no extra writes. |
| D8 | Tried | Marking Tried closes the commitment as `tried`. The task stays open: a later strike earns embers (Tried rate, D9) but does not change health or accuracy. | §5.12 "a promise was not kept". |
| D9 | Late strike | Striking a task whose commitment is `missed` or `frozen` sets it to `lateStrike`. Health stays lost. Embers: the Tried amount (half, rounded up). | §5.12 "partial embers". One rate already exists; no new constant. |
| D10 | Extensions | Only before the deadline. Pick a new preset, later than the current deadline, capped at the rollover. First is free; each later one spends 1 flask, and is refused with a calm line at 0 flasks. Stored as `extensions` count; the flask spend lowers `Settings.flasks` in the same transaction. | §5.12, §9.2 "further extensions cost a flask". |
| D11 | Waiting bosses | Setting a boss to **waiting** cancels its open commitments (`cancelled`, excluded from accuracy, deadline reminders cancelled). Committing a task on a waiting boss is not offered. | §5.12 "do not expire while it waits". Cancelling is simpler than pausing a clock, and the user re-commits on resume. |
| D12 | Recurring tasks | A daily task can carry a **standing deadline** (`Tasks.dailyDeadlineMinutes`, nullable), set in the commit sheet as "every day". The resolver inserts that day's commitment the first time it runs on a day (insert-or-ignore on `(taskId, day)`). Without a standing deadline, a daily task is committed by hand each day. | §5.12 "fresh commitment each day, with their own deadline". Lazy creation needs no background job. |
| D13 | Newcomer grace week **(accepted)** | §5.12 says grace "reduces health losses", but the gate is a beginner's **first day** falling after exactly five Heavy misses. Both cannot hold. In Stage 4, grace is recorded (`Settings.firstDay`) and shown as a calm line on a fall in week one ("Your first week: nothing is lost but health."). Losses are **not** reduced, so the gate example holds. Reduced losses move to Stage 8, with hardcore, where grace actually protects something. | Gentle mode already drops no embers, which is the half of grace that matters. Keeping loss amounts fixed keeps the lesson in §5.12 intact. |
| D14 | Health death and missed day on the same day | A boss that already fell by health death on day D is **not** failed again by the missed-day resolution for D. If both happen in one open, the user sees **one** fallen moment and writes **one** lesson, stored on every fall (as §5.4 does for missed days). | One bad day, one fall per boss. Keeps the gentle tone. |
| D15 | Rise vs daily rest | While fallen, the bonfire offers only **Rise**: restore health to full (event `rise`), bank carried embers, no flask, no picks, does not cover the day. After rising, the normal daily rest is available as before and also refills health (event `bonfireRestore`). Rises per day: unlimited. | §5.6 "rest after a fall". One screen, two states, no new route. |
| D16 | Accuracy | **Made** = the day's commitments except `cancelled`. **Kept** = struck before the deadline (`kept`), extended or not. Daily = kept / made for a day. Weekly = sums over the last 7 days, today included. Derived from `Commitments`; **no `DailySummaries` table** in Stage 4. A day with nothing made shows no number, not 0%. | §5.12 definition. One source of truth; Stage 7 can add a summary table for sync if needed. |
| D17 | Calm note on load | When committing, if the day's open commitments reach **6 or more**, show one quiet line: "That is nine promises, six of them heavy." Never blocks. | §5.12 "calm notes, not blocks". The app has no task durations, so the note counts promises instead of hours. |
| D18 | Running check | While the app is in the foreground, a `Timer.periodic` of **1 minute** runs the deadline resolver. Plus on start and on resume (as D1 in Stage 3). | Simple, testable with `fake_async`, no background work. |
| D19 | Away summary | If the resolver run on start or resume settles **one or more** deadlines, show one sheet: "While you were away, two deadlines passed." with each task, its health cost, and a "Done late" action (D9). A miss caught by the running timer shows a quiet flash line instead. | §5.12 "one summary instead of a wall of penalties". |
| D20 | Deadline reminder **(accepted: shows the task name)** | Opt-in per commitment, "Remind me 10 minutes before", off by default. Inexact (`inexactAllowWhileIdle`), no exact-alarm permission. Title "A promise is due soon.", body the **task title** as it is when the reminder is scheduled (no boss title). Android visibility `private`, so a locked screen shows only the title unless the user's system settings allow more. The Stage 3 daily reminder keeps its fixed text. Cancelled on strike, Tried, extension (then rescheduled), cancel and miss. Rescheduled when the task is renamed. Skipped if the reminder time has already passed. | §5.12 "a convenience, never the source of truth". The task name tells the user which promise is due; `private` visibility keeps it off the lock screen by default. |

---

## 5. Data model: schema v4

One migration (`from3To4`). Dump the schema and generate the step helpers, as for v3.

**New tables**

| Table | Columns | Notes |
|---|---|---|
| `Commitments` | `id` text, `taskId` text (cascade on delete), `bossId` text (cascade on delete), `day` text, `deadline` datetime, `extensions` int (default 0), `remind` bool (default false), `outcome` int nullable (`CommitmentOutcome`), `resolvedAt` datetime nullable, `createdAt` datetime, `updatedAt` datetime | Unique `(taskId, day)`. `outcome` null means open. `bossId` is denormalized so the resolver and the waiting-boss rule need no join. |
| `HealthEvents` | `id` text, `amount` int (half points), `reason` int (`HealthReason`), `commitmentId` text nullable (set null on delete), `day` text, `at` datetime | Append-only. |

**Columns added**

| Table | Column | Type and default |
|---|---|---|
| `Tasks` | `dailyDeadlineMinutes` | int nullable; only meaningful on daily tasks (D12) |
| `Settings` | `firstDay` | text nullable; set to today's day by `onCreate` and by the v4 upgrade (D13) |

**`enums.dart`** (append only):
- `CommitmentOutcome { kept, tried, missed, frozen, lateStrike, cancelled }`
- `HealthReason { miss, tried, bonfireRestore, rise }`
- `Weight.healthLoss` in half points: 2, 4, 6.

**Constants:** `kMaxHealth = 10`, the deadline presets, `kTonightHour = 23`, `kLoadNoteCount = 6`, `kReminderLead = Duration(minutes: 10)`, `kDeadlineTick = Duration(minutes: 1)`.

---

## 6. Build order

Each step: tests first (red), then code (green), then refactor. One commit per step. A step is done when `flutter analyze` is clean and the full suite passes (run from `app/`).

### Step 1: Schema v4

**Tests first**
- `test/drift/hearthrise/migration_v4_test.dart`: a v3 database upgrades to v4 with bosses, attempts, day logs, ember events, picks and settings intact; `Commitments` and `HealthEvents` exist and are empty; `Tasks.dailyDeadlineMinutes` is null on old rows; `firstDay` equals `dayOf(clock, rolloverHour: <stored hour>)`: with a stored hour of 2 and a clock at 03:00, it is that calendar day, not the previous one. A fresh `onCreate` database uses the default hour.
- `test/data/enums_test.dart`: `Weight.healthLoss` is 2, 4, 6; indexes of existing enum values are unchanged.

**Code:** tables, enums, `Weight.healthLoss`, schema dump, `from3To4` (reads the stored `rolloverHour` before stamping `firstDay`), `onCreate` sets `firstDay`.

**Done when:** both test files pass, and the v1 to v3 migration tests still pass.

### Step 2: The pure resolver

All the rules of §5.12 in one pure function, no database. This is the "unit tests for the deadline and health resolver" item.

**Tests first** `test/core/commitment_resolver_test.dart`. Input: max health, the day's existing health events, the day's deaths and rises (times), the due commitments (id, boss, weight, deadline), and `now`. Output: per commitment `missed` or `frozen`, the health events to write, and the deaths (commitment id, boss id, time).
- nothing due: no output;
- one Light miss: −2 half points, outcome `missed`;
- Heavy and Boss-tier misses cost 4 and 6;
- a deadline after `now` is not touched;
- misses are processed in deadline order, regardless of input order;
- a prior Tried event (−1) counts toward the total;
- health reaching exactly 0 is a death; the final blow is the commitment that crossed it; its boss is reported;
- a loss bigger than what is left (Boss-tier at 2 half points) still dies once and health clamps at 0;
- overkill, then Rise, then a later loss: 18 lost, a Boss-tier miss (6) at 2 left, Rise, then a Light miss: health is 0, then 20, then 18 (not 14);
- after a death, later deadlines are `frozen` with no event;
- a rise after the death: deadlines after the rise cost health again; deadlines between death and rise stay frozen;
- a second death after a rise reports a second death;
- a commitment created after a death with its deadline before any Rise: `frozen`, no loss;
- a commitment created after a death, then a Rise before its deadline: a miss costs health as usual;
- the §5.12 example: 3 kept, 5 Heavy misses, 1 more Heavy due later: health 20, 16, 12, 8, 4, 0 half points; death on the fifth; the last is frozen.

**Code:** `core/commitment_resolver.dart` with `resolveCommitments(...)` returning an immutable `ResolverResult`.

**Done when:** `commitment_resolver_test.dart` passes with full branch coverage of the function.

### Step 3: Commit, extend, cancel

**Tests first** `test/data/commitment_dao_test.dart` (in-memory Drift, fixed clock):
- `commit(taskId, preset, remind:)` writes one commitment for today with the preset's deadline; "tonight" before 23:00 is 23:00, after 23:00 is the rollover; a deadline is never past the rollover (D2);
- committing the same task twice on one day is refused (unique `(taskId, day)`);
- committing a task of a waiting or defeated boss is refused;
- `extend(id, preset)`: first is free; second spends 1 flask; at 0 flasks it is refused and nothing changes; a new deadline not later than the current one is refused; extending after the deadline is refused (D10);
- `BossDao.setStatus(boss, waiting)` cancels that boss's open commitments and only those (D11);
- `load(day)` returns each commitment with task title, boss title, weight and outcome;
- `loadNote(day)` returns null below the threshold and the count plus heavy count at or above it (D17);
- `setStanding(taskId, minutes)` stores a standing deadline on a daily task and refuses it on a one-time task (D12).

**Code:** `data/commitment_dao.dart`, provider, `BossDao.setStatus` calls the cancel in the same transaction.

**Done when:** `commitment_dao_test.dart` passes and `boss_dao_test.dart` still passes.

### Step 4: Strike, Tried and late strike close commitments

**Tests first**
- `test/data/attempt_dao_test.dart` (added group):
  - strike before the deadline sets `kept`, writes no health event, earns full embers;
  - Tried before the deadline sets `tried`, writes a `tried` health event of half the loss (1, 2, 3 half points), earns Tried embers;
  - a strike after Tried earns Tried embers and changes no commitment or health (D8);
  - strike on a `missed` or `frozen` commitment sets `lateStrike`, writes no health event, earns the Tried amount (D9);
  - strike on a task with no commitment behaves exactly as in Stage 3 (regression);
  - a daily task struck today closes only today's commitment.
- `test/data/ember_dao_test.dart`: `amountFor` for a late strike returns the Tried amount.

**Code:** in `AttemptDao.strike` and `tried`, look up today's commitment for the task and close it in the same transaction. `EmberDao.earn` takes the late case.

**Done when:** both test files pass.

### Step 5: Health DAO and deadline resolution

**Tests first**
- `test/data/attempt_dao_test.dart` (added): `failBoss(..., at:)` writes the fallen row with that time and `lastFoughtAt` set to it; without `at` it uses the clock as before.

`test/data/health_dao_test.dart`:
- `health(day)` is max with no events, falls with losses, clamps at 0 after each event in time order (overkill, Rise, later loss ends at max minus the later loss), and is max again on the next day with no event written (D4);
- `resolveDue()` on a fixed clock applies step 2's result in one transaction: outcomes, health events at the deadline's time (D6), and on death one `healthDeath` fall on the final-blow boss only, with its reset applied and its counter raised;
- running `resolveDue()` twice changes nothing the second time;
- an exception mid-way leaves nothing changed;
- standing daily deadlines: the first `resolveDue()` of a day inserts that day's commitment; a second run inserts nothing; a task on a waiting boss gets none (D12);
- deadlines on an earlier day (app closed overnight) resolve against that day's health, not today's;
- delayed resolution of several deadlines at once (app closed for hours): health events and the death fall carry their own deadline times, not the resolve time, and the final blow is the earliest deadline that reached 0;
- `isDead(day)` is true after a death and false after a rise;
- `watchHealth()` emits on every health event and on a rollover-hour change.
- `test/data/missed_day_test.dart` (added): a boss that died by health on day D is not failed again for D by `resolve()`; other active bosses still are (D14).

**Code:** an optional `at` on `AttemptDao.failBoss` (passed to `_insert` in place of `_clock()`); `data/health_dao.dart` (`health`, `watchHealth`, `isDead`, `resolveDue` returning a `DueResult` with the settled items and deaths), the D14 filter in `DayDao._affected`.

**Done when:** `health_dao_test.dart` and `missed_day_test.dart` pass.

### Step 6: Rest restores health; rise after a fall

**Tests first** `test/data/day_dao_test.dart` (added):
- `rest()` also writes a `bonfireRestore` event that brings the day's health to max, and none when already full;
- `rest()` while dead is refused (the screen offers Rise instead, D15);
- `rise()` while dead writes a `rise` event to max, banks carried embers, does not add a flask, writes no `DayLogs` row (the day is not covered), and can run again after a second death;
- `rise()` when not dead is a no-op returning false;
- after a rise, a commitment due later than the rise costs health again; one frozen before the rise stays frozen (through `resolveDue`).

**Code:** `DayDao.rest` writes the restore; new `DayDao.rise`.

**Done when:** `day_dao_test.dart` passes.

### Step 7: UI widgets

All `StatelessWidget`s in `lib/ui/`, each with its widget test written first in `test/ui/`.

| Widget | Renders | Test |
|---|---|---|
| `PlayerHealthBar` | health and max in half points; half segment drawn; a fallen state | renders 20/20, 7/20 (half segment), 0 |
| `DeadlineChip` | "in 40 min", "by 23:00", "missed", "frozen", "kept", "late" from values | each state's text; no red for missed (§5.8 tone) |
| `CommitSheet` | three presets, "Remind me 10 minutes before" switch, "Every day" switch for daily tasks, optional load note line | fires `onCommit(preset, remind, everyDay)`; hides "Every day" for one-time tasks; shows the note when given |
| `ExtendSheet` | the presets later than the current deadline, a cost line ("Free" or "Costs a flask") | disabled with a quiet line at 0 flasks; fires `onExtend` |
| `AwaySummary` | "While you were away, N deadlines passed.", one row per task with its cost and a "Done late" action | renders rows, fires `onDoneLate(id)`, singular and plural copy |
| `AccuracyLine` | "Today: 3 of 9 kept. This week: 12 of 20." | values in; no number when made is 0 |

`TaskRowTile` gets an optional `deadline` slot for the chip (same widget, one parameter).

**Done when:** the six widget tests and the updated `TaskRowTile` test pass.

### Step 8: Committing from the screens

**Tests first** `test/features/commit_test.dart`:
- the row's commit action on Today and on the boss screen opens `CommitSheet`; choosing a preset writes a commitment and the row shows its chip;
- the load note shows on the sixth promise and does not block;
- extend from the row: first free, second spends a flask and the flask pips drop;
- the Today header shows `PlayerHealthBar`, and it drops after a Tried;
- tasks of a waiting boss offer no commit action;
- `screens_test.dart` still passes.

**Code:** a thin container in `features/commit/`, `commitmentDaoProvider` and `healthDaoProvider`, header line in `TodayView`.

**Done when:** `commit_test.dart` and `screens_test.dart` pass.

### Step 9: Resolve on open, resume and timer; away summary; fallen numbers

**Tests first** `test/features/deadline_resolver_test.dart` (widget, fake clock, `fake_async`):
- open with nothing due: nothing shown;
- open after two deadlines passed: one `AwaySummary` with both rows; "Done late" sets `lateStrike` and earns embers; health is not restored;
- a deadline passing while the app is open is caught within one tick (D18) and shows a flash line, not the summary;
- a death shows the fallen screen with "Nine promised, three kept." (numbers from the day's record), and the lesson lands on the final-blow fall;
- a death and a missed day in one open: one fallen moment, one lesson stored on all falls (D14);
- on open, deadlines are settled first, then the Stage 3 missed-day prompt runs;
- the timer stops when the app goes to the background and restarts on resume.
- `test/features/fallen_feel_test.dart` (added): the fallen screen shows the numbers line and `AccuracyLine` (today and the week) only when given.

**Code:** extend `DayResolver` (or a `DeadlineResolver` it wraps) with `resolveDue()`, the periodic timer and the summary; `FallenScreen.show` takes an optional day record and week record, and composes `AccuracyLine` from `lib/ui/`.

**Done when:** both test files pass and `day_resolver_test.dart` still passes.

### Step 10: Bonfire: rise state and accuracy

**Tests first**
- `test/data/day_record_test.dart`: `record(day)` returns made, kept, health lost and fell; `cancelled` is excluded; extended-then-kept counts as kept; `week(today)` sums the last 7 days (D16).
- `test/features/bonfire_test.dart` (added): while fallen, the screen shows "Rise" and no lesson or picks; Rise restores the health bar and banks; after rising, the normal Rest is offered; the screen shows `AccuracyLine` for today and the week; the grace line shows on a fall in week one (D13).

**Code:** `data/day_record.dart` (`record`, `week`), bonfire container branches on `isDead`.

**Done when:** both test files pass.

### Step 11: Deadline reminders

**Before coding**, check the `flutter_local_notifications` docs for a one-shot `zonedSchedule` with its own id, on the version pinned in Stage 3.

**Tests first** `test/features/deadline_reminder_test.dart` (fake `Reminders`):
- committing with "remind" schedules one reminder at deadline minus 10 minutes, keyed by the commitment;
- no reminder when that time has already passed;
- strike, Tried and cancel remove it; an extension moves it;
- a commitment resolved as missed removes it;
- the body is the task title and holds no boss title; the title line is fixed; visibility is `private` (D20);
- renaming the task reschedules the reminder with the new title;
- `reminders_test.dart` (Stage 3 daily reminder) still passes.

**Code:** `Reminders` gains `scheduleOnce(key, at, body)` and `cancelOnce(key)`; `LocalReminders` implements them with `private` visibility with a stable int id derived from the commitment id, separate from the daily reminder's id; a `DeadlineReminderCoordinator` in `features/commit/`. Permission reuses the Stage 3 flow.

**Done when:** the test file passes with the Stage 3 reminder tests.

### Step 12: Scripted gate test

**Tests first** (this step is the test): `test/gate_stage4_test.dart`. One scripted run with an advancing fake clock and an in-memory database. Two active bosses, A and B. Day 1 is after the install day (Stage 3 D12).

1. **Day 1, 08:00:** commit nine tasks: three Light (A), six Heavy (four on A, two on B). The load note appears (D17). Health 10.
2. **Day 1, morning:** strike the three Light tasks before their deadlines. Three `kept`, health 10.
3. **Day 1:** five Heavy deadlines pass, one after another: four on A, then the fifth on B. After each `resolveDue()`: health 8, 6, 4, 2, 0. The death is on the fifth. Assert boss B's attempt number rose by one with `FallCause.healthDeath` and boss A's did not change.
4. **Day 1, evening:** the ninth commitment (Heavy, B) passes its deadline. Assert `frozen`, no health event, health stays 0.
5. Assert the fallen screen data reads promised 9, kept 3, and no ember event was subtracted (gentle).
6. **Day 1, late:** strike the frozen ninth task. Assert `lateStrike`, Tried embers earned, health unchanged.
7. **Day 1:** rest is refused while dead; Rise restores health to 10, banks, adds no flask. Then the normal rest succeeds.
8. **Day 2, 08:00:** health is 10 with no new event. Commit five. Assert the record for day 1 is 3 of 9 and the week reads 3 of 14 (day 2's five are made, none kept yet).
9. **Day 2:** keep four, Tried one (Heavy). Assert day 2 is 4 of 5, the week 7 of 14, health 9.

**Code:** none expected. If the test finds a hole, fix it with its own failing test first.

**Done when:** `gate_stage4_test.dart` passes with the full suite.

### Step 13: Manual checks on a device

Cannot be automated. Needs the Android SDK and a phone (same blocker as Stage 3 step 11). Write results into this section.

| Check | Pass condition |
|---|---|
| Away summary | Commit with a 1-hour deadline, close the app for 2 hours, reopen: one calm summary, not a stack of screens. |
| Running miss | Leave the app open past a deadline: the miss shows within about a minute. |
| Deadline reminder | Arrives roughly 10 minutes before (inexact window), screen off, app closed. |
| Death feel | The fall after the fifth miss feels like a lesson, not a punishment. "Nine promised, three kept" reads as information. |
| Rise | Rising at the bonfire is quick and feels like a second chance. |
| Text size | Commit sheet, away summary, health bar and accuracy line read correctly at 200% text. |
| Airplane mode | The whole flow works with no network. |

### Step 14: The gate run

After Stage 3 closes: play the §5.12 beginner day by hand on a phone (you and, ideally, one Stage 2 tester), then use commitments for a few normal days. Log every bug; fix each one test-first. The gate closes when section 1 holds. Then tick `CHECKLIST.md`, mark Stage 4 done in `STAGES.md`, and update this file's status.

---

## 7. Risks

| Risk | Handling |
|---|---|
| Over-committing beginners fall daily and quit | That is the intended lesson (§5.12), softened by the calm note, free extension, Rise and gentle mode. The gate run asks directly. Loss amounts are constants on `Weight`. |
| Wrong final blow after the app was closed | Losses are written at the deadline's time and processed in deadline order (D6), tested in step 2. |
| Missed day plus health death feels like double punishment | D14: one fall per boss per day, one fallen moment. |
| Clock or time-zone change moves deadlines | Deadlines are stored as absolute times and judged on the next check. Travel across zones is not handled, as in Stage 3. |
| Timer stops or the app is killed | Deadlines are judged from stored times on every open; the timer and reminders are conveniences. |
| Schema v4 breaks tester installs | Migration test from a v3 database in step 1. |

---

## 8. Differences from `STAGES.md`

- "Daily summaries" are derived from `Commitments` (D16), not stored in a table. The numbers are the same.
- Standalone commitments (no boss) are deferred (D3).
- Newcomer grace does not reduce health losses in Stage 4 (D13); reduced losses move to Stage 8.
- The health maximum is fixed at 10; making it adjustable moves to Stage 5 with the profile.
