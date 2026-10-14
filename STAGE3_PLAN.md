# Stage 3 Plan: Daily Ritual

Source: `STAGES.md` (Stage 3) and `souls-task-tracker-design.md` (§ numbers below refer to it). Visual rules: `DESIGN.md`.
Method: TDD (see `STAGES.md`, Development method). Every step below lists its tests first, then the code. UI follows `STAGES.md`, "UI components": new widgets go in `lib/ui/` as `StatelessWidget`s, with state in thin containers in `lib/features/`.
Status: not started. Steps 1 to 10 need no phone. Steps 11 and 12 need a phone with the Android SDK, which the dev Mac does not have yet (same blocker as Stage 2 steps 10 to 14).

Prerequisite: the Stage 2 gate (testers, `STAGE2_PLAN.md` §1) is still open. Steps 1 to 10 do not depend on its outcome, so they can start now. Step 12 (the gate) must not start until Stage 2 closes.

---

## 1. Goal and gate

**Goal:** the "do, rest, bank, plan" loop (§5.6): finish tasks, rest at the bonfire, bank the day's embers, pick tomorrow's three, and have a missed day cost an attempt unless a flask or a light day covers it.

**Gate:** the loop runs for several real days (at least 5) on a real phone with no bugs and no missed reminders. All of these are true:
1. Every day you rested, the bonfire banked the carried embers once and restored one flask (up to the cap).
2. A day with no rest, no flask and no valid light day failed one attempt on every **active** boss and no other boss, with one shared lesson.
3. The reminder fired on each of the days at the chosen time (within the inexact window, D6), including after a phone restart.
4. Rollover happened at the chosen hour: a bonfire at 1 AM counted for the evening before.
5. The full test suite passes and `flutter analyze` is clean, and the scripted gate test (step 10) passes.

---

## 2. Where Stage 2 left us

| Piece | Where | Stage 3 use |
|---|---|---|
| `dayOf(time, rolloverHour)` already supports a rollover hour; the constant `kRolloverHour = 4` is the only value used | `core/clock.dart` | Make the hour a setting (step 1) |
| Every attempt row has a `day` string, an outcome and a weight | `data/tables.dart` | Day summary, ember earning, "did you strike today" |
| `AttemptDao.fall` fails one boss: counter, lesson, reset, rule of three | `data/attempt_dao.dart` | Extract the core so a missed day fails many bosses (step 4) |
| One-row `Settings` table, schema v2, stepByStep migrations with a schema dump in `test/drift/` | `data/database.dart` | Schema v3 (step 1) |
| Fallen screen (dim, quiet line, lesson prompt) | `features/fallen/fallen_screen.dart` | Reused for the missed-day moment |
| Settings is a bottom sheet with a "Stage 3 replaces this" note | `features/home/settings_sheet.dart` | Becomes a screen (step 9) |
| `Haptics` provider, `clockProvider`, `todayTasks(view)` | `core/`, `features/today/` | Reused as is |

---

## 3. Scope

### In Stage 3

| Item | Design ref |
|---|---|
| Bonfire screen: day summary, optional lesson, tomorrow's top three, Rest button | §5.6 |
| Day rollover time setting (default 4 AM) | §5.6 |
| Missed day fails an attempt on every active boss, one shared lesson | §5.4, §5.6 |
| Embers: earn on Strike and Tried, carried total, bank at the bonfire (gentle mode only, no loss) | §5.8 |
| Flasks: cap 3, +1 per rest, spend to cover a day | §5.7 |
| Light day | §5.7 |
| Daily reminder: local notification, inexact, Android 13+ permission | §10.1 |
| Settings screen: reminder time, rollover hour, haptics, tap fallback, default reset | STAGES.md |

### Not in Stage 3 (and where it lands)

| Item | Stage |
|---|---|
| Health restore at the bonfire, rest after a fall (health does not exist yet) | 4 |
| Planning accuracy and weekly trend on the bonfire | 5 (polish); needs a week of data first |
| Spending banked embers on stats, the profile screen | 5 |
| Bloodstains, hardcore loss rule | 8 |
| Sound toggle: no audio exists yet, so a switch would do nothing | 5, with the victory tone |
| Weekly flask reset | Only if the "+1 per rest" rule fails in the gate run (D5) |
| Reminder deep link into the bonfire, per-task reminders | 4 |

---

## 4. Decisions in this plan (confirm or change)

