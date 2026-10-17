# Stage 6 Plan: Closed Test on Google Play

Source: `STAGES.md` (Stage 6) and `souls-task-tracker-design.md` (§ numbers below refer to it). Visual rules: `DESIGN.md`.
Method: TDD (see `STAGES.md`, Development method). Every step below lists its tests first, then the code. UI follows `STAGES.md`, "UI components": new widgets go in `lib/ui/` as `StatelessWidget`s, with state in thin containers in `lib/features/`.
Status: steps 1 to 7 and 9 done, and step 8's code done (on branch `stage-6-closed-test`). Step 8's manual checks and steps 10 to 12 need the Android SDK, a phone and the Play account. See "Implementation notes" at the end.

Prerequisites:
- Steps 1 to 7 and 9 are code and can start now.
- Step 8 (release build) can be coded now; its manual checks and steps 10 to 12 need the Android SDK on the dev Mac and a real phone (same blocker as Stages 3 to 5).
- Step 10 needs the Google Play developer account (`CHECKLIST.md`, Stage 0, still open). Open it **now**: identity verification can take days.
- The Stage 3, 4 and 5 device gates should pass before step 11 starts testers. A closed test of a build that breaks on a real phone wastes the 14-day window.
- Stage 5 step 9 (real sound) is **not** needed. Settings shows no Sound row until it lands.

---

## 1. Goal and gate

**Goal:** put the MVP in front of real testers through the Play closed testing track, and learn whether the tone helps or hurts. Measure the §12 signals without sending any data off the phone.

**Gate:** testers return after falling, and there are no recurring reports of guilt or discouragement. All of these are true:
1. The app is on the closed testing track, and at least the required number of testers (12 at last check, see D12) stayed opted in for the required consecutive days (14 at last check).
2. Tester reports (step 6) from at least 8 testers who fell at least once are collected at day 7 and at the end.
3. **Return after a fall:** across those reports, at least 70% of judged fallen days are followed by a visit the next ritual day (threshold D11).
4. **Feel worse:** no more than one tester answers "Often" to the check-in, and no theme of guilt or discouragement shows up in two or more testers' free-text answers (D11).
5. Scripted (step 9): a fresh install falls on day 1, returns on day 2, skips day 4 after a fall on day 3, answers the day-7 check-in; the tester report shows "returned next day 1 of 2", first-week falls 2, the check-in answer, and contains no boss, task or lesson text.
6. Every Stage 1 to 5 gate test still passes (`gate_test.dart`, `gate_stage3_test.dart`, `gate_stage4_test.dart`, `gate_stage5_test.dart`).
7. `flutter analyze` is clean and the full suite passes.
8. Manual checks in step 8 pass on the release build from the Play track.

---

## 2. Where Stage 5 left us

| Piece | Where | Stage 6 use |
|---|---|---|
| Feel report: counts only, copied to the clipboard (Stage 2 D3) | `features/feel_report/feel_report.dart`, `data/feel_report_data.dart`, `AttemptDao.feelReportData()` | Grows into the tester report (D1). Already has Tried vs Strike and lessons on falls |
| "Copy feel report" row in Settings | `features/feel_report/copy_feel_report_tile.dart` | Renamed "Copy tester report" |
| `kAppVersion` checked against `pubspec.yaml` | `feel_report.dart`, `feel_report_test.dart` | Version bump per upload (D9) |
| `Settings.firstDay` (install or v4 upgrade day) | `data/tables.dart` | Start of "first week" for signals and check-ins |
| `dayOf(time, rolloverHour)` | `core/clock.dart` | Every day in a signal is a ritual day |
| Attempts with `outcome`, `cause`, `lesson`, `at`; cascade-deleted with their boss | `data/tables.dart` | Falls come from here today, but a deleted boss erases them (D3) |
| `DayLogs.lesson` (bonfire lessons) | `data/tables.dart` | Counted with attempt lessons |
| `Commitments.extensions`, `CommitmentOutcome.lateStrike`, `CommitmentDao.week()` | `data/commitment_dao.dart` | Extra §12 signals (step 7) |
| `DayResolver` lifecycle observer (start and `resumed`) | `features/ritual/day_resolver.dart` | Where an app open is seen (D2) |
| `SettingsDao.setTapMode` | `data/settings_dao.dart` | Logs the hold-to-tap change (D4) |
| Release build signed with debug keys; default launcher icon; `applicationId` `com.hearthrise.app` | `android/app/build.gradle.kts`, `AndroidManifest.xml` | Real upload key, final ID and icon (step 8) |
| `key.properties` and `*.keystore` already gitignored | `app/android/.gitignore` | Upload key stays out of git |
| Schema v5 with step migrations and dumps in `test/drift/` | `data/database.dart` | Schema v6 (step 1) |

