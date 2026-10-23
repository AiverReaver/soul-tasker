# Hearthrise UI coverage checklist

Walk done 2026-10-19 on the iPhone 16 simulator (iOS 18.5), starting from a fresh install (`simctl uninstall`), then a second fresh install for the skip/empty path.

- `[x]` seen on the simulator (screenshots in `shots/`, numbered in walk order; `shots/full/` holds device-resolution copies).
- `[-]` not reached, with the reason in brackets (needs a backend, a device, a DB error, or blocked by a bug).
- Result: 343 `[x]`, 81 `[-]`, 0 open. Bugs and oddities found on the way: `findings.md` (54 items).
- Time-based states (missed days, deadlines passing, check-in on day 7, greetings) were reached with a throwaway entrypoint that shifted `clockProvider` by a `--dart-define` offset, installed over the app so data was kept. It was deleted after the walk.
- Screens 000-118 are in the Pharloom biome; 119-179 are in Deep Docks (a mis-tap while restoring the biome); 180+ are Pharloom again (second fresh install).

# Map A: Onboarding, Shell, Home, Today, Bosses list, Day resolver

Format: `- [ ] ID. item — trigger — precondition` (file:line in brackets). All paths under `app/lib/`.
Strings are verbatim (curly apostrophe in "Today’s tasks", "Tomorrow’s ..." where code uses it; straight `'` in "Failing is fine. Quitting isn't." and "TODAY'S THREE" / "TOMORROW'S THREE").

## 0. Global facts a tester needs

- 0.1 Fresh install: `main.dart:12-15` opens the DB and calls `ensureDayBoss()` BEFORE runApp, so a boss titled "The Day" (status active) exists from second zero, even before onboarding. Not shown during onboarding, but on every list afterward (counts, chips, groups).
- 0.2 Fresh-install router: initial `/` -> `StartGate` reads `settings.onboarded` (default false, `data/tables.dart:109`) -> `context.go('/welcome')`. `/welcome` is OUTSIDE the ShellRoute, so no tab bar during onboarding (`core/router.dart:27-43`).
- 0.3 Day boundary: day rolls over at 04:00 local (`rolloverHour` default 4, `data/tables.dart:136`). 00:00-03:59 still shows the previous day on Home. Clock changes: simulator Settings > General > Date & Time > turn OFF "Set Automatically", then pick date/time; app re-checks on resume (`day_resolver.dart:80-90`) and every 1 min in foreground (`kDeadlineTick`, `core/deadlines.dart:15`).
- 0.4 No in-app debug clock or dev menu (`clockProvider = DateTime.now`, `core/clock.dart:6`). All time-dependent states need the OS clock.
- 0.5 Tab bar (HearthShell) shows only on `/`, `/today`, `/bonfire`, `/profile`. Not on `/welcome`, `/bosses`, `/settings`, `/boss/*`, `/victory/*`, `/relic/*`.

---

## SECTION 1. Cold start / StartGate

- [-] A1. (1-2 frame blank, not capturable) Blank loading frame — launch fresh install — bare `Scaffold()` (themed background + Atmosphere) for 1-2 frames while `onboarded` is read; no text [features/onboarding/start_gate.dart:31]
- [x] A2. Redirect to onboarding — fresh install, `onboarded=false` — post-frame `context.go('/welcome')`; blank Scaffold until the route swaps [start_gate.dart:33-36]
- [x] A3. Onboarded user opens `/` or `/today` — StartGate returns DayResolver > HomeScreen [start_gate.dart:32] — finished or skipped onboarding once
- [x] A4. Atmosphere ambient layer (behind every screen) — app launch — Pharloom backdrop with drifting motes at 30 Hz, glass light tilts with accelerometer [features/shell/atmosphere.dart:13-166, app.dart:53-58, features/shell/tilt_controller.dart]. Simulator has no accelerometer so tilt is not visible (screenshot backdrop only)
- [-] A5. (system Reduce Motion not toggled (no simctl switch)) Reduce Motion variant — iOS sim Settings > Accessibility > Motion > Reduce Motion — backdrop freezes, `motionOf()` returns zero so page fades/sheets are instant [atmosphere.dart:101-105, core/theme.dart:46-47]
- [-] A6. (no accelerometer on simulator) Tilt edge states (note only, unverifiable on simulator) — flat device ignored; sensor silence over 1 s fades to centre over 0.8 s; backgrounded app stops sensor [tilt_controller.dart:38-41,98-109, atmosphere.dart:93-96]

---

## SECTION 2. Onboarding flow (route `/welcome`, `OnboardingFlow`)

Reach: fresh install automatically (A2). Re-reach only by erasing the app (no in-app replay found in my area; Settings map may have one). Layout: `PageView` of 5 pages, swipe DISABLED (`NeverScrollableScrollPhysics`) [features/onboarding/onboarding_flow.dart:151-153]. Each page = `OnboardingPage` (SafeArea, scrolling body, bottom row Skip / Next) [ui/onboarding_page.dart:34-92].

Common chrome on every page:
- [x] A7. Step marks row — 5 diamonds, first `step` silk, rest dim; Semantics "Step N of 5" [ui/step_marks.dart:16-33]
- [x] A8. Text "Step N of 5" (label-small) next to the marks [ui/onboarding_page.dart:53]
- [x] A9. Serif headline (displaySmall) = page line
- [x] A10. Body slot (page specific)
- [x] A11. Bottom-left "Skip" text button (ash) — tap — pages 1-4: `_skipToEnd` dismisses keyboard and animates to page 5 (600 ms easeInOut); page 5: `_finish(save:false)` [onboarding_flow.dart:64-72,147; onboarding_page.dart:70-76]
- [x] A12. Bottom-right primary — "Next" (pages 1-4) / "Begin" (page 5). Enabled = silk EmberButton; disabled = plain greyed TextButton with same label [ui/onboarding_page.dart:77-85]
- [x] A13. Page transition animation — tap Next — horizontal slide, 600 ms (Motion.fade) easeInOut, keyboard dismissed first [onboarding_flow.dart:56-62] (screenshot mid-transition)

Page 1 (step 1):
- [x] A14. Headline "Failing is fine. Quitting isn't." — body (bodyLarge) "Hearthrise keeps the story of the fight: every fall becomes a lesson, and nothing you earn is taken away." — Next and Skip enabled [onboarding_flow.dart:155-162]

Page 2 (step 2):
- [x] A15. Headline "Name your first boss."
- [x] A16. Field label "The boss", hint "A goal worth a fight", maxLength 80 (shows counter "0/80") [onboarding_flow.dart:169-174; ui/onboarding_fields.dart:18-52]
- [x] A17. Field label "What does defeating it mean? (optional)", hint "One line", maxLength 120 (counter "0/120") [onboarding_flow.dart:176-182]
- [x] A18. STATE: Next DISABLED (greyed plain text) until title has non-whitespace text; enables live on typing [onboarding_flow.dart:165,44] — empty or whitespace-only title. Skip stays enabled
- [x] A19. STATE: keyboard open — tap a field — verify Next/Skip row reachable and body scrolls (simulator Cmd+K toggles software keyboard) — screenshot with keyboard
- [-] A20. (80-char limit not typed out) Edge: whitespace-only title keeps Next disabled; 80-char limit enforced

Page 3 (step 3):
- [x] A21. Headline "Break it into chapters." Help line "Big goals fall in stages. Two or three is plenty." [onboarding_flow.dart:187-210]
- [x] A22. Two prefilled rows with silk roman numerals "I", "II" and text "Learn the pattern", "The fight" (`data/boss_draft.dart:52-58`); hint "Chapter name" when emptied; maxLength 60 (counter hidden)
- [x] A23. Each row has a close (X) IconButton, tooltip "Remove chapter 1" / "Remove chapter 2" (long-press shows tooltip); tap removes the row, numerals renumber [ui/onboarding_fields.dart:136-144]
- [x] A24. "Add a chapter" text button, left aligned — tap adds an empty row that autofocuses (keyboard opens). Only visible while fewer than 3 rows (`_maxPhases = 3`); disappears at 3 [onboarding_fields.dart:147-157, onboarding_flow.dart:16,204-208]
- [-] A25. (zero chapters not tried) STATE: zero chapters (remove both) — only "Add a chapter" remains; blank rows dropped on save [onboarding_flow.dart:86-89]
- [x] A26. Next always enabled here

Page 4 (step 4):
- [x] A27. Headline "What will you do every day?" Help line "Small tasks that come back each morning." [onboarding_flow.dart:211-235]
- [x] A28. One empty row "I", hint "A small daily task"; tooltip "Remove daily task 1"; add button "Add a daily task" (max 3, `_maxDailies`); blank rows dropped. Saved as Light, daily, standalone tasks on the new boss [onboarding_flow.dart:90-98]
- [-] A29. (middle-row removal not tried) Edge: ids stay stable when removing a middle row (other rows keep their text) [onboarding_fields.dart:54-61]

Page 5 (step 5, last):
- [x] A30. Headline "One last thing." Body "Gentle mode: nothing is lost but health." [onboarding_flow.dart:236-246]
- [x] A31. Row "Evening reminder" with glass switch (whole row tappable), default OFF, Semantics "Evening reminder" [ui/setting_switch_row.dart; onboarding_flow.dart:248-252]
- [x] A32. Row "Reminder time" trailing value "9:00 PM" (default 21*60) — tap opens the system Material time picker in keyboard INPUT mode (hour/minute fields, AM/PM, Cancel/OK); OK updates the value (e.g. "7:30 AM"). Works with switch off [onboarding_flow.dart:113-125,253-257; core/clock.dart:36-41]
- [x] A33. Button "Begin" — enabled only if title non-empty and not busy [onboarding_flow.dart:239]. If user used Skip from an early page with no title, Begin is DISABLED (greyed) while Skip stays enabled
- [x] A34. Tap "Begin" with title — `_finish(save:true)`: saves boss (title, meaning, default reset-on-fail from settings, phases, dailies, `allowEmpty:true`); if reminder ON calls `ReminderCoordinator.enable(minutes)` which raises the iOS notification-permission alert; denied = reminder stays off silently. Then `setOnboarded(true)` and `context.go('/')` [onboarding_flow.dart:74-111; features/ritual/reminder_coordinator.dart:22-34]. New boss is NOT pinned
- [x] A35. Tap "Skip" on page 5 — `_finish(save:false)`: no boss saved, onboarded=true, Home with only "The Day" (the empty-state path) [onboarding_flow.dart:80,109-110]
- [-] A36. (double-tap guard not timed) Double-tap guard: `_isBusy` disables Begin and ignores re-entry during save [onboarding_flow.dart:75]
- [-] A37. (typed title then Skip not tried) Typed a title, then Skip on page 5 — boss discarded (lossy, verify intended)
- [x] A38. iOS notification permission system alert — Begin with reminder ON, first time — erase app to reset permission
- [x] A39. Variant matrix: (a) title only; (b) title+meaning, 3 chapters, 3 dailies, reminder ON custom time; (c) Skip from page 1; (d) remove all chapters/dailies

---

## SECTION 3. Shell: GlassTabBar (HearthShell) [features/shell/hearth_shell.dart, ui/glass_tab_bar.dart]

