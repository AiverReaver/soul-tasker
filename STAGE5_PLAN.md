# Stage 5 Plan: Victory, Relics, Onboarding (MVP complete)

Source: `STAGES.md` (Stage 5) and `souls-task-tracker-design.md` (§ numbers below refer to it). Visual rules: `DESIGN.md`.
Method: TDD (see `STAGES.md`, Development method). Every step below lists its tests first, then the code. UI follows `STAGES.md`, "UI components": new widgets go in `lib/ui/` as `StatelessWidget`s, with state in thin containers in `lib/features/`.
Status: not started. Branch `stage-5-victory` from `stage-4-commitments` (or `main` once Stage 4 merges).

Prerequisites:
- Steps 1 to 8 and 10 do not depend on open gates and can start now.
- Step 9 (sound) needs the licensed sounds from Stage 0 (`CHECKLIST.md`, "Choose licensed sounds", still open). If they are not chosen when step 9 comes up, skip it and come back; nothing else depends on it.
- Steps 12 and 13 need a phone with the Android SDK (same blocker as Stages 3 and 4), and step 13 waits for the Stage 3 and Stage 4 gates.

---

## 1. Goal and gate

**Goal:** finish the MVP list in §11.1. Defeating a boss ends in a restrained victory screen and leaves a permanent relic. A new user is fighting their first boss in under two minutes.

**Gate:** every item in §11.1 works end to end on a small and a large Android screen. All of these are true:
1. Scripted (step 11): a new install goes through onboarding to a saved boss with phases and daily foes, fights it, falls twice with lessons, then drains the last segment. The victory screen shows 3 attempts, the days spent, the effort, and both lessons in order. The relic exists with its own snapshot.
2. After the boss is edited, renamed and then deleted, the relic is unchanged and still opens with its full story. Only its inscription can change.
3. The profile shows banked embers, level, flasks and planning accuracy, and the hall lists relics most recent first, with the empty line when there are none.
4. Every Stage 1 to 4 gate test still passes (`gate_test.dart`, `gate_stage3_test.dart`, `gate_stage4_test.dart`).
5. The new screens render without overflow at 320 x 568 and 412 x 915 logical pixels, and at 200% text on the small size (widget tests, step 10).
6. `flutter analyze` is clean and the full suite passes.
7. Manual checks in step 12 pass on a small and a large Android phone.

---

## 2. Where Stage 4 left us

| Piece | Where | Stage 5 use |
|---|---|---|
| Defeat prompt and "Declare victory", both via `confirmDefeat` then `BossDao.setStatus(defeated)` | `features/boss/task_row.dart`, `features/boss/boss_screen.dart` | One path into victory: create the relic in the same transaction, then open the victory screen |
| `setStatus(defeated)` stamps `defeatedAt` and cancels open commitments | `data/boss_dao.dart` | Also writes the relic; defeat becomes final (D2) |
| Boss menu already hides status changes on a defeated boss | `features/boss/boss_screen.dart` | Defeat stays one-way |
| Attempts keep their lesson, cause and day; resets never delete events | `data/tables.dart`, `data/attempt_dao.dart` | Lesson snapshot for the relic |
| `EmberEvents.bossId` on every earn | `data/ember_dao.dart` | Total effort per boss; lifetime banked for the level |
| `CommitmentDao.record(day)` and `week(today)`, `AccuracyLine` | `data/commitment_dao.dart`, `ui/accuracy_line.dart` | Planning accuracy on the profile |
| "Vanquished" section on Home | `features/home/home_screen.dart` | Replaced by the hall of relics (Stage 1 plan, home notes) |
| `BossDraft.fresh` with two suggested phases (§6.2) | `data/boss_draft.dart` | Onboarding builds a draft and saves it with `BossDao.saveBoss` |
| Reminder invite and permission flow | `ui/reminder_invite.dart`, `features/ritual/reminder_coordinator.dart` | Onboarding's reminder step |
| `Haptics.doubleHeavy` | `core/haptics.dart` | Victory pulse (§8.3 "slow double pulse") |
| "Foe vanquished." flash line | `features/boss/task_row.dart` | Moves to the victory screen headline |
| Schema v4 with step migrations and dumps in `test/drift/` | `data/database.dart` | Schema v5 (step 1) |

---

## 3. Scope

### In Stage 5

