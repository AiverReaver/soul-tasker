# Stage 2 Plan: Feel Prototype

Source: `STAGES.md` (Stage 2) and `souls-task-tracker-design.md` (§ numbers below refer to it). Visual rules: `DESIGN.md`.
Method: TDD (see `STAGES.md`, Development method). Every step below lists its tests first.
Status: steps 1 to 9 (code and tests) done, uncommitted; steps 10 to 14 need a phone, the Android SDK and testers. Build order ran 2 before 1 (the haptics provider reads `settings.haptics`). `FeelReportData` lives in `data/feel_report_data.dart` so `data` never imports `features`. Stage 1 already shipped most of the Stage 2 prototype; this stage finishes the missing pieces, gets the feel onto real phones, and tunes it from tester feedback.

---

## 1. Goal and gate

**Goal:** prove the Souls feel before building more on it. Does the hold feel satisfying or annoying? Does the fallen screen feel supportive or discouraging? (§12)

**Gate:** 3 to 5 testers have used the hold and met the fallen screen on their own phones for at least 3 days. Then all of these are true:
1. A majority of testers say the hold is satisfying or neutral, not annoying, **on the build that ships**. If tuning (section 8) changes the hold or the haptics in any way, the final build goes to **all** testers for at least 1 day and each answers questions 1 and 7 again; the majority is counted on those answers, not on the earlier round.
2. No tester describes the fallen screen as discouraging, **on the build that ships**. If the fallen screen changes in any way (copy, dim, prompt, haptic), the final build goes to all testers and each answers question 2 again; the condition is judged on those answers.
3. No tester reports that the app made them feel worse. If one does, the gate stays closed until the cause is found and fixed, the fixed build goes to **every** tester for at least 1 day, and the tester who reported it and every other tester answer question 5 (section 9.2) again with no "worse". This rule is fixed before feedback is collected and is not softened afterward.
4. The full test suite passes and `flutter analyze` is clean.

---

## 2. Where Stage 1 left us

Already built and tested, so not rebuilt here:

| Piece | Where | Note |
|---|---|---|
| Hold to strike: 0.3 / 0.6 / 1.2 s by weight, early release rolls back | `features/strike/hold_to_strike.dart` | Covered by `test/feel_test.dart` |
| Ember fill during hold, task dims after strike | same | Dim covered only indirectly |
| Haptic ticks during hold, impact on strike | same | Calls `HapticFeedback` directly; no test, no off switch |
| Tap fallback | `settings.tapMode` | Covered |
| Segmented health bar with slow drain | `features/boss/boss_health_bar.dart` | No test of the drain |
| Fallen screen: dim, quiet line, lesson prompt, heavy haptic | `features/fallen/fallen_screen.dart` | Round trip tested; haptic and dim not |
| Palette, type, motion tokens, reduced-motion helper | `core/theme.dart` | |

### Gaps against §7 and §8 (this stage fills them)

| Gap | Design ref |
|---|---|
| No setting to turn haptics off | §8.3 ("All haptics can be turned off") |
| No slash or fade effect when a strike lands; boss-tier has no bigger effect | §7.2, §7.4 |
| Haptic build-up is the same for every weight (Light gets 4 ticks in 0.3 s) | §7.2, §8.3 |
| Hold starts on any touch, so slowly scrolling a list with a finger on a task for 0.6 s may strike it (suspected; step 5 proves or disproves it) | §7.1 ("prevents accidental completions") |
| No way to read the §12 signals from a tester's phone | §12 |
| Never run on a real phone; no tester build | STAGES.md gate |

---

## 3. Scope

### In Stage 2

| Item | Design ref |
|---|---|
| `core/haptics.dart`: one place for all haptics, with an on/off flag | §8.3 |
| Haptics setting (default on), schema v2 | §8.3 |
| Haptic profile by weight: Light, Heavy, Boss-tier | §7.2, §7.4, §8.3 |
| Strike landing effect: a short ember sweep; longer for Boss-tier | §7.2, §7.4 |
| Scroll-safe hold: moving the finger past touch slop cancels the hold | §7.1 |
| Tests for the existing feel pieces (dim, drain, fallen dim and haptic) | TDD rule |
| Feel report: derived counts copied to the clipboard from the settings sheet | §12 |
| Tester build, tester script, a 3-day round, tuning, a short re-check | §12 |

### Not in Stage 2 (and where it lands)

