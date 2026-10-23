# Apple HIG: Liquid Glass applied to iOS 26 components and layout

Method note: developer.apple.com HIG pages are JS-rendered; plain fetch returns only titles. The JSON endpoint `https://developer.apple.com/tutorials/data/design/human-interface-guidelines/<page>.json` returned full text and was used (content passed through a summarizing model, so treat paraphrase as close but not verbatim). HIG change logs show "Updated guidance for Liquid Glass" Dec 16 2025 and terminology updates June 8 2026, so text below reflects late-2026 state. Tags: [APPLE] = published by Apple; [COMMUNITY] = single third-party/forum measurement; [UNVERIFIED] = not confirmed by a fetched source this session.

## Where glass goes / does not go; variants; tinting; legibility

### Takeaway
Glass is a functional layer of controls and navigation floating above content; never in the content layer, sparingly, and tinted only for the one primary action. Regular is the default; clear only over rich media with dimming.

### Cited Findings
- Liquid Glass forms a distinct functional layer for controls and navigation (tab bars, sidebars) floating above content; content scrolls and peeks through. [APPLE] — [Materials](https://developer.apple.com/design/human-interface-guidelines/materials)
- Don't use glass in the content layer; use standard materials there. Exception: content-layer controls with transient interactivity (sliders, toggles) may take a glass look when activated. Don't overuse on custom controls; limit to most important functional elements. [APPLE] — [Materials](https://developer.apple.com/design/human-interface-guidelines/materials)
- Regular: blurs and adjusts luminosity for legibility; use for most components and for text-heavy ones (alerts, sidebars, popovers). Clear: highly translucent, only over visually rich backgrounds/media. [APPLE] — [Materials](https://developer.apple.com/design/human-interface-guidelines/materials)
- Clear glass over bright content: add a dark dimming layer at 35% opacity; not needed if content is dark or AVKit controls. [APPLE] — [Materials](https://developer.apple.com/design/human-interface-guidelines/materials)
- Appearance changes with Reduce Transparency / Increase Contrast and user's preferred glass look; test these. [APPLE] — [Materials](https://developer.apple.com/design/human-interface-guidelines/materials); [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass)
- Avoid stacking glass elements on each other; use standard spacing; combine custom glass in `GlassEffectContainer` (perf + morphing). [APPLE] — [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass)
- Reduce custom backgrounds in tab bars, toolbars, split views; they interfere with glass and scroll edge effect. [APPLE] — same
- Glass has no inherent color; takes color from content behind. Small elements (toolbars, tab bars) flip light/dark with content; symbols/text monochrome by default. Larger elements (sidebars) look more opaque. [APPLE] — [Color](https://developer.apple.com/design/human-interface-guidelines/color)
- Tint rules: color sparingly; color the background (not symbol/text) of the primary action (e.g. Done); don't tint backgrounds of multiple controls; avoid label colors similar to colorful content behind; resting state of scroll top must stay legible; provide light/dark + increased-contrast color variants. No numeric tint opacity or contrast ratios published. [APPLE] — [Color](https://developer.apple.com/design/human-interface-guidelines/color)
- Standard materials on iOS: ultraThin, thin, regular, thick; label vibrancy levels label/secondary/tertiary/quaternary (avoid quaternary on thin/ultraThin); don't put non-vibrant colors (e.g. systemGray3) on a material. [APPLE] — [Materials](https://developer.apple.com/design/human-interface-guidelines/materials)
- API: `glassEffect(_:in:)`, `.glass`/`.glassProminent` button styles, UIKit `UIButton.Configuration.glass()/prominentGlass()/clearGlass()/prominentClearGlass()`. [APPLE] — [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass)

### Inferences
- For a mockup: glass only on tab bar, nav-bar buttons, floating action/search, sheets/menus/alerts chrome; list rows, cards, and backgrounds stay flat (opaque/standard material).

### Gaps
- No Apple-published blur radius, refraction, specular or opacity numbers for regular/clear glass; must be eyeballed from the Figma kit.

## Tab bar (floating capsule, minimize, search role)

### Takeaway
iOS 26 tab bar floats at the bottom on a glass background, can minimize on scroll with an inline accessory, and supports a separated trailing search tab. Apple publishes no height/radius; community measurement gives 62 pt bar in an 83 pt container.

### Cited Findings
- iOS: tab bar floats above content at screen bottom; items rest on a Liquid Glass background; content peeks through. [APPLE] — [Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars)
- With an attached accessory (e.g. Music MiniPlayer) the bar can minimize and move the accessory inline on scroll-down; exit by tapping a tab or scrolling to top. API `tabBarMinimizeBehavior` (`.onScrollDown`, also up/never); `tabViewBottomAccessory`. [APPLE] — [Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars); [Adopting](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass)
- Search tab: `Tab(role: .search)` / `UISearchTab`; system moves it to trailing end, separated from other tabs. Two looks: standard tab (opens landing page with field) or button appearance (focuses field + keyboard, returns to previous tab). [APPLE] — [Adopting](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass); [Search fields](https://developer.apple.com/design/human-interface-guidelines/search-fields)
- Rules: navigation not actions; keep visible; avoid overflow "More"; don't hide/disable tabs; single-word labels; filled SF Symbols preferred; icons above labels in compact width; badge = red oval for critical info only; avoid label colors similar to content backgrounds. No tab count number stated (iOS More tab appears when width-limited). [APPLE] — [Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars)
- Tab bar background color can't be changed in iOS 26 (Apple DTS). [APPLE-staff, forum] — [Forum 796986](https://developer.apple.com/forums/thread/796986)
- Measured: tab bar 62, wrapper container 83 (units "px", likely pt; iPhone 16 Pro sim vs SE). [COMMUNITY] — [Forum 796986](https://developer.apple.com/forums/thread/796986)
- Measured: capsule inset 21 pt from left, right, bottom; labels 11 pt SF regular; home-indicator zone 21 pt. [COMMUNITY] — [LearnUI](https://learnui.design/blog/ios-design-guidelines-templates.html)

### Inferences
- 390 pt wide screen minus 2x21 inset = ~348 pt wide capsule; 62 pt tall fits 83 = 62 + 21 bottom inset. Capsule radius = height/2 = 31. (Derived from community values; verify in Apple's Figma kit.)

### Gaps
- Selected-tab pill dimensions, icon size inside bar, minimized-state size: not found.

## Navigation bar / toolbars / scroll edge effect

### Takeaway
Bar items sit in floating glass groups with no bar background; backgrounds and tints reduced; a scroll edge effect (soft or hard) replaces hard dividers. One tinted primary action, trailing.

### Cited Findings
- Reduce toolbar backgrounds and tinted controls; let content layer drive color; use `ScrollEdgeEffectStyle` when needed to separate toolbar from content. [APPLE] — [Toolbars](https://developer.apple.com/design/human-interface-guidelines/toolbars)
- Group by function/frequency, about three groups max; use fixed spacers to split groups sharing a background (`ToolbarSpacer`); don't mix text and icons in one shared-background group; icons over text; no borders on symbols; titles under 15 characters; large title in iOS that collapses on scroll. [APPLE] — [Toolbars](https://developer.apple.com/design/human-interface-guidelines/toolbars); [Adopting](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass)
- Prominent style (`.prominent`) for single primary action (Done/Submit) on trailing side; standard Back/Close with no text labels. [APPLE] — [Toolbars](https://developer.apple.com/design/human-interface-guidelines/toolbars)
- Standard components' corner radii are concentric with bar corners; custom ones must be too. [APPLE] — [Toolbars](https://developer.apple.com/design/human-interface-guidelines/toolbars)
- Scroll edge effect: separates floating UI from scrolling content; not decorative. Hard = more opaque blur with defined edge; soft = gradual variable blur. Prefer automatic; it gives more opaque separation for top toolbars with many controls, text outside glass controls, pinned table headers. One effect per view. No numeric values. [APPLE] — [Scroll views](https://developer.apple.com/design/human-interface-guidelines/scroll-views)
- Custom bars: `safeAreaBar(edge:...)`, `scrollEdgeEffectStyle(_:for:)`. [APPLE] — [Adopting](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass)
- Nav bar type (community): large title 34 bold, inline title 17 semibold, toolbar labels 17 medium. Glass nav buttons are circles with icons, fixed while content scrolls beneath. [COMMUNITY] — [LearnUI](https://learnui.design/blog/ios-design-guidelines-templates.html)

### Gaps
- Nav-bar glass button diameter, nav bar height: not found (44 pt min hit target applies, below).

## Sheets, menus/popovers, alerts

### Takeaway
Sheets: detents + grabber, inset half sheet with rounder corners and glass chrome; popovers/alerts use regular glass. No Apple pt values for radius.

### Cited Findings
- Detents: large (default), medium (~half); grabber for resizable sheets (tap cycles detents); swipe-down dismiss; Cancel leading / Done trailing; one sheet at a time; nonmodal sheets allowed (Notes formatting). [APPLE] — [Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets)
- Check content around sheet edges: rounded corners and the inset half-sheet can crowd content; remove custom visual-effect backgrounds from sheets/popovers so they match system; action sheets must originate from the triggering control (source view). [APPLE] — [Adopting](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass)
- Regular glass is recommended for alerts, sidebars, popovers (text-heavy). [APPLE] — [Materials](https://developer.apple.com/design/human-interface-guidelines/materials)
- Glass morphing between shapes via `GlassEffectContainer` + `glassEffectID`. [APPLE] (Adopting: container enables morphing; `glassEffectID` is from API docs, not fetched).
- Alerts: title (max ~2 lines), optional message, up to three buttons, 1-2 word verb titles; default/preferred button trailing or top; Cancel leading or bottom; no pt values. [APPLE] — [Alerts](https://developer.apple.com/design/human-interface-guidelines/alerts)
- Menus: iOS element sizes small (4 icons row), medium (3 icon+label), large (list, default); one submenu level; icons all-or-none. No Liquid Glass-specific numbers. [APPLE] — [Menus](https://developer.apple.com/design/human-interface-guidelines/menus)

### Gaps
- Sheet corner radius (iOS 26), sheet inset margin, menu/alert width and radii: no Apple-published values found. Design-kit (Figma) not accessible.

## Buttons, sliders, toggles, segmented controls

### Takeaway
Use system glass button styles; controls get new shapes/sizes automatically. HIG pages give almost no pt values for iOS controls.

### Cited Findings
- Styles: `.glass`, `.glassProminent`; UIKit glass/prominentGlass/clearGlass/prominentClearGlass. Standard controls adopt new shapes/sizes if metrics aren't hard-coded. [APPLE] — [Adopting](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass)
- Hit region minimum 44x44 pt. Prominent style: one or two per view, accent-colored; primary = accent, destructive = system red; same size for peer options (style not size distinguishes). [APPLE] — [Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons)
- Toggles: switch only in list rows (default green); outside lists use toggle-style button. HIG art shows transparent glass toggle/slider. [APPLE] — [Toggles](https://developer.apple.com/design/human-interface-guidelines/toggles)
- Sliders: no iOS-26 specifics beyond card art (blue track, lensing thumb); don't use for audio volume on iOS. [APPLE] — [Sliders](https://developer.apple.com/design/human-interface-guidelines/sliders)
- Segmented control: about 5 segments max on iPhone, equal widths, text or images not mixed. [APPLE] — [Segmented controls](https://developer.apple.com/design/human-interface-guidelines/segmented-controls)
- Slider/toggle thumbs take glass look only while active (transient interactivity). [APPLE] — [Materials](https://developer.apple.com/design/human-interface-guidelines/materials)

### Gaps
- Capsule vs circle rules for iOS buttons not stated in HIG (visionOS/watchOS say capsule; visionOS sizes 28/32/44/52/64). Switch/slider/segment dimensions on iOS 26: not found.

## Concentricity, corner radius, sizing, spacing, safe areas

### Takeaway
Apple says "align concentrically" and gives APIs, but publishes no iOS corner values or margins in the HIG layout page.

### Cited Findings
- Align control shapes concentrically with containers: `ConcentricRectangle`, `Shape.rect(corners:isUniform:)`, `UIView.cornerConfiguration`. [APPLE] — [Adopting](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass)
- Layout page lists no iOS margins, radii, or 390x844 safe-area table (only tvOS/visionOS numbers). [APPLE] — [Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
- Lists/forms: larger row heights/padding, larger section corner radii, headers no longer all-caps (use title case), use `FormStyle.grouped`. [APPLE] — [Adopting](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass)
- 390x844 pt is the base-class screen (iPhone 12-16e etc.); 393x852 for 14 Pro/15/16; 402x874 for 16 Pro/17. [COMMUNITY] — [LearnUI](https://learnui.design/blog/ios-design-guidelines-templates.html)

### Inferences
- Concentric rule: inner radius = outer radius - inset; a capsule inside a capsule bar stays a capsule. Derived, not quoted.

### Gaps
- Device corner radius (~47.33 pt for 390x844 class), status bar (47 pt) and home indicator safe areas (34 pt bottom) are from memory [UNVERIFIED]; confirm in Apple's Figma/Sketch resources.

## Typography on glass

### Takeaway
SF Pro with standard text styles; use vibrant/monochrome labels on glass; Apple gives no glass-specific type sizes.

### Cited Findings
- iOS styles (pt/leading): Large Title 34/41, Title1 28/34, Title2 22/28, Title3 20/25, Headline 17/22 semibold, Body 17/22, Callout 16/21, Subhead 15/20, Footnote 13/18, Caption1 12/16, Caption2 11/13. Prefer Regular/Medium/Semibold/Bold; avoid Ultralight/Thin/Light. [APPLE] — [Typography](https://developer.apple.com/design/human-interface-guidelines/typography)
- Vibrant colors should sit on materials; thicker materials for fine text. Widget minimum text 11 pt. [APPLE] — [Materials](https://developer.apple.com/design/human-interface-guidelines/materials); [Widgets](https://developer.apple.com/design/human-interface-guidelines/widgets)
- Tab labels 11 pt. [COMMUNITY] — [LearnUI](https://learnui.design/blog/ios-design-guidelines-templates.html)

### Gaps
- No contrast ratios published for text on glass.

## Widgets, Home Screen icons, Control Center

### Takeaway
Home Screen offers light/dark/clear/tinted; icons built in layers via Icon Composer; widgets have published iPhone sizes and margins.

### Cited Findings
- App icons: four+ appearances (default, dark, clear light/dark, tinted light/dark); layered design (foreground/middle/background); system applies mask (rounded rect), blur, glass; don't bake effects in. [APPLE] — [Adopting](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass)
- Widgets: clear = desaturated, translucent, Liquid Glass; tinted = desaturated + user tint; accented mode on iPhone tints primary and accent groups white; full-color images desaturated in clear/tinted. [APPLE] — [Widgets](https://developer.apple.com/design/human-interface-guidelines/widgets)
- Widget margins 16 pt standard, 11 pt tight; use `ContainerRelativeShape` for concentric corners. [APPLE] — [Widgets](https://developer.apple.com/design/human-interface-guidelines/widgets)
- 390x844 widget sizes: small 158x158, medium 338x158, large 338x354; Lock Screen circular 72x72, rectangular 160x72, inline 234x26. [APPLE] — [Widgets](https://developer.apple.com/design/human-interface-guidelines/widgets)

### Gaps
- Control Center controls page: fetch returned 404 (wrong slug); no sourced Control Center specifics. Icon grid/corner radius numeric values not fetched.

## Not covered / follow-ups
- Apple Design Resources (Figma/Sketch iOS 26 kits), WWDC25 356/219/323 transcripts not accessed. Best next step for exact pt values: Figma kit inspect.
