# Native iOS Liquid Glass in Flutter: integration paths (as of 2026-10-24)

Note on dates: pub.dev shows relative dates ("N days ago"). The absolute dates below come from those offsets and the fetch date of 2026-10-24, so they are approximate.

## 1. Flutter framework status: is native glass supported or planned?

### Takeaway
No. Flutter has no official Liquid Glass support, native or drawn, as of October 2026. Cupertino was split out into a standalone `cupertino_ui` 1.0.0 package in August 2026. Flutter says "work is already underway on official implementations of Liquid Glass", but gives no date and does not say whether it will be native or Flutter-drawn. The only concrete upstream work found is two pending flutter/packages PRs that vendor the shader-based `liquid_glass_renderer`. Those are imitation glass, not native glass.

### Cited Findings
- Tracking issue flutter/flutter #170310, "Support for iOS 26 Liquid Glass Design in Cupertino Widgets", is still open. It is P3 with no assignee and no milestone. On 2026-08-18 its label changed from "framework" to "package" and `p: cupertino_ui` was added. — [GitHub #170310](https://github.com/flutter/flutter/issues/170310)
- 2025-06-10 team update in the issue body: "we are not developing the new Apple'26 UI design features in the Cupertino library right now". It added that the team would not accept contributions for this for now. — [GitHub #170310](https://github.com/flutter/flutter/issues/170310)
- 2025-07-29 team update: Material and Cupertino will be decoupled into standalone packages (tracking issue #101479). "All new work for iOS26 updates in Cupertino will happen in the new packages once established in flutter/packages." — [GitHub #170310](https://github.com/flutter/flutter/issues/170310)
- Flutter blog, 2026-09-09, by Craig Labenz: `material_ui` and `cupertino_ui` 1.0.0 are now on pub.dev. They have been open to contributions since 2026-08-13, and the in-framework libraries are frozen. Removing them from the framework is set for an unspecified future date. — [Flutter blog: decoupling](https://flutter.dev/blog/decoupling-material-cupertino)
- The same post says "work is already underway on official implementations of Liquid Glass and Material 3 Expressive". It also says the team is "working with our community of package authors". It gives no timeline and does not say native or drawn. — [Flutter blog: decoupling](https://flutter.dev/blog/decoupling-material-cupertino)
- On 2026-10-17 a commenter in #170310 listed pending PRs. flutter/packages #13162 vendors the `liquid_glass_renderer` engine and shaders. flutter/packages #13163 adds liquid_glass widgets, tests, examples and docs. Merge status was not confirmed. — [GitHub #170310](https://github.com/flutter/flutter/issues/170310)
- Requests for updates in Sept and Oct 2026 (2026-09-04/05 and 2026-10-10) have no visible team reply. — [GitHub #170310](https://github.com/flutter/flutter/issues/170310)
- A 2025-06-10 contributor comment proposed an `ImageFilter.liquidGlass` API, analogous to `ImageFilter.blur`. No team response or implementation was found. — [GitHub #170310](https://github.com/flutter/flutter/issues/170310)
- #189055, "Liquid Glass UI implementation on existing flutter App", was closed as a duplicate of #170310 on 2026-07-07. — [GitHub #170310](https://github.com/flutter/flutter/issues/170310)

### Inferences
- The likely upstream direction is shader-based. The vendored `liquid_glass_renderer` PRs point that way, so Flutter-drawn glass is more likely than wrapping `UIGlassEffect` in platform views. This would resemble what an app already painting its own glass with BackdropFilter does today.
- No Flutter design doc for native Liquid Glass was found.

### Gaps
- No exact Flutter SDK version (3.35, 3.38, 3.41 and so on) was found that ships anything Liquid Glass-specific. I did not fetch those release notes.
- Unknown whether flutter/packages #13162 or #13163 have merged, or who authored them.

## 2. Platform views: does a `UiKitView` hosting `UIVisualEffectView` / `UIGlassEffect` refract the Flutter content underneath?

### Takeaway
Probably yes for Flutter content painted below the platform view, but this is claimed rather than proven. On iOS, platform views always use hybrid composition: the real `UIView` sits in the UIKit hierarchy above the FlutterView's surface. Package authors say native glass "samples and bends what's behind it", including Flutter content. Flutter widgets drawn on top of the platform view go into extra overlay surfaces and are not refracted. Costs and pitfalls are well documented:
- whole-screen compositing cost
- z-order bugs with sheets and modals
- jank in scrolling lists
- an open iOS jank bug tied to the merged platform/UI thread

### Cited Findings
- "iOS only uses Hybrid composition, which means that the native `UIView` is appended to the view hierarchy." — [Flutter docs: iOS platform views](https://docs.flutter.dev/platform-integration/ios/platform-views)
- The docs list these limits over iOS platform views:
  - "The ShaderMask and ColorFiltered widgets are not supported."
  - "The BackdropFilter widget is supported, but there are some limitations on how it can be used."
  - The only performance advice is general: "Platform views in Flutter come with performance trade-offs".
  — [Flutter docs: iOS platform views](https://docs.flutter.dev/platform-integration/ios/platform-views)
- Flutter's design doc "Implementing iOS PlatformView BackdropFilter" says a blur over a platform view has to be applied with Quartz, while Flutter widgets are blurred in Flow. Because the two are separate, the seam between them shows visual artifacts. It also says z-order in Flutter's layer tree may not match z-order in Quartz. — [Flutter design doc (PDF mirror)](https://files.flutter-io.cn/flutter-design-docs/Flutter_iOS_PlatformView_BackdropFilter.pdf)
- `real_liquid_glass` says on iOS 26+ its widgets "host Apple's native glass material (UIGlassEffect / NSGlassEffectView) in a platform view beneath your Flutter content". It says the glass "samples and bends what's behind it". Its wording on placement is inconsistent: it also tells you to put the bar above content so the glass has something to refract. — [pub.dev real_liquid_glass](https://pub.dev/packages/real_liquid_glass)
- `native_liquid_glass` says the glass samples content behind it every frame and refracts it. It warns:
  - Mid-transition, Flutter's surface may not be readable by the glass.
  - While a platform view is visible, compositing for the whole screen is affected.
  - Flutter content painted over a platform view forces an extra overlay surface.
  - Glass sampling adds GPU work.
  - Use one or two platform views per screen, not one per list row.
  — [pub.dev native_liquid_glass](https://pub.dev/packages/native_liquid_glass)
- `cupertino_native_better` warns of three problems:
  - Native views are composited under Flutter, so glass shadows or halos can bleed through sheets and popups.
  - Without its route observer, `CNTabBar` can render above modal content, such as a TextField inside a sheet.
  - `LiquidGlassContainer` in long `ListView`/`GridView` lists "will cause significant performance drops (jank)".
  — [pub.dev cupertino_native_better](https://pub.dev/packages/cupertino_native_better); [GitHub cupertino_native_better](https://github.com/gunumdogdu/cupertino_native_better)
- Apple forum guidance: a `UIVisualEffectView` can only sample content behind it, and masking a superview breaks sampling. Mask the effect view itself through `layer.cornerRadius` or `maskView`. — [Apple Developer Forums 50854](https://developer.apple.com/forums/thread/50854)
- flutter/flutter #190815 (filed about August 2026, still reproducing on master): jank on iOS when any platform view is on screen, caused by the merged platform/UI thread. The performance overlay shows healthy build and raster times during the jank. Reported workaround: set `FLTEnableMergedPlatformUIThread` to `false` in Info.plist. — [GitHub #190815](https://github.com/flutter/flutter/issues/190815)
- PR flutter/flutter #192794 proposes making `FlutterMetalLayer` subclass `CAMetalLayer`. The goal is to remove an extra frame of presentation delay while keeping platform-view compatibility. Merge status unknown. — [GitHub PR #192794](https://github.com/flutter/flutter/pull/192794)
- A June 2025 DEV article wrapped `UIVisualEffectView` (`.systemUltraThinMaterial`) in a `UiKitView` and reports that it works. It warns of possible jank on older devices and that ShaderMask, ColorFiltered and complex animations can't go over it. It did not test whether the blur samples Flutter widgets. — [DEV: Can we build Liquid Glass in Flutter](https://dev.to/alaminkarno/can-we-build-liquid-glass-in-flutter-a-lunch-break-dive-into-platform-views-10m5)

### Inferences
- In hybrid composition, Flutter pixels below the platform view live in the FlutterView's Metal layer underneath the native view. The system backdrop sampler can therefore see them, which matches the package claims. Pixels above the platform view go into overlay layers on top of it and are never part of the glass's backdrop. As a result, the glass child (label, icon) must be native, or Flutter-drawn on top and not refracted.
- In-app evidence from the packages suggests the glass reads a stale or empty backdrop during route transitions: `native_liquid_glass` hides glass on route pushes and popups.
- Gestures are not covered in the sources. Standard `UiKitView` gesture recognizers apply.

### Gaps
- I found no independent test, screenshot comparison or issue that confirms or refutes `UIGlassEffect` refracting Flutter Metal content in a platform view. Verify on device before committing.
- No numbers were found for the cost per platform view (ms per frame, memory).

## 3. pub.dev packages: native vs shader imitation

### Takeaway
Two families exist:
- **Native platform-view wrappers**: `cupertino_native` and forks, `real_liquid_glass`, `native_liquid_glass`, `adaptive_platform_ui`, `native_liquid_glass_flutter`, `flutter_liquid_glass_kit`, `cupertino_native_ui`. These are iOS 26+ only for real glass, with Cupertino, Material or blur fallbacks.
- **Shader imitations**: `liquid_glass_renderer`, `liquid_glass_widgets`, `liquid_glass_easy`, `cupertino_liquid_glass`. These work on every platform and are closest to the team's existing BackdropFilter + CustomPainter approach.

None of the packages is official. Several are young, fast-moving, or AI-generated proofs of concept.

I found no packages named `native_glass` or `flutter_liquid_glass` on pub.dev. `flutter_liquid_glass` is the name of the whynotmake-it GitHub monorepo that holds `liquid_glass_renderer`.

### Cited Findings

**Native (platform view) packages**

**cupertino_native** (Serverpod)
- 0.1.1, published about 13 months ago (around Sept 2025). Verified publisher serverpod.dev, BSD-3-Clause.
- iOS 14+ / macOS 11+, built with Xcode 26.
- Real UIKit/AppKit controls via platform views and method channels: Slider, Switch, Segmented Control, Button, Icon, Popup Menu, Tab Bar.
- Self-described "proof of concept", largely AI-generated, code needs cleanup. Scroll-view integration is an open to-do.
- 345 likes.
— [pub.dev cupertino_native](https://pub.dev/packages/cupertino_native); [GitHub serverpod/cupertino_native](https://github.com/serverpod/cupertino_native)

**cupertino_native_better**
- 1.7.0, published about 2026-10-19. Verified publisher gunumdogdu.com, MIT.
- iOS 15+, with Liquid Glass on iOS 26+. Dart >= 3.9.
- Forked from `cupertino_native_plus`, which came from `cupertino_native`.
- The author says `cupertino_native_plus` OS detection is broken in release builds and fixed here.
- Fallbacks: Cupertino widgets on iOS 13–25, Material on Android. `CNTabBarNative` does nothing below iOS 26.
- `CNTabBarNative.enable()` presents a real SwiftUI TabView over a UITabBarController, taking over from the Flutter app.
- Known issues: z-order, halo bleed through sheets, list jank (see section 2).
— [pub.dev cupertino_native_better](https://pub.dev/packages/cupertino_native_better); [GitHub](https://github.com/gunumdogdu/cupertino_native_better)

**cupertino_native_plus**
- A fork with a scroll-aware split-mode `CNTabBar` and a native UITabBarController option. Version and date not checked.
— [GitHub litangtech/cupertino_native_plus](https://github.com/litangtech/cupertino_native_plus); [pub.dev docs](https://pub.dev/documentation/cupertino_native_plus/latest/)

**real_liquid_glass**
- 0.3.0, published about 3 months ago (around July 2026). Verified publisher kiddobuild.dev, MIT.
- `UIGlassEffect` / `NSGlassEffectView` in a platform view. `LiquidGlassGroup` shares one `UIGlassContainerEffect`, so N shapes cost one platform view. `LiquidGlassBottomBar` is a native `UITabBar`.
- Fallbacks: native system blur below iOS 26. Flutter-drawn frost with `fallbackIntensity` on Android, web and desktop.
- Needs the Xcode 26 SDK.
— [pub.dev real_liquid_glass](https://pub.dev/packages/real_liquid_glass); [GitHub](https://github.com/kiddo4/real_liquid_glass)

**native_liquid_glass**
- 0.3.1. The page said "35 days ago" (around 2026-09-19); search snippets said "10 days ago", which conflicts. Unverified uploader, MIT.
- iOS only, with glass on iOS 26+. Each widget is a `UiKitView` with a method channel per view.
- On Android, web and desktop it renders an empty `SizedBox`. You check `NativeLiquidGlassUtils.supportsLiquidGlass` and supply your own fallback.
- Auto-hides glass during route pushes. Tab switches need a manual suppress call.
- `LiquidGlassMenu` supports one trigger per screen (issue #11).
— [pub.dev native_liquid_glass](https://pub.dev/packages/native_liquid_glass); [GitHub](https://github.com/tienanh306201z/native_liquid_glass)

**adaptive_platform_ui**
- 1.0.2, published about 2026-10-09. Verified publisher medialyra.com, MIT, iOS 15+ deployment target.
- On iOS 26+ it renders native UIToolbar, UITabBar, buttons, segmented control, switch, slider and UIMenu via `UiKitView`. Below that it uses Cupertino, and Material on Android.
- Ships `PlatformInfo.isIOS26OrHigher()`.
- Its experimental `IOS26NativeSearchTabBar` replaces the root view controller with a UITabBarController and is marked "prototyping/demos only". Listed problems:
  - unreliable `Navigator.pop`
  - hot reload not working
  - possible memory leaks
  - frame stutter during transitions
— [pub.dev adaptive_platform_ui](https://pub.dev/packages/adaptive_platform_ui)

**Others (from search snippets, not fetched)**
- `native_liquid_glass_flutter` uses SwiftUI `glassEffect` on iOS 26+ and UIKit `UIVisualEffectView` material on iOS 15–25. — [pub.dev native_liquid_glass_flutter](https://pub.dev/packages/native_liquid_glass_flutter)
- `flutter_liquid_glass_kit` uses SwiftUI glass. It can group a page's surfaces into one `UiKitView` plus one `UIHostingController`. — [pub.dev flutter_liquid_glass_kit](https://pub.dev/packages/flutter_liquid_glass_kit)
- `cupertino_native_ui` (jezsung) offers native SwiftUI and UIKit widgets for real iOS 26 glass. — [GitHub cupertino_native_ui](https://github.com/jezsung/cupertino_native_ui)
- `native_glass_navbar`. — [pub.dev native_glass_navbar](https://pub.dev/packages/native_glass_navbar)

**Shader / imitation packages**

**liquid_glass_renderer** (whynotmake.it)
- 1.0.0-dev.1, published about 2026-10-21. Verified publisher, Apache-2.0.
- Full glass needs Impeller plus Flutter GPU, which is still in preview. Enable it with `--enable-flutter-gpu` or platform config keys. It falls back to "FakeGlass" with no refraction on Skia and web.
- Each `LiquidGlassLayer` is a `BackdropFilter`. On Impeller, each one copies the render pass behind it.
- Limits:
  - 16 shapes per layer
  - one corner radius per shape
  - the child is painted on top and not refracted
  - experimental and not production-proven
- 1.0.0-dev is a full rewrite that breaks the 0.2.x API.
— [pub.dev liquid_glass_renderer](https://pub.dev/packages/liquid_glass_renderer); [GitHub whynotmake-it/flutter_liquid_glass](https://github.com/whynotmake-it/flutter_liquid_glass)

**liquid_glass_widgets**
- 1.14.2, published about 2026-10-23. Verified publisher pixel-innovations.com, MIT. Supports all 6 platforms. About 109k downloads and 353 likes.
- Built on a vendored copy of `liquid_glass_renderer` with a custom fragment shader. No third-party dependencies.
- Rendering tiers:
  - Impeller "premium" runs two passes: blur, then a shader.
  - Skia and web use a single-pass `lightweight_glass.frag`.
  - "Minimal" is a plain BackdropFilter blur with saturation and a rim.
- Minimum Flutter 3.41.0.
- Limits:
  - Premium may not render correctly inside `ListView` or `CustomScrollView` on Impeller.
  - Reduce Transparency is only approximated, which is an engine limitation.
- `GlassBackdropGroup` shares one backdrop read. The publisher reports GPU time per frame dropping from 23.6 ms to 9.3 ms on iPhone Air in one sheet-over-bars case.
— [pub.dev liquid_glass_widgets](https://pub.dev/packages/liquid_glass_widgets); [GitHub](https://github.com/sdegenaar/liquid_glass_widgets)

**liquid_glass_easy**
- Lenses refract the live backdrop under Impeller. On Skia they need an ancestor view with a captured background, and otherwise degrade to frost.
— [pub.dev liquid_glass_easy](https://pub.dev/packages/liquid_glass_easy)

**cupertino_liquid_glass**
- Approximates the look with BackdropFilter and custom painting. It says exact parity with native `glassEffect` needs a native bridge.
— [pub.dev cupertino_liquid_glass](https://pub.dev/packages/cupertino_liquid_glass) (via search snippet)

### Inferences
- `cupertino_native_better` and `adaptive_platform_ui` are the most maintained native-control kits, with releases in October 2026.
- `real_liquid_glass` is the most direct "glass surface" wrapper: a `UIGlassEffect` container, not just native controls. Its grouping into one platform view addresses the per-view cost.
- For an app that already paints its own glass, the shader packages are the low-risk upgrade, and the vendored-renderer PRs suggest upstream may converge on that engine.

### Gaps
- I did not check open issue counts per repo, or the exact iOS minimum and Impeller requirement for every snippet-only package.
- I did not fetch the `cupertino_ui` 1.0.0 package page to confirm it has no glass.

## 4. Impeller shader approach: `ImageFilter.shader`, `BackdropFilter`, `BackdropGroup`

### Takeaway
Flutter 3.29 added both `BackdropGroup` / `BackdropFilter.grouped` and an `ImageFilter.shader` constructor that also works as a backdrop filter. Shader filters are Impeller-only and throw on other backends. Today's best imitation stacks a blur pass with a refraction shader. Its cost is dominated by backdrop copies, which grouping reduces. Nobody claims pixel parity with native glass.

### Cited Findings
- Flutter 3.29 added `BackdropGroup` and the `BackdropFilter.grouped` constructor, which can make multiple blurs faster than the Skia backend allowed. It also added an `ImageFilter` constructor that applies a custom fragment shader and works with backdrop filters. — [What's new in Flutter 3.29](https://flutter.dev/blog/whats-new-in-flutter-3-29)
- The custom-shader `ImageFilter` is supported only on Impeller and throws on other backends. Docs recommend a `ClipRect` to limit the filtered area. — [Flutter docs: fragment shaders](https://docs.flutter.dev/ui/design/graphics/fragment-shaders.md)
- Flutter 3.19 improved scenes with multiple backdrop filters by 20–70% in benchmarks. — [What's new in Flutter 3.19](https://flutter.dev/blog/whats-new-in-flutter-3-19)
- `liquid_glass_renderer` 1.0.0-dev: each independent glass layer costs one backdrop copy. Debug builds warn when a frame makes more than one copy. `useBackdropGroup`, a shared `backdropKey` or `LiquidGlassCapture` reduce copies. — [pub.dev liquid_glass_renderer](https://pub.dev/packages/liquid_glass_renderer)
- `liquid_glass_widgets` uses blur plus a shader on Impeller. It reports grouping cutting GPU time per frame from 23.6 ms to 9.3 ms on iPhone Air in one case. Premium is aimed at static surfaces, minimal at list cards. — [pub.dev liquid_glass_widgets](https://pub.dev/packages/liquid_glass_widgets)
- Runtime check: `ui.ImageFilter.isShaderFilterSupported`. Source is a third-party package page, via search snippet. — [search result: Flutter shader packages](https://pub.dev/packages/flutter_shader_kit)

### Inferences
- An app already using BackdropFilter plus CustomPainter can add a refraction `ImageFilter.shader` as a backdrop filter and wrap sibling glass in `BackdropGroup`. That is the same architecture the leading packages use, with no new dependency.
- How close it looks is subjective. The imitations model bevel refraction, frost, tint, glint and chromatic aberration. They do not get Apple's adaptive light/dark tinting, system morphing or accessibility settings (Reduce Transparency is only approximated).

### Gaps
- No side-by-side visual or benchmark comparison of shader glass vs native `UIGlassEffect` was found. A Medium post, "iOS 27 Liquid Glass in Flutter: Three Ways to Fake It", exists but was not fetched. — [Medium](https://medium.com/@anilcan/ios-27-liquid-glass-in-flutter-three-ways-to-fake-it-and-the-cheapest-one-b020599c9958)

## 5. Real-world reports of shipping native glass via platform views

### Takeaway
The evidence is mostly package READMEs and changelogs, not independent shipping post-mortems. The recurring themes are:
- jank in scrolling lists
- platform-view z-order and halo bleed over sheets and modals
- glass hidden during route transitions
- native tab bars taking over navigation (two sources of truth)
- an engine-level iOS jank bug whenever any platform view is visible

### Cited Findings
- iOS jank with any platform view on screen (#190815), with the `FLTEnableMergedPlatformUIThread=false` workaround. — [GitHub #190815](https://github.com/flutter/flutter/issues/190815)
- `cupertino_native_better`:
  - Says not to put `LiquidGlassContainer` in long lists, because of jank.
  - Says not to use `CNTabBarNative` as a drop-in Flutter bottom nav, because selected-tab state then has two sources of truth.
  - Notes about hiding the tab bar under full-screen sheets relate to z-order issue #31.
  — [GitHub cupertino_native_better](https://github.com/gunumdogdu/cupertino_native_better)
- `cupertino_native` still lists "Investigate how to best combine scroll views with the native components" as a to-do. — [GitHub serverpod/cupertino_native](https://github.com/serverpod/cupertino_native)
- `adaptive_platform_ui`'s native search tab bar lists stutter, leaks and broken hot reload. — [pub.dev adaptive_platform_ui](https://pub.dev/packages/adaptive_platform_ui)
- `native_liquid_glass` advises measuring on a release build and keeping to one or two platform views per screen. — [pub.dev native_liquid_glass](https://pub.dev/packages/native_liquid_glass)

### Inferences
- Native glass is workable for a few static chrome pieces, such as a tab bar, toolbar or floating button. It is not workable for glass cards inside scrolling content, which is exactly where a CustomPainter glass app tends to use it.

### Gaps
- I found no Reddit, X or blog post-mortems from teams shipping native glass in production Flutter apps.

## 6. Detecting iOS version at runtime

### Takeaway
There are three options: parse `Platform.operatingSystemVersion` synchronously, read `device_info_plus` `IosDeviceInfo.systemVersion` asynchronously, or use a one-line method channel to `UIDevice.current.systemVersion`. Packages vary in how reliable their version checks are in release builds.

### Cited Findings
- `cupertino_native_better` parses `Platform.operatingSystemVersion` directly and says this works in release builds. It also says `cupertino_native_plus`'s detection was broken in release builds. — [pub.dev cupertino_native_better](https://pub.dev/packages/cupertino_native_better)
- `adaptive_platform_ui` exposes `PlatformInfo.isIOS26OrHigher()` and `iOSVersion`. — [pub.dev adaptive_platform_ui](https://pub.dev/packages/adaptive_platform_ui)
- `device_info_plus` 13.3.0 requires iOS 13+ and Xcode >= 26.1.1. iOS info comes from `await deviceInfo.iosInfo`. — [pub.dev device_info_plus docs](https://pub.dev/documentation/device_info_plus/latest/)
- Example output format from another package: an iOS 26 device reports `systemVersion: "26.5"`. — [pub.dev device_context_plus](https://pub.dev/packages/device_context_plus/versions/1.0.4)
- `native_liquid_glass` exposes `NativeLiquidGlassUtils.supportsLiquidGlass`. — [pub.dev native_liquid_glass](https://pub.dev/packages/native_liquid_glass)

### Inferences
- `device_info_plus` exposes `IosDeviceInfo.systemVersion` (from my own knowledge of the API; the fetched docs did not show it). Parse its major number and compare it to 26.
- Shader-filter support should be gated separately with `ui.ImageFilter.isShaderFilterSupported`.

### Gaps
- I did not see the exact format of `Platform.operatingSystemVersion` on iOS 26 (for example "Version 26.0 (Build ...)") in any fetched source. Confirm on device.