| Item | Design ref |
|---|---|
| Victory screen: one line, attempts, days, effort, lesson notes, relic reveal, final inscription | §5.11 |
| Relic created on defeat with its own snapshot of the boss story | §5.14, §9.2 |
| Emblem with weathering levels by attempts | §5.14 |
| Final inscription, editable later | §5.14 |
| Hall of relics on the profile, most recent first, with empty state; relic detail with lesson timeline | §5.14 |
| Profile: banked embers, single level, flasks, planning accuracy | §5.9, §6.1 |
| Onboarding under two minutes | §6.2 |
| Sound setting (off by default) and three cues: victory tone, fallen thud, bonfire hum | §8.2 |

### Not in Stage 5 (and where it lands)

| Item | Stage |
|---|---|
| Spending embers on named stats (Discipline, Focus, Resilience) | Later. §5.9: "a single level is enough to start" (D9) |
| Hardcore mode choice in onboarding | 8. Onboarding shows gentle mode as a fact, not a choice (D11) |
| Adjustable maximum health | Not planned unless Stage 6 testers ask (Stage 4 plan section 8) |
| Data export | Stage 7 (with sync) or later |
| Sound beyond the three cues (hold tone, strike sound) | §11.2 "sound design beyond a few basics" is out of the MVP |
| Stage 4 known limit: "in N min" chip refresh | Not in scope |

---

## 4. Decisions in this plan (confirm or change)

| # | Question | Decision | Why |
|---|---|---|---|
| D1 | Where does a relic live? | A new **`Relics`** table, one row per defeated boss. Numbers as columns; the story (title, defeat meaning, phase names, lessons) as one **JSON text column `story`**, decoded into an immutable `RelicStory`. `bossId` nullable, unique, `set null` on delete. | §5.14 "keeps its own copy". JSON keeps the snapshot as one record, so later boss edits cannot touch it and Stage 7 syncs it as one row. No child tables for data that never changes. |
| D2 | Can a defeat be undone? | **No.** Defeat is final: the relic is written in the same transaction as `setStatus(defeated)`, and no screen offers a way back (the menu already hides it). `setStatus` refuses to move a defeated boss. | §9.2 "exactly one relic" and "relics are permanent". An undo would leave an orphan relic or delete a permanent record. The existing confirm dialog is the safety net. |
| D3 | Relic numbers | **Attempts** = `boss.attemptNumber` at defeat (the attempt that won). **Days** = ritual days from the boss's creation day to the defeat day, inclusive (`dayOf` with the rollover hour), minimum 1. **Effort** = sum of `earn` ember events on the boss. **Phases** = phase names in order at defeat. | §5.11 "attempts taken, days spent, total effort". Ritual days match how every other day is counted. |
| D4 | Which lessons go in the snapshot? | Every non-empty attempt lesson on the boss, in time order, with its attempt number and cause. A shared missed-day lesson appears on every boss it was written for. Bonfire lessons (`DayLogs`) are not boss-specific and are left out. | §5.14 "every lesson note the user wrote along the way". |
| D5 | Emblem weathering | Four levels by attempts, stored on the relic at creation: **1** unmarked, **2-3** worn, **4-8** scarred, **9+** weathered. Drawn by one `CustomPainter` (original abstract shape, more marks per level). No image assets. Copy never ranks levels. | §5.14 "a handful of weathering levels", "a first-try win is never shown as better". Storing it keeps old relics stable if thresholds are tuned. |
| D6 | Victory flow | Both entry points (auto prompt, "Declare victory") confirm, defeat, then push **`/victory/:relicId`**. One scrolling screen with slow fades in order: "Foe vanquished." then the three numbers, then the lessons, then "A relic remains." with the emblem and name ("Relic of <boss title>"), then the inscription field "What did this fight make of you?" (optional, max 120 characters) and "Done". Victory haptic `doubleHeavy`; victory tone if sound is on. Back and "Done" both go home; the inscription is saved on either. | §5.11 order. One screen, no extra route steps. |
| D7 | Inscription | The only mutable field on a relic. Editable from the relic detail. Empty saves as null. `updatedAt` stamped. | §5.14 "can be edited later". |
| D8 | Defeated bosses on Home | The "Vanquished" section leaves Home. Defeated bosses are reached through their relic. Deleting a defeated boss is still allowed and keeps the relic. | Stage 1 plan: "Stage 5 replaces it with the hall of relics". |
| D9 | Level | One level derived from **lifetime banked embers** (sum of `bank` events); nothing is spent. Level 1 at 0; each next level needs 10 more than the last (10, 30, 60, 100, ...). Pure `levelFor(banked)` in `core/`, with the embers to the next level. | §5.9 "a single level is enough". Deriving it needs no new table and can never go down, matching "spent embers are permanent". |
| D10 | Profile | Route **`/profile`**, opened from a Home app bar icon. Sections: level and progress to next, banked embers, flasks (`FlaskPips`), planning accuracy (`AccuracyLine` for today and the week), then the hall. | §6.1 "profile and stats". Reuses Stage 3 and 4 widgets. |
| D11 | Onboarding | Shown on start when **`Settings.onboarded` is false**. The v5 upgrade sets it true for existing installs. One route **`/welcome`**, a `PageView` of five pages: (1) "Failing is fine. Quitting isn't." (2) boss title and what defeat means; (3) phases, prefilled with the two `BossDraft.fresh` suggestions, editable, up to three; (4) up to three daily foes (title only, Light by default, standalone daily tasks); (5) "Gentle mode: nothing is lost but health." as a line, plus the bonfire reminder time with the Stage 3 permission flow. "Begin" saves through `BossDao.saveBoss` and sets `onboarded`. "Skip" on any page sets `onboarded` and goes to the empty Home. Required: a boss title only. | §6.2 steps. Hardcore does not exist until Stage 8, so a choice would be a dead option. Reusing `BossDraft` and `saveBoss` means no new save path. |
| D12 | Sound | `Sounds` interface in `core/` (like `Haptics` and `Reminders`), a fake in `test/support/`, and a real implementation on an audio package chosen in step 9 (check docs and version before coding; one dependency, short clips plus one loop). **`Settings.sound`**, default **false**. Cues: victory tone (victory screen), fallen thud (fallen screen), bonfire hum (loops while the bonfire screen is visible, stops on leave and on background). Licenses in `assets/sounds/LICENSES.md`. | §8.2 "optional, off by default", three cues. Same pattern as haptics keeps it testable. |
| D13 | Small and large screens | Widget tests for each new screen at 320 x 568 and 412 x 915, plus 200% text on the small size, fail on any overflow. Real phones in step 12. | Gate names both sizes; tests catch layout breaks early. |

