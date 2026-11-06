# Native Liquid Glass plan (iOS 26+)

Research: `reports/iOS Liquid Glass in Flutter.md` (notes in `research_notes/iOS Liquid Glass in Flutter/`).

## Goal

On iOS 26 and later, Hearthrise's glass chrome sits on Apple's real Liquid Glass material. Everywhere else (iOS 15 to 18, Android, tests) the current Flutter glass runs unchanged. The look does not change: the needle-cut paper layer, the ink key line, the bottom shade, the inner ring, the sheen, the lit rim, the glint, tilt and the 1.04 press all stay, drawn by Flutter on top of the native material.

## How it fits the current code

`GlassSurface` (`app/lib/ui/glass_surface.dart`) is the only place that uses `BackdropFilter`. Its layers, bottom to top: shadow, clip, backdrop blur + saturate, fill, child, `GlassPainter`. Only the bottom of that stack changes:

| Layer | Flutter backend (today, all platforms) | Native backend (iOS 26+) |
|---|---|---|
| Shadow | `GlassShadowPainter` | same |
| Material | `BackdropFilter` blur 16 + saturate 1.7 | `UIGlassEffect(style: .regular)` in a `UiKitView`, shape sent as `cornerConfiguration` |
| Fill | palette `glassFill` / `glassFillHi` / tinted silk | same tokens over the native material, alpha retuned in step 0 so biomes read the same |
| Child | Flutter | same |
| Finish | `GlassPainter` | same |

Rules that come from the research:

- **No mixing on one screen.** A Flutter `BackdropFilter` in the same scene reportedly stops native glass rendering. So the backend is chosen once for the whole app, never per widget.
- **Gestures stay in Flutter.** `isInteractive = false`; the press scale and `glassFillHi` stay ours. Apple has no API to trigger its press response without a real touch on the native view.
- **No native tint.** `UIGlassEffect.tintColor` is remapped by the system, so biome colour stays in our fill.
- **Native shape, not a Flutter clip.** A Flutter clip over a platform view masks it and breaks sampling. `GlassShape` maps to `UIView.cornerConfiguration`: circle and stadium to `.capsule()`, rounded(r) to `.corners(radius: .fixed(r))`.
- **Accessibility.** The system already adapts the native material for Reduce Transparency, Increase Contrast and the 26.1 Clear/Tinted setting. Flutter gets high contrast (`MediaQuery.highContrastOf`) and reduce motion but not Reduce Transparency, so a small channel reports it. Under Reduce Transparency or high contrast, the native backend falls back to today's flat path (shell fill, key line only), so the system border and our key line never double.

## Open risks (step 0 answers them)

1. Does `UIGlassEffect` in a `UiKitView` refract the Flutter pixels beneath it on a real device in release mode? Only one simulator report says yes.
2. Jank from any visible platform view (flutter/flutter#190815; reported workaround `FLTEnableMergedPlatformUIThread = false`).
3. Halo bleed-through over Flutter sheets and glass during route transitions.
4. Cost: sheets, alerts, pills and the switch would each be a platform view.

If 1 or 2 fails, stop: native glass is not viable today. Fallback B is in the last section.

## Steps

Each step is test-first. Done means the listed tests pass, `flutter analyze` is clean and the full suite passes (from `app/`).

### 0. Spike on a device (throwaway branch, no TDD, nothing merged)

Native `UIGlassEffect` platform view under the tab bar only, with every other `GlassSurface` at `blur: 0`.

- Manual check on a physical iOS 26 phone, release build: content scrolled under the bar is refracted; no jank scrolling Home (Instruments frame times, with and without the Info.plist workaround); a sheet over the bar shows no halo; the bar during a push transition.
- Screenshot the bar per biome beside the current Flutter bar; tune the fill alpha over native glass until they match by eye. Write the chosen alphas into this plan.
- **Done when:** risks 1 to 4 have written answers here, and the decision (go native for which parts, or fallback B) is recorded.

#### Spike log (branch `spike/native-glass`, 2026-10-24)

Built: `NativeGlassView` + factory and a `hearthrise/glass` channel inside `AppDelegate.swift` (no project file edits); `GlassSurface` behind `--dart-define=NATIVE_GLASS_SPIKE=true` puts the native view under the `nav-bar` surface, outside the Flutter clip, and drops `BackdropFilter` everywhere else on iOS. `NATIVE_GLASS_FILL` scales the fill alpha over native glass (default 1). `tool/deploy_iphone.sh` passes `EXTRA_BUILD_ARGS` through. Flag off: glass tests unchanged and green.

Verified:
- Swift compiles under Xcode 27.1 with an iOS 15 target; the `#available(iOS 26, *)` guards hold.
- iOS 18.5 simulator, debug: the platform view composites under the bar with the ink key line, rim and glint drawn on top, and the header circles render flat without blur, as expected.
- The release build installs on an iPhone running iOS 26.6.

- iOS 27.0 simulator (iPhone 17 Pro; the 27.1 runtime supports only an "iPhone-Duo" device type here), debug, demo data:
  - Native glass renders under the bar with our ink on top.
  - Without `overrideUserInterfaceStyle = .dark` the glass adapts to light mode: the bar turns light grey and the ash labels drop below readable contrast. With `.dark` set, the bar matches the Flutter bar closely, just slightly greyer.
  - Home's content stops at the bar's top edge in both modes, so nothing sits under the bar at rest. Refraction can't be judged without scrolling content under it (simulator input access wasn't granted), and Home may need that clip lifted for refraction to show at all.

