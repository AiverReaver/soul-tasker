# Stage 1 Plan: Core Loop, Local Only

Source: `STAGES.md` (Stage 1) and `souls-task-tracker-design.md` (§ numbers below refer to it).
Status: implemented 2026-10-13. Open items: 200% text check, Android device run.
Method: TDD (see `STAGES.md`, Development method). Stage 1 was built before this rule was adopted; its tests in section 10 are the backfill. Rework and later stages are test-first.

---

## 1. Goal and gate

**Goal:** fight a boss, fail, learn, try again. Fully offline.

**Gate:** with the phone in airplane mode, the user can
1. create a boss with phases and tasks,
2. strike some tasks,
3. declare a failed attempt and write a lesson,
4. close and reopen the app,
5. see "Attempt 2. Last time: <lesson>" on the boss screen, with progress handled by the boss's reset setting.

The gate is also covered by an automated test (section 10.3).

---

## 2. Scope

### In Stage 1

| Item | Design ref |
|---|---|
| Move the Stage 2 feel prototype into the new structure; replace in-memory models with Drift | STAGES.md |
| Bosses: unlimited, create, edit, active / waiting / defeated, focus pin | §5.1 |
| Per-boss reset on a failed attempt: nothing (default) / current phase / whole boss | §5.1 |
| Phases: create, rename, delete, reorder | §5.2 |
| Tasks: Light / Heavy / Boss-tier, one-time or daily, create, edit, delete | §5.3 |
| Strike (hold, or tap in tap mode) and Tried | §5.3, §7 |
| Attempts: declared failure raises the boss counter | §5.4 |
| Fallen flow with lesson note | §5.5 |
| "Attempt N. Last time: ..." line | §5.4 |
| Rule of three prompt (task and phase) | §5.10 |
| Home: boss cards, pinned first, waiting collapsed | §6.1 |
| Today view grouped by boss, with a boss filter | §6.1 |
| Reduced-motion support, 48 dp touch targets, 200% text check | DESIGN.md |

### Not in Stage 1 (and where it lands)

| Item | Stage |
|---|---|
| Bonfire, embers, flasks, light days, notifications, full Settings screen, user-set rollover time | 3 |
| Missed-day attempt trigger | 3 |
| Commitments, deadlines, health, health-death trigger, rest after a fall | 4 |
| Victory screen, relics, profile, onboarding | 5 |
| Sync fields beyond `id` and `updatedAt`, soft delete, sign-in | 7 |
| Bloodstains, hardcore mode | 8 |

Stage 1 leaves room for the later triggers: the `attempts.cause` column already has `healthDeath` and `missedDay` values, but only `declared` is written.

---

## 3. Decisions in this plan (confirm or change)

The design document leaves these open. Each has a default so work can start.