---

## 5. Data model: schema v5

One migration (`from4To5`). Dump the schema and generate the step helpers, as for v4.

**New table**

| Table | Columns | Notes |
|---|---|---|
| `Relics` | `id` text, `bossId` text nullable unique (set null on delete), `name` text, `emblem` int (`Weathering`), `attempts` int, `days` int, `effort` int, `story` text (JSON), `inscription` text nullable (max 120), `defeatedDay` text, `createdAt` datetime, `updatedAt` datetime | Written once at defeat; only `inscription` and `updatedAt` change. |

**Columns added**

| Table | Column | Type and default |
|---|---|---|
| `Settings` | `sound` | bool, default false (D12) |
| `Settings` | `onboarded` | bool, default false; the v5 upgrade sets it true (D11) |

**Backfill:** the v5 upgrade creates a relic for every boss already `defeated`, from its current data (its story may already have been edited; that is the best record left). Inscription null.

**`enums.dart`** (append only): `Weathering { unmarked, worn, scarred, weathered }` with `Weathering.forAttempts(int)`.

**Constants:** `kInscriptionMax = 120`, the weathering thresholds (1, 3, 8), `kLevelStep = 10`.

---

## 6. Build order

Each step: tests first (red), then code (green), then refactor. One commit per step. A step is done when `flutter analyze` is clean and the full suite passes (run from `app/`).

### Step 1: Schema v5

**Tests first**
- `test/drift/hearthrise/migration_v5_test.dart`: a v4 database upgrades to v5 with bosses, attempts, commitments, health and ember events intact; `Relics` exists; `sound` is false; `onboarded` is true; each already-defeated boss gets exactly one relic with its attempts, effort and lessons; a fresh `onCreate` database has `onboarded` false.
- `test/data/enums_test.dart` (added): `Weathering.forAttempts` gives unmarked for 1, worn for 2 and 3, scarred for 4 and 8, weathered for 9 and 40; indexes of existing enum values are unchanged.