| Item | Stage |
|---|---|
| Embers added to the carried total on a strike (§7.3 third bullet) | 3 |
| Audio (building tone, victory tone, fallen thud) | Off by default; needs licensed sounds (Stage 0 item still open). Revisit in Stage 5 with the victory tone |
| Drifting ember or fog on the home screen (§8.1) | 5 (polish) |
| Restricting the hold to Heavy and Boss-tier only | Only if testers find the hold annoying (§7.5); see section 8 |
| Bloodstain marker | 8 |
| Sync, accounts, analytics upload | 7. Stage 2 sends nothing off the phone |

---

## 4. Decisions in this plan (confirm or change)

| # | Question | Decision | Why |
|---|---|---|---|
| D1 | How do testers get the app? | **Android release APK shared as a file** (the design is Android-first, §10.4). Needs the Android SDK on the dev Mac, which is not installed yet. iOS testers would need TestFlight and the paid Apple Developer Program, so use it only if most testers are on iPhone. | No store review, no account setup for testers, fastest to iterate. The Play closed track is Stage 6. |
| D2 | Does the haptics setting default on? | **Yes.** Haptics are part of the feel being tested. | Testers should meet the intended feel first. |
| D3 | How do we read §12 signals without a server? | **Feel report** in the settings sheet: counts only, copied to the clipboard, which the tester pastes into a message. Contains strikes by weight, tried, declared falls, lessons written vs skipped, tap mode on or off, haptics on or off, app version. **Never** boss names, task titles, or lesson text. | Honors offline-first and privacy; derived from the `attempts` table and the bosses table (inputs in D13), so no new tables. |
| D4 | Schema change | **v2 adds `settings.haptics`** (bool, default true) **and `attempts.weight`** (nullable weight enum, see D12). Use `dart run drift_dev make-migrations`; the generated step and schema test cover the upgrade from v1. | Stage 1 set this process up for exactly this. |
| D5 | Where do effects and haptics follow settings? | Reduced motion removes the sweep (state changes are instant). Haptics off silences every haptic, including the fallen pulse. | DESIGN.md accessibility rules; §8.3. |
| D6 | The sweep versus "ember once per screen" | The sweep is a transient effect on the row that was just struck, so it is allowed. It must not stay on screen. | Keeps DESIGN.md's rule about competing ember elements. |
| D8 | Haptic profile versus the spec | Follow the spec for ticks; add two labeled experiments (medium build-up pulse, Boss-tier double landing). See section 5. | Gives the feel something to test without silently rewriting §8.3. |
| D9 | What period does the feel report cover? | **Whole-period totals since the earliest surviving boss was created**, from a **fresh install** (testers never share a database with development builds). The report prints the period start and end dates. Deleting a boss also deletes its attempts, so a deleted boss leaves the report entirely and the start date can move later; testers are told not to delete bosses during the round, and the report says "since the earliest surviving boss". Settings are current values only; setting changes in between are not recorded. To catch changes, each tester sends one report at the end of day 1 and one at the end of the round, and answers the tap-mode question. | Defines the window instead of leaving it implied; a change log would need new storage for little gain with 3 to 5 testers. |
| D10 | Haptics switch timing and contract | Takes effect **immediately**. `Haptics` never stores the on/off value. It is built with a lookup (`bool Function() isEnabled`, backed by the settings provider, default on while settings are still loading) and calls it **on every haptic**. So an object created before the switch was flipped, including one already held by a hold in progress or passed to `FallenScreen.show`, still obeys the new value. | A captured boolean or a stale object would keep buzzing after the switch is off. |
| D11 | How does the fallen screen reach the haptics setting? | `FallenScreen.show(context, haptics)` takes the `Haptics` object as an argument. `BossScreen._fall()` passes `ref.read(hapticsProvider)`; that is the only call site. | `show` is static and has no `WidgetRef`. Passing the object keeps the screen simple and testable. |
| D12 | Report counts by weight | **Store the weight on the attempt at strike and tried time** (`attempts.weight`, null for falls and for v1 rows created before this column). Later weight edits or deleting the task do not change it. The report counts v1 and unknown rows under "weight unknown". | Looking up the current task would miscount edited tasks and drop deleted ones (D10 of Stage 1 nulls `taskId`). |
| D13 | Report inputs | `AttemptDao.feelReportData()` returns `FeelReportData`: for each attempt only `outcome`, `weight` and `hasLesson` (never titles or lesson text); the earliest surviving `bosses.createdAt` (null if no boss); `AppSettings`. `buildFeelReport(data, now, appVersion)` is a pure function; `now` comes from `clockProvider` and `appVersion` from the package info (or a constant `kAppVersion` kept equal to `pubspec.yaml`; a test asserts they match). | The function gets everything it prints, so unit tests need no database for the text and one DAO test covers the query. |
| D7 | Tests and tuning | Tests read `Weight.holdDuration`, `Motion.*` and the new effect constants instead of literals, so tuning a number never breaks a test. | Tuning is the main work after feedback. |