| # | Question | Decision | Why |
|---|---|---|---|
| D1 | How is a missed day found when the app is closed? | **On app start and on resume.** No background job. A pure function lists the days that ended since `lastResolvedDay` and had no cover. Known limit: an app left open in the foreground past rollover resolves on the next resume or restart. | Works offline, nothing to keep alive, easy to test with a fixed clock. A background worker adds a plugin and battery cost for no gain. |
| D2 | Several missed days in a row | **One failed attempt per active boss per resolution**, no matter how many days were missed. One fallen moment, one lesson. | A second miss on an attempt that already failed and reset adds nothing real. It also keeps a week away from becoming attempt 9 on every boss, which would be discouraging (§3). Confirm. |
| D3 | What covers a day? | A **bonfire** row, or a **flask** row, or a **light** row **and** at least one strike that day. Nothing else: striking tasks without resting does not cover a day. | Matches §5.4 literally ("no bonfire check-in"). If testers find it harsh, change it in one place (the cover function). Confirm. |
| D4 | Which bosses fall on a missed day? | Bosses with status **active** that were created **before** the missed day. Waiting and defeated bosses are exempt. | §5.4. A boss created on day D is not failed for day D, so day one is not punished. |
| D5 | Flask rule | Cap **3**, **+1 on each bonfire rest**, no weekly reset. Spend: **in advance** ("Skip today", costs 1) or **at the prompt** after a miss (each flask covers one missed day, oldest first; any uncovered day still falls once, per D2). | §5.6 says +1 per rest; §5.7 says final rule is decided in testing. Simplest rule that works with no timers. Revisit after the gate run. |
| D6 | Reminder mechanism | `flutter_local_notifications` with `zonedSchedule`, `AndroidScheduleMode.inexactAllowWhileIdle`, `matchDateTimeComponents: time`, behind a small `Reminders` interface faked in tests. Fixed text, no task names. Default time 21:00, default off. The Android 13+ permission is asked **once, right after the first rest**, and when the user turns the reminder on in Settings. | §10.1. An interface makes the logic testable without a device. Asking after the first rest is a sensible moment: the user has just seen what the bonfire does. |
| D7 | Ember values | Strike: Light **1**, Heavy **3**, Boss-tier **6**. Tried: **half, rounded up** (1, 2, 3). Falls earn nothing. Stored as a **ledger** (`EmberEvents`), amounts frozen when written. Existing Stage 1 to 2 attempts are **not** backfilled. | §5.8 "heavier earns more", "effort is always paid". A ledger keeps old amounts stable if values change, and is what bloodstains need in Stage 8. Tester data is not worth a backfill. |
| D8 | Light day | Marked **today** (from the bonfire or the home screen). Covered only if at least one strike lands that day (D3). No cost. | §5.7 "only requires one small task". |
| D9 | Where the day boundary for a bonfire is | `dayOf(now, rolloverHour)`. A rest can happen once per day; after that the screen shows the summary read-only. | §5.6 rollover. One rest per day keeps flasks and banking simple. |
| D10 | Changing the rollover hour | Applies to attempts and rests written **after** the change. Old `day` strings are never rewritten. Allowed range 0 to 6. | Attempt rows are insert-only. Avoids rewriting history. |
| D12 | First day after install or upgrade | `lastResolvedDay` starts as **today's day**, so the install or upgrade day is never judged. The first day judged is the next full day (opened the day after that). Existing testers are not failed for anything before the upgrade, and the migration cannot trigger a missed-day resolution. The migration reads the date from an injected `Clock` (section 5). | Gives a grace day, needs no `previousDay` helper, and keeps the migration deterministic under test. |
| D11 | Tomorrow's three | Up to 3 open tasks from active bosses, saved as `PlanPicks(day, taskId, position)` for the day after the rest's day. They show first on the Today tab on that day. Picks are read-only after the rest. | §5.6, §5.10. Less to build than editing picks later. |

---

## 5. Data model: schema v3

One migration (`from2To3`) adds everything, so testers' installs upgrade once. Dump the schema (`dart run drift_dev schema dump`) and generate the step helpers, as for v2.

**New tables**

