# Hearthrise Design System

Source of truth for visual decisions. Tokens are implemented in `app/lib/theme.dart`.
Principles come from the design document (§3, §8): restraint, weight, calm, atmosphere over information.

## Color

Dark only. One accent. Theme: Pharloom night (Silksong-inspired, original art). Contrast ratios measured against Background (`#09060C`); `test/core/silksong_palette_test.dart` checks them.

| Token | Hex | Contrast | Use |
|---|---|---|---|
| `kBackground` | `#09060C` | — | Void: screen ground, violet-black, never pure black |
| `kSurface` | `#130E17` | — | Task rows, cards |
| `kSelected` | `#221828` | — | Selected segment, chip, pressed row |
| `kAsh` | `#E6DDCB` | 13:1 | Bone: primary text |
| `kTextMuted` | `#A79BA6` | 6.6:1 | Secondary text, labels, hints |
| `kAshDim` | `#5F5463` | — | Borders and decoration only. **Never text.** |
| `kEmber` | `#E8566D` | 5.3:1 | Silk crimson, the single accent: strike fill, primary action, focus, lit frames |
| `kBossHealth` | `#E9DFCB` | 3:1+ | Mask-ivory boss health shards (UI component) |
| `kDust` | `#F4EBDD` | — | Porcelain: display type, glints, frame brackets, the silk slash |
| `kWine`, `kPharloom`, `kMote`, `kInk` | | — | Carved edges, backdrop tint, drifting motes, ink outlines. Decoration only. |

Rules:
- Crimson is reserved for things that matter. Never more than one crimson element competing on a screen.
- No red for failure. The fallen screen uses void and bone only (§5.5).
- Porcelain is for display type and ritual moments. It never fills resting surfaces.

## Silksong restyle

- **Backdrop.** `PharloomBackdrop` (driven by `features/shell/atmosphere.dart`, 42 s loop) sits behind every screen: void, a cold violet tint from above, a vignette, lavender motes drifting up. Scaffolds and app bars are clear. Reduced motion holds it still.
- **Hand-drawn ink.** Art is kept as SVG path strings (`ui/ink_path.dart`). Three jittered redraws, stepped every 140 ms by the atmosphere, make the outlines boil like cel animation. `BossArt` is the original boss figure: porcelain mask and horns, ragged cloak, quill lance.
- **The strike** (`ui/strike_sweep_view.dart`, 700 ms, boss tier 1100 ms). Hold: the row fills crimson and glints porcelain from 85%. Landed: a crescent cut in two drawn frames with a crimson thread; a hit-stop where the row burns white under an inked impact star; then a shatter where the row shakes on ones and porcelain flecks and silk threads fly. On the boss page the boss burns white on the hit-stop and recoils in five held steps (`features/boss/boss_stage.dart`).
- **Frames.** `CarvedFrame`: square, wine edge, inner hairline, porcelain corner brackets; `isLit` adds a low crimson halo (pinned boss, unrested bonfire).
- **Transitions.** `SilkPageTransitions`: cross-fade with a 2% rise.
- Inspired by Hollow Knight: Silksong's feel (white strike trails, hit-stop, few held frames, ink outlines), never its art, characters or fonts.

## Typography

Both fonts are bundled (offline-first) under SIL Open Font License 1.1. Licenses: `app/assets/fonts/OFL-*.txt`.

| Role | Font | Size / weight | Use |
|---|---|---|---|
| `displayMedium` | Cormorant Garamond | 44 / 500 | Fallen, victory headline |
| `displaySmall` | Cormorant Garamond | 34 / 500 | Boss names |
| `titleMedium` | Cormorant Garamond | 22 / 500 | Prompts ("What did this teach you?"), strike lines |
| `bodyLarge` | Inter | 16 / 400 | Inputs, long text |
| `bodyMedium` | Inter | 15 / 400 | Task titles |
| `bodySmall` | Inter | 14 / 400, muted | Attempt line, weights, helper text |
| `labelSmall` | Inter | 13 / 500, ash, tracking 2 | Section and phase headers (uppercase) |

Rules:
- Nothing smaller than 13 px. Muted grey only for genuinely secondary text (meta, counts); anything the user should read, including headers and the screen's one-line message, uses `kAsh`.
- Ritual screens (bonfire, fallen, victory): body text 15 px or larger.
- No glow, gradient or texture behind text. Atmosphere goes around content, never under it.
- Serif only for boss names and major moments. Everything else is Inter.
- Variable fonts: always set `fontVariations` with the weight (the `_font` helper does this).
- Respect the system text scale; layouts must survive 200% text size.

## Spacing

4 pt grid: `Space.xs 4`, `sm 8`, `md 16`, `lg 24`, `xl 40`, `xxl 56`.
Screen side padding 20. Generous vertical space: the screen should feel sparse.

## Motion

Slow, never bouncy. Exits are faster than entrances.

| Token | Duration | Use |
|---|---|---|
| `Motion.quick` | 250 ms | Hold rollback, small state changes |
| `Motion.fade` | 600 ms | Standard fade, done state |
| `Motion.drain` | 900 ms | Boss health segment drain |
| `Motion.dim` | 1400 ms | Fallen screen dim-in |

Curve: `easeInOut` (or `easeIn` for dims). No springs, no overshoot.
Hold durations by weight: Light 300 ms, Heavy 600 ms, Boss-tier 1200 ms (§7.4).
Reduced motion: when the system asks for it, replace fades and drains with instant changes (Stage 1 task).

## Ritual moments

- **Strike or Tried.** A finished hold opens a centered popup: Strike (done) or Tried (not done). Tapping outside cancels and rolls the hold back. Tap mode asks too.
- **Dust.** A struck task dissolves into white-gold motes (about 1.2 s). A defeated boss name darkens the screen and turns to dust (2.4 s) before the victory screen. Reduced motion skips both.

## Haptics

See design doc §8.3. Light ticks during hold, heavy pulse on strike and fall. All haptics can be turned off in settings.

## Accessibility checklist

- [x] Text contrast at least 4.5:1 (`kAsh`, `kTextMuted`, `kEmber`)
- [x] UI component contrast at least 3:1 (health bar)
- [x] Hold has a tap alternative (§7.5)
- [x] Semantics labels on hold rows and health bar
- [ ] Touch targets at least 48 dp (check when building real screens)
- [ ] Reduced-motion support
- [ ] 200% text scale check

## Avoid

Confetti, bouncy animation, exclamation marks, red alarms, emoji as icons, game art, fonts or wording from Souls games (§4).