---

## 5. Haptic profile (D2, D5)

| Weight | During the hold | On landing |
|---|---|---|
| Light (0.3 s) | 1 selection tick | light impact |
| Heavy (0.6 s) | 3 selection ticks, then 1 medium pulse | heavy impact |
| Boss-tier (1.2 s) | 5 selection ticks, then 1 medium pulse | heavy impact, then a second heavy impact 120 ms later |
| Early release | ticks stop; no landing haptic | none |
| Fallen | none | one heavy impact when the screen opens |
| Haptics off | none | none |

**Deliberate departures from the written spec (D8).** DESIGN.md and §8.3 say "light ticks that build" during the hold, a light tick for small tasks and a heavy pulse for heavy and boss-tier strikes. This profile follows that, except for two experiments: the medium pulse at the end of the build-up (Heavy and Boss-tier), and the second heavy impact on a Boss-tier landing. Testers are asked about haptics directly (question 7, section 9.2). When tuning ends, update DESIGN.md (Haptics) and §8.3 to match what shipped, so the documents and the app agree.

The numbers are a first guess and are expected to change in section 8. They live as constants beside `Weight`.

---

## 6. Structure changes

```
lib/
  core/
    haptics.dart            Haptics class: light, tick, medium, heavy, doubleHeavy; calls an isEnabled lookup on every haptic (D10)
  features/
    strike/
      hold_to_strike.dart   uses Haptics; slop cancel; plays the sweep
      strike_sweep.dart     the landing effect (new)
    feel_report/
      feel_report.dart      FeelReportData + buildFeelReport(data, now, appVersion) (new; D13)
  ui/                       stateless widgets (STAGES.md, "UI components"); step 0 extracts the existing ones here
    strike_sweep_view.dart  paints the sweep from a progress value (new; the controller stays in features/strike)
test/
  ui/                       one widget test per ui widget
  core/haptics_test.dart
  features/strike/          haptic profile, slop cancel, sweep, dim
  features/boss/health_bar_test.dart
  features/fallen_feel_test.dart
  features/feel_report_test.dart
```

`HoldToStrike` becomes a `ConsumerStatefulWidget` so it reads the haptics provider. `FallenScreen.show` gains a `Haptics` parameter (D11) and `BossScreen._fall()` passes it. `feel_test.dart` and the screen tests override the provider with a recording fake.

---

## 7. Build order (test-first)

Each step: write the listed tests, see them fail, write the code, refactor. Each step ends with `flutter analyze` clean and the full suite green, and is one commit.

