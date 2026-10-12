# Hearthrise Design System

Source of truth for visual decisions. Tokens are implemented in `app/lib/theme.dart`.
Principles come from the design document (§3, §8): restraint, weight, calm, atmosphere over information.

## Color

Dark only. One accent. Contrast ratios measured against Background (`#0B0A09`).

| Token | Hex | Contrast | Use |
|---|---|---|---|
| `kBackground` | `#0B0A09` | — | Screen background |
| `kSurface` | `#161412` | — | Task rows, cards |
| `kAsh` | `#B8B2A7` | 9.4:1 | Primary text |
| `kTextMuted` | `#8F897F` | 5.7:1 | Secondary text, labels, hints |
| `kAshDim` | `#5E5A54` | 2.9:1 | Borders and decoration only. **Never text.** |
| `kEmber` | `#D9A441` | 8.8:1 | The single accent: strike fill, confirmations, victory, bonfire |
| `kBossHealth` | `#B0412F` | 3.4:1 | Boss health segments (meets 3:1 for UI components) |

Rules:
- Ember is reserved for things that matter. Never more than one ember element competing on a screen.
- No red for failure. The fallen screen uses black and ash only (§5.5).
- No pure white, no pure black text.

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