| # | Decision | Default in this plan | Why |
|---|---|---|---|
| D1 | Do recurring (daily) tasks damage the boss health bar? (open question 6) | **No.** Daily tasks are the boss's "daily foes": they appear in Today and on the boss screen and can be struck or tried each day, but only one-time tasks are health-bar segments. | A health bar that refills every day never shows progress. A boss made only of daily tasks shows "This foe is worn down by habit." in place of the bar. |
| D2 | What does "Strike" mean for a daily task? | Struck **for today** (see D5). Tomorrow it is open again. | Matches §5.12: recurring tasks create a fresh commitment each day. |
| D3 | When is a boss defeated in Stage 1? | **Automatic prompt:** when the health bar reaches zero (the boss has at least one segment and every segment is drained), the app shows "Foe vanquished." and asks "Mark this boss as defeated?". Yes sets status to defeated. No keeps it active. Daily and standalone tasks still open do not block the prompt. **Manual:** every active boss has "Declare victory" in its menu (with the same confirm), which is the only way to defeat a boss with no segments, such as a boss made only of daily tasks. A defeated boss's tasks leave Today. | The victory screen is Stage 5. Asking avoids an accidental defeat when the user still plans to add tasks. Habit bosses end when the user says the habit is won, not by a count. |
| D4 | Use `freezed` and `json_serializable` now? | **Not in Stage 1.** Drift already generates immutable row classes with `copyWith`. Add `freezed` when a sealed state type needs it; add JSON in Stage 7 for sync. | Less code generation, fewer dependencies. §10.1 lists them as suggestions. |
| D5 | Day boundary before Stage 3 adds the setting | Fixed rollover at **4 AM local time** in `core/clock.dart`. Stage 3 makes it a setting. | §5.6 default. Daily tasks and Today need "today" now. |
| D6 | Rule of three at phase level | A phase triggers the prompt when the boss fails **three attempts in a row with the same current phase**. | §5.10 says "task or phase" without defining a phase failure. Falling three times at the same stage is the closest match to "same path, same result". |
| D7 | Where the hold-to-tap toggle and default reset live before Stage 3 | A small **settings sheet** opened from home, with two rows: "Tap instead of hold" and "On a failed attempt, reset". Stage 3 replaces it with the full Settings screen. | Both are needed now; a full screen is Stage 3 scope. |
| D8 | Riverpod code generation | **Manual providers** (no `riverpod_generator`). | Few providers in Stage 1; one less generator. Revisit if providers grow past about 15. |
| D9 | Standalone tasks (no phase) and resets | A **whole boss** reset reopens standalone one-time tasks too. A **current phase** reset does not touch them. Standalone tasks are not health-bar segments. | Matches design §5.1: "Every task reopens" on a whole-boss reset. Standalone tasks belong to no phase, so a phase reset cannot apply to them. |
| D10 | What happens to history when a task or phase is deleted | Attempt rows are kept. Their `taskId` or `phaseId` is set to null by the database (`ON DELETE SET NULL`). `bossId` stays, so the boss's attempt history and lessons stay complete. Only deleting the whole boss removes its attempts. | Lessons and attempt counts are the story of the fight (§5.11, §5.14). A deleted task should not erase falls or lessons. |
| D11 | How the rule of three knows it has already prompted | No stored flag. The prompt shows when the count is a **non-zero multiple of 3**: tries since the task's last strike for a task, or the length of the current same-phase fall run for a phase. So it prompts at 3, 6, 9, and stays quiet at 4, 5, 7, 8. | Stateless and derived from the event history, so it survives restarts and Stage 7 sync with no extra column. |

---

## 4. Dependencies

Versions checked on pub.dev on 2026-10-13. Flutter 3.47.7 stable, Dart SDK `^3.13.5`.

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^3.4.3 | State management |
| `drift` | ^2.35.2 | Typed SQLite |
| `drift_flutter` | ^0.3.1 | Opens the database on device (handles native SQLite) |
| `go_router` | ^18.0.2 | Navigation |
| `uuid` | ^4.6.0 | Record ids, stable across devices for Stage 7 sync |
| `drift_dev` (dev) | ^2.35.1 | Drift code generation, schema dumps |
| `build_runner` (dev) | ^2.16.2 | Runs code generation |

Notes:
- `sqlite3_flutter_libs` is end-of-life. Do not add it; `drift_flutter` handles native SQLite.
- `path_provider` is not needed directly; `drift_flutter` finds the database folder.
- Read the go_router 18 and Riverpod 3 changelogs before step 4; both major lines have breaking changes.

---

## 5. Folder structure

Feature-based (§10.3). Files move from the flat `lib/` into:

```
lib/
  main.dart                     runApp(ProviderScope(child: HearthriseApp()))
  app.dart                      MaterialApp.router, theme, router
  core/
    theme.dart                  (moved, unchanged)
    router.dart                 go_router routes
    clock.dart                  clock provider, dayOf(), 4 AM rollover
    ids.dart                    newId() using uuid v4
  ui/                           stateless, reusable widgets (STAGES.md, "UI components")
    boss_health_bar.dart        takes alive flags per phase, not a BossView
    boss_card_tile.dart         presentation of a home boss card
    task_row_tile.dart          row visuals: fill, title, weight, sweep slot
    confirm_dialog.dart         calm yes/no dialog body
    flash_line.dart             the one quiet message line
    strike_sweep_view.dart      landing sweep drawn from a progress value
    ...                         new widgets are added here before a screen uses them
                                (still to extract: rule-of-three, task-edit and settings sheets, fallen screen body)
  data/
    database.dart               @DriftDatabase, schemaVersion, migrations
    tables.dart                 table classes
    boss_dao.dart               bosses, phases, tasks
    attempt_dao.dart            attempts, lessons, rule of three
    settings_dao.dart           single-row settings
    providers.dart              database, DAO, and stream providers
  features/
    home/
      home_screen.dart          Bosses / Today switch
      boss_card.dart
      settings_sheet.dart       (D7)
    today/
      today_view.dart
    boss/
      boss_screen.dart          (rebuilt on data)
      boss_health_bar.dart      (moved; takes segment data, not a Boss model)
      attempt_line.dart
      rule_of_three_sheet.dart
    boss_edit/
      boss_edit_screen.dart     create and edit, phases, reset setting
      task_edit_sheet.dart
    strike/
      hold_to_strike.dart       (moved; takes title, weight, isDone)
    fallen/
      fallen_screen.dart        (moved; unchanged behavior)
test/
  core/clock_test.dart
  data/                         DAO and rule tests (in-memory database)
  features/                     widget tests
  gate_test.dart                Stage 1 gate as a test
  feel_test.dart                (kept, imports updated)
drift_schemas/                  schema dumps per version (drift_dev)
```

`models.dart` is deleted once every screen reads from Drift.

**UI rule:** widgets under `ui/` are stateless and take values and callbacks only; `features/` screens and containers compose them (see `STAGES.md`, "UI components"). Where this tree lists a presentational widget under `features/`, it belongs in `ui/` instead. Stateful behavior such as `hold_to_strike.dart` stays in `features/` as a container that renders a stateless `ui/` widget. Each `ui/` widget has a widget test in `test/ui/`.

---

## 6. Data model (Drift)

A Stage 1 subset of §9. Every synced table has an `id` (text, uuid v4), so Stage 7 sync can be added without changing keys. The editable records (bosses, phases, tasks) also have `updatedAt`, which Stage 7 uses for last-write-wins. Attempts are append-only and never edited by the app, so their `at` time is enough and they have no `updatedAt`. Settings is a local single row (`id = 1`) with no `updatedAt` in Stage 1; Stage 7 decides whether settings sync. All times are stored in UTC. `day` columns hold the local day as `YYYY-MM-DD` text, computed with the 4 AM rollover.

### 6.1 Tables

**bosses**

| Column | Type | Notes |
|---|---|---|
| id | text PK | uuid |
| title | text | 1 to 80 characters |
| defeatMeaning | text, nullable | what "defeated" means (§5.1), up to 200 characters |
| status | int enum | active, waiting, defeated |
| attemptNumber | int | starts at 1 |
| resetOnFail | int enum | nothing, currentPhase, wholeBoss |
| isPinned | bool | default false |
| targetDate | date, nullable | |
| lastFoughtAt | datetime, nullable | set on any strike, tried, or fall; drives home order |
| createdAt, updatedAt | datetime | |
| defeatedAt | datetime, nullable | |
| openFromAttempt | int | default 1. The same rule as on phases, applied to standalone one-time tasks (D9). Raised only by a whole-boss reset. |

**phases**

| Column | Type | Notes |
|---|---|---|
| id | text PK | |
| bossId | text FK, cascade delete | |
| name | text | 1 to 60 characters |
| position | int | 0-based order |
| openFromAttempt | int | default 1. A strike counts for this phase only if it was made in this attempt number or later. Raised by resets (6.3). |
| createdAt, updatedAt | datetime | |