- [x] A40. Floating glass pill 62 px tall, 21 px side inset, 19 px + safe area above bottom; 4 tabs: "Home", "Today", "Bonfire", "Profile" (11 pt; text scale clamped to 1.0 so no growth at 200% text) [glass_tab_bar.dart:17,28-56]
- [x] A41. Selected tab: bone label/icon on brighter glass with 0.5 px ring and a small silk diamond at top; others ash. Semantics button, selected, label [glass_tab_bar.dart:58-113]
- [x] A42. Selection follows route (`kTabPaths.indexOf(location)`, clamped) [hearth_shell.dart:38]
- [x] A43. Tap "Home" — `go('/')`
- [x] A44. Tap "Today" — if ANY boss is pinned AND active: `go('/boss/<pinnedId>')` (that boss's fight screen, NOT `/today`). So the `/today` Today view is reachable only when no active boss is pinned (unpin via long-press) [hearth_shell.dart:21-31]
- [x] A45. Tap "Bonfire" — `go('/bonfire')`; tap "Profile" — `go('/profile')`
- [x] A46. Tab cross-fade — switching tabs — old fades out while new fades in with 2% rise, 280 ms easeOut [core/tab_transition.dart:6-28] (screenshot mid-transition)
- [x] A47. Bar floats over content (`extendBody:true`); lists pad bottom by 100 + Space.md so last row scrolls clear [hearth_shell.dart:36, features/today/today_view.dart:130]
- [x] A48. Layering: `showGlassSheet` uses root navigator and covers the tab bar; plain `showModalBottomSheet` (boss long-press) does not [ui/glass_sheet.dart:109-118, features/home/boss_card.dart:49]
- [-] A49. (press-scale frame not caught) PressTracker press scale (1.04) — hold finger down on a glass circle button / pill — control grows slightly (screenshot) [features/shell/press_tracker.dart]

---

## SECTION 4. Home (route `/`; StartGate > DayResolver > HomeScreen(showToday:false))

Reach: after onboarding, or tab "Home". One scrolling ListView (TodayView in home mode) [features/home/home_screen.dart:52-101].

### 4a. HomeHeader [ui/home_header.dart]
- [x] A50. Label "Hearthrise" (label-small, top-left)
- [x] A51. Top-right glass circles: profile (Semantics "Your profile") — tap `go('/profile')`; gear (Semantics "Settings") — tap `push('/settings')` [home_screen.dart:47-48]
- [x] A52. Date line (ash 14 pt) `D Mon YYYY`, e.g. "19 Oct 2026", uses rollover day [home_screen.dart:39; core/clock.dart:59-62]
- [x] A53. Greeting serif: "Morning." hours 5-11, "Afternoon." hours 12-16, "Evening." hours 17-23 and 0-4 [home_header.dart:9-13] — CLOCK CHANGE; screenshot each (e.g. 08:00, 14:00, 20:00, 02:00)
- [x] A54. LevelBadge right side: flame icon + banked embers, 5 level bars (lit = round(5*(1-toNext/(level*10))) clamped 0-5), silk diamond with level numeral. Semantics "Level N, P percent to level N+1". Fresh: embers 0, level 1, 0 bars [ui/level_badge.dart; home_screen.dart:30-49]
- [x] A55. Level-up state — bank 10+ embers (strike tasks, then rest at the bonfire; step 10 per level, `core/level.dart:5`) — number, bars, diamond change

### 4b. Pinned boss panel (only when a pinned ACTIVE boss exists; first only) [home_screen.dart:106-116, features/home/boss_card.dart:88-104, ui/pinned_boss_panel.dart]
- [x] A56. Absent state — no boss pinned (fresh default): header goes straight to "All bosses" row
- [x] A57. Panel (deep edge, gradient): title (headlineMedium); subtitle `"{progress} · Attempt N[ · X days left]"`; portrait art 72 px (ink boils among 3 frames every 140 ms); "Boss health" label + "k / 10" shard count; shard meter; silk ember button "Enter the fight" with strike icon [pinned_boss_panel.dart:54-93]. Progress text: "Daily tasks" (no phase segments), "Chapter I of II" (Roman numerals), "All chapters done". "N days left"/"1 day left" appended when a future target date exists [boss_card.dart:21-31; core/days_left.dart:3-7]. Precondition: long-press a boss card (A82) > Pin, boss active
- [x] A58. Tap "Enter the fight" — `push('/boss/<id>')` [boss_card.dart:101]
- [x] A59. Long-press title/art area (not the button) — opens Pin/Status sheet (A82) [pinned_boss_panel.dart:54-57]
- [-] A60. (only one pinned boss at a time in the run) Only one pinned shown even if several pinned (`take(1)`); others visible on All bosses [home_screen.dart:110]
- [x] A61. Portrait ink boil animation — screenshot twice 140 ms apart; frozen under Reduce Motion

### 4c. AllBossesRow [ui/all_bosses_row.dart]
- [x] A62. Needle row: bold "All bosses" + ash " · N active" [+ " · M waiting" only if M>0] + "›". Semantics "All bosses · N active[ · M waiting]". Counts include "The Day" (a fresh user with one boss reads "2 active") [home_screen.dart:86-90,103-104]
- [x] A63. Tap — `push('/bosses')` (Section 6)

### 4d. Filter chips [today_view.dart:158-167, ui/filter_chips.dart]
- [x] A64. Visible only when more than one ACTIVE boss exists (The Day counts, so nearly always after onboarding with a boss). Horizontally scrolling needle chips: "All", then one per active boss (title). Selected: silk edge, raised fill, bone text; others ash. Semantics button/selected/label, min height 48
- [x] A65. Tap chip — filters task groups to that boss; "All" resets; state local (resets on leaving). Overflow: many/long boss titles scroll horizontally

### 4e. FlashLine [ui/flash_line.dart]
- [x] A66. Reserved 36 px line under chips (empty at start). After actions it cross-fades (600 ms) a silk serif line: "It is done." (clean strike), "You tried. That counts." (mark as tried), plus messages from Promise/Extend/Rule-of-three flows (other maps). Persists until replaced

### 4f. FoesHeader [ui/foes_header.dart; today_view.dart:169-176]
- [x] A67. Row: serif "Today’s tasks" (22 pt), count "{struck} of {open+struck} struck" (ash), glass "+" target (Semantics "New task", 48x48). Fresh: "0 of 0 struck"
- [x] A68. Tap "+" — `_newFoe`: no active boss -> `push('/boss/new')` (not reachable normally); else New task sheet (Section 7) [home_screen.dart:118-127]
- [x] A69. Thread divider (silk line, centre diamond) [ui/thread_divider.dart]

### 4g. Task list / empty / done states [today_view.dart:192-238]
- [x] A70. EMPTY STATE: no open and no struck tasks — centred "Nothing stands in your way today." (bodyLarge) — skip onboarding and add nothing, or boss with no dailies
- [x] A71. ALL DONE STATE: no open tasks, at least 1 struck today — "All tasks struck. Rest at the bonfire" (no period) — strike every task
- [x] A72. Group per boss with tasks: UPPERCASE boss title (labelSmall), e.g. "THE DAY", then rows; empty groups hidden. Home shows no per-group count (Today tab does)
- [x] A73. Order inside a group: open dailies, current phase one-time tasks, standalone non-daily, struck dailies last; struck one-time tasks drop out [today_view.dart:25-34]
- [x] A74. Struck row lingers about 1.5 s in its slot during the strike animation (`strikeLinger`) [today_view.dart:36-38,70-91] (screenshot sequence)
- [x] A75. Task row content (`TaskRow` > `HoldToStrike` > `TaskRowTile`): title ("{title} · daily" for dailies), pips (Light 1, Heavy 2, Boss-tier 3), meta "{Boss} · +N embers" (Light +1, Heavy +3, Boss-tier +6) or "Struck · +N embers" when done; optional deadline chip [features/boss/task_row.dart:136-149; strike/hold_to_strike.dart:232-236]
- [x] A76. HOLD the round button — Light 300 ms, Heavy 600 ms, Boss-tier 1200 ms; haptic ticks; row trembles 1 px per 70 ms; early release rolls back in 250 ms; finger past touch slop = scroll, cancels. Semantics "Hold to strike: {title}" [hold_to_strike.dart:120-130,298; data/enums.dart:23-37]
- [x] A77. TAP MODE (Settings tap mode ON): single tap on button, Semantics "Complete {title}" [hold_to_strike.dart:211-218]
- [x] A78. Hold completes — sweep + dust animation then glass sheet label "HOW DID THE STRIKE LAND?" titled with task name: "Clean strike" (note "Done in full. Promise kept.") and "A real try" (note "Part done. Effort still earns embers."); Cancel/scrim leaves task unchanged [ui/strike_result_sheet.dart:19-35; hold_to_strike.dart:136-150]
- [x] A79. Clean strike — flash "It is done."; if it was the boss's last segment: dialog "Mark this boss as defeated?" buttons "Defeated" / "Not yet", vanish animation, then Victory screen [task_row.dart:57-58,160-180]
- [x] A80. Real try — flash "You tried. That counts."; may open Rule-of-three sheet; may deal a final blow (health 0) leading to Fallen screen [task_row.dart:67-85]
- [x] A81. Tap row body (away from button) — glass sheet label "TASK ACTIONS" titled with the task: "Promise by…" (not struck, no promise today, boss active), "Move it later" (open future promise only), "Mark as tried" (not struck), "Edit" (`/boss/<id>/edit`), "Delete" (confirm `Delete "{title}"?` buttons "Delete" / "Not yet") [ui/foe_actions_sheet.dart:52-62; task_row.dart:86-96]

### 4h. Scroll / layout / error states
- [x] A81b. Scroll — add about 10 tasks — header, panel, rows scroll together, rows pass under the floating tab bar, last row clears it
- [x] A81c. Dynamic Type 200% (iOS sim Larger Text) — header, level badge, chips, FoesHeader count, rows wrap; tab bar does NOT grow
- [-] A81d. (needs DB error) Loading/Error — loading blank; error centred "Could not load your bosses." [home_screen.dart:94-97] (hard to trigger)
- [x] A81e. Theme/biome variants (`buildTheme(biomeProvider ?? pharloom)`, app.dart:42) — switch in Settings (other map) and re-screenshot Home

---

## SECTION 5. Boss card actions (long-press) [features/home/boss_card.dart, ui/boss_card_tile.dart]

BossCard appears on All bosses (every boss) and as the pinned entry on Home.

- [x] A82. Long-press tile or panel title area — plain Material bottom sheet (shell colour, not glass): rows (48 px min) "Pin"/"Unpin"; and, unless boss defeated, "Set waiting" (if active) / "Set active" (if waiting). Tap writes and closes; scrim tap dismisses [boss_card.dart:46-85]
- [x] A83. BossCardTile: needle frame; title (headlineMedium); line "Attempt N · {progress}"; portrait 72 px; shard meter only when status active AND boss has segments; Semantics "Boss {title}, attempt N, P percent health" (button) [boss_card_tile.dart:40-107; boss_card.dart:105-115]
- [x] A84. Pinned tile variant (pinned but rendered as tile, i.e. WAITING pinned boss): deep edge, raised2 fill, top row with rotated silk diamond and "Pinned" [boss_card_tile.dart:89-102]. An ACTIVE pinned boss renders as the big panel everywhere including All bosses [boss_card.dart:91-104]
- [x] A85. Tap tile — `push('/boss/<id>')`; silk ink splash [boss_card_tile.dart:55-58]
- [x] A86. Edge: long-press "The Day" > "Set waiting" throws `StateError('The Day always stays active.')` (`data/boss_dao.dart:268-270`), fire-and-forget in the sheet — expected unhandled error / no change; VERIFY visible behaviour
- [x] A87. After Pin: boss shows as panel on Home; after "Set waiting": boss moves to Waiting section on All bosses and leaves Today lists/chips; Home counts become "N active · 1 waiting"

---

## SECTION 6. All bosses screen (route `/bosses`, push from AllBossesRow) [features/home/bosses_screen.dart]

No tab bar. SafeArea > header + list.
- [x] A88. Header: glass circle back (Semantics "Back") — `pop()`; title "All bosses" (titleLarge)
- [x] A89. List: all ACTIVE bosses (BossCard each; The Day included), spacer, pill button "Name a new boss" (left aligned) — tap `push('/boss/new')` [bosses_screen.dart:101-106]
- [x] A90. "Waiting (N)" collapsible section (only N>0): label-small "Waiting (N)" with "›" chevron rotating 90° over 250 ms; Semantics button/expanded; tap toggles; collapsed by default; resets on leave [ui/collapsible_section.dart; bosses_screen.dart:107-115] — set a boss waiting first
- [-] A91. (unreachable: The Day is always active) EMPTY state: "No boss stands before you." + "Name a new boss" pill — only if no active and no waiting (practically unreachable because The Day is always active) [bosses_screen.dart:88-99]
- [x] A92. Defeated bosses never listed here (relics on Profile) [bosses_screen.dart:87]
- [-] A93. (needs DB error) Error "Could not load your bosses." [bosses_screen.dart:47-49]; loading blank
- [-] A94. (edge-swipe back not tried) iOS edge-swipe back also pops

---

## SECTION 7. New task sheet (Home "+"; `showNewFoeSheet`) [features/boss_edit/new_foe_sheet.dart]

Glass sheet over 62% ink scrim on root navigator (covers tab bar); grabber; label "TODAY’S TASKS"; title "A new task"; right pill "Cancel"; thread divider; body:
- [x] A95. Field caption "Name the task", hint "What will you do?", autofocus (keyboard opens at once) [new_foe_sheet.dart:105-111]
- [x] A96. "Strength" + 3 segments: "Light" (note "+1 embers"), "Heavy" ("+3 embers"), "Boss-tier" ("+6 embers"), 1/2/3 pips, default Light (literal "+1 embers") [new_foe_sheet.dart:116-129]
- [x] A97. "Strikes at" + needle row with boss title and "›"; default The Day, else pinned, else first active. Tap opens nested glass sheet label "STRIKES AT", title "Which boss?", one row per active boss; choosing updates target [new_foe_sheet.dart:62-82,131-169]
- [x] A98. Ember button "Add to today" (strike icon) — blank name ignored; otherwise closes and saves: target The Day -> quick daily task (`addQuickTask`); other boss -> standalone task appended via `saveBoss`. Task appears in lists, counts update live [new_foe_sheet.dart:84-88,20-37]
- [-] A99. (covered by Cancel tap; drag-down not tried) Keyboard-up layout (bottom padded by viewInsets); scrim tap / drag-down / Cancel dismisses without saving
- [x] A100. Blank name + "Add to today" does nothing (no error text)

---

## SECTION 8. Today tab view (route `/today`; HomeScreen(showToday:true))

Reach: tab "Today" only when no active boss is pinned (A44). ListView with 20 px horizontal padding. Differences from Home:
- [x] A101. Same HomeHeader (A50-A55), then BonfireCard (needle frame, silk edge until rested): flame icon + "Rest at the bonfire"; once rested today: ash edge/icon, text "Rested". Tap `go('/bonfire')` [home_screen.dart:63-74; ui/bonfire_card.dart] — rested via Bonfire "Rest at the hearth"
- [x] A102. PlayerHealthBar: 10 pips (20 half-points), full/half/empty; Semantics "Health X of 10", at zero "Fallen. Health 0 of 10". Not on Home. Lower health: miss a promise deadline, mark a promised task tried, or fall [today_view.dart:134-138; ui/player_health_bar.dart]
- [x] A103. EmberTally: "Carried N" (silk) and "Banked N" (ash); carried = earned today not yet banked, banked after bonfire rest [today_view.dart:139-143; ui/ember_tally.dart]. Fresh "Carried 0  Banked 0"
- [x] A104. PlanBanner "TODAY'S THREE": only when last night's bonfire "Set tomorrow" saved picks for today. Needle box listing picked titles with empty circle (open) or check + strikethrough ash (done); when all done adds "The three are done." [ui/plan_banner.dart; today_view.dart:144-157]. CLOCK CHANGE: choose picks (A131), rest, advance OS clock to next day after 04:00. Not shown on Home
- [x] A105. Filter chips (A64) and FlashLine (A66) as on Home
- [x] A106. Serif "Today’s tasks" (titleMedium) and, only if (open+struck)>0, "{struck} of {total} struck · hold to strike" (bodySmall); hint text stays even in tap mode [today_view.dart:178-186]
- [x] A107. No "+" button and no AllBossesRow on this tab
- [x] A108. Per-boss group header: UPPERCASE title left, "{n} of {m} struck" right [today_view.dart:219-224]
- [x] A109. Empty / all-done messages as A70/A71
- [x] A110. Bottom padding clears tab bar; scrolls under glass bar

---

## SECTION 9. DayResolver (wraps Home and Today; runs on cold start, resume, and every 60 s in foreground) [features/ritual/day_resolver.dart]

Silent side effects: records a visit (:94), re-arms daily reminder (`rearm`, :43), syncs deadline reminders to today's promises (:49-64), starts cloud sync if configured (:107). Timer pauses when app paused/hidden (:86-87). Order in `_resolve` (:125-182): settle deadlines; settled? tick -> SnackBar, cold start/resume -> Away dialog; health deaths; missed days; flask choice; fallen screens; `days.resolve()`.

- [-] A111. (snackbar needs app open as a deadline passes) SnackBar (foreground 1-min tick) — a promised task's deadline passes while app open — single "A deadline passed: {taskTitle}." or plural "{Count word} deadlines passed." (e.g. "Two deadlines passed.", digits above twenty) [day_resolver.dart:204-210; core/deadlines.dart:127]. Create a promise (task row > "Promise by…") a few minutes ahead and keep app open
- [x] A112. Away summary dialog (cold start or resume) — deadline passed while app closed/backgrounded, then reopen — non-dismissible glass alert: label "WHILE YOU WERE AWAY", serif title "A deadline passed." (one) or "Two deadlines passed." (capitalised word), thread, scrolling list (max 280 px) of needle rows: title left, cost right ("frozen" or "−X health" e.g. "−1", "−2", "−0.5"), per-row text button "Done late" (hidden once used); single action "Go on" [ui/away_summary.dart; day_resolver.dart:212-241]. Background app with Home gesture past deadline, reopen. Make 2+ promises for plural, 5+ for scroll
- [x] A113. "Done late" tap — strikes task against that commitment; row loses button; dialog stays [day_resolver.dart:230-236]
- [x] A114. "Go on" — closes dialog, flow continues
- [x] A115. Flask choice dialog — missed day(s), affected bosses present, flasks>0 — non-dismissible AlertDialog: title "A day passed without rest." (1) or "N days passed without rest."; content "You hold N flask." / "You hold N flasks."; actions text "Let it fall" (ash) and silk "Use a flask" [ui/flask_choice.dart; day_resolver.dart:147-160]. Use spends min(flasks, missedDays). Precondition: install day D, do NOT rest at the bonfire, set OS clock to D+2 (after 04:00) or later, relaunch/resume. D+1 is the missed day; The Day boss counts as affected (created before the last missed day) so this fires even with only The Day. Flasks assumed 3 at start (unverified)
- [x] A116. Flask variants: 1 missed day (singular), 2+ (plural digits), flasks fewer than days (partial cover, remainder falls), zero flasks (dialog skipped, straight to Fallen)
- [x] A117. Fallen screen (missed-day fall) — missed days not fully covered — full-screen Fallen: "Fallen.", sub "Rest, then rise." (no story), prompt "What did this teach you?", hint "One line.", max 120, silk "Rise", text button "Rest first. Write it tomorrow." [features/fallen/fallen_screen.dart:112-285; day_resolver.dart:171-177] (detail in another map)
- [x] A118. Health fall — health hits 0 — Fallen with story "Attempt N ends. The {Boss} remains, and so do you.", health "0 / 10" pip dimming, embers count with "Embers kept", record lines (e.g. "One promised, none kept."), accuracy line, in first 7 days "Your first week: nothing is lost but health.", and "You will see it at the start of attempt N+1." [features/fallen/health_fall.dart; fallen_screen.dart]. Re-offered on startup/resume if a death from today/yesterday has no lesson
- [-] A119. (not produced) No-op path — missed days but no affected bosses — silently advances `lastResolvedDay`, shows nothing [day_resolver.dart:139-144]
- [x] A120. Fresh install first launch same day — no dialogs (`lastResolvedDay` = install day)
- [x] A121. Dialog order when several apply: Away summary, then Flask choice, then Fallen [day_resolver.dart:129-178]
- [-] A122. (60 s foreground tick not waited) Foreground tick never shows the Away dialog (SnackBar only) — wait 60 s with app open [day_resolver.dart:131]
- [-] A123. (notification delivery not checked) Deadline reminder local notification sync is invisible; verify with a promise and backgrounded app (needs notification permission) [features/commit/deadline_reminders.dart, other map]

---

## SECTION 10. Reminder coordinator and evening reminder [features/ritual/reminder_coordinator.dart]

- [x] A124. iOS permission prompt — onboarding Begin with switch ON (A34), Bonfire "Yes, remind me" (A133), or Settings toggle — system alert Allow / Don't Allow
- [-] A125. (notification delivery not checked) Granted: stored and a daily notification scheduled at chosen time (text in `core/reminders.dart`, other map). Test with a time 2 minutes ahead (set in Settings) and background app
- [x] A126. Denied: stays off; Bonfire flash "No reminder without permission." (A133); onboarding silent
- [-] A127. (invisible) `rearm()` on each Home/Today open reconciles schedule with the setting (invisible)

---

## SECTION 11. Bonfire widgets in my UI list (route `/bonfire`; full screen owned by another map) [features/bonfire/bonfire_screen.dart]

Reach: tab "Bonfire" or BonfireCard on Today tab. Header: glass back circle (Semantics "Back to bosses", `go('/')`) + "BONFIRE" label.

State A, not rested, not fallen:
- [x] A128. Title "Rest a while." (44 pt centred); sub "Night N at the hearth. Tell it how the day went." (N = rests so far + 1) [bonfire_screen.dart:255-265]
- [x] A129. Thread divider; "How did today go?"; MoodChoice three needle segments "Fought well", "Held on", "I fell" (selected: silk edge, bone text). Note line (key `mood-note`): "{n} task struck. The Warden felt it." / "{n} tasks struck. The Warden felt it." (e.g. "0 tasks struck.", "1 task struck."), "Holding on is a kind of winning.", "You fell. Rise. Embers are kept." Logged as signal [ui/mood_choice.dart; bonfire_screen.dart:77-82,241-247]
- [x] A130. "Flasks restored" row: bold title, sub "{flasks} of 3 · ready for tomorrow", FlaskPips; field caption "One thing for tomorrow", hint "Write before noon", max 120 [bonfire_screen.dart:278-306]
- [x] A131. TomorrowRow: title "Tomorrow’s tasks", summary "{n} of 3 chosen" plus " · {first two titles joined by ', '}", trailing " ›"; Semantics "Tomorrow’s tasks, {summary}". Tap opens glass sheet "Tomorrow’s three" with Cancel pill, text "Choose up to three tasks to face tomorrow. Keeping them is what counts.", row "Tasks waiting" / "{n} of 3 chosen", one toggle row per open task (title, subtitle "{Boss} · {Light|Heavy|Boss-tier}", 1-3 pips, selected state), flash "Three is enough for one day." on a 4th pick, bottom ActionRow "Set tomorrow" [ui/tomorrow_row.dart; ui/tomorrow_pick_sheet.dart; bonfire_screen.dart:84-102,323-372]. Needs at least one open task for rows
- [x] A132. Ember button "Rest at the hearth" — rests: restores health, banks embers, restores a flask, saves lesson and picks; medium haptic; then goes Home (`go('/')`). Refused if already rested today or fallen [bonfire_screen.dart:104-112; data/day_dao.dart:139-155]
- [x] A133. ReminderInvite (only after the very FIRST rest and only if reminder off) — GlassAlert title "A quiet nudge each evening?" body "One gentle reminder to come back to the bonfire." actions "Yes, remind me" (silk tint) / "Not now"; Yes raises iOS permission; refusal sets flash "No reminder without permission." and stays on Bonfire (rested state), no auto-navigation [ui/reminder_invite.dart; bonfire_screen.dart:132-147,111]
- [x] A134. With reminder enabled, line under button "One gentle reminder tomorrow at {h:mm AM/PM}." [bonfire_screen.dart:311-318]
- [x] A135. CheckInCard "Has Hearthrise left you feeling worse?" with outlined "Never", "Sometimes", "Often" and right "Not now" (ash). Shown above the plan when due: install day = day 1; windows open day 7 and day 14; closes after an answer or 3 dismissals; a dismissal hides it for the rest of that day; hidden while fallen and after acting this visit. Answer flash "Thank you." (dismiss has none) [ui/check_in_card.dart; core/check_in.dart:11-60; bonfire_screen.dart:114-123,192-201]. CLOCK CHANGE to install day + 6 (day 7) or +13 (day 14), open Bonfire
State B, rested:
- [x] A136. "You have rested." (titleMedium) + FlashLine; plan form hidden; if tomorrow picks exist, PlanBanner "TOMORROW'S THREE" with empty circles, else nothing [bonfire_screen.dart:187-206,229-239]
State C, fallen (health 0):
- [x] A137. "You have fallen." / "Rest here to rise again today." / right-aligned silk "Rise" (full health, banks embers, no flask/lesson/picks; day not covered) [bonfire_screen.dart:217-227]
- [-] A138. (dead code) `DaySummary` widget (`ui/day_summary.dart`: "A quiet day so far." or "Struck N / Tried N / Fallen N" plus lessons) is NOT used by any screen (dead code at mapping time); nothing to test, flagged

---

## SECTION 12. Routes reachable from this area (handoff)

- [x] A139. From Home: `/settings` (gear), `/profile` (circle or tab), `/bosses`, `/boss/<id>` (panel, tile, Today-with-pinned), `/boss/new` (All bosses pill), `/boss/<id>/edit` (task Edit), `/victory/<relicId>` (final strike), `/bonfire` (tab, BonfireCard)
- [x] A140. Back behaviour after Today-with-pinned path (A44): `go` replaces the stack so back may have nowhere to return — verify

---

## SECTION 13. Cross-cutting checks

- [x] A141. Orientation: no handling in this area; check portrait only (iPhone sim)
- [-] A142. (kill mid-onboarding not tried) Backgrounding mid-onboarding keeps page/text; killing the app restarts at page 1 with text lost (only `onboarded` persists)
- [x] A143. Local UI state (filter chip, mood, Waiting expansion) resets when leaving the page
- [-] A144. (haptics need a device) Haptics (hold ticks, rest) only on a real device; manual check
- [-] A145. (long-text torture not done) Long-text torture: 80-char boss title in panel, chip, group header, All bosses; 60-char chapter names; 120-char meaning
- [-] A146. (emoji/accents not typed) Emoji/accents in title fields
- [x] A147. No server configured (`hasServer` false) — sync start is a no-op, no visible effect here [main.dart:34-37, day_resolver.dart:107-109]

---

## Unsure / flagged

1. A86: "Set waiting" on "The Day" from the long-press sheet probably throws an unhandled StateError (not awaited or caught); confirm visible behaviour.
2. BossCard progress for "The Day" with quick tasks: `isDay` makes `segments` = all tasks (hasSegments true) but phases are empty, so `currentPhase` is null and the card likely reads "All chapters done" (even with open tasks). Verify on All bosses.
3. Initial flask count on a fresh install assumed 3 (`kFlaskCap`); confirm via "You hold N flasks."
4. Time picker (A32) is the framework `showTimePicker` from `material_ui`; exact system strings not verified in code.
5. Page-2 disabled "Next" is a plain greyed TextButton, not an EmberButton (visual difference).
6. Detail of Promise sheet, Move-it-later sheet, Rule-of-three, Fallen screen, deadline label strings, Victory live in other maps; only triggers listed here.
7. IDs A81b-A81e are extra sub-items inserted after A81; A66 covers the flash line.

# Map B: Boss screen, strike, victory, fallen, commit (Hearthrise)

Paths relative to /Users/ashishvagish/Documents/projects/soul-tasker/app/lib. Format: `- [ ] ID. item — trigger — precondition (file:line)`.

Global facts
- Weights: Light = hold 300 ms, +1 ember, 1 pip, health cost 1 pt (2 half). Heavy = 600 ms, +3 embers, 2 pips, 2 pt. Boss-tier = 1200 ms, +6 embers, 3 pips, 3 pt (data/enums.dart:22-60). A "Tried" costs half the health. Max health 20 half points = 10 pts (core/commitment_resolver.dart:6).
- Health only drops via promises (commitments). No promise = no health loss.
- TaskRow always passes `onTried`, so EVERY finished hold (and every tap in tap mode) plays the sweep then asks "How did the strike land?". Nothing is written until the user picks (features/strike/hold_to_strike.dart:128-148).
- Boss screen has NO "boss health" number except shards `N / 12`. Hint line only when boss has phase segments.
- Reach the Boss screen: fresh install -> finish onboarding (/welcome) -> Home -> "New boss"/'+' (route /boss/new, other mapper) -> save -> auto `context.replace('/boss/<id>')` (features/boss_edit/boss_edit_screen.dart:108). Or tap a boss card on Home/Bosses list (features/home/boss_card.dart:101,113). Or Today tab when a boss is pinned+active: tab goes straight to /boss/<id> (features/shell/hearth_shell.dart:21-28).
- The Day (quick-tasks) boss id `boss-the-day`: BossScreen works for it too (isDay). Reachable from Bosses list (data/day_boss.dart).

## A. Boss screen shell (features/boss/boss_screen.dart)

- [x] B1. Boss screen loaded: Scaffold + SafeArea, header row + scrolling ListView — route `/boss/:id` — any boss exists (router.dart:51; boss_screen.dart:121-147)
- [x] B2. Header back button (GlassCircleButton, semantics "Back"): pops, or `go('/')` if cannot pop — tap — (boss_screen.dart:153-157,119)
- [x] B3. Header centre label "Chapter I of III" (Roman numerals; counts only phases that have a one-time phase task; blank when no phase fighting / no phases) — visible — boss with >=1 phase containing one-time tasks; moves to "Chapter II of III" after phase I fully struck (boss_screen.dart:334-342,161)
- [x] B4. Header "..." button (semantics "Boss actions") opens Boss actions sheet — tap — boss loaded (boss_screen.dart:167-171)
- [-] B5. (momentary) Header while view null: 48px blank placeholder, no "..." — boss deleted/not loaded (boss_screen.dart:172-173)
- [-] B6. (deep link only) Boss-gone state: header + centred text "This boss is gone." — open /boss/<unknown id> or boss deleted while open — (boss_screen.dart:134-139) (hard to reach on device; deep link only)
- [-] B7. (needs DB error) Error state text "Could not load this boss." — DB error — not reproducible normally (boss_screen.dart:140-142)
- [-] B8. (momentary) Loading state: empty SizedBox — momentary (boss_screen.dart:143)

### Boss panel (NeedleFrame key `boss-panel`, gradient)
- [x] B9. BossStage hand-drawn boss art (BossArt width 165), boils with atmosphere — always — (boss_stage.dart:126-130)
- [x] B10. Boss title (displaySmall) — always — (boss_screen.dart:222)
- [x] B11. Defeat meaning line (bodySmall under title), only if the boss has a "defeat meaning" set — create boss with meaning text — (boss_screen.dart:223-226)
- [x] B12. Meta line "Attempt N" + optional " · N days left" / " · 1 day left" (only when target date is in the future; "days left" rounds up) — boss with target date set — (boss_screen.dart:228-237; core/days_left.dart)
- [-] B13. (BLOCKED by finding 37 (fall lesson keyboard stuck)) Meta line suffix " · Last lesson: <italic lesson>" — after a declared/health fall with a typed lesson, Attempt >= 2 — need a fall with lesson (see fallen flow B90+) (boss_screen.dart:238-247)
- [x] B14. Health block, when boss has segments: label "Boss health", count "N / 12", ShardMeter 12 skewed shards (semantics "Boss health N of 12"); shards animate (drain) when struck — boss with >=1 one-time task in a phase (or The Day with any tasks) — (boss_screen.dart:252-265; ui/shard_meter.dart)
- [x] B15. No-segments text "This task is worn down by habit." — boss with no phase one-time tasks (only daily or only "Beyond the chapters" tasks, or no tasks) — (boss_screen.dart:266-270)
- [x] B16. Shards state matrix: 12/12 full (nothing struck), partial, 0/12 (all struck = vanquished) — strike tasks progressively — (shard_meter.dart:6 `round(health*12)`)

### Hint line / flash
- [x] B17. Hint "Each strike takes shards from the <title minus leading 'The '>." (e.g. "the Certification") — boss has segments and an unfinished phase — (boss_screen.dart:279-286,306-307)
- [x] B18. Hint switches to "<Title> kneels. Chapter II awaits." and boss art kneels (opacity 0.5, squashed, 1.4 s, 7 held steps) — phase >=2 is current, an earlier phase is fully done, and nothing struck yet in current phase (one-time) — boss with >=2 phases; strike all of phase I (boss_screen.dart:191-196,281-283; boss_stage.dart:28,48-51,108-116)
- [-] B19. (next-phase strike after kneel not done) Kneel clears when first task of the next phase is struck — (boss_stage.dart:79)
- [x] B20. Hint hidden (empty SizedBox) when no segments or boss done (no current phase) — (boss_screen.dart:279-288)
- [x] B21. FlashLine (36px, silk serif, fades 600ms) shows one-line messages; replaced each time — after any action: "It is done.", "You tried. That counts.", "Return when ready.", "Promised.", "Moved later.", "Already promised today.", "It cannot move later.", "It cannot move later today.", "No reminder without permission.", and the load note "That is six promises, four of them heavy." — see C/D below — (ui/flash_line.dart; boss_screen.dart:289)
- [x] B22. Flash cleared after a declared fall — (boss_screen.dart:66)

### Task list sections
- [x] B23. Current phase heading: phase name (22pt serif) + "N of M struck · hold to strike" + ThreadDivider — first phase with unstruck one-time task — (boss_screen.dart:309-331). M counts all tasks in phase incl. daily
- [x] B24. Non-current phase header: UPPERCASED phase name (labelSmall) and "Done" at right when all its one-time tasks struck — earlier OR later phases — (boss_screen.dart:344-355)
- [x] B25. Later (locked-looking) phase still lists its tasks as live rows (no actual locking) — phase II rows holdable before phase I done — (boss_screen.dart:290-296)
- [x] B26. "BEYOND THE CHAPTERS" header + rows for tasks with no phase — boss with tasks outside phases (The Day has all tasks here / segments count) — (boss_screen.dart:297-300)
- [x] B27. Boss with zero tasks: panel + "This task is worn down by habit." only, no rows — new boss with no tasks — (boss_screen.dart:266)
- [x] B28. Split tasks (isSplit) are hidden from the list; their replacements appear — after Rule-of-three split — (data/boss_view.dart viewsOf)
- [-] B29. (not produced) Phase with zero tasks shows heading only — (boss_screen.dart:290-296)

## B. Boss actions sheet ("..."), ui/boss_actions_sheet.dart

Sheet: label "BOSS ACTIONS", title = boss name, close pill "Close" (boss_actions_sheet.dart:34-37).
- [x] B30. Row "Leave for now" — shown when boss active and not The Day — tap -> glass alert (see B36) — (boss_actions_sheet.dart:42)
- [x] B31. Row "Set active" — shown when boss status waiting — tap sets status active, sheet closes, screen refreshes (header "..." then shows Leave for now) — boss was left via B36 — (boss_actions_sheet.dart:43; boss_screen.dart:106-107)
- [x] B32. Row "Edit" — always — pushes /boss/<id>/edit — (boss_actions_sheet.dart:44; boss_screen.dart:108)
- [x] B33. Row "Pin" / "Unpin" (toggles) — always; pinned+active boss makes Today tab jump straight here — (boss_actions_sheet.dart:45; boss_screen.dart:110)
- [x] B34. Row "Declare victory" — active or waiting, not The Day — tap -> confirmDefeat (B50) — (boss_actions_sheet.dart:46-47; boss_screen.dart:112)
- [x] B35. Row "This attempt failed" — active, not The Day — tap -> Fallen flow (B90) — (boss_actions_sheet.dart:48; boss_screen.dart:114)
- [x] B35a. The Day variant: only Edit and Pin/Unpin rows — open The Day -> "..." — (boss_actions_sheet.dart:27,42-48)
- [-] B35b. (defeated bosses are not listed, cannot open) Defeated-boss variant (status defeated): only Edit and Pin — open defeated boss from Bosses list -> "..." — (boss_actions_sheet.dart:22)
- [-] B35c. (waiting boss ⋯ not opened) Waiting-boss variant: Set active, Edit, Pin, Declare victory (no Leave, no failed) — (boss_actions_sheet.dart)
- [x] B35d. Close pill / tap scrim dismisses with no action — (glass_sheet.dart:90-93)
- [x] B36. Leave alert (GlassAlert): label = BOSS TITLE (caps), title "Leave the fight?", body "Struck tasks stay struck and you keep N embers. <Boss> waits where you left it.", actions "Keep fighting" (default, silk tint) | "Leave for now" — tap Leave for now: boss -> waiting, navigates `go('/')`; Keep fighting / scrim: nothing — (boss_screen.dart:92-105; glass_alert.dart)
- [-] B37. (not tried) Waiting boss rows: can't "Promise by…" (canCommit false), strike still works — open a waiting boss — (boss_screen.dart:186; task_row.dart:153)

## C. Task row (TaskRow -> HoldToStrike -> TaskRowTile)

Row layout (ui/task_row_tile.dart): left weight pips (1 diamond Light, 2 Heavy, 3 Boss-tier), title (16pt), meta line, optional deadline chip, right 48px hold button (struck: silk check).
- [x] B38. Row meta line "<Boss title> · +1 embers" (always plural "embers": "+1 embers", "+3 embers", "+6 embers") — idle task on Boss screen (bossName passed) — (hold_to_strike.dart:233-236; boss_screen.dart:187)
- [x] B39. Daily task title gets suffix " · daily" — task with recurrence daily — (task_row.dart:138-140)
- [x] B40. Pips: 1/2/3 diamonds in silk (struck: dim) per weight — create Light/Heavy/Boss-tier tasks — (task_row_tile.dart:112-114)
- [x] B41. Hold button idle: 48px glass ring, strike icon, semantics "Hold to strike: <title>" — (hold_to_strike.dart:209-217; ui/hold_button.dart)
- [x] B42. HOLD to strike (press and hold the ring, finger stays within touch slop): silk fill rises in ring, row edge turns silk (RowPhase.charge), row trembles 1px every 70 ms, haptic ticks building (Light 1 tick; Heavy 3 ticks+medium pulse; Boss-tier 5 ticks+medium pulse) — Light 300 ms / Heavy 600 ms / Boss-tier 1200 ms — (hold_to_strike.dart:57,67,99-112,202-207; enums.dart:22-37)
- [x] B43. Ring edge turns bone ("ready") past 80% of the hold — hold a Boss-tier task (1200 ms, easiest to see) — (hold_to_strike.dart:57,215; hold_button.dart:36)
- [-] B44. (early release not tried) Early release rolls fill back (reverse, Motion.quick) and nothing happens — release before full — (hold_to_strike.dart:70,179-181,224)
- [-] B45. (drag-cancel not tried) Drag/scroll cancel: finger moving beyond touch slop (~18px) cancels the hold and lets the list scroll — start on ring, drag — (hold_to_strike.dart:170-177)
- [x] B46. Hold completes: final haptic (Light light / Heavy heavy / Boss-tier double heavy) then landing sweep (see B47) — (hold_to_strike.dart:118-129)
- [x] B47. Strike landing animation (WORTH SCREENSHOTTING): 1300 ms (Boss-tier 1600 ms) — row flashes bone/inked "hit" 0-110 ms, "shatter" 110-500 ms (row shakes; Light shakes at 0.6x), "settle" 500-1300 ms; slash arc StrikeSweepView (Boss-tier variant heavier flecks); gold dust DustVanish over row (24 motes, 3x duration) — complete a hold — skipped entirely when system Reduce Motion on — (hold_to_strike.dart:150-158,188-200,249-269; strike_sweep.dart:13-15; ui/strike_sweep_view.dart:41-52)
- [x] B48. How-did-it-land sheet opens AFTER the sweep: GlassSheet label "HOW DID THE STRIKE LAND?", title = task title, close pill "Cancel", two framed choices: "Clean strike" / note "Done in full. Promise kept." (silk-tinted) and "A real try" / note "Part done. Effort still earns embers." — (ui/strike_result_sheet.dart:18-36; hold_to_strike.dart:134-148)
  - [x] B48a. Tap "Clean strike" -> task struck: row gets struck colours, ink line through title, meta "Struck · +N embers", silk check replaces ring, semantics "<title>, struck", pip dim; shard meter drains one shard-share; boss art flashes white then recoils (700 ms: wait, white 25-45%, recoil settles in 5 steps); Flash "It is done." — (task_row.dart:47-59; task_row_tile.dart; boss_stage.dart:80-82)
  - [x] B48b. Tap "A real try" -> row resets (not struck), Flash "You tried. That counts." (see B52 for effects) — (hold_to_strike.dart:142-144; task_row.dart:67-85)
  - [x] B48c. Tap "Cancel"/scrim -> nothing written, fill resets to 0 — (hold_to_strike.dart:145-146)
- [x] B49. Struck row is non-holdable (ring replaced by check); row tap still opens actions — (task_row_tile.dart:147-156; hold_to_strike.dart:166)
- [x] B49a. Tap mode (Settings "tap mode" switch ON): ring is a single-tap button, semantics "Complete <title>", tap goes straight to sweep + same Clean/Try sheet, no hold/tremble — Settings -> turn tap mode on — (hold_to_strike.dart:210-220; settings_screen.dart:120)
- [x] B49b. Struck daily task reappears unstruck the next day; struck one-time task unstruck after a fall reset (progress cleared) — clock +1 day / fall — (boss_view.dart:isStruck; hold_to_strike.dart:86)
- [-] B49c. (system Reduce Motion not toggled) Reduce Motion: sweep, kneel, stamp skipped (value jumps to end) — iOS Settings > Accessibility > Motion > Reduce Motion — (hold_to_strike.dart:151-152; boss_stage.dart:66)
- [-] B49d. (dead code) Stripe: BossStage `stamp` ("Struck" italic stamp over the boss, -5 deg, 700 ms 4 held steps) exists but BossScreen never sets stamp:true (only `felled`). NOT user-reachable — (boss_stage.dart:14-30,143-182; boss_screen.dart:220)

## D. Victory path

- [x] B50. Final strike of the last segment (isVanquished) -> ConfirmDialog (GlassAlert, no title): body "Mark this boss as defeated?" actions "Defeated" (default) | "Not yet" — strike last unstruck one-time phase task, or "Declare victory" in "..." — boss with segments, all other tasks struck; not The Day — (task_row.dart:57-58,162-172; ui/confirm_dialog.dart)
- [x] B51. "Not yet": boss stays active with 0/12 shards; may later use "Declare victory" — (task_row.dart:172)
- [x] B51a. "Declare victory" from "..." works on a boss that still has unstruck tasks (waiting/active) — (boss_screen.dart:112-113)
- [-] B51b. (not tried from Today) Task done-late strike path that triggers vanquish from the Today tab uses same dialog — Today -> hold a task of a nearly-won boss — (features/today/today_view.dart:229)
- [x] B51c. Defeated tap: boss status -> defeated, then BossVanish overlay, then push /victory/<relicId> — (task_row.dart:173-179)
- [x] B52. Boss vanish (WORTH SCREENSHOTTING): barrier 92% void black, boss title (serif, bone, glow) dissolves into 140 white-gold motes over 2.4 s ease-in, auto-dismisses; no buttons; skipped under Reduce Motion — tap Defeated — (features/strike/boss_vanish.dart:7-77)

### Victory screen (features/victory/victory_screen.dart), route /victory/:relicId
- [x] B53. Entry: double-heavy haptic + victory sound; 5 s staged fade-in (sections 0..4 fade sequentially); back gesture/button = same as "Return to the hearth" (PopScope canPop:false) — reach via B50-B52 — (victory_screen.dart:41-53,84-89)
- [x] B54. Relic emblem (RelicEmblem size 140, weathering per relic) at top — (victory_screen.dart:105)
- [x] B55. Heading "<Name> falls." where name = relic name minus "Relic of " (e.g. "Relic of The Certification" -> "The Certification falls."), 42pt — fades in 1st — (victory_screen.dart:107-114)
- [x] B56. ThreadDivider (200 wide) — (victory_screen.dart:116)
- [x] B57. "Taken in" [big number, key victory-attempts] "attempt" / "attempts" ("attempt" only when exactly 1) — first-try win vs after falls — (victory_screen.dart:118-137)
- [x] B58. StatRow: "<days>" / "Days"  |  "<effort>" / "Embers" — (victory_screen.dart:139-147)
- [-] B59. (no lesson saved (finding 37)) "What the falls taught you" heading + LessonTimeline rows (Roman attempt numeral in silk + italic lesson text; "a missed day" sub-caption for lessons from a missed day) — only if story has lessons (>=1 fall with lesson) — boss fell >=1 time, typed lesson — (victory_screen.dart:148-168; ui/lesson_timeline.dart)
- [x] B60. No lessons: heading and timeline absent — win first try or falls skipped lessons — (victory_screen.dart:148,156)
- [x] B61. InscriptionField: label "Inscription", live counter "<len> / <kInscriptionMax>" (max from core/weathering.dart), framed TextField hint "A line to remember this by"; no Save button here — type text — (ui/inscription_field.dart; victory_screen.dart:170)
- [-] B62. (used "Keep as a relic" instead) EmberButton "Return to the hearth": saves inscription if non-empty, `go('/')` (Home) — tap — (victory_screen.dart:177,71-79)
- [x] B63. Framed button "Keep as a relic": saves inscription, `go('/')` then pushes /relic/<id> (Relic detail screen, other mapper) — tap — (victory_screen.dart:179-190)
- [-] B64. (system Reduce Motion) Reduced motion: whole screen shown immediately — (victory_screen.dart:48-49)
- [-] B65. (momentary) Blank screen (SizedBox) until relic loads (momentary) — (victory_screen.dart:91)

## E. Foe actions sheet (tap row away from the ring), ui/foe_actions_sheet.dart

Sheet: label "TASK ACTIONS", title = task title, close pill "Cancel". (foe_actions_sheet.dart:51-53)
- [x] B66. Row "Promise by…" — task unstruck, no promise today, boss ACTIVE — tap -> Commit sheet (B72) — (foe_actions_sheet.dart:58; task_row.dart:153)
- [x] B67. Row "Move it later" — promise open and deadline still ahead — tap -> Extend sheet (B80) — (foe_actions_sheet.dart:59; task_row.dart:132-135)
- [x] B68. Row "Mark as tried" — task not struck — tap -> try flow (B70) — (foe_actions_sheet.dart:60; task_row.dart:109)
- [x] B69. Rows "Edit" (push /boss/<id>/edit) and "Delete" (confirm B69a) — always — (foe_actions_sheet.dart:61-62; task_row.dart:86-94)
- [x] B69a. Delete confirm: GlassAlert body `Delete "<title>"?`, actions "Delete" (default) | "Not yet"; Delete removes task — (task_row.dart:88-94; confirm_dialog.dart)
- [-] B69b. (struck-row actions not opened) Struck task: sheet has only Edit + Delete (+Move it later if somehow promised) — tap a struck row — (task_row.dart:109)
- [x] B69c. Sheet variants matrix: (promise available) / (promised + extendable) / (promised past deadline or closed: no promise/move rows) / struck / waiting-boss (no Promise row) — see preconditions in section G

## F. Tried flow and Rule of three

- [x] B70. "Mark as tried" or "A real try": records try, earns half embers (rounded up), Flash "You tried. That counts."; if the task had an OPEN promise today: promise closes as "tried" (chip "tried") and health drops by HALF the weight cost (Light -0.5, Heavy -1, Boss-tier -1.5) — task with promise + tried — (task_row.dart:67-85; data/attempt_dao.dart:165-202)
- [x] B71. Rule of three: on the 3rd, 6th, 9th... try since the last strike for one task, sheet opens automatically: GlassSheet title "Same path, same result. What will you change?", close pill "Close", rows "Change the approach" / "Split into smaller tasks" / "Rest first" / "Keep going" — mark the same task as tried 3 times (no strike between) — (features/boss/rule_of_three_sheet.dart:49-80; attempt_dao.dart:200; boss_view.dart isRuleOfThree)
  - [-] B71a. (not tapped) "Change the approach" -> pushes boss edit /boss/<id>/edit — (rule_of_three_sheet.dart:30-31)
  - [x] B71b. "Split into smaller tasks" (task-level) -> split sheet B71e — (rule_of_three_sheet.dart:32-39)
  - [x] B71c. "Rest first" -> Flash "Return when ready." — (rule_of_three_sheet.dart:42-43)
  - [-] B71d. (not tapped) "Keep going" / Close / scrim -> nothing — (rule_of_three_sheet.dart:44-45)
  - [x] B71e. Split sheet: title `Split "<original>"`, close pill "Cancel", two NeedleTextFields captions "Smaller task 1", "Smaller task 2" (autofocus first), "Add another" text button until 5 fields, ActionRow "Split" appears only when >=2 non-empty titles; Split replaces original with N smaller tasks (one weight lighter, min Light) — (rule_of_three_sheet.dart:84-142; enums.dart:62)
- [ ] B71f. Phase-level rule of three (no task): after the 3rd consecutive declared fall in the SAME phase, same sheet opens after the Fallen flow; "Split into smaller tasks" then just opens boss edit (no split sheet) — fall (B90) 3 times in a row with same current phase — (boss_screen.dart:67-73; rule_of_three_sheet.dart:40-41; boss_view.dart samePhaseFallRun)

## G. Commit (Promise) and Extend flow (features/commit/commit_flow.dart)

Commit sheet (ui/commit_sheet.dart): label "PROMISE BY", title task title, close pill "Cancel".
- [x] B72. Commit sheet rows (TimeChoiceRow): "In 1 hour", "In 3 hours", "Tonight" — tap one commits immediately and closes — Foe actions -> "Promise by…" — (commit_sheet.dart:47-48; core/deadlines.dart:5-9)
- [-] B73. (reminder switch not used on commit) Switch "Remind me 10 minutes before" (GlassSwitch, row tappable) — toggle then pick a time; on commit asks iOS notification permission (system prompt "Allow Notifications?") — (commit_sheet.dart:50-54; commit_flow.dart:51-54)
- [x] B74. Switch "Every day" — ONLY for daily tasks; makes the chosen time the standing deadline each day — create a daily task — (commit_sheet.dart:55-60; commit_flow.dart:57-61)
- [-] B75. (not produced) Permission denied -> Flash "No reminder without permission." then promise still made — decline iOS notification prompt — (commit_flow.dart:51-54)
- [x] B76. After commit: Flash "Promised." — (commit_flow.dart:63)
- [x] B77. Heavy-day note: when today has >=6 promises, sheet shows bodySmall note "That is six promises, four of them heavy." (count word, heavy = non-Light count) before committing, and Flash shows the same text after committing instead of "Promised." — make 6 promises today (use 6 tasks / The Day) — (commit_flow.dart:14-17,43,62-63; commitment_dao.dart:71,240-250)
- [-] B78. (race only) Already promised: Flash "Already promised today." — only via race/standing (one promise per task per day; row hides Promise option normally) — (commit_flow.dart:56)
- [x] B79. Deadline chip on the row (ui/deadline_chip.dart): "by 3:41 PM" (12-hour clock, > 1 h away); "in 12 min" (ember/silk edge+text, within 60 min, minute clamp 0-60); outcomes after close: "kept", "tried", "missed", "frozen", "done late", "set aside" (muted) — promise a task; chip sits left of the ring — (core/deadlines.dart:69-92; task_row.dart:129-149)
  - Tonight = today 23:00 (or end of ritual day if already past 23:00); 1h/3h clipped to end of day (deadlines.dart:36-45).
  - "in N min" easiest: choose "In 1 hour" (shows "in 60 min" immediately because left <= 1 h).
- [-] B79a. ("kept" chip not produced) Chip "kept": strike (clean) a promised task before deadline — (attempt_dao.dart:135-136)
- [x] B79b. Chip "done late": strike a task whose promise was missed/frozen — (attempt_dao.dart:137-141)
- [-] B79c. (not produced) Struck row hides Promise option but chip persists as "kept" — (task_row.dart)

Extend sheet (ui/extend_sheet.dart): title "Move it later", close pill "Cancel", no label.
- [x] B80. First extension: caption "Free, once." + TimeChoiceRows for presets that would land later ("In 1 hour"/"In 3 hours" add to current deadline, "Tonight" absolute) — Foe actions -> "Move it later" on a promised task — (extend_sheet.dart:27-47; deadlines.dart:51-65)
- [x] B81. Second+ extension costs a flask: caption "Costs a flask. You hold N." — extended once already, flasks > 0 (fresh install has flasks? check Profile/Bonfire FlaskPips; flask count seeded by flask_dao) — (extend_sheet.dart:32)
- [x] B82. Blocked: caption "No flask left to move it again." and rows dimmed/disabled — extended once and 0 flasks — (extend_sheet.dart:27-31,43)
- [x] B83. After picking: Flash "Moved later." (or "It cannot move later." if refused) — (commit_flow.dart:102-103)
- [-] B84. (not produced) No options: Flash "It cannot move later today." instead of a sheet — near end of day (e.g. promise already at Tonight/end of day) — (commit_flow.dart:91)
- [x] B84a. Chip updates to the new time; flask pips elsewhere decrease — (commit_flow.dart)

Deadline reminders (features/commit/deadline_reminders.dart) — non-visual: schedules iOS local notification 10 min before deadline (body = task title) for promises made with "Remind me" switch while that time is still ahead; cancelled on strike/delete/day change. Lead = 10 min (kReminderLead). Manual check: promise "In 1 hour" with reminder ON, wait ~50 min or set sim clock; see lock-screen notification.
- [-] B85. (notification delivery not checked) Reminder notification fires 10 min before deadline — requires notification permission granted — (deadline_reminders.dart:8,22-51)
- [-] B85a. (not produced) No notification if deadline is < 10 min away at commit time — promise cannot get "In 1 hour" shorter; use Tonight near 23:00 — (deadline_reminders.dart:27-29)

Deadline passing (consequence of a promise):
- [-] B86. (snackbar needs app open as a deadline passes) Deadline passes while app open: checked every 60 s (kDeadlineTick) and on every strike/try: promise becomes "missed" (chip "missed"), health -(1/2/3 pts by weight), quiet snackbar "A deadline passed: <task>." (or "two deadlines passed." etc.) on Home — promise "In 1 hour" then set sim clock +1h (or wait) and keep app open ≥1 min — (features/ritual/day_resolver.dart:74-76,125-132,204-210; core/deadlines.dart:14)
- [x] B87. Deadline passed while app was closed/backgrounded: on resume AwaySummary alert: label "WHILE YOU WERE AWAY", title "A deadline passed." / "Two deadlines passed." etc., one framed row per task (title left, cost right "−1 health"/"−2 health"/"−3 health" or "frozen"), per row text button "Done late" (strikes it, row marks done), action "Go on" — promise, background app, change clock +1h, reopen — (ui/away_summary.dart; day_resolver.dart:212-241)
- [-] B88. (precondition unknown) Frozen outcome ("frozen" chip, no health loss) — likely when the day was covered by bonfire/flask/light; UNSURE of exact precondition (data/health_dao.dart `_makeStanding`/`_due`)
- [-] B89. (standing daily not checked next day) Standing daily deadline: daily task committed with "Every day" gets a promise automatically each new day — daily task + Every day ON, advance clock a day — (commit_flow.dart:57-61; health_dao.dart:169)

## H. Fallen (declared fall, missed day, health death)

Fallen screen (features/fallen/fallen_screen.dart): non-opaque route, fades in 1.4 s (Motion.dim) over the void; heavy haptic + fallen sound.
- [x] B90. Declared fall: Boss "..." -> "This attempt failed" -> FallenScreen with story — active non-Day boss — (boss_screen.dart:43-75)
- [x] B91. Content top-to-bottom: "Fallen." (60pt, letter-spacing 8) / subtitle "Attempt N ends. The <Boss> remains, and so do you." ("The " added unless title already starts with "The ") / SnappingThread (thread splits at 1.2 s) / health row diamond pip dimming at 1.6 s + "<health> / <max>" (e.g. "10 / 10", "3.5 / 10") / embers count (comma thousands) + "Embers kept" / "What did this teach you?" / framed TextField hint "One line." (max 120, 3-4 lines) / caption "You will see it at the start of attempt N+1." / EmberButton "Rise" / text button "Rest first. Write it tomorrow." — (fallen_screen.dart:204-286)
- [x] B92. "Rise": pops with typed lesson (trimmed); "Rest first. Write it tomorrow." pops null (no lesson). Both then execute the fall — (fallen_screen.dart:270-280; boss_screen.dart:62-64)
- [x] B93. After fall: attempt number +1, lesson becomes "Last lesson:" line (B13) if non-empty; reset per boss setting resetOnFail: "Nothing" (struck tasks remain), "Current chapter" (current phase tasks reopen, struck reset), "Whole boss" (all phases reopen; kneel/shards back to 12/12) — fall a boss with some struck tasks, three different configs (set in boss Edit) — (attempt_dao.dart:327-352; enums.dart:11-18)
- [-] B94. (not produced) Fall with no segments / "Nothing" reset: shards unchanged — (attempt_dao.dart:338-339)
- [x] B95. Daily tasks are not affected by reset (they key off today) — (boss_view.dart isStruck)
- [x] B96. Fallen screen with no story (missed day via DayResolver, flask declined): subtitle "Rest, then rise.", no thread/health/embers, no attempt caption — missed a whole day with no flask (clock +2 days) — (fallen_screen.dart:225-231; day_resolver.dart:171-177)
- [x] B97. FlaskChoice dialog (AlertDialog, barrier non-dismissible): title "A day passed without rest." / "N days passed without rest."; content "You hold N flask(s)." (singular "flask" when 1); buttons text "Let it fall" (ash) and EmberButton "Use a flask" — day(s) missed with an active boss and flasks > 0 — advance sim clock a day w/o visiting bonfire; "Use a flask" spends min(flasks, daysMissed) and avoids fall — (ui/flask_choice.dart; day_resolver.dart:146-160)
- [x] B98. Health death (health reaches 0): FallenScreen with record: story absent, shows: "Rest, then rise." subtitle; line "<Count word> promised, <count word> kept." (capitalised, only if promised > 0); AccuracyLine "Today: K of M kept. This week: K of M." (parts hidden if made = 0); in first 7 days grace line "Your first week: nothing is lost but health."; plus lesson field/Rise/Rest buttons (no "You will see..." caption) — drain health to 0: 20 half-points = e.g. 4 Boss-tier promised tasks missed (3 pts each => 12; need ~10 pts: 4 boss-tier misses = 12 pts), or 7 Boss-tier promised then "Mark as tried" (1.5 pts each = 10.5), or 5 Heavy misses; Easiest: create 4 Boss-tier tasks, promise "In 1 hour", set sim clock +90 min, resume app — (fallen_screen.dart:129-158; features/fallen/health_fall.dart:15-56)
- [-] B99. (not produced) Health death auto-triggers while striking/trying: if a strike settles a passed deadline that kills, FallenScreen appears from the row action (task_row.dart:47-56,72-76) and lesson stored on fall rows; offered once per app run (offeredDeathsProvider) — (health_fall.dart:10,47)
- [-] B100. (not produced) Health-death from "Mark as tried": a promised boss-tier try that crosses 0 triggers failBoss(healthDeath) + fall screen — (attempt_dao.dart:189-197)
- [x] B101. Fallen screen scrim/back: no back button; only Rise or Rest — (fallen_screen.dart:270-280)
- [x] B102. Fallen record variants: kept==promised, none promised (numbers block shows only accuracy line hidden), grace week on/off (first week from install; after 7 days needs clock +8 days) — (health_fall.dart:17-29)

## I. Player health UI shown near this area (ui/player_health_bar.dart, flask_pips.dart) — also on Today/Profile/Bonfire
- [x] B103. PlayerHealthBar: 10 pips (20 half points / 2), each full/half/empty; semantics "Health 7 of 10" / "Health 3.5 of 10", prefixed "Fallen. " at 0 — Today header (today_view.dart:137), Profile (profile_screen.dart:87) — drain health per B98
- [x] B104. FlaskPips: circles filled for flasks held, capped at kFlaskCap; semantics "Flasks N of cap" — Bonfire (bonfire_screen.dart:296), Profile (profile_screen.dart:82) — spending flasks via B81 reduces
- [x] B105. StrengthSegments (task weight picker "Light/Heavy/Boss-tier" with pips and "+N embers" notes) used in New foe / task edit sheets (other mapper: boss_edit) — features/boss_edit/new_foe_sheet.dart:117, task_edit_sheet.dart:99; ui/strength_segments.dart
- [x] B106. PhasePanel (boss editor chapter card: drag handle, Roman numeral, "Chapter name" hint field, "Delete chapter" tooltip X, foe rows with chevron, "Add a task" button) — boss edit screen only (other mapper): ui/phase_panel.dart; boss_edit_screen.dart:280

## J. Conditional-state quick recipes (preconditions)

- [x] B107. Boss with phases (chapters) + one-time tasks: create boss, add phases "Chapter" names and tasks within; gives Chapter header (B3), kneel (B18), "Done" headers (B24)
- [x] B108. Boss with no phases: tasks land under "BEYOND THE CHAPTERS" (B26); shards still count? NO: segments only count phase tasks, so shards/hint absent and B15 text shows unless The Day — (boss_view.dart:60-66)
- [x] B109. The Day boss: every task counts as a segment, no phases, no vanquish (refills each morning), no Leave/Victory/Fail — Bosses list -> The Day, or quick-add tasks — (boss_view.dart:60-62,67-69; boss_actions_sheet.dart:27)
- [x] B110. Recurring (daily) tasks: " · daily" title suffix, not a segment, struck state resets next day, "Every day" switch on commit, excluded from phase "Done" test — (boss_view.dart:20-24,32-34)
- [x] B111. Weights: create a Light, Heavy and Boss-tier task and hold each (B42/B46 timings and haptics; boss-tier also changes sweep to 1600 ms heavier flecks)
- [x] B112. resetOnFail variants: set in boss Edit (other mapper) to Nothing / Current chapter / Whole boss then fall (B93)
- [x] B113. Past deadline: promise then change sim clock (Settings > General > Date & Time off Auto) +1 h/+1 day; closed chip texts B79
- [x] B114. Near deadline: "In 1 hour" shows chip "in 60 min" in ember/silk with silk border (isSoon) from the start; "in N min" counts down — (deadlines.dart:79-82)
- [x] B115. Flasks available/empty: see B81/B82; flask supply managed on Bonfire (other mapper)
- [-] B116. (not tried) Commitments on waiting/defeated boss: Promise row hidden; commit() also refuses non-active bosses (returns null -> "Already promised today.") — (commit_flow.dart:56; commitment_dao.dart:97)

## K. Animations worth screenshotting (summary)
- [x] B117. Charge: ring fill rising + silk row edge + tremble (hold Boss-tier mid-way) — hold_to_strike.dart:202,215
- [x] B118. Slash/hit/shatter/settle + gold dust + boss white flash/recoil — landing of a strike (B47, B48a)
- [x] B119. Boss kneel (B18)
- [x] B120. Boss vanish dust (B52)
- [x] B121. Victory staged fade (B53-B63) over 5 s
- [x] B122. Fallen dim-in + thread snap at 1.2 s + pip dim at 1.6 s (B91)
- [x] B123. Shard meter drain colour tween (Motion.drain) on strike (B14)

## Items I am unsure about
- Frozen outcome precondition (B88).
- Flask starting count on fresh install and kFlaskCap value (B81).
- BossStage.stamp ("Struck" stamp) is dead code in BossScreen (B49d).
- Notification permission dialog appearance depends on iOS simulator state (B73/B85).
- Today tab view of TaskRow is the same widget (features/today/today_view.dart:229) but without canCommit param override (defaults true) and with bossName shown; Today layout belongs to another mapper.
- Day-boss quick task flow: reachable from Home "quick task" (other mapper).

# Map C: boss edit, new task sheet, bonfire, profile, relic, settings, sync, tester report

Paths relative to /Users/ashishvagish/Documents/projects/soul-tasker/app/lib. Format: `- [ ] ID. item — trigger — precondition`.
Fresh install: StartGate (features/onboarding/start_gate.dart) redirects `/` and `/today` to `/welcome` (onboarding) until onboarded. Finish onboarding first (other map). Defaults on fresh DB: tapMode off, haptics on, rollover 4 (4:00 AM), reminder off, reminder time 1260 = 9:00 PM, default reset = Nothing (index 0), biome = Pharloom (index 0), motionEffects on (so "Reduce motion" OFF), sound off (no UI in my area).
Typography note: sheet labels are upper-cased by GlassSheet (glass_sheet.dart:76) and `labelSmall` captions may be styled caps by theme.

## 0. Routes and entry paths (core/router.dart)
- [x] C1. Route table: tabs (ShellRoute with glass tab bar Home, Today, Bonfire, Profile): `/`, `/today`, `/bonfire`, `/profile`; full-screen: `/bosses`, `/welcome`, `/settings`, `/relic/:id`, `/boss/new`, `/boss/:id`, `/victory/:relicId`, `/boss/:id/edit` — core/router.dart:24-64 — n/a
- [x] C2. Tab bar labels "Home", "Today", "Bonfire", "Profile" (ui/glass_tab_bar.dart:17); Today tab opens the pinned active boss's fight (`/boss/<id>`) if one is pinned, else `/today` (features/shell/hearth_shell.dart:16-25) — tap tab — onboarded
- [x] C3. Reach Profile: Home header profile button (semantic "Your profile", ui/home_header.dart:57) OR Profile tab → `/profile` (go) — fresh install after onboarding
- [x] C4. Reach Settings: Home header settings button (semantic "Settings", ui/home_header.dart:63) → `/settings` (push) — Home only (not on Today/Bonfire/Profile tabs)
- [x] C5. Reach Bonfire: Bonfire tab, OR Today tab BonfireCard (home_screen.dart:72) → `/bonfire` — onboarded
- [x] C6. Reach New boss: Home → "All bosses" row (home_screen.dart:89) → `/bosses` → glass pill "Name a new boss" (home/bosses_screen.dart:83) → `/boss/new`; also Home "New task" plus (FoesHeader key `new-foe`, semantic "New task") when NO active boss exists (home_screen.dart:121-123) — fresh install, but the default "The Day" boss may exist as an active boss (data/boss_dao.dart:228-246), in which case the plus opens the New task sheet instead (see C60)
- [x] C7. Reach Edit boss: Boss screen (`/boss/:id`) ⋯ → Boss actions sheet → "Edit" (boss/boss_screen.dart:109; ui/boss_actions_sheet.dart:44) → `/boss/:id/edit`; also task ⋯ menu "Edit" (task_row.dart:87), and Rule-of-three sheet "change"/"split" without a task (boss/rule_of_three_sheet.dart:31,41) — boss exists
- [x] C8. Reach Relic: Profile → Hall of relics tile tap → `/relic/<id>` (profile_screen.dart:109); also Victory screen button (victory/victory_screen.dart:78) — need ≥1 defeated boss (Boss ⋯ → "Declare victory" when all phase tasks struck)
- [-] C9. (deep link only) `/boss/:id/edit` with unknown id shows error text "This boss is gone." (boss_edit_screen.dart:61) — deep link only (xcrun simctl openurl needs custom scheme; likely untestable, otherwise delete a boss then reopen)

## 1. Boss edit screen: NEW boss (`/boss/new`) — features/boss_edit/boss_edit_screen.dart
- [-] C10. (momentary) Loading state: body is centered empty text (`_error ?? ''`) until draft loads (line 211) — momentary on open
- [x] C11. Header row: GlassCircleButton back (semantic "Back"; pop if can pop else go `/`) (183-188); title "A new boss" (191); GlassPillButton "Save" (198) — open `/boss/new`
- [x] C12. "Save" disabled (onTap null) until draft.canSave = title non-empty AND every chapter has a non-empty name AND at least one task exists (standalone or in any chapter) (data/boss_draft.dart:94-99) — fresh new boss starts disabled
- [x] C13. Thread divider under header (205-208)
- [x] C14. Title field: caption "Title", hint/placeholder "A goal worth a fight", max 80 chars, counter hidden (NeedleTextField default maxLength 80, ui/needle_text_field.dart:15,58) — type
- [x] C15. Defeat meaning field: caption "What does defeat mean?", NO hint, maxLength 200 (237-241) — optional
- [x] C16. Target-date row: calendar icon + "Set a target date" (when none) in needle frame (374-377) — tap opens Material `showDatePicker` (range: Jan 1 of last year to Dec 31 of year+10; initial = existing or today) (159-168); picking a date shows "Target: <medium date e.g. Oct 25, 2026>"; picker has its own Cancel/OK buttons
- [x] C17. Clear target date: close "X" IconButton, tooltip "Clear target date", only shown once a date is set (387-393)
- [x] C18. Reset choice row: title "On a failed attempt, reset"; 3 segments: "Nothing", "Current chapter", "Whole boss" (data/enums.dart:11-17); preselected from Settings default (Nothing on fresh install; change in Settings to see preselect change) (245-250). Semantics: each segment button, selected flag, label=option text
- [x] C19. Thread divider, then section header row "Chapters" (serif 22) with right-aligned hint "Hold the grip to reorder" (254-268)
- [x] C20. New boss starts with ONE blank chapter panel (PhaseDraft(name:'')) (57); Roman numeral "I" (core/roman.dart), drag handle icon (≡, grip), name field hint "Chapter name" maxLength 60, close X tooltip "Delete chapter", then foe rows, then TextButton "Add a task" (ui/phase_panel.dart:54-126)
- [x] C21. Reorder chapters: press-and-drag the grip (ReorderableDragStartListener, buildDefaultDragHandles false) — needs ≥2 chapters (add one via "Add a chapter") (269-277). Roman numerals renumber. Tasks are NOT reorderable.
- [x] C22. Rename chapter: type in chapter name field (285-292). Blank chapter name keeps Save disabled
- [x] C23. Delete chapter (X): if chapter has 0 tasks, deletes immediately with no confirm; if it has tasks, confirm dialog (C24) (145-157). Deleting the last chapter leaves zero chapters (allowed; standalone tasks can still save)
- [x] C24. Confirm dialog (GlassAlert, ui/confirm_dialog.dart:17-20): body `Delete this chapter and its N tasks?` (N always plural "tasks", even 1: "its 1 tasks"), actions ["Delete" (silk tint, default), "Not yet"]; tap outside = cancel — chapter has ≥1 task
- [x] C25. Chapter "Add a task" → Task sheet in new mode (C40) bound to that chapter (294-298)
- [x] C26. Foe row inside chapter: title + note `<Weight label>` plus ` · daily` if daily (e.g. "Heavy · daily"), chevron; tap → Task sheet in edit mode (299, 346-350)
- [x] C27. TextButton "Add a chapter" appends blank chapter (303-313)
- [x] C28. Section "Beyond the chapters" (serif) with caption "Tasks that belong to the boss but no chapter, like daily habits." (315-320)
- [x] C29. Standalone task lines (same layout: title, "<Weight>[ · daily]", chevron); tap edits (321-322, 401-446)
- [x] C30. TextButton "Add a task" (key `add-standalone-task`) → Task sheet new mode, chapter = "Beyond the chapters" (323-328)
- [x] C31. "Delete boss" button is ABSENT in new-boss mode (only `widget.bossId != null`, 329) 
- [x] C32. Save outcome new boss: saves, then `context.replace('/boss/<id>')` (opens the new boss's fight screen) (101-112). Save outcome edit boss: pop back if possible, else replace with `/boss/<id>`
- [-] C33. (needs save error) Save error: red/silk text at top of form `Could not save: <exception>` (110, 225-229) — hard to force
- [x] C34. NO discard-changes dialog: Back button pops immediately and loses edits (187) — verify by typing then Back
- [x] C35. Keyboard: fields autofocus off on this screen; ListView scrolls; typing in chapter field calls onRename per keystroke

## 2. Boss edit screen: EDIT boss (`/boss/:id/edit`)
- [x] C36. Title reads "Edit boss" (191); fields prefilled (title, defeat meaning, target date, reset, chapters with names and tasks, standalone tasks) from BossDraft.fromView (data/boss_draft.dart:60) — open Edit from boss ⋯
- [x] C37. "Delete boss" TextButton at bottom (ash colour) (329-338) → confirm dialog `Delete "<boss title>" and all its history?` actions ["Delete","Not yet"] → on confirm deletes and `go('/')` (114-123). NOTE: uses draft title (current edited text). Not shown for new boss
- [x] C38. The Day boss ("The Day", data/boss_dao.dart:228-246) is also editable via this screen if reachable; delete would remove it (it is re-created on demand) — Boss ⋯ on The Day: sheet omits Leave/Failed/Victory (ui/boss_actions_sheet.dart:42-48)
- [-] C39. ("Change the approach" not tapped) Edit boss from Rule-of-three sheet ("change"/"split"): same screen (boss/rule_of_three_sheet.dart:31)

## 3. Task edit sheet (boss_edit/task_edit_sheet.dart) — GlassSheet (grabber, header, Cancel pill, thread)
- [x] C40. New task mode: header title "A new task" (no small label), closeLabel pill "Cancel" (glass_sheet.dart:18, task_edit_sheet.dart:83); name field caption "Name the task", hint "What will you do?", autofocus ON (keyboard opens), maxLength 80, caption styling small label (not plain) (92-98)
- [x] C41. Edit task mode: title "Edit task", prefilled name, no autofocus, plus "Delete" row (142-147) 
- [x] C42. Strength selector (StrengthSegments, ui/strength_segments.dart): 3 segments, each shows 1/2/3 diamond pips, label, note: "Light" "+1 embers", "Heavy" "+3 embers", "Boss-tier" "+6 embers" (note text is literally "+1 embers", even for 1) (data/enums.dart:22-37). Semantics label "<Label>, +N embers". Default for tasks created in the boss editor = Heavy (data/boss_draft.dart:11) 
- [x] C43. "Every day" switch row (SettingSwitchRow, GlassSwitch semanticLabel "Every day"); on → recurrence daily, row note in list becomes "· daily" (113-121). Whole row tappable
- [x] C44. "Chapter" dropdown (Material DropdownButtonFormField, label "Chapter"): items for each chapter (name, or "Unnamed chapter" if blank) plus "Beyond the chapters"; default = the chapter it was opened from, else "Beyond the chapters" (122-139). Moving chapter appends the task at the end of the target list
- [x] C45. "Done" ActionRow appears ONLY when trimmed name is non-empty (140-141); returns to form with task saved into draft (not DB until boss Save)
- [-] C46. (delete-in-sheet not tried) "Delete" ActionRow (edit mode only) removes task from draft immediately with NO confirm (142-147)
- [x] C47. "Cancel" pill / drag-down / scrim tap discards sheet changes
- [x] C48. Sheet with keyboard: bottom padding follows viewInsets (85-87)

## 4. New task sheet (Home "New task") — boss_edit/new_foe_sheet.dart
- [x] C49. Trigger: Home FoesHeader plus button (semantic "New task", ui/foes_header.dart:33) → home_screen `_newFoe` (116-127): if no ACTIVE boss exists → pushes `/boss/new`; else shows this sheet — onboarded, Home tab
- [x] C50. Sheet header: small label "TODAY’S TASKS" (curly apostrophe, uppercased), title "A new task", pill "Cancel" (94-96)
- [x] C51. Name field: caption "Name the task" (plain bold caption), hint "What will you do?", autofocus, maxLength 80 (105-111)
- [x] C52. "Strength" label + same 3 StrengthSegments as C42; DEFAULT here = Light (50)
- [x] C53. "Strikes at" label + needle-framed row showing the selected boss title + "›" (131-169). Default boss: The Day if present, else pinned boss, else first active (51-54). Tap → picker sheet
- [x] C54. Boss picker sheet (nested GlassSheet): small label "STRIKES AT", title "Which boss?", Cancel pill, one ActionRow per active boss title (62-80). Only active bosses are passed in
- [x] C55. EmberButton "Add to today" with strike icon (170-174): ignored if name blank; else pops with (boss, task). Outcome: if boss is The Day → `addQuickTask` (daily, chosen weight); else boss saved with new standalone task (31-37). New task appears on Home/Today list
- [x] C56. "Cancel" discards

## 5. Bonfire screen (`/bonfire`, tab) — features/bonfire/bonfire_screen.dart
- [x] C57. Blank until day status & summary load (160-161)
- [x] C58. Header: GlassCircleButton back (semantic "Back to bosses", go `/`) + caption "BONFIRE" (174-180)
- [-] C59. (audio not checked (no sound files ship)) Bonfire hum sound starts on open, stops on leave/background (55-67) — manual audio check (sound setting default off may gate)
- [x] C60. STATE A (default, not rested, not fallen) `_plan` (249-320): big centered "Rest a while." (display 44); sub-line `Night N at the hearth. Tell it how the day went.` (N = rests so far + 1; fresh = "Night 1"); thread divider; "How did today go?"
- [x] C61. Mood choice (ui/mood_choice.dart): 3 segments "Fought well", "Held on", "I fell" (77); tap sets selected (silk edge) and logs mood signal. Notes under: Fought well → `N task(s) struck. The Warden felt it.` ("1 task struck…" singular, "0 tasks struck…") (summary strikes); Held on → "Holding on is a kind of winning."; I fell → "You fell. Rise. Embers are kept." (241-247). No note until picked (key `mood-note`)
- [x] C62. "Flasks restored" row: bold label, subtext `N of 3 · ready for tomorrow` (kFlaskCap = 3, data/day_dao.dart:15) and FlaskPips (3 circles, filled N; semantic "Flasks N of 3") (278-298)
- [x] C63. Lesson field: caption "One thing for tomorrow" (plain), hint "Write before noon", maxLength 120 (300-306); sent as `lesson` on rest
- [x] C64. TomorrowRow (ui/tomorrow_row.dart): title "Tomorrow’s tasks", summary `0 of 3 chosen` or `N of 3 chosen · title1, title2` (first 2 titles), chevron "›"; semantic "Tomorrow’s tasks, <summary>" (308) → opens picker
- [x] C65. Tomorrow picker sheet (`_TomorrowPicker` → ui/tomorrow_pick_sheet.dart): title "Tomorrow’s three", Cancel pill; body text "Choose up to three tasks to face tomorrow. Keeping them is what counts."; row "Tasks waiting" + `N of 3 chosen`; flash text "Three is enough for one day." when tapping a 4th; list of PickToggleRow (diamond pips by weight, title, subtitle `<Boss title> · <Weight label>`, diamond checkbox, selected = silk edge/raised fill; semantic `title, subtitle` with selected); ActionRow "Set tomorrow" (saves picks via setTomorrow). Empty list = no rows (just text + Set tomorrow) — need ≥1 open task to see rows; Cancel = nothing saved (84-102, 323-372)
- [x] C66. EmberButton "Rest at the hearth" (310): medium haptic; `days.rest`; false if already rested today or fallen. On success: if first-ever rest AND reminder off → ReminderInvite dialog (C67); then `go('/')` Home unless a flash is showing
- [x] C67. Reminder invite (ui/reminder_invite.dart): GlassAlert title "A quiet nudge each evening?", body "One gentle reminder to come back to the bonfire.", actions ["Yes, remind me" (default), "Not now"] — only after the very first rest, reminder off (132-147). Yes → iOS notification permission prompt. If permission refused → FlashLine "No reminder without permission." on Bonfire (145) and screen stays
- [x] C68. If reminder enabled in Settings: caption under Rest button `One gentle reminder tomorrow at <h:mm AM/PM>.` (311-318) (default time "9:00 PM")
- [x] C69. STATE B rested today: header text "You have rested." (serif) + FlashLine slot; then PlanBanner "TOMORROW'S THREE" listing picked tasks (empty circle icon + title) — banner hidden entirely if no picks (187-191, 229-239; ui/plan_banner.dart: banner shows "The three are done." only when all isDone, not here since isDone false). Precondition: tap Rest at the hearth then return to Bonfire tab the same day (it navigates Home first)
- [x] C70. STATE C fallen (health 0): "You have fallen." (serif), "Rest here to rise again today.", EmberButton "Rise" right aligned (medium haptic, `dayDao.rise`); mood/lesson/rest UI replaced (217-227). Precondition: health 0 (lose 10 points: break commitments / "This attempt failed" does not equal fallen; see Fallen flow in another map). Hard to reach on a fresh install
- [x] C71. Check-in card (ui/check_in_card.dart): framed card "Has Hearthrise left you feeling worse?" with outline buttons "Never", "Sometimes", "Often" and right-aligned text button "Not now". Shown when `checkInDue` non-null AND not already answered this visit AND not fallen. Due on day 7 and day 14 after install (kCheckInDays [7,14], day 1 = install day), max 3 "Not now" per window, dismissal hides it for the rest of that day (core/check_in.dart). Answer → FlashLine "Thank you."; dismiss → nothing shown. Precondition: change device date/clock to day ≥7 (simulator Settings > Date & Time, or run with fake clock) 
- [x] C72. FlashLine slot under "You have rested." / check-in (ui/flash_line.dart, 36 px reserved)
- [x] C73. Today tab BonfireCard (ui/bonfire_card.dart; used from Today tab header, home_screen.dart:70-73) — covered by Home map; navigates here

## 6. Profile screen (`/profile`, tab) — features/profile/profile_screen.dart
- [x] C74. Blank until profile loads (33-34)
- [x] C75. Header: back circle (semantic "Back", go `/`), caption "PROFILE" (41-47)
- [x] C76. ProfileLevel block (ui/profile_level.dart): framed diamond with level numeral, "Level N", 5 bars (lit by share of level), line `N embers to the next` ("1 ember to the next" singular); semantic "Level N, P percent to level N+1". Fresh install: Level 1, 10 embers to the next (kLevelStep 10: L2 at 10, L3 at 30, L4 at 60; core/level.dart). Make N change by striking tasks (1/3/6 embers per Light/Heavy/Boss-tier, tried = half rounded up)
- [x] C77. Thread divider; ember row: flame icon + `N embers banked` (singular "1 ember banked"; "0 embers banked" on fresh) (68-74)
- [x] C78. "Flasks" label + FlaskPips (3 pips; semantic "Flasks N of 3") (78-84)
- [x] C79. PlayerHealthBar (ui/player_health_bar.dart) — 10 pips (20 half points ÷ 2), half-pip support; semantic "Health X of 10" or "Fallen. Health 0 of 10"; hidden until health loads (86-89)
- [x] C80. AccuracyLine (ui/accuracy_line.dart): text `Today: K of M kept.` (only if M>0) and `This week: K of M.` (only if week M>0), joined by space; renders nothing when no promises made (so absent on a fresh install). Precondition: make a promise via task ⋯ → "Promise by…" (90-95)
- [x] C81. "Hall of relics" heading (serif) (97)
- [x] C82. Empty hall: "No bosses vanquished yet. The first relic awaits." (ui/hall_of_relics.dart:35) — fresh install
- [x] C83. Populated hall: RelicTile rows (emblem 48px, name with "Relic of " prefix stripped, date `D Mon YYYY`, semantic "<name>, <date>"), newest first; tap pushes `/relic/<id>` (ui/relic_tile.dart) — ≥1 defeated boss
- [-] C84. (only one relic weathering seen) Emblem weathering by attempts (core/weathering.dart): ≤1 attempts "unmarked" (0 nicks, semantic "An unmarked emblem"), 2-3 "worn" (3 nicks, "A worn emblem"), 4-8 "scarred" (6 nicks, "A scarred emblem"), 9+ "weathered" (10 nicks, "A weathered emblem") (ui/relic_emblem.dart). To vary, defeat bosses after N "This attempt failed" actions

## 7. Relic screen (`/relic/:id`) — features/profile/relic_screen.dart
- [x] C85. Back circle (semantic "Back", pop) only in header, no title (65-70)
- [x] C86. Large emblem (96px) centered; relic name (without "Relic of "), 40pt serif centered; date `D Mon YYYY` (91-103)
- [x] C87. Defeat meaning line (centered small) shown only if the boss had one (104-107)
- [x] C88. Divider (200 wide); StatRow with 3 columns: `<attempts>` "Attempts", `<days>` "Days", `<effort>` "Effort" separated by seam lines (111-117; ui/stat_row.dart)
- [x] C89. Attempts line: `One attempt. It counted.` for 1, else `N attempts. Every one of them counted.` (20-22)
- [x] C90. Chapter names joined with " · " centered (only if boss had chapters) (124-131)
- [-] C91. (no lesson saved (finding 37)) "What the falls taught you" heading + LessonTimeline rows: roman attempt numeral (silk), lesson text italic, and sub-label "a missed day" when lesson cause was missed day (ui/lesson_timeline.dart:73-74). Entirely hidden when no lessons (132-149). Precondition: write a lesson on a fall (fall flow) 
- [x] C92. InscriptionField (ui/inscription_field.dart): label "Inscription", live counter `N / 120`, textfield hint "A line to remember this by", maxLength 120; EmberButton "Save" right aligned → saves inscription and dismisses keyboard (45-48, 151). Prefilled with saved inscription once. Empty save clears it
- [-] C93. (not reachable) Blank body if relic not found (73-75)

## 8. Settings screen (`/settings`, pushed from Home) — features/settings/settings_screen.dart
- [x] C94. Blank until settings load (87-88). Header: back circle (semantic "Back", go `/`), "SETTINGS", thread divider (101-113)
- [x] C95. Switch row "Tap instead of hold" (GlassSwitch semantic = title). Default OFF. ON makes strikes tap-to-strike instead of hold (also logged to tester report as tap mode change) (118-122)
- [x] C96. Switch row "Haptics" default ON (123-127)
- [x] C97. Switch row "Reduce motion" default OFF (shown inverted of motionEffects; ON disables glass light following device motion) (128-132)
- [x] C98. Switch row "Evening reminder" default OFF (133-137). Turning ON triggers iOS notification permission prompt (Allow / Don't Allow). If denied: switch snaps back off and FlashLine (silk serif, 36px) "No reminder without permission." Turning OFF clears flash and cancels notification (37-50). On simulator: Settings app > Notifications to re-test
- [x] C99. FlashLine slot below Evening reminder (138)
- [x] C100. Value row "Reminder time" showing `h:mm AM/PM` (default "9:00 PM") (139-143). Tap → Material `showTimePicker` in text INPUT mode (initialEntryMode input) with hour/minute fields, AM/PM toggle, Cancel/OK; OK saves and reschedules if reminder on (52-62)
- [x] C101. Value row "Day starts at" showing e.g. "4:00 AM" (default 4 AM) (144-148). Tap → ChoiceDialog (GlassAlert, title "Day starts at", no action buttons, tap outside dismisses) with 7 options: "12:00 AM", "1:00 AM", "2:00 AM", "3:00 AM", "4:00 AM", "5:00 AM", "6:00 AM" (hours 0-6) (64-77; ui/choice_dialog.dart). Picking closes and saves
- [x] C102. Choice row "On a failed attempt, reset (new bosses)" with 3 segments "Nothing" / "Current chapter" / "Whole boss", default "Nothing" (150-157). Affects the preselected value on `/boss/new` (C18)
- [x] C103. "Copy tester report" ListTile (features/tester_report/copy_tester_report_tile.dart:42-47). Tap copies report to clipboard, subtitle then shows "Copied." (or "Could not copy." on PlatformException). Subtitle persists until leaving screen. Clipboard text (tester_report.dart:33-56): "Hearthrise tester report", "Version: 0.7.0+1", "Period: <first> to <today> (day N)", "Visits recorded since: ...", "Fallen days", "Returned the next day after a fall: X of Y (Z pending)", "First-week fallen days", "Strikes: N (Light a, Heavy b, Boss-tier c, weight unknown d)", "Tried", "Tried per Strike: n/a|x.xx", "Lessons on falls: written/skipped", "Bonfire lessons", "Tap mode: on|off (never changed | changed N time(s), first on day D)", "Haptics: on|off", "Check-in from day 7/14: <Never|Sometimes|Often|not asked yet|no answer>[ (dismissed N)]", "Extensions: free N, with a flask N", "Late strikes", "Promises week 1/4: not yet | N made, K kept over D day(s) (x.x a day)". Paste into a note/search field on the simulator to verify
- [x] C104. Sync section "Back up and sync" (SyncSection → ui/sync_status_row.dart) — see C108-C118
- [x] C105. Biome picker "Biome" (ui/biome_choice_row.dart): five full-width bordered rows, name + 4 colour swatches (void, shell, silk, bone); selected row has silk border; tap applies immediately app-wide (biomeProvider, device-only setting). Options IN ORDER: (1) "Pharloom" (dark, default), (2) "Deep Docks" (dark, orange silk), (3) "Choral Chambers" (LIGHT), (4) "Moss Grotto" (LIGHT), (5) "Greymoor" (dark) (core/palette.dart:163-169). Row keys `biome-<name>`: pharloom, docks, choral, moss, greymoor. Last item at the bottom of Settings (scroll). Tester: screenshot each primary screen in all 5 (note the two light themes for contrast)
- [x] C106. Screen scroll: ListView; everything below "Copy tester report" requires scroll on small devices
- [x] C107. Settings persistence: toggles write immediately (no Save button); leave and re-enter to verify

## 9. Sync / account UI (features/settings/sync_section.dart, ui/sync_status_row.dart, data/account_service.dart, server_config.dart)
- [x] C108. Signed-out block (always the case on a fresh install): bold "Back up and sync"; muted "Optional. Sign in with Google to keep your bosses safe and bring them to another phone."; TextButton "Sign in with Google" (left-aligned 48px) (sync_status_row.dart:73-86)
- [x] C109. Server config: `kApiBaseUrl` from `--dart-define=API_BASE_URL` (default empty → hasServer false) (server_config.dart:12-14). Without it main.dart does not install the real account/sync API (main.dart:34), AccountApi is a `_NoServer` that throws, `hasServerProvider` false
- [x] C110. Tapping "Sign in with Google" with NO server (default simulator build): AccountService.signIn returns `unavailable` before any Google sheet (account_service.dart:65-67) → FlashLine "Sign-in is not available in this build." under the block (sync_section.dart:55-56). Button disabled while busy
- [-] C111. (needs server build) Same message also if server set but iOS has no `GOOGLE_IOS_CLIENT_ID` dart-define (auth_gateway.dart:48-49)
- [-] C112. (needs backend) With server + Google configured: Google sign-in sheet; cancel → no message; failure → FlashLine "Could not sign in. Nothing changed." (54). NOT testable without backend/credentials. Do NOT enter real credentials
- [-] C113. (needs backend) Stranger-account confirm dialog (only when phone previously belonged to another account or session ended): ConfirmDialog body `Back up this phone's data to <email>?`, actions ["Back up" (default), "Not yet"]; decline → sign-in declined, nothing changes (42-50) — needs backend
- [-] C114. (needs backend) Merge notice dialog (NoticeDialog): "This account has data from another phone. Both will be kept." action ["OK"] (59-66) — needs backend
- [-] C115. (needs backend) Signed-in block layout (needs session): "Back up and sync"; account email (body); status line: "Waiting for a connection" (last sync error) | "Not synced yet" | "Last synced just now / N min ago / N h ago / N d ago"; `N item(s) not backed up` (parked/rejected outbox entries; only if >0); buttons "Sign out", "Delete account" (sync_status_row.dart:50-107). Buttons disabled while busy
- [-] C116. (needs backend) "Sign out" → ends session immediately (no confirm); returns to signed-out block; local data kept (sync_section.dart:70-71; account_service.dart:149)
- [-] C117. (needs backend) "Delete account" → ConfirmDialog body "Delete your account? Everything backed up is removed. This phone keeps its data." actions ["Delete","Not yet"]; failure FlashLine "Could not delete the account. Try again." (73-95)
- [-] C118. (n/a) Possible simulation without backend: unit/widget tests only; on simulator only C108-C110 reachable

## 10. Shared dialog/sheet component facts (for screenshots)
- [x] C119. GlassAlert (ui/glass_alert.dart): centered glass card max width 334, first action row silk-tinted default; scrim 62% ink; tap outside = dismiss (returns null = cancel). Used by ConfirmDialog, NoticeDialog ("OK"), ReminderInvite, ChoiceDialog (no actions)
- [x] C120. GlassSheet (ui/glass_sheet.dart): bottom sheet, grabber bar, optional uppercase label, serif title, glass pill (default "Cancel"; "Close" on boss/foe actions), thread divider, scrolling body, max 90% height; covers tab bar (root navigator)
- [x] C121. Text size / accessibility: sheet content scrolls; test with large Dynamic Type (iOS Settings > Accessibility > Display & Text Size > Larger Text); minimum tap target 48 (kMinTarget)
- [-] C122. (not used by screens) Widgets in my area NOT used by these screens (no tester action): ui/ember_tally.dart, ui/level_line.dart, ui/level_badge.dart (Home header), ui/time_choice_row.dart, ui/collapsible_section.dart (All bosses "Waiting (N)", other map), ui/bonfire_card.dart (Today tab), ui/foes_header.dart (Home), ui/pick_toggle_row.dart (used in picker C65)

## 11. Suggested tester path on fresh simulator (fast route to every state in this map)
- [x] C123. 1) Finish onboarding → Home. 2) Settings: toggle everything, set reminder time, Day starts at, all 3 reset options, Copy tester report, Sign in with Google (expect unavailable flash), cycle all 5 biomes and screenshot Settings in each. 3) All bosses → Name a new boss: verify disabled Save, fill title, chapter name, add task in chapter (all 3 weights, Every day on, chapter dropdown), add standalone task, date picker, clear date, reset options, reorder chapters, delete chapter w/ and w/o tasks, Back with unsaved edits, Save. 4) Boss ⋯ → Edit: verify prefill, Delete task, Delete boss confirm (Not yet then Delete). 5) Home "New task" sheet: default Light/The Day, boss picker, Add to today. 6) Bonfire: mood each, flasks, lesson, tomorrow picker (pick 4 to see flash), Rest → reminder invite (accept with permission allowed, then repeat with denied on a reset sim) → Home; revisit Bonfire for rested state. 7) Strike tasks to gain embers → Profile level changes; promise a task for accuracy line. 8) Defeat a boss (Declare victory) → Profile hall of relics, Relic screen, edit inscription, Save. 9) Date-shift to day 7 for check-in card. 10) Fallen/Rise needs health 0.