| Table | Columns | Notes |
|---|---|---|
| `DayLogs` | `day` text, `kind` int (`DayKind { bonfire, flask, light }`), `lesson` text nullable (max 120), `at` datetime | Primary key `(day, kind)`. Lesson only on `bonfire`. |
| `EmberEvents` | `id` text, `kind` int (`EmberKind { earn, bank }`), `amount` int, `bossId` text nullable (set null on delete), `taskId` text nullable (set null on delete), `day` text, `at` datetime | Append-only. Carried = sum of earn since the last bank. Banked = sum of bank events. A `bank` event stores the carried sum it moved. |
| `PlanPicks` | `day` text, `taskId` text (cascade on delete), `position` int | Primary key `(day, taskId)`. Max 3 per day, enforced in the DAO. |

**`Settings` columns added** (single row)

| Column | Type and default |
|---|---|
| `rolloverHour` | int, 4 |
| `reminderEnabled` | bool, false |
| `reminderMinutes` | int, 1260 (21:00, minutes from midnight) |
| `flasks` | int, 3 |
| `lastResolvedDay` | text nullable; set to **today's day** (`dayOf(clock())`) by `onCreate` and by the v3 upgrade (D12) |

**Clock in the database (D12).** `AppDatabase` takes a `Clock` constructor argument (default `DateTime.now`; `AppDatabase.open` passes the real one, tests pass a fixed one). `onCreate` and `from2To3` read it only to set `lastResolvedDay`. The migration never judges a day itself.

**`enums.dart`:** add `DayKind`, `EmberKind`. Append only, never reorder. `FallCause.missedDay` already exists.
**`Weight`:** add `embers` (1, 3, 6) next to `holdDuration`.

---

## 6. Build order

Each step: tests first (red), then code (green), then refactor. One commit per step. A step is done when `flutter analyze` is clean and the full suite passes (run from `app/`).

### Step 1: Schema v3 and the rollover setting

**Tests first**
- `test/drift/hearthrise/migration_test.dart`: a v2 database upgrades to v3 with its bosses, attempts and settings intact; the three new tables exist and are empty; new settings columns hold their defaults; `lastResolvedDay` equals `dayOf` of the injected fixed clock (D12). A fresh `onCreate` database gets the same value.
- `test/data/settings_dao_test.dart`: `setRolloverHour` stores 0 to 6 and rejects 7 and -1; `setReminder(enabled, minutes)` round-trips; minutes outside 0 to 1439 are rejected.
- `test/data/attempt_dao_test.dart`: with rollover 4 a strike at 03:00 belongs to the previous day; with rollover 2 it belongs to the same day; changing the hour does not alter old rows (D10).
- `test/data/boss_dao_test.dart` (the read side must agree with the write side): with rollover set to 2, strike a daily task at 03:00. The attempt's `day` is that calendar day, **and** `loadBoss` and `loadAll` show the task as struck (`isStruck` true). A second strike on it is a no-op (no second attempt row; the ember side of this is asserted in step 2). With rollover 4, a strike at 03:00 is recorded for the previous day, and the task still shows struck at 03:00 because the ritual day has not changed; advance the clock to 04:00 and it shows unstruck (existing behavior stays). Changing the setting while the boss list stream is open re-emits the views with the new "today" (watchers also react to settings changes). Write this test first and see it fail on the current `dayOf(_clock())` default.
- `test/features/feel_report_test.dart`: the report's date range uses the stored rollover hour.

**Code:** tables and enums above, `Weight.embers`, an injected `Clock` on `AppDatabase` (D12), schema dump and v3 step, `SettingsDao` methods. Thread the stored `rolloverHour` into **every** `dayOf` caller, not only the write path: `AttemptDao._insert` (`attempt_dao.dart:58`), `BossDao._views` (`boss_dao.dart:74`, which computes "today" for `isStruck`; load the hour with the tables in `loadAll` and `loadBoss`, and add the settings table to `_changes()` so the watchers re-emit when it changes), and `feel_report.dart:17,21`. Keep `kRolloverHour` only as the column default. After this step a grep for `dayOf(` in `lib/` finds no call that omits the hour.

**Done when:** the five test files pass (migration, settings DAO, attempt DAO, boss DAO, feel report).

### Step 2: Embers: earn, carry, bank

**Tests first**
- `test/data/ember_dao_test.dart`: strike earns 1, 3, 6 by weight; tried earns 1, 2, 3; a fall earns nothing; striking an already struck task earns nothing; a task deleted later keeps its event (null reference); `watchTally` shows carried and banked; `bank` moves carried to banked once, writes one `bank` event, and a second `bank` with nothing carried writes no event; nothing is ever subtracted.
- `test/ui/ui_widgets_test.dart`: `EmberTally` renders carried and banked from values; shows "0" without error.
- `test/features/screens_test.dart`: the Today tab shows the carried total and it rises after a strike.