**tasks**

| Column | Type | Notes |
|---|---|---|
| id | text PK | |
| bossId | text FK, cascade delete | |
| phaseId | text FK, nullable, cascade delete | null = standalone task under the boss (§5.3) |
| title | text | 1 to 80 characters |
| weight | int enum | light, heavy, bossTier |
| recurrence | int enum | none, daily |
| position | int | order within the phase |
| isSplit | bool | true when replaced by smaller foes (6.4); hidden and not a segment |
| createdAt, updatedAt | datetime | |

Phase status (listed in §9) is derived, not stored: a phase is done when all its live one-time tasks are struck.

**attempts** (the §9 "Attempt" entity). App code only inserts rows; it never updates or deletes them. The database itself changes them in two cases only: deleting a task or phase sets the matching reference to null (D10), and deleting a boss removes its rows.

| Column | Type | Notes |
|---|---|---|
| id | text PK | |
| bossId | text FK, cascade delete | always set |
| taskId | text FK, nullable, on delete set null | set for strike and tried; null for a boss fall or after the task is deleted (D10) |
| bossAttempt | int | the boss's attempt number when this happened |
| outcome | int enum | strike, tried, fallen |
| cause | int enum, nullable | declared, healthDeath, missedDay; only for fallen. Stage 1 writes `declared` only. |
| phaseId | text FK, nullable, on delete set null | for fallen: the boss's current phase at the moment of the fall (feeds D6); null after the phase is deleted (D10) |
| lesson | text, nullable | up to 120 characters, trimmed; empty becomes null |
| day | text | local day with 4 AM rollover |
| at | datetime | |

**settings** (single row, id = 1)

| Column | Type | Notes |
|---|---|---|
| tapMode | bool | default false |
| defaultResetOnFail | int enum | default nothing |

### 6.2 Derived values (queries, not columns)

- **One-time task in a phase is struck:** a strike exists for it with `bossAttempt >= phase.openFromAttempt`.
- **Standalone one-time task is struck:** a strike exists for it with `bossAttempt >= boss.openFromAttempt` (D9).
- **Daily task is struck:** a strike exists for it with `day == today`.
- **Health bar segments:** live (`isSplit = false`) one-time tasks in phases, in phase then task order; each segment is alive or drained.
- **Current phase:** the first phase by `position` that still has an unstruck live one-time task. Null when none is left.
- **Last lesson:** the newest `fallen` attempt for the boss with a non-null lesson.
- **Tries since last strike (task):** count of `tried` attempts for the task after its newest strike (all of them if it was never struck).
- **Same-phase fall run (boss):** walk the boss's `fallen` attempts from newest to oldest and count while `phaseId` equals the newest one's `phaseId`. A null `phaseId` (no current phase, or a deleted phase) gives a run of 0.
- **Rule of three fires (D11):** after a tried, when tries since last strike is a non-zero multiple of 3; after a fall, when the same-phase fall run is a non-zero multiple of 3. A strike sets the task count back to 0; a fall in a different phase starts a new run.
- **Defeat prompt (D3):** the boss has at least one segment and none is alive.

### 6.3 Failed attempt (declared), in one transaction

1. Read the boss, its current phase, and its reset setting.
2. Insert an `attempts` row: outcome fallen, cause declared, `bossAttempt` = current number, `phaseId` = current phase, lesson.
3. Increment `bosses.attemptNumber`; set `lastFoughtAt` and `updatedAt`.
4. Apply the reset with the new attempt number N:
   - nothing: no change.
   - currentPhase: set that phase's `openFromAttempt = N`.
   - wholeBoss: set `openFromAttempt = N` on every phase of the boss and on the boss itself (reopens standalone one-time tasks, D9).
5. Embers are not in Stage 1, but the rule is fixed: a reopened task does not pay embers twice (Stage 3 checks for an earlier strike).

Resets never delete events. History stays complete for the victory screen and relics (Stage 5) and safe for event-based sync (Stage 7).