| # | Step | Tests first | Done when |
|---|---|---|---|
| 0 | **UI extraction.** Move presentational widgets into `lib/ui/` as `StatelessWidget`s: `boss_health_bar`, `boss_card`, `task_row`, `flash_line`, and the visual part of `hold_to_strike` (row, progress fill) and `strike_sweep`. Providers, hold timer, animation controllers and haptics stay in thin `features/` containers that pass values down. Screens import from `ui/`; no behavior change. | `test/ui/` widget test per extracted widget: renders from given values, fires callbacks, no provider needed (pumped without `ProviderScope`). All existing tests pass unchanged apart from import paths. | No presentational widget remains in `features/`; `ui/` imports no `data/` or provider code |
| 1 | **Haptics seam.** Add `core/haptics.dart` and a provider. Replace direct `HapticFeedback` calls in `hold_to_strike.dart` and `fallen_screen.dart`; change `FallenScreen.show` to take `Haptics` and update `BossScreen._fall()` (D11). | `haptics_test`: with the platform channel mocked, each method sends the expected haptic type; with the lookup returning false none is sent; one `Haptics` object created while the lookup returned true sends nothing after the lookup flips to false, and resumes when it flips back (D10). A test also builds `hapticsProvider` from a real settings stream and flips the database setting under an existing object. `feel_test` still passes with a recording fake. | No `HapticFeedback` call remains outside `core/haptics.dart`; `FallenScreen.show` has one call site |
| 2 | **Schema v2.** Add `settings.haptics` and `attempts.weight`; generate the migration; `AttemptDao.strike` and `tried` write the task's weight (D12). Keep the committed `app/drift_schemas/hearthrise/drift_schema_v1.json` unchanged; it is the upgrade fixture. | Migration test using the generated `SchemaVerifier` (`test/drift/hearthrise/generated`): open a **v1** database seeded with a boss, phases, tasks, attempts with a lesson, and a settings row with `tapMode = true`; migrate to v2; assert every seeded row is unchanged, `tapMode` is still true, `haptics` reads true, and seeded attempts have a null `weight`. Also the generated v2 schema-shape check. DAO tests: new database defaults haptics to true and `setHaptics(false)` persists; a strike and a tried record the task's weight; changing the task's weight afterward, or deleting the task, leaves the stored attempt weight as it was; a fall stores null. | Upgrade test passes against the v1 snapshot; `git diff` shows the v1 snapshot untouched; `drift_schemas/` has v2 |
| 3 | **Haptics switch** in the settings sheet, read by the `Haptics` lookup (D10). | Widget test: switch shows on by default; toggling off stores false; a strike with haptics off sends no haptic. Mid-hold test (D10): start a Boss-tier hold, switch haptics off through the settings database or notifier halfway (the `Haptics` object already exists), finish the hold: no tick or landing haptic is sent after the switch. | Switch works end to end and takes effect at once |
| 4 | **Haptic profile by weight** (section 5). | One test per table row: tick counts, medium pulse, landing impact, boss-tier double pulse, early release sends no landing haptic, tap mode sends the landing haptic only. Durations come from the constants (D7). | Profile matches the table |
| 5 | **Scroll-safe hold.** Cancel the hold when the pointer moves past touch slop. | Run against a **real scrolling list** (a `ListView` of `HoldToStrike` rows, and once more through `TodayView`), not a lone widget, so scroll and hold recognition interact for real: press a row, drag the list 30 px or more, keep the pointer down past the hold duration, release: no strike, progress rolled back, list scrolled. Pressing without moving still strikes. If the drag test passes before any change, the bug is not real: record that and drop the code change. | A scrolling finger cannot strike |
| 6 | **Strike sweep** (stateless `ui/strike_sweep_view.dart` painted from a progress value; the controller lives in `features/strike/strike_sweep.dart`): an ember line sweeps across the row on landing; Boss-tier sweeps longer and brighter. | Sweep appears on strike and is gone after its duration; Boss-tier duration is longer than Heavy's; reduced motion shows no sweep; tap mode also sweeps; the done row's opacity is 0.35 (regression test for the existing dim). | Sweep visible on strike, gone afterward |
| 7 | **Health bar test.** No new code expected. | Widget test: striking a segment task animates that segment from full to empty over `Motion.drain`; reduced motion makes it instant; daily tasks do not change the bar (D1 of Stage 1). | Drain behavior locked by tests |
| 8 | **Fallen feel tests.** No new code expected. | The screen shows "Fallen." and "Rest, then rise."; one heavy haptic on open through the real `BossScreen._fall()` path; none with haptics off in that same path; Skip pops null; Rise pops the trimmed text; reduced motion opens instantly. | Fallen behavior locked by tests |
| 9 | **Feel report** (`feel_report.dart`, `AttemptDao.feelReportData()`) and a "Copy feel report" row in the settings sheet. | DAO: `feelReportData()` returns outcome, weight and lesson presence per attempt, the earliest boss `createdAt`, and settings; it never returns titles or lesson text. Unit (`buildFeelReport`, fixed `now`): counts of strikes by weight plus "weight unknown", tried, falls, lessons written vs skipped; period start (earliest surviving boss) and end (`now`) dates (D9); deleting the earliest boss moves the start to the next boss's date; no bosses gives "no bosses yet" and zeros; `kAppVersion` matches `pubspec.yaml`; empty database gives zeros; output contains no boss, task or lesson text (insert known strings and assert they are absent). Widget: tapping the row puts the report on the mocked clipboard and shows a quiet confirmation. | Report copies; nothing personal in it |
| 10 | **Tester build.** Install the Android SDK; first build a **Stage 1 APK** from commit `1f83a90`; then bump to `0.2.0+2` and build the Stage 2 release APK. Both must be signed with the same key. `android/app/build.gradle.kts` currently signs release with the debug key, which is acceptable for sideloading only if every tester APK is built on this Mac (the debug key is per machine; a different key forces uninstall, which deletes data). Record that in the feedback file. | Full suite green on the release commit. Install checks on at least one real phone: (a) the Stage 2 APK installs fresh; (b) with the Stage 1 APK installed and a boss with a lesson saved, installing the Stage 2 APK over it (`adb install -r`) keeps the boss and lesson, and the haptics setting reads on. | Both install checks pass |
| 11 | **Developer pass** on a real phone (section 9). | Manual checklist. | Every box ticked, or a fix made first |
| 12 | **Test round** with 3 to 5 testers for at least 3 days (section 9). | Collect answers and feel reports. | Feedback logged in `STAGE2_FEEDBACK.md` |
| 13 | **Tuning** (section 8). | For each change: a failing test when behavior changes, or a constant edit that keeps tests green (D7). | Each finding is fixed, parked with a reason, or rejected with a reason |
| 14 | **Re-check.** If tuning changed the hold or haptics, send the final build to **all** testers and collect questions 1 and 7 again (gate item 1); if the fallen screen changed, collect question 2 again from all testers, who must each declare one more failed attempt to see it (gate item 2); if anyone reported feeling worse, also repeat question 5 with everyone (gate item 3). If nothing changed, say so in the feedback file and the round's answers stand. Update DESIGN.md (Haptics) and §8.3 to match the final haptic profile (D8). Update `CHECKLIST.md`. | Full suite green. | **Gate passed** |