**Code:** `data/ember_dao.dart` (earn is written in the same transaction as the attempt row inside `AttemptDao`), `ember` providers, `ui/ember_tally.dart`, header line in `TodayView`.

**Done when:** the three test groups pass.

### Step 3: Day logs, rest, flasks, light day

**Tests first**
- `test/data/day_dao_test.dart`: `rest` writes a `bonfire` row for `dayOf(now)`, banks carried embers, adds 1 flask (3 stays 3), saves the lesson (trimmed, 120 chars, empty becomes null); a second `rest` on the same day is a no-op and returns false (D9); a rest at 01:00 belongs to the previous day; `skipToday` spends 1 flask and writes a `flask` row, fails with 0 flasks, and is a no-op if the day is already covered; `markLight` writes a `light` row once; flasks never go below 0 or above 3.
- `test/ui/ui_widgets_test.dart`: `FlaskPips` shows n of 3 filled.

**Code:** `data/day_dao.dart` (`rest`, `skipToday`, `markLight`, `watchToday`), `ui/flask_pips.dart`, providers.

**Done when:** `day_dao_test.dart` and the `FlaskPips` test pass.

### Step 4: Missed-day resolution (pure logic and DAO)

**Tests first**
- `test/core/missed_days_test.dart` (pure function, no database): given `lastResolvedDay`, today, the covered days and the strike days, returns the ended days with no cover. Cases: nothing ended yet; one missed day; bonfire covers; flask covers; light with a strike covers; light without a strike does not; today is never judged (it has not ended); a three-day gap returns three days; rollover hour moves the boundary; a daylight-saving day is judged once.
- `test/data/missed_day_dao_test.dart`: `pending()` returns the missed days and the affected bosses (active, created before the missed day, D4); waiting, defeated and same-day-created bosses are exempt; `resolve(lesson, flasksToSpend)` in one transaction: spends flasks oldest first, then fails each affected boss once (D2) with `FallCause.missedDay`, the same lesson on every row, the counter raised, the boss's reset applied; sets `lastResolvedDay` to yesterday; running `resolve` twice changes nothing the second time; with no active bosses it only advances `lastResolvedDay`; an interrupted resolve (exception mid-way) leaves nothing changed.
- Upgrade grace (D12), in `missed_day_dao_test.dart`: a database upgraded from v2 on day D0 has nothing pending on D0 or D1, even with active bosses and no rests; on D2 only D1 is pending.
- `test/data/attempt_dao_test.dart`: `fall` behaves exactly as before (regression for the refactor).

**Code:** `core/missed_days.dart`, extract the failure core of `AttemptDao.fall` into one shared method used by both `fall` and `resolve`, `MissedDayDao` (or methods on `DayDao`).

**Done when:** the three test files pass, and `fall` tests still pass unchanged.

### Step 5: Tomorrow's three (picks)

**Tests first**
- `test/data/plan_pick_dao_test.dart`: `candidates()` returns open tasks of active bosses only, with the boss title; `setPicks(day, taskIds)` stores up to 3 in order, throws on a fourth, replaces an earlier set for that day; deleting a task removes its pick; `picksFor(day)` returns tasks with a struck flag.
- `test/ui/ui_widgets_test.dart`: `PickRow` renders title, boss name and selected state, fires `onChanged`; `PlanBanner` (the "Today's three" block) renders its rows and an all-done state.
- `test/features/screens_test.dart`: Today shows the planned block first on the picked day and hides it when there are no picks.

**Code:** `data/plan_pick_dao.dart`, `ui/pick_row.dart`, `ui/plan_banner.dart`, planned block in `TodayView`.

**Done when:** the three test groups pass.

### Step 6: Bonfire screen

**Tests first**
- `test/data/day_summary_test.dart`: counts strikes, tried and falls for `dayOf(now)`; counts carried embers; lists the day's lessons (text stays on the phone).
- `test/ui/ui_widgets_test.dart`: `DaySummary` renders counts from values; `BonfireCard` (home entry) shows "Rest at the bonfire" before a rest and a quiet "Rested" after, and fires `onTap`.
- `test/features/bonfire_test.dart`: the screen shows summary, lesson field and the candidate list; choosing a fourth task is blocked with a quiet line; Rest writes the day log, banks, saves picks and the lesson, then shows the read-only summary; reopening the screen after a rest is read-only (D9); the screen reads at 15 px or larger (`DESIGN.md`).
- `test/features/screens_test.dart`: Home shows the bonfire card and it navigates to `/bonfire`.