### 6.4 Split into smaller foes (rule of three option)

1. The user enters 2 to 5 smaller task titles. Weight defaults to one step lighter (minimum Light).
2. In one transaction: insert the new tasks in the same phase right after the original; set `isSplit = true` on the original.
3. The original's attempts stay in history. The health bar shows the new tasks in its place.

### 6.5 Migrations

- `schemaVersion = 1`.
- Use `dart run drift_dev make-migrations` from the start, so later stages get generated migration steps and schema tests.
- Commit `drift_schemas/` with the code.

---

## 7. State and data flow

- `databaseProvider` opens `AppDatabase(driftDatabase(name: 'hearthrise'))`. Tests override it with `NativeDatabase.memory()`.
- `clockProvider` returns `DateTime.now`. Tests override it with a fixed clock.
- DAO providers: `bossDaoProvider`, `attemptDaoProvider`, `settingsDaoProvider`.
- Stream providers from Drift `watch` queries, so screens update when data changes:
  - `bossListProvider` for home
  - `bossDetailProvider(bossId)` for the boss screen: boss, phases, tasks with struck state, segments, last lesson
  - `todayProvider` for Today
  - `settingsProvider`
- Writes: widgets call DAO methods through `ref.read(...)`. No Notifier classes unless a screen needs multi-step local state; the boss edit form uses a plain `StatefulWidget`.

The rule of three check runs inside the DAO methods for `tried` and fall, which return whether the UI should show the prompt. The DAO is the only place the rule lives.

---

## 8. Screens and behavior

### 8.1 Routes (go_router)

| Path | Screen |
|---|---|
| `/` | Home (Bosses / Today switch) |
| `/boss/new` | Boss edit (create) |
| `/boss/:id` | Boss screen |
| `/boss/:id/edit` | Boss edit |

The fallen screen stays a pushed transparent route (`FallenScreen.show`), because it returns the lesson and has its own dim transition.

### 8.2 Home

- Top: "Hearthrise" in `labelSmall`, a two-option switch **Bosses | Today**, and a settings icon (D7).
- **Bosses:**
  - One card per active boss: title (serif), "Attempt N", "Phase 2 of 3" (or "Daily foes" per D1), compact health bar.
  - Order: pinned first, then `lastFoughtAt` (newest first), then `createdAt`.
  - "Waiting" section, collapsed, with a count. Waiting cards show no health bar.
  - "Vanquished" section, collapsed. Stage 5 replaces it with the hall of relics.
  - Action at the end of the list: "Name a new boss".
  - Empty state: "No boss stands before you." with the same action.
- Long-press a card: Pin / Unpin, Set waiting / Set active.

### 8.3 Today

- Groups by active boss, in home order. Group header: boss title.
- Each group lists daily tasks not yet struck today, then unstruck one-time tasks of the current phase, then standalone unstruck tasks. Daily tasks struck today show dimmed at the end of the group.
- Filter: a row of boss chips ("All" plus one per active boss). Remembered for the session only.
- Rows use the same strike widget and Tried action as the boss screen.
- Empty: "Nothing stands in your way today."

### 8.4 Boss screen

- Title, health bar (or the D1 line), attempt line: "Attempt N." or "Attempt N. Last time: <lesson>".
- Phases with tasks. A phase header shows "Done" when the phase is done.
- Standalone tasks, if any, follow the phases under the header "Beyond the phases".
- Task row: hold (or tap) to strike. A trailing "..." button (48 dp) opens **Mark as tried**, Edit, Delete.
- Tried records the attempt and shows "You tried. That counts." in the flash line.
- Strike shows "It is done." When the strike drains the last segment: the D3 prompt.
- Bottom: "This attempt failed" opens the fallen screen. On return, records the fall (6.3), then checks the phase rule of three.
- App bar menu: Edit, Pin / Unpin, Set waiting / Set active, Declare victory (D3).

### 8.5 Boss edit (create and edit)