Still open (needs a person looking at the phone):
- Risk 1: is content scrolled under the bar refracted?
- Risk 2: does Home scroll smoothly? If not, retry with `FLTEnableMergedPlatformUIThread = false`.
- Risk 3: halo over sheets, and the bar during push transitions.
- Fill alpha: does 1 hide the glass? Rebuild with `NATIVE_GLASS_FILL=0.5` / `0.3` and compare.

### 1. Detect support once

Tests first:
- `test/core/glass_backend_test.dart`: `resolveGlassBackend` returns `flutter` for Android, for iOS when the channel says unsupported, and when the channel throws or is missing (tests, older builds); returns `native` only when the channel says supported.
- `ios/RunnerTests/RunnerTests.swift`: the channel handler answers `true` only under `#available(iOS 26, *)`.

Code:
- `lib/core/glass_backend.dart`: `enum GlassBackend { flutter, native }`, `resolveGlassBackend()` via a `MethodChannel('hearthrise/glass')` call `isLiquidGlassAvailable`, and an inherited `GlassBackendScope` read like `GlassTilt.of(context)`; default `flutter`.
- `main.dart` / `main_demo.dart`: resolve once before `runApp`, wrap the app in the scope.
- `ios/Runner/AppDelegate.swift`: register the channel in `didInitializeImplicitFlutterEngine`.

**Done when:** `glass_backend_test.dart` and the new RunnerTests case pass.

### 2. Native glass view (iOS side)

Tests first (`RunnerTests`):
- The factory builds a `UIVisualEffectView` whose effect is a `UIGlassEffect` with `.regular` style and `isInteractive == false` on iOS 26.
- Shape args map: `circle` and `stadium` give a capsule corner configuration; `rounded` with `r` gives fixed corners of `r`.
- Below iOS 26 the factory returns a plain clear view (never reached in practice; guards the build).

Code:
- `ios/Runner/NativeGlassView.swift`: `FlutterPlatformViewFactory` + `FlutterPlatformView`, view id `hearthrise/glass-view`, args `{shape, radius}`, `isUserInteractionEnabled = false` so taps fall through to Flutter.
- Register in `AppDelegate` via `engineBridge.pluginRegistry.registrar(forPlugin: "NativeGlass")`.

**Done when:** the RunnerTests cases pass (`xcodebuild test`).

### 3. `GlassSurface` picks the material

Tests first (`test/ui/glass_surface_test.dart`, extend):
- With `GlassBackendScope(native)` and the platform overridden to iOS: no `BackdropFilter` in the tree; one `UiKitView` with view type `hearthrise/glass-view` and the right shape args; `glass-fill` still present; `GlassPainter` still painted with the same key colour, glint and tilt.
- Native + high contrast: no `UiKitView`, flat shell fill (same as today's flat path).
- Native + Reduce Transparency flag: same flat path.
- Default scope (flutter): tree identical to today (existing tests and goldens unchanged).
- `blur: 0` in native mode still skips the material (hold button on a row stays plain).

Code:
- `GlassSurface.build`: when the backend is native and not flat, `Positioned.fill(child: UiKitView(...))` replaces the `BackdropFilter`; fill alphas from step 0. Everything else untouched. The widget stays stateless (backend read from the scope like `GlassTilt`).
- Reduce Transparency: an `EventChannel('hearthrise/glass/transparency')` read in the same scope; Swift side listens to `UIAccessibility.reduceTransparencyStatusDidChangeNotification`.

**Done when:** the new `glass_surface_test.dart` cases pass, all existing `test/ui/glass_*_test.dart` and goldens pass unchanged.

### 4. Roll out per part (only what step 0 approved)

Order, smallest risk first: tab bar, header circle buttons, pills, switch, then sheets and alerts only if step 0 showed no halo or transition bug. Parts step 0 rejects keep the Flutter material, which means on iOS 26 they run at `blur: 0` over the fill (no `BackdropFilter` allowed while native glass is on screen). Record that per part here.

Tests first, per part: a widget test in its existing test file asserting the native material under `GlassBackendScope(native)` and the Flutter material under the default.

**Done when:** each approved part's test passes and the full suite is green.

### 5. Docs

- `DESIGN.md`, Glass section: the two backends, the no-mixing rule, the native shape mapping, the a11y fallback.
- `CHECKLIST.md` (or the current checklist): one line per step.

## Manual checks (cannot be automated)

- Physical iOS 26 device, release build: refraction, scroll jank, sheet halo, route transitions, battery over a 10-minute session.
- Each biome: native bar beside the Flutter bar screenshot; ink line, rim and glint read the same.
- Settings > Display & Brightness > Liquid Glass set to Clear and to Tinted: ink stays readable on both.
- Reduce Transparency, Increase Contrast, Reduce Motion toggled live: flat path appears, no double border, no press scale under Reduce Motion.
- 200% text on the header and pills.
- iOS 18 device or simulator: no visual change from today.

## Fallback B (if step 0 fails)

Stay Flutter-only on every platform: add an Impeller `ImageFilter.shader` refraction pass to `GlassSurface` (gated on `ImageFilter.isShaderFilterSupported`, else today's blur), and group surfaces with `BackdropGroup` to share one backdrop copy. Same tests as step 3, with the shader in place of the platform view.