**Code:** `Relics` table, settings columns, `Weathering`, schema dump, `from4To5` with the backfill (calls the same snapshot builder as step 2, so there is one way to build a relic).

**Done when:** both test files pass, and the v1 to v4 migration tests still pass.

### Step 2: Relic snapshot and creation

**Tests first** `test/data/relic_dao_test.dart` (in-memory Drift, fixed clock):
- defeating a boss writes one relic in the same transaction: name "Relic of <title>", attempts, days, effort, emblem, phases in order, lessons in time order with attempt number and cause (D3, D4);
- days: created and defeated on the same ritual day is 1; across the rollover hour counts by ritual day;
- effort counts only `earn` events on this boss, not banks and not other bosses;
- empty and null lessons are left out; a missed-day lesson appears on each boss it was written for;
- defeating twice does not write a second relic; `setStatus` refuses to move a defeated boss (D2);
- editing the boss title, phases and tasks, then deleting the boss, leaves the relic and its story unchanged; `bossId` becomes null;
- `setInscription(id, text)` saves, trims, stores empty as null, refuses over 120 characters, stamps `updatedAt`; no other field changes (D7);
- `watchAll()` lists relics most recent first; `load(id)` returns one with its decoded `RelicStory`.
- `test/data/relic_story_test.dart`: `RelicStory` JSON round-trips; decoding bad JSON fails with a clear error, not a crash in the UI layer.

**Code:** `data/relic_story.dart` (immutable, `toJson` / `fromJson`), `data/relic_dao.dart` (`createFor(bossId)` used inside `setStatus`, `setInscription`, `watchAll`, `load`), provider; `BossDao.setStatus(defeated)` calls `createFor` in its transaction.

**Done when:** both test files pass and `boss_dao_test.dart` still passes.

### Step 3: Level and profile data

**Tests first**
- `test/core/level_test.dart`: `levelFor(0)` is 1 with 10 to next; 10 is level 2; 29 is level 2 with 1 to next; 30 is level 3; 100 is level 5; never below 1 (D9).
- `test/data/profile_dao_test.dart`: lifetime banked sums `bank` events only; spending a flask or resting does not lower it; `watchProfile()` emits banked, level, flasks, today's record and the week, and updates after a bank and after a flask is spent.

**Code:** `core/level.dart`, `data/profile_dao.dart` (or a method group on `EmberDao` if it stays small), provider.

**Done when:** both test files pass.

### Step 4: UI widgets

All `StatelessWidget`s in `lib/ui/`, each with its widget test written first in `test/ui/`.

| Widget | Renders | Test |
|---|---|---|
| `RelicEmblem` | the emblem for a `Weathering` value, sized by a parameter, with a semantic label ("A worn emblem") | each level paints and has its label; no level uses red or a rank word |
| `VictoryNumbers` | "3 attempts", "12 days", "48 embers of effort" | singular and plural copy; 1 attempt reads "1 attempt", never "first try" |
| `LessonTimeline` | lessons in order: "Attempt 2. Rushed the second phase." with a quiet cause marker for missed days | renders rows from values; empty list shows nothing |
| `InscriptionField` | prompt "What did this fight make of you?", 120-character limit, a save action | fires `onSaved(text)`; counter shows the limit |
| `RelicTile` | emblem, relic name, victory date | fires `onTap` |
| `HallOfRelics` | a list of `RelicTile`s, or "No foes vanquished yet. The first relic awaits." | empty and filled states |
| `LevelLine` | "Level 4", and "12 embers to the next" | values in |
| `OnboardingPage` | one onboarding page: a line, a body slot, "Next" or "Begin", and "Skip" | fires both callbacks; "Begin" disabled when told |

**Done when:** the eight widget tests pass.

### Step 5: Victory screen

**Tests first** `test/features/victory_test.dart` (widget, fake clock, in-memory Drift):
- draining the last segment and confirming opens the victory screen; so does "Declare victory" from the menu (D6);
- declining the confirm leaves the boss active and writes no relic;
- the screen shows "Foe vanquished.", the three numbers, the lessons in order, "A relic remains.", the emblem and the relic name;
- typing an inscription and tapping Done saves it and returns home; back also saves it;
- the victory haptic fires once (`RecordingHaptics`), and none with haptics off;
- the defeated boss is gone from Home and from Today (D8).
- `screens_test.dart` still passes; the "Foe vanquished." flash line test moves here.

