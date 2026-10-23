# Hearthrise design system map (D)

Paths relative to /Users/ashishvagish/Documents/projects/soul-tasker/app/lib. "Line refs": exact for core/*, glass_surface.dart, and the files in the first dump; for glass_alert/circle/pill/sheet/switch/tab_bar/tap_target, pharloom_backdrop, stroke_icon, nav_icon, boss_art, ink_path, thread_divider, diamond_pip the refs are by symbol (blank/import lines were filtered when I read them, so I did not record numbers). All are short files; grep the symbol.

Alpha note: Flutter 0xAARRGGBB. 0x14=8%, 0x24=14%, 0x29=16%, 0x38=22%, 0x99=60%, 0xD9=85%, 0xE6=90%, 0xF2=95%.

---------------------------------------------------------------------------
## 1. PALETTES / BIOMES (core/palette.dart)

`enum Biome` (palette.dart:163-168), stored in DB by index (append only):
0 pharloom "Pharloom" dark | 1 docks "Deep Docks" dark | 2 choral "Choral Chambers" light | 3 moss "Moss Grotto" light | 4 greymoor "Greymoor" dark.
Default = pharloom. Each biome = one `HearthPalette` (26 tokens: 22 colour + 4 glass). Read via `context.palette`. ThemeExtension, lerps per token.

### Token meaning (DESIGN.md:12-18, theme.dart usage)
| token | use |
|---|---|
| void_ | screen ground base; backdrop base fill; nick marks on relic emblem |
| ground | backdrop gradient mid stop |
| ground2 | (defined; secondary ground) |
| voidfall | fallen screen ground |
| shell | panel/card default fill (NeedleFrame), dialog/picker bg, ColorScheme.surface, flat (high-contrast) glass fill, glass alert/sheet scrim base |
| raised | selected-chip/segment fill, picker dial; ColorScheme.secondaryContainer; boss cloak fill |
| raised2 | pinned boss card fill, top of pinned panel gradient |
| seam | default 1px NeedleFrame edge, dividers, outline |
| struckBg / struckEdge | fill / edge of a struck (done) task row |
| deep | featured edge (pinned boss), boss lance head fill, level diamond edge |
| silk | THE accent. CTA fill, selected edges, pips, threads, tint of glass switch/alert default action |
| silkHi | brighter accent (defined) |
| onSilk | text/icon on silk fill |
| bone | display type (headline/title/display), icon colour, selected text |
| text | primary body text (bodyLarge/Medium), emblem ring |
| ash | secondary text (bodySmall, labelSmall), unselected tab, placeholders |
| shard | boss-health shard fill (3:1 on shell), player-health pip fill, ColorScheme.error |
| dim | disabled/decoration: empty pips, borders, off level bars (35% alpha) |
| ink | outlines of hand-drawn art, scrim colour (62%), vignette, strike line through done rows |
| mote | floating motes in backdrop; boss cloak fold lines (30% alpha) |
| mask | hit-flash colour that boss art burns to |
| glassFill | glass resting fill |
| glassFillHi | glass pressed fill; selected tab fill |
| glassLight | rim light colour (conic highlight) |
| glassKey | key line / dark edge of glass; equals `ink` hex |

### Pharloom (dark, default) palette.dart:177
void_ #09060C | ground #140B1C | ground2 #0D0811 | voidfall #060408 | shell #130E17 | raised #221828 | raised2 #1C1420 | seam #3A2F3E | struckBg #0F0B12 | struckEdge #241C28 | deep #7A2638 | silk #E8566D | silkHi #EF6E83 | onSilk #09060C | bone #F4EBDD | text #E6DDCB | ash #A79BA6 | shard #E9DFCB | dim #5F5463 | ink #050307 | mote #B7A8D6 | mask #F4EBDD | glassFill #FFFFFF@8% | glassFillHi #FFFFFF@16% | glassLight #FFF8EC@85% | glassKey #050307

### Deep Docks (dark) palette.dart:206
void_ #0B0806 | ground #1F120A | ground2 #120B07 | voidfall #070504 | shell #16100C | raised #2B1B10 | raised2 #21150E | seam #403126 | struckBg #110C09 | struckEdge #2A2019 | deep #8C3B12 | silk #FF7A2E | silkHi #FF9550 | onSilk #160A03 | bone #FBE9D4 | text #EDDCC6 | ash #B3A291 | shard #F4BB84 | dim #6D5C4D | ink #050302 | mote #FFAE63 | mask #EAD9C4 | glassFill #FFFFFF@8% | glassFillHi #FFFFFF@16% | glassLight #FFF8EC@85% | glassKey #050302

### Choral Chambers (light) palette.dart:235
void_ #EFE6D1 | ground #FBF3E0 | ground2 #F4EAD3 | voidfall #E8DCC2 | shell #FFFAF0 | raised #F5E6C2 | raised2 #FBF1DA | seam #D6C49C | struckBg #F1E8D3 | struckEdge #E3D6B7 | deep #B8913F | silk #94640F | silkHi #A87414 | onSilk #FFFAF0 | bone #2A1E0F | text #3B2D1B | ash #6B5A41 (design hex C49030 darkened for 3:1) | shard #B8872D | dim #B7A37F | ink #2A1E0F | mote #C49030 | mask #FFFAF0 | glassFill #FFFAF0@60% | glassFillHi #FFFAF0@90% | glassLight #FFFFFF@95% | glassKey #2A1E0F

### Moss Grotto (light) palette.dart:266
void_ #E7EEDC | ground #F2F6E8 | ground2 #E9EFDD | voidfall #DFE7D0 | shell #FBFDF5 | raised #E4EECF | raised2 #F1F6E6 | seam #C3D2A8 | struckBg #EEF2E4 | struckEdge #D9E2C8 | deep #7FA05A | silk #3D6B2C | silkHi #4A7D36 | onSilk #FBFDF5 | bone #1C2A1A | text #2A3A27 | ash #5A6B52 (design 8DB255 darkened) | shard #7C9C4A | dim #A9B894 | ink #1C2A1A | mote #8DB255 | mask #FBFDF5 | glassFill #FBFDF5@60% | glassFillHi #FBFDF5@90% | glassLight #FFFFFF@95% | glassKey #1C2A1A

### Greymoor (dark) palette.dart:297
void_ #0A0D11 | ground #131B24 | ground2 #0D1218 | voidfall #080A0D | shell #111820 | raised #1C2733 | raised2 #16202A | seam #2E3B48 | struckBg #0D1218 | struckEdge #1D2630 | deep #2F4A62 | silk #7FB2D9 | silkHi #98C4E6 | onSilk #08121C | bone #E9EEF2 | text #D5DDE3 | ash #9AA7B2 | shard #CFDBE4 | dim #4F5D6A | ink #04070A | mote #A9C3D6 | mask #E3E9EE | glassFill #FFFFFF@8% | glassFillHi #FFFFFF@16% | glassLight #FFF8EC@85% | glassKey #04070A

### Fixed (biome-independent) glass whites, palette.dart:5-10
glassSheen #FFFFFF@14% | glassRing #FFFFFF@16% | glassRim #FFFFFF@22% | glassGlint #FFF8EC (opaque warm white; glint arc+dot)

### Theme wiring (core/theme.dart:73-146)
- brightness per biome; ColorScheme from dark()/light() with primary=silk, onPrimary=onSilk, secondaryContainer=raised, onSecondaryContainer=text, outline/outlineVariant=seam, surface=shell, onSurface=text, error=shard.
- scaffoldBackgroundColor and AppBar bg/surfaceTint = transparent (backdrop shows through); scrolledUnderElevation 0; status bar light on dark biomes, dark on light.
- dialog/time/date pickers bg=shell; hourMinute+dial=raised.
- Rules (DESIGN.md): crimson/accent reserved, max one competing accent per screen; no red for failure (fallen = void+bone); porcelain only for display type/rituals.

---------------------------------------------------------------------------
## 2. TYPOGRAPHY (theme.dart:52-71,125-145)

Families (pubspec.yaml fonts): `CormorantGaramond` (display serif, assets/fonts/CormorantGaramond.ttf, variable wght) and `HankenGrotesk` (body sans, assets/fonts/HankenGrotesk.ttf, variable wght). Default `fontFamily` = HankenGrotesk. Weight set via both FontWeight and `FontVariation.weight` (variable fonts). Licenses: OFL-*.txt in assets/fonts.
Helper `_font(family,size,weight,color,{spacing=0,height=1.4})`.

| theme style | font | size | wght | letterSpacing | height | colour | used for |
|---|---|---|---|---|---|---|---|
| displayMedium | Cormorant | 44 | 500 | 1 | 1.1 | bone | major moments |
| displaySmall | Cormorant | 34 | 500 | 1 | 1.15 | bone | greeting ("Morning."), onboarding line |
| headlineMedium | Cormorant | 28 | 500 | 1 | 1.15 | bone | boss title on card + pinned panel |
| titleMedium | Cormorant | 22 | 500 | 0 | 1.3 | bone | section titles, check-in question, lesson/emphasis; base for many copyWith overrides |
| bodyLarge | Hanken | 16 | 400 | 0 | 1.5 | text | text fields, task title base |
| bodyMedium | Hanken | 15 | 400 | 0 | 1.45 | text | default body, row labels |
| bodySmall | Hanken | 14 | 400 | 0 | 1.45 | ash | notes, sub-lines, meta |
| labelSmall | Hanken | 12 | 600 | 1.6 | 1.4 | ash | meter/section label; call sites upper-case it |

Overrides at call sites (size/weight/height/colour):
- Alert title: titleMedium 30/34h (glass_alert); sheet title 26/30h (glass_sheet); FoesHeader title 22/28h; ProfileLevel "Level N" 30/34h, numeral 28 w600 h1; PhasePanel chapter name 20; lesson text titleMedium italic 19/24h; LevelBadge numeral titleMedium 16*scale in onSilk.
- Alert action: Hanken 17 w600 bone. Pill button label 15 w600 bone. ActionRow 16 w600 bone. EmberButton 15 w700 onSilk. Tab label 11 (h 13/11) w600 (bone selected / ash). Strike result choice: 16 w700 + note 13 (onSilk when tinted else bone/ash).
- TaskRowTile title bodyLarge 16 h22/16 w500 (bone; ash when done; ink when hit); meta bodySmall 13 h18/13 (ash; ink when hit).
- StatRow value bodyLarge 17 h24/17 w600 text; label bodySmall.
- HomeHeader date bodyMedium 14 ash; "Hearthrise" labelSmall.
- Lesson roman numeral bodySmall silk w600 h24/13.
- Chevron "›" text 22 ash (AllBossesRow, CollapsibleSection, TomorrowRow " ›").
- Selected segment/chips: bodyMedium w600, bone selected / ash unselected.
- Text scale: GlassTabBar clamps text scale to 1.0 (fixed 62px pill).

---------------------------------------------------------------------------
## 3. SPACING / RADII / BORDERS / SHADOWS / GLASS / BACKDROP

### Spacing (theme.dart:14-21) 4pt grid
Space.xs 4 | sm 8 | md 16 | lg 24 | xl 40 | xxl 56. Screen side padding 20 (DESIGN.md; HomeHeader, OnboardingPage use 20). Frequent literals: 6 (card vertical pad), 10, 12 (=sm+4), 14, 18, 28 (alert side), 21/19 (tab bar). `kMinTarget = 48` min touch target (theme.dart:50). GlassTabBar.clearance = 100 bottom pad for tab screens.

### Radii (Cut, theme.dart:24-28)
Cut.lg 8 (panels, default NeedleFrame tier), Cut.md 6 (rows, buttons, fields, chips), Cut.sm 4 (tags/deadline chip). Inner clip = tier-1. Glass radii: alert 34, sheet 44, circle, stadium. Shard/grabber radius 2.

### Borders
- NeedleFrame: 1px frame in `edge ?? seam`, interior filled `fill ?? shell`. Focus: 2px bone ring outside (needle_frame.dart:43-51).
- Glass key line: edgeWidth 2 (drawn as 4px stroke clipped to inside); HoldButton 1.5.
- Alert action divider: top border 1.5 in glassKey. Grabber border 1 glassKey. Switch knob border 1.5 glassKey. Selected tab: 0.5px glassRing stadium border.
- Level diamond: edge 1.5; inner ring 1.5 at silk 60%.
- Lesson timeline: 1px seam top (+bottom on last). StatRow dividers 1px seam. ThreadDivider/SnappingThread 1px silk.

### Shadows
- Glass drop shadow (glass_surface.dart:~137-148): outline shifted (x = -tilt.x*8, y = 8), black @35%, MaskFilter blur 14, clipped OUT of the shape (cut under glass), clip bounds inflate 80. Not drawn in high contrast.
- No other elevation shadows in the app (cards are flat, edged).

### Glass (core: ui/glass_surface.dart, `GlassSurface`)
Layer order bottom->top: shadow | clip to shape | BackdropFilter(compose: saturate matrix outer, gaussian blur inner) over fill | child | GlassPainter overlay.
- Shapes: circle, stadium, rounded(r).
- blur sigma default 16 (alert 24, sheet 28, HoldButton 0 = no filter, tab bar/circle/pill/switch 16).
- Saturation 1.7 matrix (glass_surface.dart:~66-70), row-major 4x5:
  [1.5511 -0.5005 -0.0504 0 0 / -0.1491 1.1998 -0.0504 0 0 / -0.1491 -0.5005 1.6496 0 0 / 0 0 0 1 0] (rows sum to 1).
- Fill: high-contrast -> shell (flat); isTinted -> silk @55%; isPressed -> glassFillHi; else glassFill.
- Press: AnimatedScale 1.0 -> 1.04, 350ms, Curves.easeOutBack (0ms with reduce motion). Only springy motion in app.
- GlassPainter (glass_surface.dart:~182-290), all clipped inside the shape:
  1. key line: stroke width edgeWidth*2 (=4), colour edge ?? glassKey.
  2. bottom shade: path minus itself shifted up 5px, glassKey @28%.
  3. inner ring: 2px stroke glassRing (#FFF@16%).
  4. sheen: linear gradient along angle 152deg + tilt.x*14deg, stops [0,.33,.33,1] colours [sheen14%, sheen14%, sheen@0, transparent] (top third lit).
  5. rim: 4px SweepGradient starting at (230 + tilt.x*40 - 90)deg; colours/stops: glassLight 0-.18, transparent .18-.5, glassRim(22%) .5-.62, transparent .62-1 (hard stops).
  6. glint: arc "M14.3 37 A38 38 -> 37 14.3" + dot at (53.3,12.1) in a 100-unit box scaled to glintSize (default min(shorter side,88)); rotates tilt.x*9deg about its centre; stroke ink = 3 + side*.04; drawn twice: glassKey (width ink) then glassGlint (width ink*.6); dot r ink*.65 key, ink*.45 glint; round caps.
  High contrast: key line only, flat shell fill, no blur/shadow/sheen/glint.
- Tilt (core/glass_tilt.dart): idleTilt = (sin(.7t)*.8, cos(.5t)*.5) (defined, but Atmosphere rests at centre 0,0). easeTilt: 12% per 60Hz frame (k = 1-0.88^(dt/16.67ms)). fullTilt 22deg, deadzone 1.5deg; flat-phone threshold |gz|/|g| > .95 falls back to idle. Tilt range -1..1 per axis.
- Composite scrims on top of GlassSurface: alert shell@62%, sheet shell@58%. Modal barrier = ink @62% (glass_alert showGlassAlert, glass_sheet showGlassSheet).

### Backdrop (ui/pharloom_backdrop.dart; driven by features/shell/atmosphere.dart)
Layers: (1) solid void_; (2) RadialGradient center Alignment(0,-1.15) radius 1.1, colours [mote@12%, ground, void_] stops [0,.4,.8]; (3) vignette RadialGradient radius .95 [transparent, ink@vignette] stops [.55,1], vignette = 0.6 dark / 0.18 light; (4) 14 motes, Random(41) fixed seed: speed .6-1.4, x sway sin((rise+phase)*2pi)*14, rise from height+10 to -10, alpha = sin(rise*pi)*.6; glow circle r3 blurred 3 at alpha*.5, core r1.4 at alpha; colour mote. Wrapped in ExcludeSemantics. Atmosphere: 42s loop, throttled to 30 Hz, boil step 140ms (3 frames), still under reduce-motion / Settings motion off / tests / app inactive.

---------------------------------------------------------------------------
## 4. ICONOGRAPHY

All on a 24px grid, scaled by size/24, strokes square caps + round joins, default stroke 1.6 (scaled by size).

### StrokeIcons (ui/stroke_icon.dart) SVG path data; `StrokeIcon(path,color,size=22,strokeWidth=1.6,filled=false)`
- back `M15 5 8 12l7 7` (chevron)
- more `M5.2 10.4 7 12.2 5.2 14 3.4 12.2zM12 10.4l1.8 1.8L12 14l-1.8-1.8zM18.8 10.4l1.8 1.8-1.8 1.8-1.8-1.8z` (3 diamonds, always drawn filled in GlassCircleButton)
- check `M5 12.5 10 17.5 19 7`
- profile `M12 4 15 8 12 12 9 8zM5 20 8 15.5h8L19 20`
- settings `M4 8h16M4 16h16M9 6l2 2-2 2-2-2zM15 14l2 2-2 2-2-2z`
- plus `M12 5v14M5 12h14`
- flame `M12 2l5 8-2.6-.6L18 15l-6 7-6-7 3.6-5.6L7 10z`
- strike `M4 20 16 8M18.5 3 21 5.5 18.5 8 16 5.5z` (blade + diamond guard)
Sizes in use: 22 default (circle buttons), 20 w1.8 (plus in FoesHeader), 18 w1.8 (Ember/Hold strike icon), 14 w1.8 (flame in LevelBadge), 22 (row check, silk). Parsed by `inkPath` (supports M L H V C S Z, abs+rel).

### NavIcon (ui/nav_icon.dart) polylines on 24 grid, stroke 1.6 square/round, size 22
0 Bosses = mask: closed hexagon (5,4)(12,6)(19,4)(18,13)(12,21)(6,13) + eyes (9,11)-(11,12), (15,11)-(13,12)
1 Today = blade: (4,20)-(16,8); closed diamond (18.5,3)(21,5.5)(18.5,8)(16,5.5); hilt (4,8)(10,8)(10,14)
2 Bonfire = flame over crossed logs: closed (12,3)(16,9)(14,8.6)(16.5,13)(12,17)(7.5,13)(10,8.6)(8,9); base (4,21)-(20,21); logs (7,18.5)-(17,21) and (17,18.5)-(7,21)
3 Profile/Relics = cut gem: closed (12,3)(19,10)(12,21)(5,10); (5,10)-(19,10); (12,3)-(12,21)

### Other drawn marks
- DiamondPip: square rotated 45deg, default 6px, solid colour (the "dot" replacement). Sizes in use: 5 (tab), 6, 8 (steps, selected-pick unselected), 12 (selected pick), 14 knob (switch, bordered), 26*scale (level badge).
- Material icons used directly (not custom): local_fire_department_outlined (BonfireCard), close, drag_handle, chevron_right, check, circle_outlined (PlanBanner 16px).
- BossArt: see component list. RelicEmblem: see list.

---------------------------------------------------------------------------
## 5. COMPONENTS (every file in lib/ui/)

NeedleFrame is the content container: 1px edge (seam default) + clip fill (shell default), radius tier (Cut). Glass = chrome. Tokens: N=NeedleFrame.

1. accuracy_line.dart: one-line Text bodySmall: "Today: x of y kept." + "This week: x of y."; empty when both zero.
2. action_row.dart ActionRow: full-width plain row in sheets, N tier md, inner height 50 (52 with frame), label Hanken 16 w600 bone centred. No glass (cheap). Tap only.
3. all_bosses_row.dart AllBossesRow: GlassTapTarget (48 min) wrapping N(lg) with padding h14 v12, side margin 20; "All bosses" w600 + " · n active · n waiting" ash, trailing "›" 22 ash.
4. away_summary.dart AwaySummary: GlassAlert (label "While you were away", title "A deadline passed."/"Two deadlines passed.", action "Go on"); content max-height 280 scroll, rows N(md) pad h16 v4 spacing 8; title bodyMedium bone, cost bodySmall; "Done late" TextButton when not done.
5. biome_choice_row.dart BiomeChoiceRow: "Biome" bodyMedium; per biome row min-height 48, pad h16, radius 6, 1px border silk when selected else seam, label bodyMedium, 4 swatches 20x20 (void_, shell, silk, bone) with seam border, 4px gaps, 8px between rows.
6. bonfire_card.dart BonfireCard: N(md); edge silk when not rested; InkWell splash silk@12%; min height 64; pad h20 v8; flame outline icon (silk, or ash when rested) + 16 gap + bodyMedium "Rest at the bonfire"/"Rested" (ash).
7. boss_actions_sheet.dart BossActionsSheet: GlassSheet label "Boss actions", title boss name, closeLabel "Close"; ActionRows spaced 10: Leave for now / Set active / Edit / Pin|Unpin / Declare victory / This attempt failed.
8. boss_card_tile.dart BossCardTile: outer pad v6; N(lg) with edge deep + fill raised2 when pinned; InkWell splash silk@12%, highlight dim@10%; pad 20; row: heading column (pinned label: 6px silk diamond rotated + "Pinned" labelSmall silk; title headlineMedium; "Attempt n · progress" bodySmall) + 8 gap + BossArt width 72; optional ShardMeter height 8 (16 above). Semantics "Boss X, attempt n, p percent health".
9. check_in_card.dart CheckInCard: N(md) pad 16; titleMedium question; Wrap spacing 8 of OutlinedButton (min 48, side dim, label bodyMedium) Never/Sometimes/Often; right-aligned TextButton "Not now" ash.
10. choice_dialog.dart ChoiceDialog<T>: GlassAlert (title, no actions) with options as N(md) rows min 48, centred bodyMedium bone, spacing 8.
11. collapsible_section.dart CollapsibleSection: header row min 48: labelSmall title + "›" 22 ash that rotates 0 -> 0.25 turns (Motion.quick 250ms); child shown when expanded.
12. commit_sheet.dart CommitSheet: GlassSheet label "Promise by"; TimeChoiceRow per DeadlinePreset spacing 8; 4 gap; _SwitchRow (min 48, bodyMedium label + GlassSwitch) "Remind me 10 minutes before", "Every day" (if daily); optional note bodySmall.
13. confirm_dialog.dart ConfirmDialog: GlassAlert body=question, actions [action, "Not yet"] -> pops bool.
14. day_summary.dart DaySummary: column bodyMedium lines "Struck n / Tried n / Fallen n" or "A quiet day so far."; lessons below in ash with 8 top pad.
15. deadline_chip.dart DeadlineChip: h8 margin; N(sm) edge silk when soon; pad h8 v2; bodySmall silk (soon) or ash.
16. dust_vanish.dart DustVanish: child opacity 1 - easeIn(t); motes (default 48, seed 7): x random, y .2-.8 of height, delay 0-.4, rise 20-90px upward, sway +/-20, radius .8-2.6; alpha sin(local*pi); glow circle r*3 at 18% blur 4, core at 90%; colour bone. Shown only 0<t<1.
17. ember_button.dart EmberButton: primary CTA. N(md) edge+fill silk; min height 52; pad h24; optional StrokeIcon 18 w1.8 onSilk + 10 gap; label Hanken 15 w700 onSilk; InkWell.
18. ember_tally.dart EmberTally: Wrap spacing 24: "Carried n" silk, "Banked n" ash, bodyMedium.
19. extend_sheet.dart ExtendSheet: GlassSheet "Move it later"; cost line bodySmall ("Free, once." / "No flask left to move it again." / "Costs a flask. You hold n."); TimeChoiceRow list (disabled when blocked), spacing 8.
20. filter_chips.dart FilterChips<T>: horizontal scroll row spacing 8; each N(md) min height 48 pad h16, bodyMedium; selected = edge silk + fill raised + bone text, else ash.
21. flash_line.dart FlashLine: height 36, titleMedium silk, AnimatedSwitcher kSlowFade 600ms (0 on reduced motion), left aligned, cross-fades.
22. flask_choice.dart FlaskChoice: Material AlertDialog (bg shell): title titleMedium, content bodyMedium, actions TextButton "Let it fall" (ash) + EmberButton "Use a flask".
23. flask_pips.dart FlaskPips: row of cap circles 12px, gap 8; full = fill text colour, border 1 dim; empty = just dim border.
24. foe_actions_sheet.dart FoeActionsSheet + showGlassFoeActions: GlassSheet label "Task actions"; ActionRows spacing 10: Promise by… / Move it later / Mark as tried / Edit / Delete.
25. foes_header.dart FoesHeader: Row: "Today's tasks" titleMedium 22/28h, count bodyMedium ash, GlassTapTarget 48x48 with plus icon 20 w1.8 silk.
26. glass_alert.dart GlassAlert + showGlassAlert: centred, side pad 28, maxWidth 334, GlassSurface rounded 34, blur 24, glint 68; shell@62% scrim; content pad (22,24,22,20) spacing 14: optional label (labelSmall upper), title titleMedium 30/34h centred, ThreadDivider, body bodyMedium ash centred (or content widget); action rows min height 52 with 1.5px glassKey top border, text Hanken 17 w600 bone, first action bg silk@28%. Barrier ink@62%. Semantics alertDialog.
27. glass_circle_button.dart GlassCircleButton: GlassTapTarget (48) + GlassSurface circle 44x44, StrokeIcon 22 bone (filled for `more`). States: pressed (fill hi + scale 1.04), tinted (silk@55%).
28. glass_pill_button.dart GlassPillButton: stadium 44 tall, pad h18, label Hanken 15 w600 bone ("Cancel"/"Close"). Pressed state.
29. glass_sheet.dart GlassSheet + showGlassSheet: outer pad 8, max height 90% screen; GlassSurface rounded 44, blur 28, glint 88, shell@58%; inner pad (20,26,20,24), spacing 18: grabber (40x6, white@45%, radius 2, border 1 glassKey, skewX -0.42), header row (gap 12): label labelSmall + title titleMedium 26/30h on left, GlassPillButton right; ThreadDivider; scrolling child. Barrier ink@62%, root navigator, safe area.
30. glass_surface.dart GlassSurface/GlassShape/GlassShadowPainter/GlassPainter: see section 3. Params: blur=16, edgeWidth=2, glintSize, edge, isPressed, isTinted, tilt.
31. glass_switch.dart GlassSwitch: 52x32 stadium glass; diamond knob 14px (rotated 45deg, border 1.5 glassKey) at left 8 (off, ash fill) / 30 (on, bone fill), top 8; animates 300ms easeOutBack; on = silk-tinted track.
32. glass_tab_bar.dart GlassTabBar: stadium glass 62 tall; margin L/R 21, bottom 19 + safe inset; inner pad 4, tab gap 2; tabs Home/Today/Bonfire/Profile; selected: stadium fill glassFillHi + 0.5 glassRing border, bone icon/text, 5px silk diamond at top 3; unselected ash. Icon 22 + 2 gap + label 11/13h w600. Text scale clamp 1.0. clearance 100.
33. glass_tap_target.dart GlassTapTarget: invisible 48x48 min hit area, Semantics button/toggle, forwards tapDown/Up/Cancel as press reports.
34. hall_of_relics.dart HallOfRelics: column of RelicTile; empty = bodyMedium "No bosses vanquished yet. The first relic awaits." pad v16.
35. hold_button.dart HoldButton: GlassSurface circle 48 (blur 0), edge bone when ready else ink, edgeWidth 1.5; vertical fill rising from bottom (inset bottom 1) height = progress*46 in silk@78%; strike icon 18 w1.8 bone.
36. home_header.dart HomeHeader: pad (20,8,20,16), spacing 8: row "Hearthrise" labelSmall + two GlassCircleButtons (profile, settings) 8 apart; row: date bodyMedium 14 ash over greeting displaySmall; trailing LevelBadge. greetingFor: 5-11 Morning., 12-16 Afternoon., else Evening.
37. ink_path.dart inkPath(): SVG-path parser (M L H V C S Z abs/rel) -> Path with optional per-point random jitter by seed (cel "boil").
38. inscription_field.dart InscriptionField: label bodyMedium w600 + "n / 120" bodySmall; N(md) TextField bodyMedium, cursor silk, hint "A line to remember this by" ash, pad 16/16; optional right-aligned EmberButton "Save".
39. lesson_timeline.dart LessonTimeline: rows with seam top borders, pad v10; 38-wide silk roman numeral (bodySmall w600, 24/13h) + titleMedium italic 19/24h lesson, optional "a missed day" bodySmall.
40. level_badge.dart LevelBadge: silk diamond (26px * scale, bounding 26*1.4142) with level numeral titleMedium 16*scale onSilk; next to it embers count (bodyMedium, flame icon 14 silk when trailing) and 5 bars 10x4 (silk on / dim@35% off), gap 2; isLarge scale 1.8; spacing 10 (trailing) or 8.
41. level_line.dart LevelLine: "Level n" titleMedium + "n embers to the next" bodySmall.
42. mood_choice.dart MoodChoice: row of equal N(md) tiles gap 8, min 48, pad h4 v8, bodyMedium w600 centred (bone/ash), selected edge silk; optional note bodyMedium.
43. nav_icon.dart NavIcon: section 4.
44. needle_frame.dart NeedleFrame: see top of section 5 (tier, edge, fill, isFocused 2px bone ring).
45. needle_text_field.dart NeedleTextField: caption (labelSmall, or bodyMedium w600 if plain) gap 6; N(md) with TextField bodyLarge, pad h16 v14, cursor silk, hint ash, counter hidden, maxLength 80.
46. notice_dialog.dart NoticeDialog: GlassAlert body + single action "OK".
47. onboarding_fields.dart: inscriptionDecoration (underline dim, focused silk, hint ash); LineField (bodySmall label + underline TextFormField bodyLarge); NameListEditor: help bodyMedium, rows with 30px silk roman numeral (labelSmall), underline field maxLength 60, 48 close IconButton (Icons.close ash), "add" TextButton min 48.
48. onboarding_page.dart OnboardingPage: SafeArea; scroll area pad h20; top 24; StepMarks + "Step n of 5" labelSmall (gap 12); 16; line displaySmall; 24; body. Footer pad h12: "Skip" TextButton ash left, EmberButton "Next"/"Begin" right (disabled = plain TextButton).
49. pharloom_backdrop.dart: section 3.
50. phase_panel.dart PhasePanel: pad v8; N(md) pad (8,0,8,8); header row: 48x48 drag handle (ash), 26px roman numeral labelSmall silk, name field titleMedium 20, close IconButton; foes as nested N(md) rows min 52 pad h16 v8 with bodyMedium + bodySmall + chevron_right; TextButton "Add a task".
51. pick_toggle_row.dart PickToggleRow: N(md) min 48 pad h16 v8; left column of pips (4 gap) DiamondPip(6) silk/dim, title bodyMedium bone + subtitle bodySmall, trailing DiamondPip 12 (selected silk) / 8 (dim). Selected: edge silk + fill raised.
52. pinned_boss_panel.dart PinnedBossPanel: pad v6; N(lg) edge deep; vertical gradient raised2 -> shell; pad 20; heading (headlineMedium + bodySmall) + BossArt 72; "Boss health" labelSmall + "n / 12" bodySmall; ShardMeter (height 10); EmberButton "Enter the fight" with strike icon. Long-press opens actions.
53. plan_banner.dart PlanBanner: N(md) pad 16; title labelSmall ("TODAY'S THREE"); rows 16px icon (check ash / circle_outlined dim) + bodyMedium (done = ash + line-through), 8 gap; "The three are done." bodySmall.
54. player_health_bar.dart PlayerHealthBar: pips 14x6, gap 4, 1px dim border, fill shard by half units (0/50/100% width, left aligned); count = max/2.
55. profile_level.dart ProfileLevel: 64px diamond painter (fill shell, edge deep 1.5 inset 1.5, inner ring silk@60% 1.5 inset size*7/44) with numeral titleMedium 28 w600; right: "Level n" titleMedium 30/34h, 5 bars 10x4 gap 3 (silk/dim), "n embers to the next" bodyMedium 14 ash; spacing 16/6.
56. relic_emblem.dart RelicEmblem + EmblemPainter: size default 96; circle r=size/2-2 stroke size/28 colour text; inner diamond r*.62 stroke text@80%; centre dot r*.14 silk; weathering marks: unmarked 0, worn 3, scarred 6, weathered 10 nicks (round-cap, size/40 wide, void_ colour, from r*(.78+.1*(i%3)) to r+2, angle i*2pi/n + i*.35).
57. relic_tile.dart RelicTile: InkWell min 48 pad v8; RelicEmblem 48 + 16 gap + name titleMedium + date bodySmall.
58. reminder_invite.dart ReminderInvite: GlassAlert "A quiet nudge each evening?" / "One gentle reminder to come back to the bonfire." actions "Yes, remind me" / "Not now".
59. setting_choice_row.dart SettingChoiceRow<T>: title bodyMedium, 8, equal N(md) tiles gap 8 min 48 pad 4, bodyMedium w600 centred, selected edge silk + bone text.
60. setting_switch_row.dart SettingSwitchRow: row min 48, bodyMedium title + GlassSwitch.
61. setting_value_row.dart SettingValueRow: ListTile (zero content pad), bodyMedium title, trailing value bodyMedium ash.
62. shard_meter.dart ShardMeter: 12 skewed parallelograms (skewX -0.42), radius 2, gap 3, default height 10 (card 8), filled = shard, empty = dim@35%, colour tween Motion.drain 900ms easeInOut. shardsFor(h) = round(h*12).
63. silk_page_transition.dart SilkPageTransitions: crossfade + rise: enter easeOut, FadeTransition(opacity: reverse of secondary) over FadeTransition(enter) over SlideTransition from (0,0.02) to 0. Used for every platform. Duration = framework default (route).
64. snapping_thread.dart SnappingThread: two 1px silk lines with centre gap 32*t, each line opacity 1 - 0.6t.
65. stat_row.dart StatRow: IntrinsicHeight row, equal columns: value bodyLarge 17/24h w600 text over label bodySmall; 1px seam dividers.
66. step_marks.dart StepMarks: n DiamondPip(8) gap 8; i<step silk else dim.
67. strength_segments.dart StrengthSegments: equal N(md) tiles gap 8 min 72 pad v8; diamond pips (6, gap 4) silk/dim, label bodyMedium w600 bone/ash, note bodySmall; selected edge silk.
68. strike_result_sheet.dart StrikeResultSheet + showStrikeResultSheet: GlassSheet "How did the strike land?"; two _Choice N(md) height 68 (gap 12): "Clean strike" (tinted: edge+fill silk, text onSilk, 16 w700, note 13) and "A real try" (plain, bone/ash).
69. strike_sweep_view.dart StrikeSweepView + helpers: slash overlay beats by progress: <.12 arcRising, <.25 arcFull (+ silk thread 2px), <.38 hitStop (bone@55% full-screen flash, broken arc, ink-outlined bone star scale 1.1 boss / .8 normal at (0.62w, 0.5h)), else shatter (arc fading in 4 steps, flecks: 14 boss / 8 normal, golden angle 2.39996, reach (40+(i%4)*18)*(1.3 boss)*easeOutCubic, every 3rd is silk 2px streak, others 5-pt bone shards with ink 1.2 outline). Ink stroke 2.2, round joins. Screen shake offsets [(-7,3),(6,-4),(-5,-2),(4,3),(-3,1),(2,-2),(-1,1)] during shatter 0.38-0.70. Row shake [(-5,2),(4,-2),(-3,-1),(2,1),(-1,0)] each 56ms from 110ms. Beats (Duration): hit 0-110ms, shatter 110-500, settle 500-1300, idle after.
70. sync_status_row.dart SyncStatusRow: "Back up and sync" bodyMedium; muted lines bodyMedium ash; TextButtons min 48x48, pad h4, left aligned ("Sign in with Google", "Sign out", "Delete account"); disabled while busy; status strings: Not synced yet / Last synced just now|n min ago|n h ago|n d ago / Waiting for a connection / n item(s) not backed up.
71. task_row_tile.dart TaskRowTile: pad v4; N(md) min height 64, pad L16 R8; pip column (DiamondPip 6, gap 4; silk, dim when done); title bodyLarge 16/22h w500 + meta bodySmall 13/18h; spacing 14; optional deadline chip; trailing (48x48 hit; done shows 22 silk check). RowPhase idle/charge/hit/shatter/settle: charge = edge silk; hit = fill bone + ink text; done (struck) = edge struckEdge, fill struckBg, title ash, 1.5px ink line through title. Tap uses pointer slop (kTouchSlop) so trailing controls can absorb taps. Optional sweep overlay inset top/bottom 4.
72. thread_divider.dart ThreadDivider: 1px silk line, 6px silk diamond in the centre with 8px side padding.
73. time_choice_row.dart TimeChoiceRow: N(md) min 48, pad h16, left-aligned bodyMedium (bone enabled, dim disabled).
74. tomorrow_pick_sheet.dart TomorrowPickSheet: GlassSheet "Tomorrow's three"; bodyMedium intro; labelSmall row "Tasks waiting" / "n of 3 chosen"; flash bodySmall; PickToggleRow list; ActionRow "Set tomorrow"; spacing 16.
75. tomorrow_row.dart TomorrowRow: N(md) min 48 pad h16 v8; "Tomorrow's tasks" bodyMedium bone + summary bodySmall; " ›" 22 ash.
76. boss_art.dart BossArt + BossArtPainter: 200x180 design box, width default 200 (72 on cards), height = 0.9*width. Hand-drawn ink with 3 jitter frames (jitter 1.4, seeds 7, 20, 33), boilFrame%3. Layers back to front (fill, stroke, width): lance line stroke ink 6 then shard 2.6; lance head fill deep stroke ink 2; cloak fill raised stroke ink 2.6; cloak edge lines mote 1.4 (drawn at 30% alpha); cloak folds ink 1.6; arm ink 2.4; horns fill bone stroke ink 2.2; mask face fill bone stroke ink 2.6; eyes fill ink. Round caps/joins. `hit` 0..1 lerps every colour toward `mask`. Path data in boss_art.dart:42-78.
77. diamond_pip.dart DiamondPip: described in iconography.
78. stroke_icon.dart StrokeIcon + StrokeIcons: described in iconography.

(See section 6 for animations; no component files omitted.)

---------------------------------------------------------------------------
## 6. MOTION, HAPTICS, SOUND

### Duration tokens (theme.dart:31-41)
Motion.quick 250ms (rollback, small state, chevron rotate) | Motion.fade / kSlowFade 600ms (standard fade, FlashLine) | Motion.drain 900ms (shard colour) | Motion.dim 1400ms (fallen dim). Curve default Curves.easeInOut. `motionOf(ctx,d)` = zero under system reduce-motion.
Rules: slow, no bounce, exits faster than entrances; only exception = glass press overshoot.

### Specific
- Glass press: scale 1.04, 350ms, easeOutBack (glass_surface.dart:~101-105).
- GlassSwitch knob: 300ms easeOutBack, left 8 <-> 30.
- Page transition (silk_page_transition.dart): crossfade+rise 2% (Offset(0,0.02)), enter easeOut; old page fades out via ReverseAnimation(secondary).
- Tab transition (core/tab_transition.dart:10-11): CustomTransitionPage 280ms forward and reverse, same fade+rise recipe.
- Atmosphere: loop 42s, clock 30Hz, ink boil step 140ms over 3 frames; glass tilt easing 12%/60Hz frame; sensor deadzone 1.5deg, full 22deg; tilt controller silence 1s (shell/tilt_controller.dart:41).
- ShardMeter drain 900ms easeInOut; level badge none.
- DustVanish: struck task ~1.2s; boss vanish 2400ms (strike/boss_vanish.dart:7, easeIn); DustVanish opacity easeIn.
- Strike sweep: 1300ms normal, 1600ms boss-tier (features/strike/strike_sweep.dart:13-15); beats: hit 0-110ms, shatter 110-500ms, settle 500ms-1300ms; row shake step 56ms x5; strikeLinger 1500ms (today_view.dart:38).
- Hold durations by weight: Light 300ms, Heavy 600ms, Boss-tier 1200ms (DESIGN.md). Rollback 250ms.
- Fallen: dim 1400ms, easeIn fade (fallen_screen.dart:81), span 2000ms (:99). Victory reveal 5000ms (victory_screen.dart:18). Boss stage run 700ms, other 700/1400ms (boss/boss_stage.dart:37-50).
- Reminder lead 10 min (commit/deadline_reminders.dart:8).
- Reduced motion: backdrop/glass tilt/animations hold still; Settings "motion effects" switch also stills them.

### Haptics (core/haptics.dart)
Single gate `Haptics(isEnabled)`, asks on every call: tick = selectionClick; light = lightImpact; medium = mediumImpact; heavy = heavyImpact; doubleHeavy = heavy, then heavy again after 120ms (boss-tier landing). Usage: strike/hold_to_strike.dart:108-126 (tick or medium during hold by weight; light/heavy/doubleHeavy on landing); fallen_screen.dart:72 heavy.

### Sound (core/sounds.dart)
`Cue { victory, fallen }`; `Sounds` gated by setting; bonfire hum loop `startHum/stopHum` (stop is never gated). Default player `SilentSoundPlayer` (no audio files bundled); real `AudioSoundPlayer` referenced but no sound assets exist in app/assets.

---------------------------------------------------------------------------
## 7. ASSETS (app/assets)
Only fonts. pubspec.yaml `flutter:` registers exactly:
- assets/fonts/CormorantGaramond.ttf (family CormorantGaramond, variable)
- assets/fonts/HankenGrotesk.ttf (family HankenGrotesk, variable)
- Licences (not registered): assets/fonts/OFL-CormorantGaramond.txt, assets/fonts/OFL-HankenGrotesk.txt
No raster images, sounds or SVGs. All art (boss, icons, emblem, slash) is code-painted. `uses-material-design: true` (Material icon font). iOS native assets only: ios/Runner/Assets.xcassets (AppIcon, LaunchImage).

---------------------------------------------------------------------------
## Unsure / caveats
- Line numbers for glass_alert/circle/pill/sheet/switch/tab_bar/tap_target, pharloom_backdrop, stroke_icon, nav_icon, boss_art, ink_path, thread_divider, diamond_pip are not recorded (symbol refs only). glass_surface.dart numbers are approximate (+/- 2).
- BossArt jitter seeds: code is `7 + f*13` -> 7, 20, 33 (derived, not printed).
- Sweep arcs/star path data are in strike_sweep_view.dart:76-87; not reproduced here.
- Palette `ground2` and `silkHi` have no direct usage found in ui/ (defined, possibly used in features/); glass alert/sheet scrim alphas (62%/58%) are Colors layered over glass, not palette tokens.
- Did not read features/ screens, so layout of screens (as opposed to components) is not covered; DESIGN.md Strike/Dust timings quoted as documented, not verified in code.
- Skimmed DESIGN.md only; THEME_PLAN.md headings only.