- Fields: Title (required), "What does defeat mean?" (optional), Target date (optional, native date picker), "On a failed attempt, reset" (nothing / current phase / whole boss; new bosses take the settings default).
- Phases: list with drag handles (`ReorderableListView`), add, rename, delete (asks to confirm if the phase has tasks).
- Tasks per phase: add with title, weight (three-option switch), and an "Every day" toggle.
- Standalone tasks: a "Beyond the phases" section after the phase list, with the same add, edit, and delete controls. Tasks here have no phase (`phaseId` null).
- Moving a task: task edit has a "Phase" field listing the boss's phases plus "Beyond the phases", so a task can move between phases or out of them. A move keeps the task's attempts; its struck state then follows the new location's `openFromAttempt`.
- Save is disabled until the title is set and at least one task exists.
- Create starts with two phases named "Learn the pattern" and "The fight", which the user can rename or delete (§6.2 "simple suggestions").

### 8.6 Fallen

Unchanged from Stage 2. Returns the lesson, or null when skipped.

### 8.7 Rule of three sheet

Shown after a `tried` that makes 3 tries since the task's last strike, or after a fall that makes 3 falls in a row with the same current phase (D6).

> "Same path, same result. What will you change?"

| Option | Stage 1 behavior |
|---|---|
| Change the approach | Opens task edit (task) or boss edit (phase) |
| Split into smaller foes | Task: the split flow (6.4). Phase: opens boss edit on that phase |
| Rest first | Closes the sheet with "Return when ready." Flask use arrives in Stage 3 |
| Keep going | Closes the sheet |

The prompt fires at every non-zero multiple of 3 (D11): the 3rd, 6th, 9th try or same-phase fall, and never at the counts in between.

### 8.8 Settings sheet (D7)

Two rows: "Tap instead of hold" (switch) and "On a failed attempt, reset" (applies to new bosses).

---

## 9. Accessibility and motion

- Reduced motion: when `MediaQuery.disableAnimations` is true, the fallen dim, health drain, and fades are instant. The hold fill still runs (it is the input) but without easing.
- Touch targets at least 48 dp, including the "..." button and filter chips.
- Every screen checked at 200% text scale: no clipped text, lists scroll.
- Semantics: boss cards read "Boss <title>, attempt N, <percent> health". Mark as tried is reachable without holding.
- No new colors. Ember appears once per screen (DESIGN.md).

---

## 10. Testing

Target: 80% line coverage for `lib/core` and `lib/data`, plus widget tests for each screen's main path.

### 10.1 Unit (in-memory database, fixed clock)

- Clock: 03:59 belongs to the previous day; 04:00 starts a new day; daylight-saving change days.
- Boss create, edit, status change, pin order.
- Phase reorder keeps positions contiguous.
- Struck state: one-time in a phase, standalone, daily (resets at rollover).
- Failed attempt: counter rises; lesson trimmed; empty lesson stored as null; last lesson keeps the older one when skipped.
- Reset setting: nothing / currentPhase / wholeBoss produce the expected struck states; history rows remain.
- Rule of three (D11): task fires on the 3rd and 6th try and not on the 4th or 5th; a strike after 2 tries means the next 3 tries are needed again; phase fires on the 3rd same-phase fall, a fall in another phase restarts the run; a deleted phase breaks the run.
- History on delete (D10): deleting a task or phase keeps its attempts with a null reference; the boss's attempt number and last lesson are unchanged.
- Resets (D9): whole boss reopens standalone one-time tasks; current phase does not.
- Moving a task between a phase and "Beyond the phases" keeps its attempts, and its struck state follows the new location's floor.
- Defeat (D3): the prompt fires when the last segment drains even with daily tasks open; a boss with only daily tasks never prompts; "Declare victory" sets status to defeated and removes its tasks from Today.
- Split: original hidden, new tasks in place, segments updated.
- Today query: grouping, order, waiting and defeated bosses excluded, filter.
- Deleting a boss removes its phases, tasks, and attempts.