**Code:** `features/victory/victory_screen.dart` (thin container, staged fades), `/victory/:relicId` route, `confirmDefeat` pushes the route, Home drops the "Vanquished" section.

**Done when:** `victory_test.dart` and `screens_test.dart` pass.

### Step 6: Profile and hall of relics

**Tests first** `test/features/profile_test.dart`:
- the Home app bar opens `/profile`;
- the profile shows level, banked embers, flasks and the accuracy line from the day's data;
- with no relics, the hall shows the empty line; with two, the newer is first;
- tapping a relic opens its detail: numbers, inscription, lesson timeline, and the line "<N> attempts. Every one of them counted." (one attempt: "One attempt. It counted.");
- editing the inscription on the detail saves it; the hall and detail update;
- a relic whose boss was deleted still opens with its full story.

**Code:** `features/profile/profile_screen.dart`, `features/profile/relic_screen.dart`, routes `/profile` and `/relic/:id`, Home app bar action.

**Done when:** `profile_test.dart` passes.

### Step 7: Onboarding

**Tests first** `test/features/onboarding_test.dart`:
- a fresh database (`onboarded` false) opens `/welcome`, not Home; an upgraded one opens Home (D11);
- page 1 shows "Failing is fine. Quitting isn't.";
- "Begin" is disabled until the boss has a title;
- phases start with the two suggestions; one can be renamed, one added (max three), one removed;
- up to three daily foes; blank ones are dropped;
- the last page shows the gentle line and the reminder time; turning the reminder on uses the Stage 3 permission flow (fake `Reminders`), and a denied permission still finishes onboarding;
- "Begin" saves one boss with its phases and daily tasks (Light, daily, standalone), sets `onboarded`, and lands on Home with the boss card and its foes on Today;
- "Skip" on any page sets `onboarded` and lands on the empty Home; the next start does not show onboarding again;
- the whole happy path takes at most 12 taps and text entries (a proxy for "under two minutes"; the real timing is a manual check).

**Code:** `features/onboarding/onboarding_flow.dart` (thin container holding a `BossDraft` and the page index), `/welcome` route, the start redirect in `buildRouter`, `SettingsDao.setOnboarded`.

**Done when:** `onboarding_test.dart` passes and `screens_test.dart` still passes (its harness marks itself onboarded).

### Step 8: Sound plumbing (no audio files yet)

**Tests first**
- `test/core/sounds_test.dart`: with sound off, no cue reaches the player; with sound on, each cue reaches it once; the hum starts and stops; an error from the player is logged and swallowed, never shown and never blocks a screen.
- `test/features/sound_cues_test.dart` (fake `Sounds`, sound stored as on): victory plays the tone, the fallen screen plays the thud, the bonfire screen starts the hum and stops it on leave and when the app goes to the background; with sound off, nothing plays.

**Code:** `core/sounds.dart` (`Sounds` interface plus a gate on `Settings.sound`), a silent default implementation, `test/support/fake_sounds.dart`, provider, `SettingsDao.setSound`, calls from the three screens. No Settings row yet: a switch with no audio behind it would mislead (Stage 3 plan).

**Done when:** both test files pass.

### Step 9: Real audio (needs the licensed sounds)

**Before coding:** pick the three clips (Stage 0 item), record source and license in `assets/sounds/LICENSES.md`, and tick "Choose licensed sounds" in `CHECKLIST.md`. Choose one audio package and check its current docs and version for a one-shot and a loop on Android.

**Tests first**
- `test/core/audio_sounds_test.dart`: the implementation maps each cue to its asset path, and every asset path listed exists in `pubspec.yaml` (an asset-list test, so a missing file fails in CI, not on a phone).
- `test/features/sound_switch_test.dart`: Settings shows "Sound", off by default; turning it on is stored and the next cue plays.

**Code:** the package, `core/audio_sounds.dart`, assets in `pubspec.yaml`, wired in `main.dart`, the Settings row (reuse `SettingSwitchRow`).

**Done when:** the test passes; the sound itself is a manual check in step 12.

### Step 10: Screen sizes

**Tests first** `test/features/screen_sizes_test.dart`: victory, relic detail, profile (empty and with relics) and each onboarding page render at 320 x 568 and 412 x 915 with no overflow exceptions, and at 200% text on 320 x 568 (D13). Add any Stage 3 and 4 screen that fails the same check (bonfire, commit sheet, away summary) to the same file.