---

## 8. Tuning rules

Decide from the feedback, in this order, and only as far as needed:

**If the hold is annoying (§7.5):**
1. Shorten the durations (Light 0.2 s, Heavy 0.45 s, Boss-tier 0.9 s are the first candidates).
2. Make the hold apply to Heavy and Boss-tier only; Light becomes a tap. This is a behavior change, so it starts with a failing test.
3. Make tap mode the default for new installs, with the hold as an opt-in.

**If the hold feels like lag:** make the fill and haptic build-up start sooner or stronger before touching durations.

**If the fallen screen feels discouraging:** change copy, then the dim level, then the lesson prompt. Never add red, a counter, or a loss message (DESIGN.md).

**If the attempt line reads as a record of failure:** try wording first. The "Last time:" part carries the lesson, so keep it prominent.

Cutting a feature needs a reason written in the feedback file.

---

## 9. Manual checks and tester protocol

### 9.1 Developer pass (real phone, release build)

- Hold feels right for each weight; haptics build and land as in section 5.
- Haptics switch turns every haptic off, including the fallen pulse.
- Tap mode works.
- Slowly scrolling the Today list never strikes a task.
- Sweep is visible but brief; reduced motion (system setting) removes it and the fades.
- 200% text size: boss screen, fallen screen, settings sheet (carried over from Stage 1).
- Fallen screen: dim reads as quiet, not alarming; the lesson field is easy to reach with the keyboard open.
- Run on two phones if possible; vibration motors differ a lot between devices.

### 9.2 Tester round

- Recruit 3 to 5 people who play Souls games. The Stage 0 recruitment list has not been started yet (`CHECKLIST.md`), so this is the first thing to do.
- Give each tester the APK and a one-page script: create one real boss with 4 to 6 tasks (do not delete bosses during the round); use it for 3 days; declare one failed attempt on purpose on day 2 or 3; send a feel report at the end of day 1, and another report plus your answers at the end. Install on a fresh phone or after uninstalling any development build (D9).
- Ask directly (from §12):
  1. Did the hold feel satisfying or annoying? Did you turn on tap mode, and why?
  2. Did the fallen screen feel supportive or discouraging?
  3. Did the attempt counter read as pride or as a record of failure?
  4. Did you open the app the day after falling?
  5. Did the app ever make you feel worse?
  6. Did you ever strike something by accident?
  7. Did the haptics feel right for each task weight, or too much, too little, or annoying? (This tests the experiments in section 5.)
- Signals from the feel report (§12): Tried vs Strike, lessons written vs skipped, tap mode on or off.
- Keep answers in `STAGE2_FEEDBACK.md`, one section per tester, quotes kept short.

---

## 10. Risks

| Risk | Mitigation |
|---|---|
| No Android SDK on the dev Mac | Install it in step 10; if blocked, TestFlight for iPhone testers (D1) |
| Tester recruitment not started | Start before step 10; the round cannot begin without people |
| Haptics differ by phone, so the feel passes on one device and fails on another | Developer pass on two phones; ask testers for their phone model |
| Sweep or haptics feel gimmicky | Both are off-switchable (D5); cut if testers dislike them (section 8) |
| A silent tester says nothing | Ask each tester the questions directly; the feel report shows whether they used the app |
| Scope creep into Stage 3 (embers, sounds, home atmosphere) | Section 3 lists what waits |
| Debug-key signing breaks updates if built on another machine, and is never valid for Play | Build every tester APK on the same Mac; create a real keystore before Stage 6 |
| Feel report covers the wrong period | D9: fresh installs, whole-period totals, period dates printed, a day-1 report and an end report |
| Tuning that fixes one tester and breaks another | Change one thing at a time; re-check with the tester who raised it |
