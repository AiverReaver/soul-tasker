# v4.1 Plan: The Fight, in Glass

Source: the "Hearthrise v4.1" design canvas (https://claude.ai/artifact/5bU9fETFefqgD6a1UAeZfM). It has 13 screens (Home, Boss, Struck, Settings, Profile, Relic, All bosses, Bonfire, Fallen, Victory, New foe, Leave the fight), 7 strike frames, the shape system and the five biome variants.
Builds on: `THEME_PLAN.md` (palette, biomes, needle-cut). The colors and the 8 / 6 / 4 cut tiers stay as they are.
Method: TDD (see `STAGES.md`, Development method). Every step lists its tests first, then the code. UI follows `STAGES.md`, "UI components".
Status: not started. The questions are answered (section 5). Three boards were added to the canvas for them: "Boss actions · A", "Boss actions · B" (not chosen) and "Tomorrow’s three · sheet". The "Tomorrow’s foes" row was added to "Bonfire check-in".

---

## 1. What v4.1 changes

v4.1 adds a second material on top of v3. **Content stays needle-cut. Chrome becomes glass.**

| Layer | Material | Where |
|---|---|---|
| Content | Needle-cut: 1 px edge, radius 8 / 6 / 4, solid fill | Boss panel, task rows, fields, choices, relic rows, the solid silk button |
| Chrome | Glass: blurred, tinted, ink-keyed, lit from a moving light | Circle buttons (back, profile, settings, leave), the floating tab bar, sheets, alert dialogs, the strike result panel, switches, the hold button |

Glass, as drawn in the design (the `.glass` class):

- **Fill:** `gf` (white at 8% on dark biomes, shell at 60% on light ones) over a backdrop blur of 16 with saturation 170%. When pressed, the fill goes to `gf2` and the widget scales to 1.04 with a slight overshoot (350 ms).
- **Key line:** a 2 px outline in `gk`, the biome's ink, outside the shape. Glass reads as an object, not a haze.
- **Inner depth:** a 5 px inner shadow along the bottom in `gk` at 28%, plus a 1 px inner ring in white at 16%.
- **Sheen:** a hard-edged diagonal band, white at 14%, over the top third. Its angle is 152° plus 14° times tilt.
- **Rim light:** a 2 px conic stroke. A bright arc in `gl` covers 18% of the rim, then a faint one in white at 22% on the opposite side. It starts at 230° plus 40° times tilt.
- **Glint:** a short top-left arc and a dot, white outlined in ink, rotated by 9° times tilt.
- **Drop shadow:** black at 35%, blur 28, offset (−8 × tilt, 8).
- **Tint variant:** silk at 55% instead of `gf`, used for a switch that is on.
- **High contrast:** a flat `shell` fill with no blur and no sheen.
- **Reduced motion:** the glint and light hold still at tilt 0.

**Tilt** is one value from −1 to 1. In the design it follows the phone's gyroscope or the pointer. With no input for 2.5 s it drifts on its own: x = sin(0.7 t) × 0.8, y = cos(0.5 t) × 0.5, eased at 12% a frame. Every glass surface on screen shares it, so the light moves across the whole screen as one.

**The strike** keeps the v3 beats with new timings and a new order (frames 1 to 6, section 6 phase B):

1. **Hold.** The glass hold button fills silk from the bottom while the row trembles 1 px on 140 ms steps. The row edge turns silk.
2. **Ready.** At 80% the button's ink edge turns bone.
3. **Hit, 0 to 110 ms.** The row flashes bone. On the Boss page, the boss burns white and the slash appears.
4. **Shatter, 110 to 500 ms.** The row shakes for 280 ms in 5 held steps. The boss recoils for 500 ms in 5 steps. The slash fades in 260 ms, and the shards drain over 0.9 s.
5. **Settle, 500 to 1300 ms.** "Struck" stamps onto the boss panel: 700 ms in 4 steps, ending at −5°. An ink line strikes through the title in 400 ms (4 steps). The meta line becomes "Struck · +N embers".
6. **Mark it.** A glass panel asks "How did the strike land?". "Clean strike" earns full embers and "A real try" earns half.
   When every foe of a phase is struck, the boss kneels: 1.4 s in 7 steps, to 50% opacity.

---

## 2. Gate

The work is done when all of these are true:

1. `test/core/palette_test.dart` passes with the four glass tokens for every biome. Ash text on a glass surface over `void_` keeps 4.5:1 in every biome.
2. `test/ui/glass_surface_test.dart` passes: a `BackdropFilter` by default, a flat `shell` fill and no `BackdropFilter` under high contrast, and a 2 px `gk` key line.
3. `test/features/strike/strike_flow_test.dart` passes, with a fixed clock and in-memory Drift:
   - A full hold runs hit, shatter and settle at 0, 110 and 500 ms, then opens the result panel.
   - "Clean strike" writes `Outcome.strike` and full embers.
   - "A real try" writes `Outcome.tried` and half embers, rounded up.
   - Leaving before a choice writes nothing, and the row is open again.
4. Every screen's widget test (phase C) passes on its main path.
5. `test/core/no_raw_colors_test.dart` still passes. The glass whites are tokens, not literals.
6. `flutter analyze` is clean and the full suite passes from `app/`.
7. Manual checks (step D2) are done on one iPhone and one mid-range Android phone.

---

## 3. Where we are

| Area | Now (`theme-biomes`) | v4.1 |
|---|---|---|
| Palette | 22 tokens × 5 biomes | Plus 4 glass tokens: `glassFill`, `glassFillHi`, `glassLight`, `glassKey` (D1) |
| Chrome | Material `AppBar`, `IconButton`, `PopupMenuButton` | Glass circle buttons in a bare header row (D4) |
| Tab bar | `HearthNavBar`: flat, full width, seam top border | `GlassTabBar`: a floating pill, 21 px from the sides, 19 px from the bottom (D5) |
| Hold | `HoldToStrike` + `TaskRowTile`: the whole row fills with ember | A 48 px glass hold button on the row's right; the row only trembles (D7) |
| Strike order | Hold, then the Strike / Tried popup, then the sweep | Hold, then the sweep, then the result panel (D8) |
| Boss stage | `boss_stage.dart`: idle, charge, hit, recoil | Plus the "Struck" stamp and the kneel (D8) |
| Health | `ShardMeter` exists; `BossHealthBar` still on some screens | `ShardMeter` with "Boss health" and "N / 12" everywhere |
| Sheets and dialogs | Material sheets and dialogs, restyled by `dialogTheme` | `GlassSheet`, `GlassAlert` (D6) |
| Switches | `SettingSwitchRow` on a Material `Switch` | `GlassSwitch`: a diamond knob in a glass track (D6) |
| Bonfire | Lesson, check-in, picks for tomorrow, health, accuracy | Mood, flasks restored, "One thing for tomorrow", rest (D9, Q4, Q5) |
| All bosses | A section on Home | Its own screen at `/bosses` (D10) |
| Ambient clock | `Atmosphere`: motes and ink boil | Also drives the shared tilt (D3) |

Reuse as they are: `NeedleFrame`, `ShardMeter`, `DiamondPip`, `ThreadDivider`, `HomeHeader`, `PinnedBossPanel`, `BossArt`, `InkPath`, `StrikeSweepView`, `DustVanish`, `RelicEmblem`, `LessonTimeline`, `FlaskPips`, `BiomeChoiceRow`, `InscriptionField`, `VictoryNumbers`.

---

## 4. Decisions

**D1. Glass tokens join `HearthPalette`.** These are the design's `--gf`, `--gf2`, `--gl` and `--gk`:

| Biome | `glassFill` | `glassFillHi` | `glassLight` | `glassKey` |
|---|---|---|---|---|
| Pharloom | white 8% | white 16% | `#FFF8EC` 85% | `#050307` |
| Deep Docks | white 8% | white 16% | `#FFF8EC` 85% | `#050302` |
| Choral Chambers | `#FFFAF0` 60% | `#FFFAF0` 90% | white 95% | `#2A1E0F` |
| Moss Grotto | `#FBFDF5` 60% | `#FBFDF5` 90% | white 95% | `#1C2A1A` |
| Greymoor | white 8% | white 16% | `#FFF8EC` 85% | `#04070A` |

- `glassKey` equals `ink` in every biome. Keep it as its own field anyway, so it can move without touching ink.
- `lerp` and `copyWith` gain the four fields, so the biome cross-fade covers glass too.
- The fixed whites in the sheen (14%), inner ring (16%) and faint rim (22%) live as `const` values in `GlassPainter`. They are white in every biome, so they are shape, not palette. They sit in `palette.dart` so the raw-colors scanner keeps passing.

**D2. One glass widget, one painter.** `lib/ui/glass_surface.dart`:

```dart
GlassSurface({
  required Widget child,
  required GlassShape shape,     // circle, stadium, or rounded(radius)
  ValueListenable<Offset>? tilt, // null = still
  bool isPressed = false,
  bool isTinted = false,
  double blur = 16,
})
```

- Layers, bottom to top: drop shadow, then a clip to the shape, then `BackdropFilter`, then the fill, then `child`, then `GlassPainter`.
  - The backdrop filter is `ImageFilter.compose(blur, saturation 1.7)`. The saturation is a `ColorFilter.matrix`.
  - `GlassPainter` draws the key line, inner shadow, inner ring, sheen, rim light and glint.
- `GlassPainter` takes the tilt as its `repaint:` listenable. A moving light then repaints the painter only. Nothing rebuilds, and layout never runs.
- `MediaQuery.highContrastOf(context)` gives the flat fallback: `shell` fill, no `BackdropFilter`, no sheen. The key line stays.
- Press feedback is `AnimatedScale` to 1.04 over 350 ms with `Curves.easeOutBack`, plus the `glassFillHi` fill. `DESIGN.md` says "no springs, no overshoot", so this is a rule change. Step D1 records it as glass-only.
- No `BackdropFilter` where the glass sits on a solid, known fill, like the hold button on a row. There is nothing to blur there. `blur: 0` skips the filter and saves its cost on Android.
- Several blurred surfaces on one screen (tab bar, two circle buttons, a sheet) share one backdrop pass through `BackdropGroup` and `BackdropFilter.grouped`, if the pinned Flutter SDK has them. Otherwise they stay separate, and the Android check in step D2 decides.

**D3. Tilt is ambient, like the theme.**
- `lib/core/glass_tilt.dart` holds `GlassTilt`, an `InheritedWidget` that carries a `ValueListenable<Offset>`. `GlassTilt.of(context)` returns it, or a still zero.
- `features/shell/atmosphere.dart` owns the `ValueNotifier`. On its existing ticker it runs the design's idle drift and easing.
  - Under reduced motion and `isStill` (tests), the value stays at zero.
- `lib/ui/` glass widgets read `GlassTilt.of(context)` the same way they read `context.palette`. This extends the STAGES.md rule "the theme is the only shared input" to "theme and glass tilt". Step D1 records the change in STAGES.md.
  - The alternative, passing tilt through every screen, touches every constructor for a light effect.
- **Gyroscope: not in this plan.** It needs a new dependency (`sensors_plus`) and the iOS motion permission. The idle drift gives the moving light without either. It is a follow-up if the feel check asks for it.

**D4. Glass circle buttons replace the app bars.** `GlassCircleButton({icon, semanticLabel, onTap})` in `lib/ui/`:
- 44 px visible, inside a 48 px hit area. The icon is a 22 px stroke icon at 1.6 px, with square caps and round joins, in bone.
- Screens drop `AppBar`. Each screen has a bare header row in a `SafeArea`, with the glass buttons placed as drawn:
  - Home: the "HEARTHRISE" label on the left; profile and settings on the right.
  - Boss: back, then "Phase II of III" centered, then ⋯ (boss actions, Q2b).
  - Profile, Settings, Relic, All bosses and Bonfire: back on the left, then the screen label.
- The new icons go in `nav_icon.dart` as `InkPath` strings, or in a sibling `glass_icon.dart`: back chevron, profile, settings gear, leave (a door with an arrow).

**D5. `GlassTabBar` replaces `HearthNavBar`.**
- Geometry: a pill with radius 31 and height 62, 21 px from each side and 19 px above the bottom safe inset. It has 4 equal columns, 4 px of padding and a 2 px gap.
- Each tab is 54 px tall with radius 27: a 22 px icon over a label at 11 / 13 weight 600. Unselected tabs are ash.
  - The selected tab is bone on a `glassFillHi` pill with a 0.5 px white inner ring. A 5 px silk diamond sits 3 px from its top.
- `HearthShell` sets `extendBody: true`, so content scrolls under the bar. Tab screens add 100 px of bottom padding, exported as `GlassTabBar.clearance`.
- The keys `nav-bar`, `nav-item-i` and `nav-icon-i` are kept, so the existing shell tests keep passing.
- `HearthNavBar` is deleted once nothing uses it.

**D6. Sheets, alerts and switches.**
- `GlassSheet` is the New foe sheet:
  - Glass with radius 8 on the top corners, over a void scrim at 60%.
  - A 36 × 4 grabber, then a header row: a glass "Cancel" pill on the left, the serif title centered, an empty slot on the right. A `ThreadDivider` follows.
  - `showGlassSheet(context, builder)` wraps `showModalBottomSheet` with a clear background and `isScrollControlled`.
  - Task edit, extend, commit and rule-of-three move onto it one at a time, each with its own test.
- `GlassAlert` is "Leave the fight?":
  - Glass with radius 8, 300 px wide, centered.
  - The body: a small uppercase label (the boss name), the serif title, a thread and the body text.
  - Then 52 px full-width action rows, each with a 1.5 px `gk` top border. The first row is the default.
  - `showGlassAlert(...)` returns the index of the chosen action. `ConfirmDialog`, `NoticeDialog` and `ChoiceDialog` re-skin onto it, and their public APIs stay as they are.
- `GlassSwitch({value, onChanged, semanticLabel})`:
  - A 52 × 32 stadium track. The knob is a 14 px diamond (a square rotated 45°) with a 1.5 px `gk` ring.
  - Off: the knob is ash at left 8. On: the track is tinted silk at 55%, and the knob is bone at left 30.
  - The knob moves over 300 ms. It has `Semantics(toggled:)` and a 48 px hit area.
  - `SettingSwitchRow` keeps its API and swaps the Material `Switch` for it.
- Segmented choices stay needle-cut, as drawn: mood, strength and reset on fail. The selected one has a silk edge, a raised fill and bone text. The rest have a seam edge, a shell fill and ash text. `SettingChoiceRow` moves onto `NeedleFrame` segments, with the same API.

**D7. The hold button.** `HoldButton({progress, isReady, semanticLabel})` in `lib/ui/`. It is drawn only: the gesture stays in `HoldToStrike`.
- 48 px, circular (radius 24), with a 1.5 px ink key edge. Inside is glass with `blur: 0` (D2), a silk fill at 78% rising from the bottom to `progress`, and the strike icon in bone above it.
- `isReady` turns the edge bone. Ready now begins at **80%**. The ember glint at 85% goes away.
- `TaskRowTile` changes:
  - The full-row ember fill goes. The row gets a `phase` (idle, charge, hit, shatter, settle) and a `trailing` slot for `HoldButton`.
  - The pips move to the left: one diamond per weight step, silk while open and dim once struck.
  - The meta line is "{boss} · +N embers", or "Struck · +N embers" once struck.
  - A struck row has a `struckBg` fill, a `struckEdge` edge, ash text with the ink line through it, and a silk check where the button was.
- Hold lengths stay per weight (Light 300 ms, Heavy 600 ms, Boss-tier 1200 ms). The design's single 560 ms run is illustrative.
- Tap mode stays: one tap runs the strike with no hold.

**D8. Strike order: animation first, then the choice.**
- The hold completes, then the row and boss beats run (section 1, steps 3 to 5). Then the result panel opens. The outcome is written only on the choice.
  - Leaving before choosing writes nothing. The row goes back to open, so a kill or a back swipe loses nothing.
- The result panel is the lower half of the Struck board, as a `GlassSheet`:
  - "How did the strike land?" in serif.
  - The solid silk "Clean strike" choice: "Done in full. Promise kept."
  - The framed "A real try" choice: "Part done. Effort still earns embers."
  - It cannot be dismissed by tapping outside. Back closes it as "no choice" (above).
  - It replaces `StrikeChoiceDialog` (Q3 decides whether the full Struck screen also shows).
- The phase timeline is a pure function, `strikeBeatAt(Duration t)`: idle, then hit, shatter and settle. It lives in `strike_sweep_view.dart` next to the existing beat code, so it is tested without widgets.
- `boss_stage.dart` gains:
  - `stamp`: the italic serif "Struck" at 52, with a 1.5 px ink stroke, scaling from 1.6 at −8° to 0.94 at −5° and resting at −5°, in 4 steps.
  - `felled`: the 7-step kneel when the phase's last foe falls.
  - Hit (`brightness(0) invert(1)` in the design) becomes a solid `mask` color filter on the art. `mask` is white on dark biomes and shell on light ones, so the flash works in Choral and Moss.

**D9. Bonfire becomes a check-in, not a planner.** The design has four parts:
1. The flame, "Rest a while." in serif 44, and "Night {n} at the hearth. Tell it how the day went."
2. "How did today go?" with three needle-cut segments: "Fought well", "Held on" and "I fell". A live note under them changes with the pick:
   - Fought well: "{n} foes struck. The Warden felt it."
   - Held on: "Holding on is a kind of winning."
   - I fell: "You fell. Rise. Embers are kept."
3. "Flasks restored", "3 of 3 · ready for tomorrow", and three flask glyphs.
4. "One thing for tomorrow", a one-line field with the placeholder "Write before noon". Then "Rest at the hearth", and under it "One gentle reminder tomorrow at 9:00." (the reminder time from Settings).

Mapping to data:
- **"One thing for tomorrow"** is the existing `DayLogs.lesson`, 120 characters. There is no schema change. Boss shows it next day as "Last lesson: …", which already reads `lastLesson`.
- **Mood:** see Q4. The default: a new `SignalKind.mood`, appended to the enum, with the pick as the signal's value. It has no game effect. It shows in the tester report.
- **Flasks:** `FlaskPips` and the flask provider, as they are now.
- **Rest:** the existing rest call (`dayDao.rest`), unchanged.
- The fallen state ("You have fallen. Rest here to rise again today.", "Rise") stays. It shows instead of part 2 when health is 0.
- **Tomorrow's picks** stay, as the "Tomorrow’s foes" row and sheet (Q5). The sheet reads `pickCandidatesProvider` and saves through the existing pick path. The 3-pick limit and its message come from the current `_toggle`.
- **The check-in card** stays when due. **The health bar and accuracy line** move to Profile. **The day summary and ember tally** leave Bonfire (Q5b).

**D10. Screen map and routes.**

| Board | Route | Tab |
|---|---|---|
| Home | `/` | Bosses |
| Boss | `/boss/:id` | none (pushed) |
| All bosses | `/bosses` (new, pushed from Home's "All bosses" row) | none |
| Bonfire | `/bonfire` | Bonfire |
| Profile | `/profile` | Relics |
| Relic | `/relic/:id` | none |
| Settings | `/settings` | none |
| Fallen, Victory | as now | none |
| New foe | a sheet over Home or Boss | n/a |
| Boss actions | a sheet over Boss, from ⋯ | n/a |
| Leave the fight | an alert from Boss actions | n/a |
| Tomorrow’s three | a sheet over Bonfire | n/a |

The "Today" tab: see Q1.

**D11. Copy comes from data, not the canvas.**
- `[NAME]` is the profile name. "Phase II of III" uses `romanNumeral`. "9 days left" comes from `deadlines.dart`. "Night 41" is the count of bonfire `DayLogs`.
- The design's embers (+10 / +20 / +30) and strength names (Light / Steady / Heavy) are illustrative. The app keeps `Weight` (Light, Heavy, Boss-tier) with its own embers (1, 3, 6). The design is not changed to match.
- Profile drops "Relic of" from relic names, as drawn.

---

## 5. Answered questions (2026-10-18)

- **Q1. The "Today" tab** opens the pinned boss's fight (`/boss/:pinnedId`). With no pinned boss, it opens the current `TodayView`, re-skinned with the same rows. Home is the Bosses tab, as drawn, with today's foes on it.
- **Q2. "Leave for now"** sets the boss to `BossStatus.waiting` and pops to Home. "Keep fighting" closes the alert.
- **Q2b. Boss actions** (canvas board "Boss actions · A: tap the ⋯ circle"):
  - The Boss header's ⋯ circle opens a glass "Boss actions" sheet. Its header has the label "Boss actions", the boss name, "Attempt 4 · Phase II of III" and a glass Close pill.
  - The rows: "Leave for now" (opens the Leave the fight alert), "Edit the boss", "Unpin from home" or "Pin to home", and "Declare victory".
  - Below a faint thread, a quieter row: "This attempt failed".
  - The `PopupMenuButton` and the bottom "This attempt failed" button go.
  - A waiting boss's sheet shows "Set active" instead of "Leave for now".
  - Board B (long-press) was drawn and not chosen.
- **Q3. The full-screen "Struck."** plays only when a strike ends a phase. Every other strike plays in place on its row (frames 1 to 5), then the result sheet opens.
- **Q4. The mood** is stored as a `SignalKind.mood` signal, with no game effect (D9).
- **Q5. Tomorrow's three** (canvas boards "Bonfire check-in" and "Tomorrow’s three · sheet"):
  - **The row:** under "One thing for tomorrow", "Tomorrow’s foes" shows "{n} of 3 chosen · {first titles}" and a chevron.
  - **The sheet:** tapping the row opens a glass sheet with Cancel, "Tomorrow’s three", "Choose up to three foes to face tomorrow. Keeping them is what counts.", a "Foes waiting" label with "{n} of 3 chosen", and the candidates.
    - Each candidate row has weight pips, the title, "{boss} · {weight}" and a diamond checkbox. A chosen row has a silk edge and a raised fill.
    - A fourth pick shows "Three is enough for one day." and changes nothing.
    - "Set tomorrow" saves the picks and closes the sheet.
- **Q5b. The stats:** the health bar and the accuracy line move to Profile, and the embers are already there. The day summary and ember tally leave Bonfire, because the mood note covers the day. The check-in card stays on Bonfire, shown only when due.
- **Q6. The biome names** stay for now. Choosing original names is a separate task before release, required by the Stage 8 trademark gate. It does not block this plan.

### 5a. Boards added after the first plan (canvas version 12)

The canvas is now laid out in app order: first run, Home and Today, a fight, the strike, the evening, falls and wins, then Settings. Each board has a note under it saying how you reach it, what it does and where it goes next. The new boards:

| Board | Replaces | Step |
|---|---|---|
| Onboarding 1–5 | `onboarding_flow.dart` pages: diamond step markers, serif 40 line, Skip and Next/Begin | C13 |
| Today | `today_view.dart`: Today’s three panel, boss filter chips, grouped rows with deadline chips | C14 |
| Boss edit (new and edit) | `boss_edit_screen.dart`: glass back and Save, framed phase panels with a grip, "Beyond the phases", Delete boss | C15 |
| Foe actions · sheet | The `PopupMenuButton` (⋮) on `TaskRow`. **New decision:** tapping a row, anywhere but the hold button, opens this sheet | C16 |
| Promise by · sheet | `CommitSheet` | C16 |
| Move it later · sheet, and its no-flask state | `ExtendSheet` | C16 |
| While you were away · dialog | `AwaySummary` dialog | C17 |

### 5b. Screens with no board: re-skin with the v4.1 parts

These keep their current layout and behavior. They only swap to the parts from phase A: `GlassSheet`, `GlassAlert`, `GlassSwitch`, `NeedleFrame` rows and segments, and the solid silk button. No new board is drawn for them. Each one's existing widget test must still pass, plus one assertion that it uses the glass part.

- **Sheets:** task edit (`task_edit_sheet.dart`, the same fields as New foe plus phase and Delete) and rule of three (`rule_of_three_sheet.dart`).
- **Dialogs:** `ConfirmDialog`, `NoticeDialog`, `ChoiceDialog` and `ReminderInvite`, all on `GlassAlert`.
- **Cards and parts:** `CheckInCard` (a needle-cut panel on Bonfire), `DeadlineChip` (the 4 px tag drawn on the Today board), `PlanBanner` (the Today’s three panel on the Today board), and `LessonTimeline` on Boss.
- **Settings:** the signed-in sync state (`SyncStatusRow`), drawn with the same rows as the "Sign in" offer.
- **System pickers:** time and date. `timePickerTheme` and `datePickerTheme` are set from the palette in `buildTheme`.
- **Home empty state:** "No boss stands before you." with the solid "Name a new boss" button.
- **Profile:** the health bar (`PlayerHealthBar`) under the flasks.

---

## 6. Steps

### Phase A: glass foundation (`lib/core`, `lib/ui`)

**Step A1. Glass tokens.**
Tests first, in `test/core/palette_test.dart`:
- Each biome pins its four glass values from the D1 table.
- `lerp(other, 0.5)` blends the glass fields.
- For each biome, ash and bone over `glassFill` composited on `void_` keep 4.5:1. `glassKey` against `void_` is not tested, because it is a key line, not text.

Code: add the fields to `HearthPalette`, its five consts, `copyWith`, `lerp`, plus the three fixed whites (D1).
Done when: `palette_test.dart` and `no_raw_colors_test.dart` pass.

**Step A1b. Glass system board.** Design only, no app code, so no automated test.
Added to the end of the v4.1 canvas as row "Glass system" (`Glass.dc.html` plus one board per biome). It shows each glass part (circle, pill, switch, hold ring, tab bar, action rows, sheet, alert, tint and focus), the four tokens per biome, the seven layers, and the usage rules. A3 and A4 build to this board.
Done when: manual check on the canvas in Pharloom and Choral, text readable and each part matches its shipped screen.

**Step A2. Shared tilt.**
Tests first, `test/features/shell/atmosphere_test.dart` (extend):
- With `isStill`, `GlassTilt.of` stays `Offset.zero` after 10 s of pumping.
- Under `MediaQueryData(disableAnimations: true)`, it stays at zero.
- Otherwise, after 3 s it moves away from zero and stays within −1 to 1 on both axes.
- With no `GlassTilt` above it, `GlassTilt.of` returns a still zero.

Code: `lib/core/glass_tilt.dart`, plus the notifier and idle drift in `Atmosphere` (D3).
Done when: the atmosphere tests pass.

**Step A3. `GlassSurface` and `GlassPainter`.**
Tests first, `test/ui/glass_surface_test.dart`:
- Each shape (circle, stadium, rounded 8) clips its child. A tap outside a circle's radius misses.
- One `BackdropFilter` by default, and none with `blur: 0`.
- High contrast: no `BackdropFilter`, and the fill is `palette.shell`.
- `isPressed` scales to 1.04 after 350 ms and fills with `glassFillHi`.
- `isTinted` fills with silk at 55%.
- `GlassPainter.shouldRepaint` is true when a color changes, and false for the same values. A tilt change repaints, and the builder's build count stays at 1.

Code: `lib/ui/glass_surface.dart` (D2).
Done when: the test passes. Manual: screenshots in Pharloom and Choral, next to the canvas.

**Step A4. Glass parts.** Each part gets its own test file in `test/ui/`, written first:
- `GlassCircleButton`: a 48 px hit area, a semantics button with its label, and `onTap` fires.
- `GlassSwitch`: semantics `toggled` matches `value`, a tap fires `onChanged(!value)`, and the knob sits at 30 when on and 8 when off.
- `GlassTabBar`: 4 labelled tabs, `selected` marks one with `Semantics(selected:)` and the silk diamond, and a tap fires `onTap(i)`. The `nav-*` keys are present, and `clearance` is 100.
- `GlassSheet`: the title, the Cancel pill pops, the grabber is present, and the content scrolls when tall at 200% text.
- `GlassAlert`: an `alertdialog` with the label, title and body. Actions pop their index, and a tap outside pops null.
- `HoldButton`: the fill height is `progress` × 46. The edge is bone when `isReady` and ink otherwise. Its semantics label is the label passed in.

Code: one file per part in `lib/ui/`, all on `GlassSurface`.
Done when: all six tests pass.

### Phase B: the strike

**Step B1. The beat timeline.**
Tests first, `test/ui/strike_sweep_view_test.dart` (extend): `strikeBeatAt` returns hit at 0 and 109 ms, shatter at 110 ms, settle at 500 ms and idle at 1300 ms. The row shake offsets are 5 held steps that settle by 280 ms.
Code: the timeline and shake table in `strike_sweep_view.dart` (D8).

**Step B2. Row visuals.**
Tests first, `test/ui/task_row_tile_test.dart` (update):
- Idle shows the pips, title, meta and trailing button.
- `charge` gives a silk edge.
- `hit` fills the row with bone.
- Struck shows `struckBg`, the ink line (a key), "Struck · +N embers" and the check.
- Semantics: "Hold to strike: {title}" while open, "{title}, struck" when done.

Code: `TaskRowTile` per D7, and `HoldToStrike` passes `phase`, `progress` and `isReady` into it with `HoldButton` as trailing. The threshold becomes 0.8.

**Step B3. Boss stage.**
Tests first, `test/features/boss/boss_stage_test.dart` (extend):
- The settle beat shows "Struck" in the stamp, rotated −5° at the end.
- `felled` ends at 50% opacity.
- The hit beat paints the art in `mask`.

Code: the stamp, kneel and mask flash in `boss_stage.dart`.

**Step B4. Result sheet and the new order.**
Tests first, `test/features/strike/strike_flow_test.dart`: the gate cases in section 2, item 3, plus:
- Tap mode skips the hold, then plays and asks the same way.
- Back on the sheet writes nothing.

Code:
- `lib/ui/strike_result_sheet.dart`, a `GlassSheet` body with the two choices.
- `HoldToStrike` reorders: play the beats, then show the sheet, then write the outcome.
- `StrikeChoiceDialog` is deleted.
- The ritual note in `DESIGN.md` changes in step D1.

Done when: the strike flow test passes, along with the full suite.
Manual: the feel of the strike on both phones. Haptics: ticks while holding, a heavy pulse on the hit, nothing on the sheet.

### Phase C: screens

In each step, first update the screen's widget test so it asserts the new main path: texts, semantics, the glass buttons and where they go. Then build the screen from `lib/ui/` parts.

**C1. Shell.** Test: `extendBody` is on, the bar floats (its bottom is at 19 + inset), and a tab tap goes to its route. The Q1 default is tested: "Today" opens the pinned boss. Code: `HearthShell` with `GlassTabBar`, and `HearthNavBar` is deleted.

**C2. Home.**
Test:
- The header has the date, "Evening, {name}.", the embers, a level badge with its semantics label ("Level 7, 56 percent to level 8") and the profile and settings circles.
- The pinned panel has the title, "Phase II of III · Attempt 4 · 9 days left", the "Boss health" label, "N / 12" and the "Enter the fight" button, which goes to `/boss/:id`.
- The "All bosses · 2 active · 1 waiting" row goes to `/bosses`.
- "Today’s foes" shows "N of 4 struck" and a "New foe" button that opens the sheet.
- The rows have hold buttons. "All foes struck. Rest at the bonfire" shows when every row is done.

Code:
- `HomeHeader` gains the level badge, a `LevelBadge` in `lib/ui/`: a diamond with a serif numeral, the ember count and 5 bars of 10 × 4.
- `PinnedBossPanel` gains the health label and count.
- A new `AllBossesRow` in `lib/ui/`. The Home body drops the boss sections, which move to C3.

**C3. All bosses (`/bosses`, new).**
Test:
- The pinned boss is first, with a deep edge, "Pinned" and its art.
- The other active bosses follow. "Name a new boss" goes to `/boss/new`.
- "Waiting (n)" is collapsed. Expanding it shows the waiting bosses, and `aria-expanded` maps to `Semantics(expanded:)`.

Code: a `BossesScreen` from `BossCardTile` and a new `CollapsibleSection` in `lib/ui/`.

**C4. Boss.**
Test:
- The header has back, "Phase II of III" and ⋯ (boss actions).
- The panel has the stage, name, and "Attempt 4 · 9 days left · Last lesson: …" with the lesson in italic serif. Health is "N / 12".
- The current phase name is a serif 22 heading, with "N of M struck · hold to strike", then a thread, then the rows.
- The hint line reads "Each strike takes shards from the {boss}.", or "{boss} kneels. Phase {n+1} awaits." when the phase is done.
- ⋯ opens the Boss actions sheet with the Q2b rows. Edit goes to `/boss/:id/edit`. Pin toggles the boss's pin. Declare victory runs the existing victory flow. "This attempt failed" runs the existing fall flow.

Code: rebuild `boss_screen.dart` from these parts. `PopupMenuButton` goes. "Beyond the phases" keeps its own section under the list.

**C5. Leave the fight.** Test: "Leave for now" in the actions sheet opens the alert with the boss label and "Struck foes stay struck and you keep {n} embers. …". "Keep fighting" closes it. "Leave for now" sets waiting and lands on Home (Q2). Code: `showGlassAlert` from the Boss screen.

**C6. New foe sheet.**
Test:
- "A new foe", then "Name the foe".
- "Strength" segments with the real `Weight` labels, each with a pip count and an embers note.
- "Strikes at" opens the boss picker. "Add to today" saves the task to today and closes the sheet. Cancel saves nothing.

Code: a `GlassSheet` body in `features/boss_edit/`, from `NeedleFrame` fields and segments, reusing the `TaskEditSheet` save path.

**C7. Bonfire.** Test: the D9 parts in order. A mood pick changes the live note and writes a `mood` signal (Q4). The field saves to `DayLogs.lesson` on rest. "Rest at the hearth" rests and goes to Home. The fallen state still offers "Rise".

Q5 is tested:
- The "Tomorrow’s foes" row shows "{n} of 3 chosen".
- The row opens the sheet. Toggling a candidate updates the count, and a fourth pick shows "Three is enough for one day." and changes nothing.
- "Set tomorrow" saves the picks, and `tomorrowPicksProvider` returns them.
- Cancel saves nothing.

The day summary, ember tally, health bar and accuracy line are gone.

Code:
- Rebuild `bonfire_screen.dart`, with a new `MoodChoice` in `lib/ui/` (needle-cut segments and a note).
- Add `TomorrowRow` and `TomorrowPickSheet` in `lib/ui/`. `TomorrowPickSheet` is a `GlassSheet` body built from a new `PickToggleRow`, which replaces `PickRow`.

**C8. Profile.**
Test:
- The back button and "PROFILE" label.
- `LevelBadge` large, "Level 7", the bars and "160 embers to the next".
- "1,240 embers banked", "Flasks 3 of 3", the health bar (moved from Bonfire, Q5b) and the accuracy line.
- "Hall of relics" lists names without "Relic of", each with its date.

Code: rebuild from `LevelBadge`, `LevelLine`, `FlaskPips`, `PlayerHealthBar`, `AccuracyLine` and `HallOfRelics`. The health bar is not on the Profile board yet. Add it to the canvas before building C8.

**C9. Relic.**
Test:
- The back button, emblem, name and date.
- Attempts, Days and Effort.
- "{n} attempts. Every one of them counted."
- The phase names joined with " · ".
- "What the falls taught you" with roman numerals.
- The inscription with a "0 / 120" counter.

Code: re-skin `relic_screen.dart`, mostly a layout change.

**C10. Settings.**
Test:
- The back button and "SETTINGS" label.
- Three `GlassSwitch` rows toggle their settings in Drift.
- Reminder time and Day starts at open their pickers.
- Reset-on-fail segments, "Copy tester report", the sync section and five biome rows.

Code: swap in `GlassSwitch` and needle-cut segments (D6). The board height in the canvas, 920 px, means the screen scrolls, which it already does.

**C11. Fallen.**
Test:
- "Attempt {n} ends. The {boss} remains, and so do you."
- Health "2 / 5" and "Embers kept".
- The deep-edged lesson field with its helper "You will see it at the start of attempt {n+1}."
- "Rise" and "Rest first. Write it tomorrow."

Code: add the snapping thread (two halves pulling apart at 1.2 s) and the lost health pip fading to dim at 1.6 s, to `fallen_screen.dart` and `health_fall.dart`.

**C12. Victory.** Test: the existing assertions, with the glass treatment only where drawn, which is nowhere. The canvas Victory board has no glass, so the code is unchanged apart from copy checks.

**C13. Onboarding.**
Test:
- The 5 pages in order, each with its line and "Step n of 5".
- Skip jumps to page 5. Next on page 2 stays disabled until there is a title.
- Phases and daily foes add and remove rows.
- Begin saves the boss with its phases and daily foes, then lands on Home.

Code: re-skin `OnboardingPage` and `onboarding_fields.dart`, with `StepMarks` (the diamonds) in `lib/ui/`.

**C14. Today.**
Test:
- The Today’s three panel shows last night’s picks, struck ones inked.
- The "All" chip shows every active boss. A boss chip filters to that boss.
- Rows are grouped under each boss with "n of m struck".
- A promised row shows its deadline chip, in silk when within the hour.
- The tab bar marks Today.

Code: rebuild `today_view.dart`. `PlanBanner` and `DeadlineChip` move onto `NeedleFrame`. Add `FilterChips` in `lib/ui/`.

**C15. Boss edit.**
Test:
- New mode reads "A new boss" with empty fields and one empty phase. Edit mode loads the boss.
- Phases reorder by the grip.
- Tapping a foe opens the task sheet. "Add a foe" and "Add a phase" add rows.
- Save writes the boss, phases and foes. Back without saving changes nothing.
- Delete boss and delete phase ask first.

Code: rebuild `boss_edit_screen.dart` from the parts. Keep `ReorderableListView`. Add `PhasePanel` in `lib/ui/`.

**C16. Foe actions, promise and move later.**
Test:
- Tapping a row opens Foe actions. A press on the hold button does not.
- Rows appear only when they apply: Promise by… unpromised and open, Move it later promised, Mark as tried open, plus Edit and Delete.
- Promise by: tapping a time commits, the reminder and every-day switches pass through, and the heavy-day note shows.
- Move it later: "Free, once." the first time, then the flask cost. With no flask, the times are disabled and the note reads "No flask left to move it again."

Code:
- `FoeActionsSheet` in `lib/ui/`, on `GlassSheet`.
- `CommitSheet` and `ExtendSheet` re-skin onto `GlassSheet` with `NeedleFrame` time rows and `GlassSwitch`.
- `TaskRow` drops its `PopupMenuButton` and opens the sheet on tap.

**C17. While you were away.**
Test:
- One dialog lists every passed deadline with its cost.
- "Done late" marks it and changes the row in place.
- "Go on" closes the dialog.
- With one row, the title reads "A deadline passed."

Code: re-skin `AwaySummary` onto `GlassAlert` with `NeedleFrame` rows.

**C18. Re-skins with no board (section 5b).** Each listed widget swaps to the glass and needle-cut parts. Its existing test still passes, with one added assertion that it uses the glass part.

Done when (phase C): every screen test passes, along with the full suite.

### Phase D: docs and the manual gate

**D1. Docs.**
- `DESIGN.md` gets a "Glass" section: where glass goes and where needle-cut stays, the anatomy, the tokens, tilt, the fallbacks, and the glass-only press overshoot.
- In `DESIGN.md`, "Ritual moments" changes to: animation first, then "How did the strike land?".
- `STAGES.md`, "UI components": the shared inputs become theme and `GlassTilt`.
- Link this plan from `THEME_PLAN.md`.

**D2. Manual checks** (cannot be automated):
- [ ] Every screen in all five biomes, next to the canvas, on one iPhone and one mid-range Android phone.
- [ ] Glass on Choral and Moss: the fill is not muddy, and the key line is not heavy.
- [ ] Android frame time with the tab bar, two circle buttons and a sheet open: no dropped frames on scroll in the profile tool. If frames drop, turn on `BackdropGroup`, or lower `blur` to 8 on Android.
- [ ] The strike feel and haptics on both phones.
- [ ] 200% text: the tab labels fit, the sheet scrolls, and the header buttons don't overlap the title.
- [ ] The system "Increase contrast" setting gives the flat glass. "Reduce motion" holds the light and glint still.
- [ ] The status bar icons are readable over the glass header on the light biomes.

---

## 7. Order and size

A1 → A1b → A2 → A3 → A4 → B1 → B2 → B3 → B4 → C1 → C2 … C18 → D1 → D2.

- Phase A blocks everything. Phase B needs A4's `HoldButton` and `GlassSheet`.
- C1, C2 and C4 come first because they carry the hold rows. C16 changes how `TaskRow` opens its actions, so it goes right after C4. After that, C3, C5 to C15, C17 and C18 do not depend on each other and can be done in any order, or split across sessions. They touch separate files, apart from shared `lib/ui/` parts, which already exist after phase A.
- One commit per step, each with a green suite.

---

## 8. Risks

- **Blur cost on Android.** `BackdropFilter` is the main cost. The mitigations are in D2: `blur: 0` on solid fills, a grouped backdrop and a lower blur on Android. The step D2 manual check decides.
- **Strike reorder.** Moving the choice after the animation changes when data is written. The B4 tests cover the kill and back paths. Sync and the ember fold see the same writes as before, only later.
- **Tilt rebuilding everything.** Tilt is a repaint listenable, never `setState` (D2). The A3 test pins a build count of 1.
- **Overshoot rule.** The glass press breaks `DESIGN.md`'s "no springs". It is limited to glass and recorded in step D1.
- **Light biomes.** Glass was drawn mainly on Pharloom. The A3 screenshots and the step D2 check catch muddy fills.
- **Trademark gate** (Q6) blocks release, not this work.
