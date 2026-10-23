# Liquid Glass implementation recipes per platform (as of Oct 2026)

Source-quality legend: [V] verified from a fetched page this session; [M] from model memory or a secondary summary of Apple docs (Apple developer pages are JS-rendered and did not fetch; treat as UNVERIFIED against Apple docs); [S] secondary/blog source.

## 1. SwiftUI / UIKit native (iOS 26+) and iOS 18 fallbacks

### Takeaway
Native glass is a small API surface: `glassEffect(_:in:)`, `GlassEffectContainer`, `glassEffectID`, button styles `.glass`/`.glassProminent`. Glass cannot sample other glass, so adjacent glass goes in one container. Below iOS 26 use `Material` (e.g. `.ultraThinMaterial`) behind an `#available` check.

### Cited Findings
- `glassEffect()` applies glass behind content; default shape is capsule; custom shape e.g. `glassEffect(in: .rect(cornerRadius: 16))` — [WWDC25 323](https://developer.apple.com/videos/play/wwdc2025/323/) [V]
- Config chain: `.glassEffect(.regular.tint(.green).interactive())`. `tint` should convey meaning (call to action), not decoration. `interactive()` makes glass scale/bounce/shimmer on touch; for custom controls on iOS — [WWDC25 323](https://developer.apple.com/videos/play/wwdc2025/323/) [V]
- "Glass can't sample other glass", so nearby glass elements should share a `GlassEffectContainer` (consistent visuals, blending) — [WWDC25 323](https://developer.apple.com/videos/play/wwdc2025/323/) [V]
- `glassEffectID(_:in:)` with a shared `@Namespace` gives morphing transitions when views appear/disappear inside a `GlassEffectContainer` — [WWDC25 323](https://developer.apple.com/videos/play/wwdc2025/323/) [V]
- Button styles: `.buttonStyle(.glass)` (standard) and `.buttonStyle(.glassProminent)` (prominent); bordered buttons are capsule by default, `.buttonBorderShape(.capsule)` sets explicitly — [WWDC25 323](https://developer.apple.com/videos/play/wwdc2025/323/) [V]
- `backgroundExtensionEffect()` mirrors+blurs content outside safe area so art extends behind floating sidebars — [WWDC25 323](https://developer.apple.com/videos/play/wwdc2025/323/) [V]
- Scroll edge effect is automatic under system toolbars; remove custom backgrounds/darkening behind bar items; tune with `.scrollEdgeEffectStyle(.hard, for: .top)` — [WWDC25 323](https://developer.apple.com/videos/play/wwdc2025/323/) [V]
- Tab bar: `.tabBarMinimizeBehavior(.onScrollDown)` collapses floating iPhone tab bar; `.tabViewBottomAccessory { }` plus `@Environment(\.tabViewBottomAccessoryPlacement)` (`.inline` = compact) — [WWDC25 323](https://developer.apple.com/videos/play/wwdc2025/323/) [V]
- Partial-height sheets get glass background by default; remove custom `presentationBackground` so it shows — [WWDC25 323](https://developer.apple.com/videos/play/wwdc2025/323/) [V]
- Text over glass: SwiftUI picks vibrant adaptive text color; scroll edge effect keeps bar items legible — [WWDC25 323](https://developer.apple.com/videos/play/wwdc2025/323/) [V]
- Signatures (not confirmed by Apple page): `Glass.regular`, `.clear`, `.tint(_:)`, `.interactive(_:)`; `GlassEffectContainer(spacing:)` where spacing = distance at which shapes begin to merge; `glassEffectUnion(id:namespace:)` merges several views into one glass shape — [M]; Expo/Callstack wrappers document the same `spacing` semantics ([Expo](https://docs.expo.dev/versions/latest/sdk/glass-effect.md) [V])
- Guidance: glass for navigation/floating-control layer, not content; avoid glass-on-glass; `.regular` for text-bearing surfaces, `.clear` only over rich/bright media, add dimming layer under clear for legibility — [M] (Apple "Adopting Liquid Glass", not fetched)
- UIKit: `UIGlassEffect(style: .regular)` with `isInteractive`, `tintColor`, put in `UIVisualEffectView(effect:)`; `UIGlassContainerEffect` with `spacing`, children added to the container view's `contentView`; `cornerConfiguration = .capsule()` — [S community skill, third-party](https://tessl.io/registry/skills/github/affaan-m/ECC/liquid-glass-design) and [M]
- Opt-out while migrating: Info.plist `UIDesignRequiresCompatibility = YES`; Apple indicated it is temporary — [M] (search found nothing; verify)
- System honors Reduce Transparency, Increase Contrast, Reduce Motion automatically for native glass — [M]

### Inferences
- Fallback recipe: `if #available(iOS 26, *) { view.glassEffect(...) } else { view.background(.ultraThinMaterial, in: shape) }` wrapped in one custom ViewModifier. Material has no tint/interactive equivalent; fake tint with an overlay color and press scale manually.
- Group controls in one `GlassEffectContainer`; never nest `glassEffect` inside another glass surface.

### Gaps
- Apple docs pages (glassEffect, Glass, UIGlassEffect, Adopting Liquid Glass) did not load; exact signatures, `glassEffectUnion`, `UIDesignRequiresCompatibility` lifetime need verification in Xcode 26 headers.
- WWDC25 219 and 356 not read. No 2026 (iOS 27/WWDC26) API changes checked (liquid_glass_widgets page mentions "iOS 26/27-style").

## 2. Flutter

### Takeaway
Baseline recipe is `BackdropFilter(ImageFilter.blur)` + saturation `ColorFilter` + tint + specular stroke, grouped with `BackdropGroup`/`BackdropFilter.grouped`. True refraction needs an Impeller fragment shader; packages exist (`liquid_glass_renderer`, `liquid_glass_widgets`). Flutter does not expose Reduce Transparency; use `MediaQuery.highContrast` as approximation or a platform channel.

### Cited Findings
- `BackdropGroup` "establishes a shared backdrop layer for all child BackdropFilter widgets that opt into using it" to improve performance; children must use `BackdropFilter.grouped`; ctor `BackdropGroup({Key? key, required Widget child, BackdropKey? backdropKey})`; `BackdropGroup.of(context)` — [Flutter API](https://api.flutter.dev/flutter/widgets/BackdropGroup-class.html) [V]
- `ImageFilter.isShaderFilterSupported`: true only when Impeller enabled; creating `ImageFilter.shader` when false throws `UnsupportedError` — [Flutter API](https://api.flutter.dev/flutter/dart-ui/ImageFilter/isShaderFilterSupported.html) [V]
- `liquid_glass_renderer` 0.2.0-dev.4 (pre-release/experimental), publisher whynotmake.it, MIT; Impeller only (Skia unsupported); platforms Android/iOS/macOS; widgets `LiquidGlassLayer`, `LiquidGlass`, `LiquidGlassBlendGroup` (+`LiquidGlass.grouped`), `FakeGlass` (shader-free), `GlassGlow`, `LiquidStretch`, `Glassify` (experimental); `LiquidGlassSettings`: `glassColor, thickness, blur, refractiveIndex, lightAngle, lightIntensity, ambientStrength, outlineIntensity, saturation`; max 16 shapes per blend group; memory spikes animating shapes (Flutter bug); blur artifacts when blending; blur unsupported in `Glassify`; ~31.1k downloads, "published 11 months ago" — [pub.dev](https://pub.dev/packages/liquid_glass_renderer) [V]
- `liquid_glass_widgets` v1.13.0 exists (publisher pixel-innovations.com, MIT, "4 days ago" at fetch), needs Flutter 3.41+/Dart 3.5+, no third-party deps, keep `cupertino_icons`; widgets incl. `GlassCard, GlassButton, GlassTabBar, GlassAppBar, GlassSheet, GlassSwitch, GlassSearchBar, GlassScaffold, ProgressiveBlur`; quality tiers `premium` (Impeller only; falls to `standard` on Skia/Web) and `minimal` (BackdropFilter blur + saturation + specular stroke, no custom shader); suggests `minimal` when `ImageFilter.isShaderFilterSupported` false; Android Impeller Vulkan full pipeline, GLES fallback reduced 8-shape; High Contrast on iOS/macOS bypasses shader for plain frosted panel because "Flutter does not expose Reduce Transparency directly"; Reduce Motion snaps springs; experimental `adaptiveQuality: true` — [pub.dev](https://pub.dev/packages/liquid_glass_widgets) [V]
- Secondary: Flutter does not pass reduce transparency / increased contrast on macOS; iOS/Android 34+ read contrast via MediaQuery — [S pub README snippet via search](https://pub.dev/packages/g1455) (weak)
- Secondary perf advice: avoid live blur/shader behind every scrolling row; ShaderMask/ColorFilter can trigger `saveLayer`; profile on Impeller — [S gskinner](https://blog.gskinner.com/?p=5994), [S search results]

### Inferences
- Recipe tiers: (1) premium = shader package on Impeller + non-low-end; (2) standard/minimal = `BackdropFilter(filter: ImageFilter.compose(outer: ColorFilter.matrix(saturation ~1.5-1.8), inner: ImageFilter.blur(sigma 12-24)))` + 8-20% white tint + 1px gradient stroke; (3) opaque tinted fill when `MediaQuery.highContrast`/`disableAnimations` or perf budget exceeded. Saturation matrix/ImageFilter.compose parameter values are from memory [M].
- Clip with `ClipRRect` around each `BackdropFilter` to bound the blur area.
- Reduce Transparency needs a MethodChannel to `UIAccessibility.isReduceTransparencyEnabled` (iOS); Android has no direct equivalent.

### Gaps
- Did not verify `BackdropFilter.grouped` signature text, `MediaQuery.highContrast`/`accessibleNavigation`/`disableAnimations` docs, or any Flutter Android blur benchmark numbers. Other packages (e.g. `liquid_glass_easy`) not checked. "liquid_glass_renderer" last update (~11 months before fetch) may mean slow maintenance.

## 3. Web (CSS / SVG)

### Takeaway
`backdrop-filter: blur() saturate()` is Baseline 2024 and the safe layer. SVG `feDisplacementMap` refraction via `backdrop-filter: url(#f)` is Chromium-only; Firefox/Safari degrade to blur (or render nothing). `prefers-reduced-transparency` has very limited support.

### Cited Findings
- `backdrop-filter` is Baseline 2024 ("newly available" since Sept 2024); syntax accepts `url("filters.svg#filter") blur(4px) saturate(150%)` — [MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/backdrop-filter) [V]
- Backdrop-root gotcha: parent with `filter`, `opacity<1`, `mask`/`clip-path`, `mix-blend-mode`, `will-change` of these, or another backdrop-filter bounds what is blurred; `opacity: 0.9` on parent can make child's backdrop-filter appear to do nothing — [MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/backdrop-filter) [V]
- `prefers-reduced-transparency`: values `no-preference` / `reduce`; MDN: limited availability, experimental, MQ5 draft — [MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/@media/prefers-reduced-transparency) [V]
- caniuse data: Chrome 118+, Edge 118+, Opera 104+, Samsung 25+; Firefox disabled by default (113-161 listed); Safari/iOS no support — [caniuse](https://caniuse.com/mdn-css_at-rules_media_prefers-reduced-transparency) [V]
- SVG displacement refraction: `backdrop-filter: url(#svg-filter)` full effect Chrome/Chromium only; Firefox/Safari degrade to blur — [S LogRocket](https://blog.logrocket.com/how-create-liquid-glass-effects-css-and-svg/), [S ekino](https://medium.com/ekino-france/liquid-glass-in-css-and-svg-839985fcb88d); a May 2026 WebKit bug reports Safari failing refraction (foreignObject + feDisplacementMap) — [WebKit Bugzilla 313914](https://bugs.webkit.org/show_bug.cgi?id=313914) [S, only snippet read]
- Library `liquid-glass-js` avoids backdrop-filter mode, uses SVG filters over cloned background snapshot for cross-browser — [S README](https://cdn.jsdelivr.net/npm/liquid-glass-js@0.1.0/README.md)

### Inferences
- Recipe: layer 1 `background: rgb(255 255 255 / .12); backdrop-filter: blur(16px) saturate(1.6); border:1px solid rgb(255 255 255/.25); box-shadow inset highlight`; layer 2 gated by `@supports (backdrop-filter: url(#x))` plus Chromium UA check (feature query alone is not a reliable Chromium test) adds displacement filter; layer 3 `@media (prefers-reduced-transparency: reduce), (prefers-contrast: more)` -> opaque fill, no blur. Also `-webkit-backdrop-filter` for older Safari [M].
- Always include a `@supports not (backdrop-filter: blur(1px))` solid fallback.

### Gaps
- `prefers-contrast` support table not fetched (believed broad in 2026 [M]). Firefox/Safari 2026 behavior of url() in backdrop-filter not directly tested; caniuse Chrome range "118-158" suggests future versions listed, treat with caution.

## 4. Jetpack Compose and React Native

### Takeaway
Compose: use the Haze library (`hazeSource`/`hazeEffect`; v2 adds `hazeGlass`). React Native: `expo-glass-effect` or `@callstack/liquid-glass` give real native glass on iOS 26 only; Android gets an opaque View.

### Cited Findings
- Haze (Chris Banes): Compose Multiplatform (Android, Desktop JVM, iOS, macOS, Wasm, JS); README says "Haze 2.0 is currently in beta"; modular: core `haze` + `haze-blur` dep; API per README: `rememberHazeState()`, `Modifier.hazeSource(state)`, `Modifier.hazeBlur(input = HazeInput.Sources(state), style = HazeBlurStyle { blurRadius(20.dp) })`, `Modifier.hazeGlass(input, style)` with `GlassStyle.regular`/`.clear`, `HazeMaterials` (`ultraThin() thin() regular() thick() ultraThick()`) in `haze-blur-materials` — [GitHub README](https://github.com/chrisbanes/haze), [docs site](https://chrisbanes.github.io/haze/latest/) [V]. Note: README fetch did not list `hazeEffect`/`HazeStyle`/progressive blur, which are known from Haze 1.x [M].
- `expo-glass-effect`: `GlassView` (props `glassEffectStyle` 'clear'|'regular'(default)|'none' or `{style, animate, animationDuration}`, `tintColor`, `isInteractive` default false, set once on mount, `colorScheme`), `GlassContainer` (`spacing`); needs iOS 26; falls back to plain `View` elsewhere; in Expo Go; `isLiquidGlassAvailable()` can be true even when accessibility limits effect, so also check `AccessibilityInfo.isReduceTransparencyEnabled()`; `isGlassEffectAPIAvailable()` guards beta builds that crash; avoid opacity <1 on GlassView/parents — [Expo docs](https://docs.expo.dev/versions/latest/sdk/glass-effect.md) [V]; isInteractive note via [Expo v54 docs](https://docs.expo.dev/versions/v54.0.0/sdk/glass-effect.md) [S]
- `@callstack/liquid-glass`: RN 0.80+, Xcode 26+, not supported in Expo Go; `LiquidGlassView` (`effect` 'clear'|'regular', `tintColor`, `interactive`, `colorScheme`), `LiquidGlassContainerView` (`spacing`), `isLiquidGlassSupported`; renders normal opaque View on iOS<26 and Android; supply translucent fallback background — [Callstack blog](https://www.callstack.com/blog/how-to-use-liquid-glass-in-react-native) [V]
- Neither RN library covers Android; a comparison points to `react-native-liquid-glassmorphism` for a cross-platform refractive effect — [S DEV](https://dev.to/wrack/the-best-react-native-liquid-glass-glassmorphism-libraries-in-2026-compared-15o6) (not verified; package existence unconfirmed)

### Inferences
- RN recipe: `isLiquidGlassAvailable() && !reduceTransparency ? <GlassView/> : <View style={{backgroundColor:'rgba(255,255,255,.7)'}}/>`; optionally `expo-blur` `BlurView` (exists [M], not fetched) for pre-26 iOS and Android.
- Compose recipe: Haze on all API levels; manual `Modifier.blur`/`RenderEffect.createBlurEffect` works only on API 31+ [M]; below that Haze falls back to non-blurred scrim [M, unverified]; always add tint + border.

### Gaps
- Haze minimum API, fallback behavior, glass guide, current stable version, performance/benchmark pages not retrieved. `expo-blur` and `react-native-liquid-glassmorphism` not fetched.

## 5. Performance rules

### Takeaway
Few blurred surfaces, shared backdrop passes, and no live blur in scrolling lists; degrade to opaque tint on low-end or accessibility settings. Numeric budgets below are heuristics, not sourced.

### Cited Findings
- Flutter: `BackdropGroup` + `BackdropFilter.grouped` share one backdrop layer for multiple filters — [Flutter API](https://api.flutter.dev/flutter/widgets/BackdropGroup-class.html) [V]
- liquid_glass_renderer caps 16 shapes per blend group and performance drops as shapes are added — [pub.dev](https://pub.dev/packages/liquid_glass_renderer) [V]
- liquid_glass_widgets: Android GLES fallback reduced to 8 shapes; `minimal` tier skips shaders; adaptiveQuality experimental — [pub.dev](https://pub.dev/packages/liquid_glass_widgets) [V]
- Callstack: apply glass to floating controls/panels, not full-screen backgrounds; avoid stacking many translucent views or heavy animation — [Callstack](https://www.callstack.com/blog/how-to-use-liquid-glass-in-react-native) [V]
- Native: group in `GlassEffectContainer` (one sampling region) — [WWDC25 323](https://developer.apple.com/videos/play/wwdc2025/323/) [V]
- Avoid independent live blur/shader behind every scrolling row; saveLayer-triggering widgets are costly — [S gskinner](https://blog.gskinner.com/?p=5994)

### Inferences (heuristic, unsourced)
- Budget: 2-4 glass surfaces per screen (nav bar, tab bar, one sheet/card cluster); >1 shader-refraction layer on Android is risky; never glass inside list items; sheets/dialogs over static backdrop can use a one-time snapshot blur.
- Skip blur (opaque tinted fill) when: reduce transparency / high contrast, low-end device or Skia without shader support, battery saver, during heavy scroll/animation if frame budget missed, or content behind is flat (blur invisible).
- Web: avoid animating elements carrying backdrop-filter; keep blur radius <= ~20px; limit SVG displacement to a few hero elements.

### Gaps
- No sourced numeric benchmarks (ms/frame, GPU cost per surface) found for any platform.
