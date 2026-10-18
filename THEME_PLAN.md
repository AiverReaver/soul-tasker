# Theme Plan: Biome Themes and the Needle-cut Redesign

Source: the "Hearthrise Silksong v3" design canvas (https://claude.ai/artifact/JKvd8CanBzrhueJkPsV7Jj). It has six screens (Home, Boss, Struck, Bonfire, Fallen, Victory), one shape system and five biome palettes. Visual rules are in `DESIGN.md`, which step 9 updates.
Method: TDD (see `STAGES.md`, Development method). Every step lists its tests first, then the code. UI follows `STAGES.md`, "UI components".
Follow-up: the glass layer and v4.1 screens are in `V41_PLAN.md`.
Status: done except the manual checks (step 3, step 6, step 8 on-device in all five biomes, 100% and 200% text, status bar icons on Choral and Moss). Not built from the design: see the notes under step 8.

---

## 1. Goal and gate

**Goal:** the user picks a biome in Settings and every screen repaints in it, and the app matches the v3 design. There are three phases:

- Phase A refactors the code to a theme system, with no visual change.
- Phase B adds the biomes and the picker.
- Phase C applies the new design.

**Gate:** all of these are true:

1. `test/core/palette_test.dart` passes: every biome meets the design's contrast rules. Text and ash keep 4.5:1 on shell, raised and void. Shard keeps 3:1 on shell. onSilk keeps 4.5:1 on silk.
2. `test/core/no_raw_colors_test.dart` passes: no `Color(0x…)` literal and no `k<Color>` token appears in `lib/` outside `lib/core/palette.dart`.
3. `test/features/biome_switch_test.dart` passes: picking Moss Grotto in Settings repaints Home in Moss colors without a restart. The choice survives a restart, tested by reopening the in-memory Drift database.
4. `flutter analyze` is clean and the full suite passes from `app/`.
5. Manual check: each biome on a real phone, Home and Boss, at 100% and 200% text. Status bar icons are readable on the two light biomes (Choral, Moss).

---

## 2. Where we are

| Area | State | Change |
|---|---|---|
| Tokens | 13 `const Color k…` in `core/theme.dart`, used in 50 files | One `HearthPalette` `ThemeExtension`, read from context (D1) |
| Theme | `buildTheme()`, no input, dark only | `buildTheme(Biome)`, light or dark per biome (D2) |
| Painters | Read the constants | Take colors as constructor fields (D5) |
| Choice | None | `Settings.biome`, device-only, schema v8 (D3) |
| Shape | `CarvedFrame`: square, wine edge, corner brackets | `NeedleFrame`: 1 px edge, radius 8 / 6 / 4 (D6) |
| Body font | Inter | Hanken Grotesk (D7) |

The busiest tokens are `kTextMuted` (35 uses), `kEmber` (35) and `kDust` (26). The painters are `CarvedEdgePainter`, `_NightPainter`, the boss art and the sweep.

---

## 3. Decisions

**D1. Tokens are a `ThemeExtension`.** Flutter documents `ThemeExtension` as the way to add custom colors beyond `ColorScheme`.
- `HearthPalette extends ThemeExtension<HearthPalette>` holds the design's 22 tokens: `void_`, `ground`, `ground2`, `voidfall`, `shell`, `raised`, `raised2`, `seam`, `struckBg`, `struckEdge`, `deep`, `silk`, `silkHi`, `onSilk`, `bone`, `text`, `ash`, `shard`, `dim`, `ink`, `mote`, `mask`.
- It has `copyWith`, and a `lerp` that runs `Color.lerp` on each field. `MaterialApp`'s built-in `AnimatedTheme` then cross-fades a biome change.
- Widgets read it with `context.palette`, an extension on `BuildContext`.
- `lib/ui/` widgets keep the STAGES.md rule that the theme is their only shared input. The theme now comes from context, not from globals.

**D2. `ColorScheme` is mapped by hand, not with `fromSeed`.** The design fixes exact hexes, and a seed would shift them.
- `buildTheme(Biome b)` sets `brightness` from the biome. Choral and Moss are light.
- The mapping: primary to silk, onPrimary to onSilk, surface to shell, onSurface to text, outline to seam, secondaryContainer to raised, error to shard.
- Stock widgets (SegmentedButton, Switch, dialogs, time picker) then follow the biome with no extra code.
- `appBarTheme.systemOverlayStyle` follows brightness.

**D3. The choice is stored on this phone only.**
- The device table `Settings` gets `biome`, an `intEnum<Biome>` with default 0 (Pharloom). The v7 to v8 migration adds the column, so old installs stay Pharloom.
- Add `SettingsDao.setBiome` and a `biomeProvider` that watches it.
- `HearthriseApp` becomes a `ConsumerWidget` and passes `buildTheme(biome)`.
- *Not synced.* Syncing would need a server column, a `SYNCED_COLUMNS` entry, a regenerated OpenAPI client and sync protocol work. To sync later, move the column to `UserSettings`, for example if testers ask.

**D4. The biome order is fixed.**
- `enum Biome { pharloom, docks, choral, moss, greymoor }`.
- Each value holds `label` ("Deep Docks", …), `brightness` and a `const HearthPalette`.
- The database stores the int, so add new biomes only at the end.

**D5. Painters take colors as fields.** A `CustomPainter` has no context.
- The widget that owns a painter reads `context.palette` and passes in the colors.
- `shouldRepaint` compares those colors.
- Pass only the colors each painter uses, not the whole palette.

**D6. One shape language.** `NeedleFrame({tier, edge, fill, child})` in `lib/ui/` replaces `CarvedFrame`. It is a 1 px edge plus a `ClipRRect` with one of three radius tiers:
- `Cut.lg` = 8: panels and sheets.
- `Cut.md` = 6: rows, buttons and fields.
- `Cut.sm` = 4: tags.

State changes the edge color, never the shape: seam at rest, silk on hover or selection, bone when a hold is ready, deep on featured panels. Ornaments stay pointed: diamond pips and skewed shards.
`Cut` sits next to `Space` and `Motion` in `core/theme.dart` and stays `const`, because shape is the same in every biome.

**D7. Two voices.**
- Cormorant Garamond 500: titles, boss names and lessons, at 44, 34, 30 and 22.
- Hanken Grotesk 400 to 700: UI and data, at 16, 15, 14 and 13.
- The label style is 12, weight 600, +1.6 tracking, uppercase. It only labels a meter.
- Hanken Grotesk is bundled as a variable TTF under OFL 1.1, offline-first like Inter. It downloads from the official Google Fonts GitHub repository, but only once you approve the download.
- Inter is removed once nothing uses it.

**D8. File layout.**
- `lib/core/palette.dart` holds `HearthPalette`, `Biome`, the five palettes and `context.palette`.
- `lib/core/theme.dart` keeps `buildTheme`, `Space`, `Motion`, `Cut` and the text styles. It re-exports `palette.dart`, so the 50 existing imports do not change.
- This follows Flutter's architecture guide: the data layer (DAO and provider) holds the choice, the app root maps it to `ThemeData`, and widgets only read `Theme`.

---

## 4. Steps

### Phase A: theme system, no visual change

**Step 1. `HearthPalette` and `Biome.pharloom`.**
Tests first, in `test/core/palette_test.dart`:
- `Biome.pharloom.palette` equals today's values: void `#09060C`, silk `#E8566D`, shard `#E9DFCB`, and so on.
- `lerp(other, 0)` returns this palette, and `lerp(other, 1)` returns `other`.
- `copyWith` replaces only the fields passed.
- `buildTheme(Biome.pharloom).extension<HearthPalette>()` is not null.
- `textTheme.displaySmall.color` is bone, and `bodyMedium.color` is text.
- The contrast checks move here from `silksong_palette_test.dart`, and that file is deleted.

Code: write `palette.dart` and `buildTheme(Biome)`. Keep the old `k…` constants as `@Deprecated` aliases for now.
Done when: `palette_test.dart` passes, along with the whole suite.

**Step 2. Move `lib/ui/` off the constants.**
Tests first: add `test/core/no_raw_colors_test.dart`, which scans `lib/` the same way the Stage 8 trademark gate does. It starts with an allowlist of the files still to migrate. Each file leaves the allowlist once migrated.
Code:
- In each of the 44 `lib/ui/` widgets, replace `kX` with `context.palette.x`. Remove any `const` that stops compiling.
- Give the painters color fields (D5): `CarvedEdgePainter`, `_NightPainter`, the `InkPath` users, `StrikeSweepView`, `DustVanish` and `BossArt`.
- The existing widget tests must stay green with no changes. The 3 tests that use `k…` read `Biome.pharloom.palette` instead.

Done when: no `lib/ui/` file is left on the allowlist and every `test/ui/` test passes.

**Step 3. Move `lib/features/` off the constants and delete the aliases.**
Tests first: the allowlist is now empty, and the scanner test passes.
Code: make the same swap in the remaining feature files (`boss_stage`, `hold_to_strike`, `boss_vanish`, `health_fall` and the screens). Delete the deprecated `k…` constants.
Done when: `no_raw_colors_test.dart` passes with no allowlist, analysis is clean and the suite passes.
Manual check: on a phone, the app looks identical to `main`.

### Phase B: biomes and the Settings picker

**Step 4. The four new palettes.**
Tests first:
- `palette_test.dart` loops over `Biome.values` and checks the gate's contrast rules.
- It checks `brightness`: Choral and Moss are light, the rest dark.
- It pins one silk hex per biome so a typo fails: `#FF7A2E`, `#94640F`, `#3D6B2C`, `#7FB2D9`.

Code:
- Add the four `const HearthPalette`s, with hexes copied from the design's `System` artboard.
- The backdrop's vignette uses `palette.ink` at a per-biome opacity, not hard black, so the light biomes do not turn muddy.

Done when: `palette_test.dart` passes for all five biomes.

**Step 5. Store the choice.**
Tests first, in `test/data/settings_dao_test.dart` with in-memory Drift:
- A fresh database reads `Biome.pharloom`.
- `setBiome(moss)` followed by `device()` reads moss.
- A migration test from schema v7 to v8 keeps every existing row and sets pharloom. It uses the existing `test/drift` harness, with a new v8 schema dump from `drift_dev schema dump`.

Code: add the `Settings.biome` column, schema version 8, `SettingsDao.setBiome` and `biomeProvider`.
Done when: the DAO and migration tests pass.

**Step 6. Re-theme live.**
Tests first:
- `test/features/biome_switch_test.dart` pumps the app on `/settings` and picks "Moss Grotto". After popping to Home, it expects a widget painted in `Biome.moss.palette.shell`. It then reopens the same in-memory database in a new `ProviderScope` and expects Moss again.
- A widget test for `BiomeChoiceRow`: it renders five options with swatches and fires `onChanged`.

Code:
- `HearthriseApp` watches `biomeProvider`.
- Add `lib/ui/biome_choice_row.dart`, a stateless list of five rows. Each row has the name and a strip of four swatches (void, shell, silk, bone). The selected row has a silk edge. `SettingChoiceRow` is not reused because its segmented button cannot fit five names at phone width.
- Settings adds a "Biome" row at the top.

Done when: both tests pass.
Manual check: on a phone, the cross-fade feels calm. It runs for `Motion.fade` (`themeAnimationDuration`).

### Phase C: the v3 design

In each screen step, first update that screen's existing widget test. It should assert the new structure on the main path: texts, semantics labels and the hold button. Then rebuild the screen from `lib/ui/` parts.

**Step 7. Shape system and type.**
Tests first:
- `NeedleFrame`: the radius per tier, the edge color per state, and a 2 px bone focus ring on the unclipped wrapper.
- `ShardMeter`: 12 skewed shards, a `filled` count, and the semantics label "Boss health N of 12".
- `DiamondPip`.
- Text theme: the body family is Hanken Grotesk, and `labelSmall` has size 12 and letterSpacing 1.6. Uppercase is a convention, not tested.

Code:
- Add `NeedleFrame`, `DiamondPip`, `ShardMeter` and `ThreadDivider`. `ShardMeter` replaces or extends `BossHealthBar`: decide after reading `BossHealthBar`. `ThreadDivider` is the silk thread with its centre diamond.
- Add `SilkButton`, solid silk at 52 to 56 px, with a ghost or framed variant. If `EmberButton`'s API fits, re-skin it instead.
- Bundle Hanken Grotesk.
- Delete `CarvedFrame` once nothing uses it.

**Step 8. The screens, one sub-step each, each with its widget test first.**
- **8a Home.**
  - Header: the date line, "Evening, {name}." in serif 34, the ember count, the level diamond and a 5-bar level meter.
  - Pinned boss panel: deep edge, raised2-to-shell gradient, small boss art top right, the shard meter and "Enter the fight".
  - Foes: "Today's foes" in serif 22 with "{n} of 4 struck · hold to strike", then the thread.
  - Task rows: weight pips, "boss name · +embers", and a 48 px hold button that fills silk from the bottom.
  - "All foes struck. Rest at the bonfire" when every row is done.
  - Bottom nav: Bosses / Today / Bonfire / Relics. Check `core/router.dart` first. If the nav needs a new route shell, that becomes its own sub-step.
- **8b Boss.** A "Phase II of III" header, a 150 px boss stage and the "Struck" stamp. The idle, charge, hit, shatter and settle states already exist in `boss_stage.dart`: re-skin them and keep the timings. The phase task list uses the same row as Home.
- **8c Struck.** The task title in italic serif, "Struck." at 72, the shard drain and "+30 embers". Then the "How did the strike land?" panel with two choices, a re-skin of `StrikeChoiceDialog`.
- **8d Bonfire.** The flame art, "Rest a while." at 44, a three-way mood segment, flasks restored, the "One thing for tomorrow" field and "Rest at the hearth".
- **8e Fallen.** The `voidfall` ground, tracked "FALLEN" at 60, health pips and embers kept. The lesson field has a deep edge. Actions: "Rise" and the ghost "Rest first".
- **8f Victory.** A spinning diamond emblem, "{boss} falls." at 42 and the attempts numeral at 88. Three stats with seam dividers, and the lessons list with roman numerals. Actions: "Return to the hearth" and "Keep as a relic".

Done when: each screen's widget test passes, and the full suite passes.
Manual check: each screen on a phone in all five biomes.

**Step 8 notes (what shipped).** Re-skinned on the existing structure, with new copy and parts: Home header (date, greeting, embers, level meter), "Today’s foes" count and thread, needle-cut task rows and boss/bonfire cards; Boss "Phase I of II" label; the strike dialog ("How did the strike land?"); Bonfire "Rest a while." and "Rest at the hearth"; Fallen on `voidfall` with a 60 px tracked title, deep-edged field, "Rise" and "Rest first"; Victory "{boss} falls." at 42, the 88 px attempts numeral, roman-numeral lessons, "Return to the hearth" and "Keep as a relic". Not built: bottom nav (Bosses / Today / Bonfire / Relics, needs a router shell), the pinned panel's "Enter the fight" button and gradient, the "Struck" stamp, the full-screen "Struck." at 72, the bonfire mood segment and flasks line, the spinning victory emblem, and the 12-shard `ShardMeter` on screens (`BossHealthBar` is still used).

**Step 9. Docs.**
- Rewrite the Color section of `DESIGN.md` (22 tokens, 5 biomes), its Shape section (the needle-cut tiers) and its Typography section (Hanken Grotesk).
- Change the STAGES.md "UI components" line to: "theme (`context.palette`, `Theme.of`) is the only shared input". Link this plan from there.

---

## 5. Risks

- **Many `const` removals in step 2.** The work is mechanical but touches many lines. Migrate one file at a time, keep the suite green after each, and never do it in one sweep.
- **Light biomes.** Code written for dark only may look wrong on Choral and Moss: black vignettes, `withValues(alpha:)` glows on the ground, a white hit-flash. The hit-flash uses `mask`, and glows use `silk` or `mote` from the palette. The manual check covers the rest.
- **No golden tests.** None exist today, so screen tests assert structure and colors, not pixels.
- **Design names.** "Pharloom", "Deep Docks", "Choral Chambers", "Moss Grotto" and "Greymoor" are Silksong place names, and `DESIGN.md` forbids using Silksong's art, characters or fonts. The Stage 8 trademark gate also bans protected terms in user-visible strings. Check its banned list before shipping these labels: the picker may need original biome names.