**Code:** `features/bonfire/bonfire_screen.dart` and a thin container, `ui/day_summary.dart`, `ui/bonfire_card.dart`, route `/bonfire` in `core/router.dart`, card on `HomeScreen`. Haptic on Rest through the existing `Haptics`.

**Done when:** the four test groups pass.

### Step 7: Resolve on open and resume

**Tests first**
- `test/features/day_resolver_test.dart` (widget, fake clock, in-memory database):
  - opening with no missed day shows nothing;
  - opening after a missed day shows one fallen moment, and its lesson lands on every affected boss;
  - skipping the lesson still resolves;
  - with flasks, the prompt offers "Use a flask" and covering the day means no fall;
  - with 1 flask and 2 missed days, one day is covered and one falls (D5, D2);
  - simulated resume (lifecycle `resumed`) after rollover resolves the day;
  - killing the screen before the lesson is saved leaves the day unresolved and it is offered again;
  - the screen never shows twice for the same days.
- `test/ui/ui_widgets_test.dart`: `FlaskChoice` (prompt body: days missed, flasks left, two actions) renders from values.

**Code:** `features/ritual/day_resolver.dart`, a thin stateful container that wraps `HomeScreen`, observes `WidgetsBindingObserver`, calls `pending()`, shows the fallen screen or the flask prompt and then `resolve`. `ui/flask_choice.dart`. Copy is calm and plain, no red (§5.8 tone).

**Done when:** `day_resolver_test.dart` and the `FlaskChoice` test pass.

### Step 8: Reminders

**Tests first**
- `test/core/reminders_test.dart` (fake `Reminders` in `test/support/fake_reminders.dart`): turning the reminder on asks for permission, then schedules at the stored minutes; if permission is denied the setting stays off and a quiet line is shown; changing the time cancels and reschedules once; turning it off cancels; app start re-arms the schedule when it is on and cancels when it is off.
- `test/features/bonfire_test.dart`: right after the first rest, with the reminder off, a one-time invitation appears and accepting runs the permission flow; after the second rest it does not appear; declining is remembered by the rest count alone (D6).
- `test/core/reminder_text_test.dart`: the notification title and body are fixed strings and contain no task or boss text.

**Code:** `core/reminders.dart` (interface plus provider), `core/local_reminders.dart` (the plugin: `zonedSchedule`, inexact, `matchDateTimeComponents: time`, timezone data), `ReminderCoordinator` in `features/ritual/`. Packages: `flutter_local_notifications`, `timezone`, `flutter_timezone`. Android: `POST_NOTIFICATIONS` permission and the boot receiver in the manifest, core library desugaring if the plugin needs it. **Before coding**, check the plugin's current docs for API and version, pin the versions, then write the tests.

**Done when:** the three test groups pass.

### Step 9: Settings screen

**Tests first**
- `test/ui/ui_widgets_test.dart`: `SettingSwitchRow` and `SettingValueRow` render from values and fire callbacks.
- `test/features/settings_test.dart`: the screen lists tap fallback, haptics, reminder (switch and time), rollover hour, default reset and the feel report; each control writes through to `SettingsDao`; the time picker stores minutes; the rollover control offers 0 to 6 only; the old bottom sheet is gone and the home button opens the screen.
- `test/features/haptics_switch_test.dart` and `test/features/screens_test.dart`: existing tests updated to the new entry point, still passing.

**Code:** `features/settings/settings_screen.dart`, `ui/setting_switch_row.dart`, `ui/setting_value_row.dart`, route `/settings`, delete `settings_sheet.dart`.

**Done when:** the three test groups pass.

### Step 10: Scripted gate test

**Tests first** (this step is the test): `test/gate_stage3_test.dart`, one scripted run with an advancing fake clock, in-memory database and fake reminders, over several days and bosses (two active, one waiting):
The script has one order, with expected outcomes stated at each point. The bosses are created on day 1, so day 1 is exempt (D4) and the first judged day is day 2.