**Code:** layout fixes only, inside the `lib/ui/` widgets.

**Done when:** `screen_sizes_test.dart` passes.

### Step 11: Scripted gate test

**Tests first** (this step is the test): `test/gate_stage5_test.dart`. One scripted run with an advancing fake clock and an in-memory database, through the widgets where practical.

1. **Install, day 1:** the app opens onboarding. Name the boss, keep two suggested phases, add one task to each phase (Heavy), add two daily foes, turn the reminder on, Begin. Home shows the boss; Today shows the two daily foes.
2. **Day 1:** strike one daily foe (earns embers), then declare a failed attempt with the lesson "Started too late." Attempt 2.
3. **Day 2:** rest at the bonfire (banks embers); the profile shows the level and banked embers from that bank.
4. **Day 3:** fall again with "Skipped the warm-up." Attempt 3.
5. **Day 3:** strike both phase tasks. The last segment drains; confirm.
6. Assert the victory screen: 3 attempts, 3 days, effort equals the sum of embers earned on this boss, both lessons in order, emblem `worn`. Write the inscription "Patience." and tap Done.
7. Rename the boss, edit a phase, then delete the boss. Assert the relic's name, numbers, phases and lessons are unchanged and the inscription is "Patience.".
8. Open the profile: the hall shows one relic; its detail shows the timeline. Edit the inscription; assert only it and `updatedAt` changed.

**Code:** none expected. If the test finds a hole, fix it with its own failing test first.

**Done when:** `gate_stage5_test.dart` passes with the full suite, including the Stage 1 to 4 gate tests.

### Step 12: Manual checks on devices

Cannot be automated. Needs the Android SDK and two phones (or emulators): one small (about 5 inches, 360 dp wide or less) and one large (6.5 inches or more). Write results into this section.

| Check | Pass condition |
|---|---|
| Onboarding time | Two people who have not seen the app finish onboarding in under two minutes (timed). |
| Victory feel | Restrained and earned, not a celebration. The lesson list reads as the real story. |
| Emblem | The four levels look different, and a weathered emblem looks more earned, not damaged. |
| Hall on a hard day | Opening a relic after a fall reads as encouragement. |
| Sound | Off on first launch. When on: tones are quiet, the hum stops on leaving the bonfire and with the screen off, and the system volume and silent mode are respected. |
| Haptics | Victory double pulse is felt; nothing with haptics off. |
| Text size | Victory, profile, relic detail and onboarding read correctly at 200% text on the small phone. |
| Screen sizes | Every §11.1 item works on both phones. |
| Airplane mode | The whole flow works with no network. |

### Step 13: The gate run

After the Stage 3 and Stage 4 gates close: walk §11.1 items 1 to 8 on both phones, then use the app for a few normal days until one real boss is defeated. Log every bug; fix each one test-first. The gate closes when section 1 holds. Then tick `CHECKLIST.md`, mark Stage 5 done in `STAGES.md`, and update this file's status.

---

## 7. Risks

| Risk | Handling |
|---|---|
| A relic misses data because the boss was edited before defeat | The snapshot uses attempts and ember events, which are append-only. Only titles and phase names are as of the defeat, which is what §5.14 asks for. |
| Accidental defeat cannot be undone (D2) | The confirm dialog stays. If testers hit this, add an undo within the victory screen itself in Stage 6, before the relic is shown. |
| The victory screen feels like a reward chart | One headline, no confetti, slow fades only, no ranking copy (DESIGN.md). Manual check in step 12. |
| Onboarding takes longer than two minutes | Only the boss title is required; Skip is on every page. Timed manual check. |
| Audio package or clip licensing slips | Steps 8 and 9 are split: the plumbing is tested with a fake, and the switch appears only in step 9 with real clips, so step 9 waits without blocking the rest. |
| Schema v5 breaks tester installs | Migration test from a v4 database, including the relic backfill, in step 1. |

---

## 8. Differences from `STAGES.md`

- The level is derived from lifetime banked embers; no stats are spent (D9).
- Onboarding shows gentle mode as a line, not a choice, until hardcore exists in Stage 8 (D11).
- Defeat is final (D2), so a relic is never orphaned.