---

## 3. Scope

### In Stage 6

| Item | Design ref |
|---|---|
| Record one visit per ritual day the app is opened | §12 next-day return |
| Signal log that survives boss deletion: falls, hold-to-tap changes, check-in answers | §12 |
| Tester report: next-day return after a fall, Tried vs Strike, lessons written, hold-to-tap changes, first-week falls and returns, check-in answers | §12, `STAGES.md` Stage 6 |
| In-app check-in: "Has Hearthrise left you feeling worse?" on day 7 and day 14 | §12 "ask directly" |
| Extra §12 signals already in the data: free extensions used, late strikes, commitments per day and planning accuracy in week 1 vs week 4 | §12 |
| Release build: upload key signing, version scheme, target SDK, original launcher icon, AAB | §10.4 |
| Play Console: listing, privacy policy, Data safety, content rating, closed track, testers | §10.4 |
| Tester kit: invite text, how to copy the report, feedback form with the §12 questions | §12 |

### Not in Stage 6 (and where it lands)

| Item | Stage |
|---|---|
| Analytics or crash SDK, any network call | Not planned before Stage 7 (D1). Play vitals gives crash and ANR data with no SDK |
| Production release | 8 |
| Hardcore mode | 8 |
| Sound cues (Stage 5 step 9) | When the licensed sounds are chosen |
| Tuning from tester feedback (hold durations, copy, loss amounts) | Follow-up after the gate review; each change is its own TDD step |

---

## 4. Decisions in this plan (confirm or change)