### 10.2 Widget

- Existing `feel_test.dart` (hold strikes, early release does not), on the moved widget.
- Tap mode strikes on a single tap.
- Mark as tried shows "You tried. That counts.".
- Fallen round trip shows the new attempt line.
- Home ordering and the waiting section.
- Boss edit: add a standalone task under "Beyond the phases", then see it on the boss screen and in Today.

### 10.3 Gate test (`gate_test.dart`)

Uses a temporary database file, not memory:
1. Create a boss with two phases and three tasks.
2. Strike one task.
3. Declare a failed attempt with the lesson "Rushed the second phase."
4. Close the database and open a new `AppDatabase` on the same file (an app restart).
5. Expect "Attempt 2. Last time: Rushed the second phase." and the struck task still struck (default reset: nothing).

### 10.4 Manual

On one small and one large Android screen (or emulator), in airplane mode: run the gate steps by hand, then the 200% text and reduced-motion checks.

---

## 11. Build order

Each step is test-first: write the failing tests named in "Done when" (section 10), see them fail, then write the code to pass them, then refactor. A step ends with `flutter analyze` clean and all tests passing, and is one commit. A bug found later starts with a failing test.

| # | Step | Done when |
|---|---|---|
| 1 | Add dependencies and `build_runner`; move existing files into `core/` and `features/`; add `ProviderScope`; no behavior change | App runs as before on Android; `feel_test` passes; Drift's native SQLite builds on Android |
| 2 | `core/clock.dart`, `core/ids.dart`, with tests | Clock tests pass |
| 3 | Drift tables, database, DAOs, schema dump, unit tests (10.1) | DAO tests pass |
| 4 | Providers, go_router, `app.dart`, empty home | App opens on home with the empty state |
| 5 | Boss edit: create and edit, phases with reorder, phase and standalone tasks, moving tasks | A boss can be created and edited, including standalone tasks, and survives a restart |
| 6 | Boss screen on data: health bar from segments, strike, Tried, D3 | Strikes persist; health bar drains |
| 7 | Failed attempt: fallen flow, reset setting, attempt line | Gate test passes |
| 8 | Rule of three sheet and split flow | Rule tests and sheet widget test pass |
| 9 | Home cards: order, pin, waiting and vanquished sections, settings sheet | Home widget tests pass |
| 10 | Today view with filter | Today tests pass |
| 11 | Reduced motion, 48 dp targets, 200% text, semantics | Manual checks done |
| 12 | Delete `models.dart`, update `CHECKLIST.md`, run the manual gate on a device | **Gate passed** |

---

## 12. Risks

| Risk | Mitigation |
|---|---|
| Native SQLite setup changed (`sqlite3_flutter_libs` end-of-life) | Prove the Android build with `drift_flutter` in step 1, before feature work |
| Breaking changes in Riverpod 3 and go_router 18 | Read the changelogs in step 1; keep provider use simple (D8) |
| D1 (daily tasks not on the health bar) feels wrong for habit bosses | Ask the Stage 2 testers; changing it is a query change, not a schema change |
| Code generation slows the edit loop | Run `dart run build_runner watch -d` while working |
| Rule of three prompts too often | Fires only at multiples of 3 (D11); watch in Stage 6 |
| Scope creep into Stage 3 (embers, bonfire) | Anything not in section 2 waits; the schema already leaves room |

---

## 13. Copy added in Stage 1

| Moment | Line |
|---|---|
| Home empty | "No boss stands before you." |
| New boss action | "Name a new boss" |
| Today empty | "Nothing stands in your way today." |
| Boss with only daily tasks (D1) | "This foe is worn down by habit." |
| Tried | "You tried. That counts." (§6.3) |
| Defeat confirm (D3) | "Foe vanquished." then "Mark this boss as defeated?" |
| Rule of three | "Same path, same result. What will you change?" (§5.10) |
| Rest first (Stage 1) | "Return when ready." |