1. **Day 1:** strike a Heavy and a Light task, rest with a lesson and three picks. Assert carried 0, banked 4, one `bank` event, flasks stay 3 (cap), picks saved for day 2, reminder scheduled.
2. **Day 2:** strike a Heavy task (carried 3). **No rest.**
3. **Day 3, 05:00, open:** assert one pending missed day (day 2) and the flask prompt. **Use the flask at the prompt.** Assert no boss falls, attempt numbers unchanged, flasks 2, `lastResolvedDay` is day 2.
4. **Day 3, later that day:** strike a Light task (carried 4), then rest. Assert one new `bank` event of 4, banked 8, carried 0, flasks 3 (2 plus 1). A second rest the same day changes nothing.
5. **Day 4:** mark a light day, strike a Light task, **no rest**.
6. **Day 5, open:** day 4 is covered by the light day plus a strike. Assert nothing pending and nothing falls. **Day 5:** no activity, no rest.
7. **Day 7, 05:00, open** (days 5 and 6 passed with nothing): assert two pending days. **Decline the flask** and write a lesson. Assert both active bosses fall exactly once (D2) with the same lesson and `FallCause.missedDay`, the waiting boss does not, flasks stay 3, carried embers are not reduced (gentle), `lastResolvedDay` is day 6.
8. **Day 7, after the fall:** carried is still 1 (from day 4, untouched by the fall). Strike a Light task (carried 2), then rest. Assert the `bonfire` row is for day 7, one `bank` event of 2, banked 10, flasks stay 3 (cap).
9. **Day 8:** strike a Light task, then rest at 01:00 on day 9's calendar date. Assert the rest is stored for day 8 (not day 9), one `bank` event of 1, nothing is pending (days 7 and 8 are both covered by rests), and day 9 is not judged until it ends.

Together, steps 1, 4, 8 and 9 check the rest rule on four days: bank once, and +1 flask up to the cap. Banked totals run 4, 8, 10, 11.

**Code:** none expected. If the test finds a hole, fix it with its own failing test first.

**Done when:** `gate_stage3_test.dart` passes with the full suite.

### Step 11: Manual checks on a device

Cannot be automated. Needs the Android SDK and a phone (Android 13 or newer, plus one older if available). Write results into this section.

| Check | Pass condition |
|---|---|
| Permission | The prompt appears once after the first rest and when the reminder is switched on. Denying leaves the switch off. |
| Reminder time | The notification arrives at the chosen time, within the inexact window, with the screen off and the app closed. |
| After restart | The reminder still fires after rebooting the phone. |
| Doze | Still fires after a night with the phone idle and unplugged. |
| Real rollover | Resting at 01:00 counts for the previous day. Opening at 05:00 after skipping the day shows the fallen moment. |
| Airplane mode | The whole loop works with no network. |
| Text size | Bonfire, settings and the missed-day moment read correctly at 200% text. |
| Feel | Resting feels like a pause, not a chore. The fallen moment for a missed day feels supportive. The bonfire takes under a minute on a normal day. |

### Step 12: The gate run

Run the loop for at least 5 real days on a real phone (you and, ideally, one or two Stage 2 testers). Log every bug and every missed or late reminder. Fix each bug test-first (failing test, then fix). The gate closes when section 1 holds. Then tick `CHECKLIST.md`, mark Stage 3 done in `STAGES.md`, and update this file's status.

---

## 7. Risks

| Risk | Handling |
|---|---|
| Inexact alarms are late or dropped by aggressive battery settings on some phones | Step 11 checks Doze and restart. Record phones that fail. The app does not rely on the reminder: a missed day is judged on open. |
| A missed day feels punishing, especially the first one | Day-one exemption (D4), one shared lesson (D2), flasks (D5), calm copy. The gate run asks directly. |
| Flask rule too stingy or too generous | Cap and per-rest rate are two constants. Decide after the gate run. |
| Rollover edge cases (daylight saving, changing the hour, travel across time zones) | Pure function with tests for daylight saving and hour changes. Time-zone travel is not handled; note it if it comes up. |
| Android build not testable yet | Logic is covered with fakes. Device behavior is steps 11 and 12 and waits on the SDK. |
| Schema v3 breaks tester installs | Migration test from a v2 database in step 1. |

---

## 8. Differences from `STAGES.md`

- The "sound" setting is left out until audio exists (Stage 5). A switch with no effect would mislead. `STAGES.md` (Stage 3 and Stage 5) and `CHECKLIST.md` now record the deferral, so it is not unfinished Stage 3 work.
- Light day and flask spending have rules beyond the one line in `STAGES.md` (D5, D8). The planning accuracy line from §5.6 is deferred to Stage 5.
- Health restore from §5.6 waits for Stage 4, where health first exists.