| # | Question | Decision | Why |
|---|---|---|---|
| D1 | How do signals reach us? | **Local only.** The feel report grows into a **tester report**: counts, ratios and dates, copied to the clipboard and pasted by the tester into the feedback form. No analytics SDK, no network. Data safety form: "No data collected or shared." | Same reasoning as Stage 2 D3: offline-first and privacy. Keeps the Data safety answer simple and honest. The cost is that testers must paste the report; step 11 asks for it twice. |
| D2 | What is a "visit"? | New **`Visits`** table, one row per ritual day (`day` primary key, `firstAt`). Written on app start and on every `resumed`, idempotent. Installs upgraded from v5 have no history before v6. | "Next-day return" needs to know the app was opened, even with nothing struck. `DayResolver` already sees start and resume. |
| D3 | Where do falls come from? | New append-only **`SignalEvents`** table (`id`, `kind`, `day`, `at`, `value` int nullable), **no foreign keys**. A `fell` event is written in the same transaction as every fallen attempt (declared, missed day, death). A missed day that fails three bosses writes one event per attempt; the report counts **fallen days**, not events. | Attempts cascade-delete with their boss, so a tester who deletes a lost boss would hide the falls we most want to see. One small table also holds D4 and D6, and holds no text. |
| D4 | Hold-to-tap changes | `setTapMode` writes a `tapModeChanged` event (`value` 1 on, 0 off) only when the value changes. Report: current mode, number of changes, day of the first change relative to install. | §12 "how often the hold is turned into a tap". A count plus the first day tells "dropped the hold on day 1" from "tried it for two weeks". |
| D5 | Next-day return after a fall | For each **fallen day** F (ritual day of a `fell` event's `at`), returned = a visit on F+1. F is **pending** while F+1 is today or later, and is left out of the ratio. A missed-day fall is written when the user opens the app, so its fallen day is the day they saw the fallen screen. | `at` is when the fall was felt, which is what the question is about. Pending days would read as "did not return" otherwise. |
| D6 | "Did it make you feel worse?" | A quiet **check-in card** on the bonfire screen, once in each window: from day 7 and from day 14 after `firstDay`, until answered or dismissed. "Has Hearthrise left you feeling worse?" with **Never / Sometimes / Often** and "Not now" (dismiss counts as no answer; the card returns next bonfire, at most 3 times per window). Answer stored as a `checkIn` event (`value` 0 to 2). The feedback form asks the same thing with a free-text "When?" | §12 "ask directly". In-app puts the answer in the report next to the falls. The bonfire is the calm end of the day, not the fallen screen. Neutral options, no score, no follow-up nag. |
| D7 | Lessons written | Report counts: falls with a lesson vs without (today), plus bonfire lessons (`DayLogs.lesson`). Still no lesson text. | §12 "how often lesson notes are written" covers both places a lesson is written. |
| D8 | Report period | From `firstDay` (install day for every Play tester) to today, plus "visits recorded since" the earliest visit. Replaces "since the earliest surviving boss". | Testers install fresh, so `firstDay` is the true start. Visit history may be shorter on upgraded dev installs. |
| D9 | Versions | `version: 0.6.0+N` in `pubspec.yaml`, N increases by one for every upload. `kAppVersion` stays equal (existing test). | Play rejects a reused versionCode. 0.x says "not launched". |
| D10 | Release signing | Release reads `android/key.properties` (gitignored); the upload keystore lives outside the repo, backed up. **No debug fallback for release**: without `key.properties` the release build fails. Play App Signing on. | A debug-signed upload is rejected anyway, and a silent fallback hides a missing key. The upload key can be reset through Play support; the app signing key never leaves Google. |
| D11 | Gate thresholds | Return after a fall: **at least 70%** of judged fallen days. Feel worse: **at most one** "Often", and no guilt theme in **two or more** testers' free text. Minimum sample: **8 testers who fell at least once**. | `STAGES.md` gives no numbers. These are a starting line to argue with, set before the data comes in so they are not bent to fit it. |
| D12 | Play rules | At last check (October 2026, third-party sources): personal accounts created after 13 Nov 2023 need **12 testers opted in for 14 consecutive days** before applying for production; the count dropping below 12 may restart the clock. Recruit **at least 16**. Target API level for new apps may now be **36**. **Verify both in Play Console Help before step 10.** | §10.4 "rules change, so verify". Buffer protects the 14-day clock. |
| D13 | Test length | Run **4 weeks**, not the 14-day minimum. Reports at day 7 and at the end. | §12 compares week 1 with week 4 for accuracy and commitments per day. |
| D14 | Launcher icon | Original abstract mark (ember over a bonfire ring), drawn as an adaptive icon (foreground vector + background color from `DESIGN.md`). No game art. | §13 trademark risk. Required for the store listing. |

---

## 5. Data model: schema v6

One migration (`from5To6`). Dump the schema and generate step helpers, as for v5.

**New tables**

| Table | Columns | Notes |
|---|---|---|
| `Visits` | `day` text primary key, `firstAt` datetime | One row per ritual day opened (D2) |
| `SignalEvents` | `id` text, `kind` int (`SignalKind`), `day` text, `at` datetime, `value` int nullable | Append-only, no foreign keys, no text (D3, D4, D6) |

**Backfill:** one `fell` event per existing fallen attempt, with its own `day` and `at`. No visits (unknown).

**`enums.dart`** (append only): `SignalKind { fell, tapModeChanged, checkIn, checkInDismissed }`, `CheckInAnswer { never, sometimes, often }`.

**Constants:** `kCheckInDays = [7, 14]`, `kCheckInMaxShows = 3`.

---

## 6. Build order

Each step: tests first (red), then code (green), then refactor. One commit per step. A step is done when `flutter analyze` is clean and the full suite passes (run from `app/`).

### Step 1: Schema v6

**Tests first**
- `test/drift/hearthrise/migration_v6_test.dart`: a v5 database upgrades with bosses, attempts, relics, commitments, health and ember events intact; `Visits` and `SignalEvents` exist and `Visits` is empty; each fallen attempt has one `fell` event with the same `day` and `at`; strikes and tries get none.
- `test/data/enums_test.dart` (added): `SignalKind` and `CheckInAnswer` values; existing enum indexes unchanged.

**Code:** tables, enums, schema dump, `from5To6` with the backfill.

**Done when:** both pass, and the v1 to v5 migration tests still pass.

### Step 2: Visits

**Tests first**
- `test/data/visit_dao_test.dart` (in-memory Drift, fixed clock): `record(now)` writes the ritual day; a second call the same day keeps the first `firstAt`; 03:59 and 04:00 with rollover 4 are different days; `days()` returns them sorted.
- `test/features/visit_recorder_test.dart`: pumping the app records today; sending `AppLifecycleState.resumed` after the clock moves a day records the next day; pausing records nothing.

**Code:** `VisitDao` and provider; `DayResolver` calls `record` on start and on `resumed` (it already observes both), before resolving deadlines.

**Done when:** both files pass.

### Step 3: Signal events (falls and hold-to-tap)

**Tests first**
- `test/data/signal_dao_test.dart`: every way to fall writes one `fell` event in the same transaction as the attempt: declared fall, missed day (one per failed boss), death at zero health (reuse the setups in `attempt_dao_test.dart`, `missed_day_test.dart`, `health_dao_test.dart`); a fall whose attempt write throws leaves no event; deleting the boss keeps the events.
- `test/data/settings_dao_test.dart` (added): `setTapMode(true)` from off writes `tapModeChanged` with value 1; setting the same value again writes nothing; back to off writes value 0.

**Code:** `SignalDao.add` used inside the existing fall transactions in `AttemptDao` and `HealthDao`; `SettingsDao.setTapMode` compares first.

**Done when:** both files pass and `attempt_dao_test`, `missed_day_test`, `health_dao_test`, `settings_dao_test` are still green.

### Step 4: Signals (pure)

**Tests first** `test/core/signals_test.dart` (pure Dart, no database), `computeSignals(input, today)`:
- one fall on day 1 and a visit on day 2: returned 1 of 1;
- fall on day 3, no visit on day 4, visit on day 5: returned 0 of 1;
- fall today or yesterday: pending, not in the ratio;
- three `fell` events on one day (missed day, three bosses): one fallen day;
- fall at 03:30 with rollover 4 belongs to the previous day;
- first week = `firstDay` to `firstDay + 6`: falls in it, and returns after them, counted separately; a fall on day 8 is not first-week;
- Tried vs Strike: counts and ratio, "n/a" with no strikes;
- tap mode: change count and first change as "day N";
- check-ins: latest answer per window, dismiss count;
- empty input gives zeros and "n/a", never a division error.

**Code:** `core/signals.dart`: `SignalInput` (visit days, signal events, attempt outcomes, lesson flags, bonfire lesson count, `firstDay`, rollover hour) and `Signals` value. `SignalDao.input()` builds the input and never reads a title or lesson text.

**Done when:** `signals_test.dart` passes, plus a `signal_dao_test.dart` case that `input()` on a seeded database matches the expected counts.

### Step 5: Check-in card

**Tests first**
- `test/ui/check_in_card_test.dart`: renders the question and three choices plus "Not now" from given values; each choice fires `onAnswer` with its `CheckInAnswer`; "Not now" fires `onDismiss`; 48 dp targets; no overflow at 320 x 568 and 200% text.
- `test/core/check_in_test.dart` (pure): `dueCheckIn(firstDay, today, events)` is null before day 7; window 7 from day 7; still due on day 9 if dismissed once; not due after 3 dismissals; not due once answered; window 14 from day 14 even if window 7 was never answered.
- `test/features/bonfire_check_in_test.dart`: on day 7 the bonfire shows the card below the summary; answering writes the event and the card fades out; on day 6 there is no card.

**Code:** `ui/check_in_card.dart` (stateless); `core/check_in.dart`; the bonfire screen container reads due state and writes through `SignalDao`. Copy is neutral; no reply line after answering beyond "Thank you."

**Done when:** the three files pass and `bonfire_test.dart` is still green.

### Step 6: Tester report

**Tests first** `test/features/tester_report_test.dart` (fixed `now`):
- the text has a version line, period from `firstDay` (D8), visits-since line, and lines for: returned next day after a fall (N of M, P pending), first-week falls and returns, strikes by weight, tried, Tried per Strike, lessons on falls (written vs skipped) and bonfire lessons, tap mode (now, changes, first change day), check-ins (per window: answer, or "not asked yet" or "dismissed N");
- privacy: seed known boss titles, task titles, phase names, lessons, bonfire lessons and an inscription; none appear in the output;
- `kAppVersion` matches `pubspec.yaml` (existing test, moved);
- widget: tapping "Copy tester report" puts the text on the mocked clipboard and shows the quiet confirmation.

**Code:** rename `feel_report` to `tester_report` (files, builder, tile); builder takes `Signals`. Delete `FeelReportData` once nothing reads it.

**Done when:** `tester_report_test.dart` passes and `feel_report_test.dart` / `feel_report_data_test.dart` are folded into it with no lost case.

### Step 7: Extra §12 signals

**Tests first** `test/core/signals_test.dart` and `test/data/signal_dao_test.dart` (added):
- free extensions used and flask extensions used (from `Commitments.extensions`);
- late strikes (`CommitmentOutcome.lateStrike`);
- commitments per day and planning accuracy in week 1 vs week 4 (days 22 to 28); "not yet" before day 22;
- report lines for each, still counts only.

**Code:** extend `SignalInput` and the report.

**Done when:** the added cases pass.

### Step 8: Release build

**Tests first** `test/release_config_test.dart` (reads files as text, no Gradle run):
- `pubspec.yaml` version matches `0.6.0+N` with N at least 1, and equals `kAppVersion`;
- `build.gradle.kts` release `signingConfig` is not `"debug"` and loads `key.properties`;
- `AndroidManifest.xml` asks only for `POST_NOTIFICATIONS` and `RECEIVE_BOOT_COMPLETED` (keeps the Data safety answer true) and has no `INTERNET` permission in `src/main` (D1);
- the launcher icon is the adaptive `ic_launcher` with a foreground vector (D14).

**Code:** signing config from `key.properties` (D10); version 0.6.0+1; `targetSdk` set to the Play minimum if `flutter.targetSdkVersion` is lower (D12); adaptive icon; remove the template `TODO` comments; `pubspec.yaml` description.

**Manual checks** (release build on a real phone, installed from the internal testing track so it is Play-signed):
- `flutter build appbundle --release` succeeds; size noted;
- R8 does not break `flutter_local_notifications`: the daily reminder and a deadline reminder fire, and survive a reboot;
- haptics, hold, fallen, bonfire, victory and onboarding work as in debug;
- cold start time noted on the small phone;
- the tester report copies and pastes into a message app.

**Done when:** `release_config_test.dart` passes and every manual check is ticked.

### Step 9: Scripted gate

**Tests first** `test/gate_stage6_test.dart` (fixed clock, real database in memory, app pumped):
- fresh install; onboarding; fall on day 1; open on day 2; fall on day 3; skip day 4; open day 5; toggle tap mode on day 5; open the bonfire on day 7 and answer "Never";
- the copied report says returned next day 1 of 2, first-week falls 2, tap mode changes 1 (first day 5), check-in day 7 "Never";
- delete the boss; the report numbers do not change;
- no boss, task or lesson text in the report.

**Code:** none expected; fix whatever the gate finds, test first.

**Done when:** `gate_stage6_test.dart` and the Stage 1 to 5 gate tests pass.

### Step 10: Play Console setup (manual, no code)

- Verify D12 against Play Console Help; update this plan if the numbers changed.
- Create the app: name Hearthrise, default language, free, app (not game).
- Privacy policy page (static page, e.g. GitHub Pages): everything stays on the phone; no account; no data collected or shared; notifications are local; contact email.
- Data safety: no data collected, no data shared.
- Content rating questionnaire; target audience 18+ (avoids the Families policy).
- Store listing: short and full description in Hearthrise vocabulary with no game trademarks; icon 512 x 512; feature graphic 1024 x 500; at least 2 phone screenshots (home, boss, fallen, bonfire, victory).
- Upload 0.6.0+1 to **internal testing** first; run the step 8 manual checks on that build.
- Closed testing track: tester list (Google Group or email list), countries, feedback channel.

**Done when:** the closed track is approved and the opt-in link works from a tester's account.

### Step 11: Run the test (manual)

- Tester kit (`docs/tester-kit.md`): invite text, opt-in link, "please do not uninstall for 14 days", how to copy the tester report (Settings, "Copy tester report"), and the feedback form link.
- Feedback form: the §12 questions in plain words (hold, fallen screen, bloodstain, coming back after a fall, attempt counter, reminder, deadlines, health loss), "Has Hearthrise left you feeling worse? When?", and a box for the pasted report.
- Day 0: invite at least 16 (D12). Day 7 and day 28: ask for the form with the report. Track opt-ins daily in Play Console so the 14-day count never drops below the minimum.
- Collect each report into one sheet (one row per tester per report). Fixes for crashes go out as new uploads (N + 1), test first; tone changes wait for step 12.

**Done when:** 4 weeks have passed (D13), the 14-day requirement shows as met in Play Console, and reports are in from at least 8 testers who fell.

### Step 12: Gate review

- Compute gate items 3 and 4 from the sheet. Group free-text answers by theme.
- Write `STAGE6_RESULTS.md`: numbers, themes, quotes (with tester consent), and a list of tuning changes, each as a future TDD step.
- Tick `CHECKLIST.md` Stage 6.

**Done when:** every gate item in section 1 is true, or the review names what failed and the plan to fix it before Stage 7.

---

## 7. `lib/ui/` widgets

| Widget | Step | New or reused |
|---|---|---|
| `CheckInCard` | 5 | New |
| `SettingValueRow` (Copy tester report) | 6 | Reused |
| `DaySummary`, `BonfireCard` | 5 | Reused (card sits below them) |

---

## 8. Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| Play account or identity check takes weeks | Medium | Open it now, before any code (prerequisites) |
| Fewer than 12 testers stay opted in; 14-day clock restarts | High | Recruit 16 or more, check opt-ins daily, ask testers not to leave early |
| Testers do not paste reports | High | Two asks only (day 7, day 28), report is one tap, form has a paste box; Play vitals still gives crashes |
| R8 or release mode breaks scheduled notifications | Medium | Step 8 manual check on a Play-signed build from internal testing before any tester sees it |
| Upload keystore lost | Low | Back up outside the repo; Play App Signing allows an upload key reset |
| Check-in card itself feels like pressure | Medium | Bonfire only, two windows, three shows max, neutral copy, "Not now" always there |
| Sample too small to read a 70% ratio | Medium | Minimum of 8 fallen testers (D11); report ratios with counts, not percentages alone |
| Android SDK still missing on the dev Mac | High | Same blocker as Stages 3 to 5; steps 1 to 7 and 9 do not need it |
| Rules (tester count, target API) changed since last check | Medium | Verify in step 10 against Google's own pages (D12) |

---

## 9. Implementation notes

Done test-first, one commit per step, with `flutter analyze` clean and the full suite passing (538 tests, Flutter 3.47.7):

| Step | Status |
|---|---|
| 1 Schema v6 | Done. `migration_v6_test.dart`, `enums_test.dart`. |
| 2 Visits | Done. `visit_dao_test.dart`, `visit_recorder_test.dart`. |
| 3 Signal events | Done. `signal_dao_test.dart`, `settings_dao_test.dart`. |
| 4 Signals | Done. `test/core/signals_test.dart`, `signal_dao_test.dart` (`input`). |
| 5 Check-in card | Done. `check_in_card_test.dart`, `test/core/check_in_test.dart`, `bonfire_check_in_test.dart`. |
| 6 Tester report | Done. `tester_report_test.dart` (replaces `feel_report_test.dart` and `feel_report_data_test.dart`). |
| 7 Extra signals | Done. Cases added to `signals_test.dart`, `tester_report_test.dart`, `signal_dao_test.dart`. |
| 8 Release build | **Code done**, `release_config_test.dart`. Gradle changes **not yet built**: no Android SDK on the dev Mac. Manual checks open. |
| 9 Scripted gate | Done. `gate_stage6_test.dart`. |
| 10 Play Console | **Open.** Drafts ready: `docs/privacy-policy.md`, Play icon `app/store/play_icon_512.png`. |
| 11 Run the test | **Open.** `docs/tester-kit.md` has the invite, report steps, form and sheet columns. |
| 12 Gate review | **Open.** |

Where the build differs from the plan above:
- The upgrade from Flutter 3.29.3 to 3.47.7 was needed first: `pubspec.lock` already required Flutter 3.47 or later.
- `CheckInAnswer` lives in `core/check_in.dart` and is re-exported from `data/enums.dart`, like `Weathering`, so `lib/ui` can use it. `dayNumber` (install day is day 1) is in `core/clock.dart`.
- Every fall goes through `AttemptDao.failBoss`, so that is the one place the `fell` event is written, with the attempt's own `day` and `at`.
- A visit is recorded outside `DayResolver`'s busy guard: a resume while a fallen prompt is open still counts (`visit_recorder_test.dart`).
- A dismissal also hides the check-in card for the rest of that day, so "Not now" means not now; the card returns at the next day's bonfire. It never shows while fallen.
- `SettingsDao` takes the clock (optional, default now) so a tap-mode change is stamped like every other event.
- Week promises (step 7) count from `Commitments`, which cascade-delete with their boss; so do lessons on falls. Fallen days, returns, tap changes and check-ins come from `SignalEvents` and survive a deleted boss.
- Release signing reads `android/key.properties` (template: `android/key.properties.example`); with no file, Gradle's signing check fails the release build. `targetSdk` stays `flutter.targetSdkVersion`, which is 36 in Flutter 3.47.
- The launcher icon is an adaptive vector (also used as the monochrome icon). The PNG fallbacks for API 24 and 25 and the 512 px Play icon are drawn by `tool/render_launcher_icons.dart` (`flutter test tool/render_launcher_icons.dart`) from the same shapes.
