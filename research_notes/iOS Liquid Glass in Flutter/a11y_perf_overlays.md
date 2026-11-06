# Native iOS 26 Liquid Glass: accessibility, adaptivity, custom overlays, performance, interactivity (for a Flutter app drawing its own ink/rim/glint on top)

Research date: 2026-10-24. Primary sources: WWDC25 sessions 219 (Meet Liquid Glass), 323 (Build a SwiftUI app with the new design), 284 (Build a UIKit app with the new design), Apple docs "Applying Liquid Glass to custom views", "Adopting Liquid Glass", HIG Materials and Color. Flutter engine source and pub.dev glass plugins for the Flutter side. Claims marked **(unverified)** were not confirmed against a primary source in this session.

## 1. What native glass does automatically under Reduce Transparency, Increase Contrast, Reduce Motion, and the iOS 26.1 Clear/Tinted setting; which APIs report these; can Flutter read them

### Takeaway
All three accessibility settings and the 26.1 Clear/Tinted preference are applied by the system to native glass automatically, with no app code. Flutter already exposes Increase Contrast (`highContrast`, from `UIAccessibilityDarkerSystemColorsEnabled`) and Reduce Motion, but not Reduce Transparency, and no public API for the Clear/Tinted choice was found; a method channel is needed for Reduce Transparency, and Clear/Tinted is likely undetectable.

### Cited Findings
- Reduce Transparency "makes Liquid Glass frostier and obscures more of the content behind it." — [WWDC25 219 Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/)
- Increase Contrast "makes elements predominantly black or white and highlights them with a contrasting border." — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- Reduce Motion "decreases the intensity of some effects and disables any elastic properties for the material." — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- These are automatic: "whenever these settings are turned on at a system-level, Liquid Glass elements will get them across the board." — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- HIG: variant appearance "can differ in response to certain system settings, like if people choose a preferred look for Liquid Glass in their device's settings, or turn on accessibility settings that reduce transparency or increase contrast." — [HIG Materials](https://developer.apple.com/design/human-interface-guidelines/materials)
- Apple's adoption doc: these settings "can remove or modify certain effects. If you use standard components ... this experience adapts automatically. Ensure you test your app's custom elements, colors, and animations with different configurations of these settings." Custom colors should have light/dark variants "and an increased contrast option for each variant." — [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass)
- Reviewer observations: Reduce Transparency removes almost all translucency (darker backgrounds behind translucent areas); Increase Contrast keeps translucency but adds a slight outline and grey smokiness; both together give sharp edges and no translucency. — [TechRadar](https://www.techradar.com/phones/ios/not-vibing-with-liquid-glass-in-ios-26-heres-how-to-make-it-easier-on-the-eyes); [Neowin](https://www.neowin.net/guides/how-to-reduce-the-annoying-liquid-glass-effects-on-ios-26/)
- iOS 26.1 added Settings > Display & Brightness > Liquid Glass with Clear / Tinted. Apple's in-settings text: "Clear is more transparent, revealing the content beneath. Tinted increases opacity and adds more contrast." First in 26.1 beta 4; 26.1 shipped Nov 3, 2025. — [Macworld](https://www.macworld.com/article/2947565/ios-26-1-beta-4-does-the-unthinkable-you-can-control-how-glassy-liquid-glass-should-be.html); [9to5Mac 26.1 release](https://9to5mac.com/2025/11/03/apple-releases-ios-26-1-for-iphone-with-these-changes/); [iClarified](https://www.iclarified.com/98836/ios-261-beta-4-adds-new-tinted-setting-to-reduce-liquid-glass-transparency)
- Tinted applies to third-party apps that adopted Liquid Glass. — [Tom's Guide](https://www.tomsguide.com/phones/iphones/ios-26-1-lets-you-adjust-liquid-glass-transparency-on-your-iphone-heres-how-to-do-it)
- The Clear/Tinted control is reported disabled while Reduce Transparency or Increase Contrast is on (accessibility settings take precedence). Single/secondary sources only. — [Yahoo Tech](https://tech.yahoo.com/ai/apple-intelligence/articles/change-iphone-settings-adjust-liquid-100000676.html); [webnots](https://www.webnots.com/how-to-reduce-liquid-glass-effect-on-iphone-and-mac/)
- Flutter iOS engine `accessibilityFlags`: `UIAccessibilityIsInvertColorsEnabled` -> kInvertColors, `UIAccessibilityIsReduceMotionEnabled` -> kReduceMotion, `UIAccessibilityIsBoldTextEnabled` -> kBoldText, `UIAccessibilityDarkerSystemColorsEnabled` -> kHighContrast, OnOffSwitchLabels -> kOnOffSwitchLabels. Observes the matching `...StatusDidChangeNotification`s (incl. `UIAccessibilityDarkerSystemColorsStatusDidChangeNotification`, `UIAccessibilityReduceMotionStatusDidChangeNotification`). `UIAccessibilityIsReduceTransparencyEnabled` was not found in the flag computation. — [flutter/engine FlutterViewController.mm (archived repo)](https://raw.githubusercontent.com/flutter/engine/main/shell/platform/darwin/ios/framework/Source/FlutterViewController.mm). Current flutter/flutter master moved this into a `FlutterAccessibilityFeatures` class (not inspected). — [flutter/flutter FlutterViewController.mm](https://raw.githubusercontent.com/flutter/flutter/master/engine/src/flutter/shell/platform/darwin/ios/framework/Source/FlutterViewController.mm)
- Flutter also sends a separate `contrastMode` "high"/"normal" from `traitCollection.accessibilityContrast == UIAccessibilityContrastHigh` over the settings channel. — [flutter/flutter FlutterViewController.mm](https://raw.githubusercontent.com/flutter/flutter/master/engine/src/flutter/shell/platform/darwin/ios/framework/Source/FlutterViewController.mm)
- `dart:ui` `AccessibilityFeatures` fields: accessibleNavigation, autoPlayAnimatedImages, autoPlayVideos, boldText, deterministicCursor, disableAnimations, highContrast, invertColors, onOffSwitchLabels, reduceMotion, supportsAnnounce. No reduce-transparency field. — [AccessibilityFeatures](https://api.flutter.dev/flutter/dart-ui/AccessibilityFeatures-class.html)
- `MediaQueryData.highContrast` is tied to Settings > Accessibility > Increase Contrast, iOS 13+ only. — [MediaQueryData.highContrast](https://api.flutter.dev/flutter/widgets/MediaQueryData/highContrast.html)
- An older forum report (Flutter 3.27.4) said `disableAnimations` stayed false on iOS with Reduce Motion on. — [itsallwidgets forum](https://forum.itsallwidgets.com/t/should-flutter-honor-ioss-reduce-motion-option-in-accessibility-settings/4657)
- No public API for reading the Clear/Tinted preference turned up in searches. — [iClarified](https://www.iclarified.com/98836/ios-261-beta-4-adds-new-tinted-setting-to-reduce-liquid-glass-transparency) (says custom UI should be tested in both modes; names no API)

### Inferences
- Native glass under the decoration will change look by itself (frosted, black/white with a border, less elastic). The Flutter ink line, rim and glint will not change unless the app reads the flags. Under Increase Contrast the system adds its own contrasting border, which could double up with the hand-drawn ink key line.
- Read Reduce Transparency with a small method/event channel: `UIAccessibility.isReduceTransparencyEnabled` plus `UIAccessibility.reduceTransparencyStatusDidChangeNotification` **(standard UIKit API, not re-verified in this session)**. Use `MediaQuery.highContrastOf` and `MediaQuery.disableAnimationsOf` / `AccessibilityFeatures.reduceMotion` for the other two.
- Under Reduce Transparency, consider dropping the glint and lit-rim highlights, since they imply translucency the system has removed.
- Clear/Tinted: design the overlay to read correctly over both, because the app likely cannot know which is active.

### Gaps
- No primary source confirms a public API for the Clear/Tinted preference. Check iOS 26.1/26.2 SDK diffs (UIKit/SwiftUI headers) before concluding none exists.
- Not verified whether current Flutter stable maps `UIAccessibilityIsReduceTransparencyEnabled` anywhere (the newer `FlutterAccessibilityFeatures.mm` returned 404 at the guessed path).
- Not verified whether `MediaQuery.reduceMotion` vs `disableAnimations` is the field set by iOS Reduce Motion in current Flutter.
- Exact visual change of glass under Reduce Motion (which "effects" decrease) is not documented beyond the WWDC sentence.

## 2. Does native glass adapt tint/brightness to content underneath, how does that interact with custom tints, and does it change legibility of content on top

### Takeaway
Yes. Glass continuously adapts to what is behind it; small elements flip between light and dark, large ones get more opaque but do not flip. Custom tints are mapped to the brightness of content underneath ("vibrant" tint), so the actual tint shown varies. Native labels inside glass are made vibrant to stay legible, but Flutter-drawn content gets none of this, because the native view does not report what it sampled.

### Cited Findings
- "each layer continuously adapts based on what's behind it"; glass "can also independently switch between light and dark." — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- Small elements (nav bars, tab bars) flip light/dark with the background; "Bigger elements, like menus or sidebars also adapt based on context, but they don't flip from light to dark." — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- Shadow opacity increases over text and decreases over solid light backgrounds. — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- "The amount of tint and the dynamic range shift to always ensure buttons remain legible." — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- Tinting: "Selecting a color generates a range of tones that are mapped to content brightness underneath the tinted element." Tinting "is natively compatible with all the behaviors of glass." Use it only for primary actions; "If you want to imbue color into your app, do it in the content layer instead." — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- UIKit: "Tinted glass color, automatically adapts to a vibrant version." Labels in `contentView` become vibrant based on `textColor`. "Depending on the colors behind, the glass and its content will switch to light or dark mode automatically, when using dynamic colors." "A larger size is more opaque. A smaller size is clearer." — [WWDC25 284](https://developer.apple.com/videos/play/wwdc2025/284/)
- SwiftUI: "the tint also uses a vibrant color that adapts to the content behind it"; text in a glass effect gets "a vibrant text color that adapts to maintain legibility." — [WWDC25 323](https://developer.apple.com/videos/play/wwdc2025/323/)
- `UIGlassContainerEffect` "enforces a uniform adaptation", so grouped glass gets a consistent appearance. — [WWDC25 284](https://developer.apple.com/videos/play/wwdc2025/284/)
- HIG: "By default, Liquid Glass has no inherent color, and instead takes on colors from the content directly behind it." Symbols/text on small elements go darker over light content and lighter over dark. — [HIG Color](https://developer.apple.com/design/human-interface-guidelines/color)
- Clear variant "does not have adaptive behaviors"; it needs a dimming layer (HIG: "a dark dimming layer of 35% opacity" over bright content). Use Clear only over media-rich content with bold, bright content on top. — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/); [HIG Materials](https://developer.apple.com/design/human-interface-guidelines/materials)
- Flutter plugin: native glass view "doesn't report what it samples," so icon and label colors must come from your theme. — [ios_liquid_glass](https://pub.dev/packages/ios_liquid_glass)

### Inferences
- Flutter-drawn ink lines and labels on top will not flip with the glass. If the glass flips to dark over a dark scene, a dark ink line can vanish. Either keep the glass in a large-element regime (more opaque, no flip), control what is behind it (known Flutter background), or draw ink with a light halo that reads both ways.
- A custom `tintColor` will not render as the exact brand color; it is remapped by background brightness. Do not rely on matching a Flutter-drawn rim color to the native tint.
- Use the Regular variant. Clear has no adaptive legibility and requires a dimming layer.

### Gaps
- No documented threshold for the size at which glass stops flipping light/dark.
- No API found for reading the glass's current light/dark state back from the native view.

## 3. Can custom opaque/stroked decoration be drawn on top of glass without breaking the effect

### Takeaway
Apple's guidance allows content on top of glass but wants it light: fills, transparency and vibrancy that feel like "a thin overlay", never a second glass layer, and never an opaque solid fill that hides the material. Nothing says strokes or highlights drawn above break the native effect technically; the risk is visual (fighting the system's own rim, shadow, and Increase-Contrast border). In Flutter, the decoration is a separate Flutter layer composited above the platform view, so it cannot break the native rendering, but Flutter clips, fades and BackdropFilters can.

### Cited Findings
- "When placing elements on top of Liquid Glass, avoid applying the material to both layers. Instead, use fills, transparency, and vibrancy for the top elements to make them feel like a thin overlay that is part of the material." — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- "Always avoid glass on glass." — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/); UIKit session: hide glass that would overlap other glass "keeps the illusion of a single floating layer of glass intact." — [WWDC25 284](https://developer.apple.com/videos/play/wwdc2025/284/)
- A solid-fill button "is completely opaque and breaks the visual character of Liquid Glass." — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- "Any custom backgrounds and appearances you use in these elements might overlay or interfere with Liquid Glass or other effects that the system provides"; "Prefer to remove custom effects and let the system determine the background appearance." — [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass)
- "Don't use Liquid Glass in the content layer"; it is for controls/navigation floating above content. — [HIG Materials](https://developer.apple.com/design/human-interface-guidelines/materials)
- SwiftUI: "Apply the `glassEffect(_:in:)` modifier after other modifiers that affect the appearance of the view." Glass shape comes from the `in:` shape (default capsule). — [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)
- Forum: applying `glassEffect()` to a stroked circle glasses the filled shape, not the stroke (no answer in thread). — [Apple Developer Forums 792239](https://developer.apple.com/forums/thread/792239)
- UIKit: remove glass by setting `effect = nil`, not alpha; "Always prefer setting the effect property over the alpha." — [WWDC25 284](https://developer.apple.com/videos/play/wwdc2025/284/)
- Flutter plugins: content "stays an ordinary Flutter subtree composited above" the material-only platform view. — [fresnel_ios](https://pub.dev/packages/fresnel_ios). Flutter can't fade or mask the glass; a Flutter clip "becomes a mask on the glass view's parent"; put BackdropFilters beneath glass controls. — [ios_liquid_glass](https://pub.dev/packages/ios_liquid_glass). "A Flutter `BackdropFilter` in the same scene suppresses native glass platform views entirely." — [fresnel_ios](https://pub.dev/packages/fresnel_ios)
- Conflict on sampling: one search snippet attributed to ios_liquid_glass said native UIGlassEffect "samples layers beneath the Flutter view and does not refract Flutter pixels"; the package page itself says glass blurs/bends Flutter content underneath and updates as it scrolls. — [ios_liquid_glass](https://pub.dev/packages/ios_liquid_glass) (versions may differ)

### Inferences
- Ink key line, lit rim and glint on top are within Apple's "thin overlay" guidance if they are thin and partly transparent. A thick opaque ink border reads as the "solid fill breaks the character" case.
- The system already draws a rim highlight, adaptive shadow and (under Increase Contrast) a contrasting border. A Flutter lit rim and glint will stack on these. Expect to tune or drop the Flutter rim per setting.
- Do not put Flutter-drawn frosted panels (BackdropFilter) on the same screen as native glass.
- Do not animate opacity of the glass from Flutter; drive show/hide natively (`effect = nil` animation) or by scaling.

### Gaps
- No Apple statement on custom strokes/borders drawn over glass specifically.
- Whether native glass under a Flutter platform view samples Flutter content below it is contested between sources; must be verified on device.

## 4. Performance: number of glass elements, GlassEffectContainer, older devices, battery, known complaints

### Takeaway
Apple's only concrete guidance: limit simultaneous glass effects, and group them in `GlassEffectContainer` / `UIGlassContainerEffect` for best rendering performance and correct shared sampling. Apple publishes no numeric limits or per-device costs. Reports of lag and battery drain on older iPhones exist but are anecdotal. In Flutter, each glass surface is also a platform view with its own compositing cost.

### Cited Findings
- "Creating too many Liquid Glass effect containers and applying too many effects to views outside of containers can degrade performance. Limit the use of Liquid Glass effects onscreen at the same time." — [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)
- "Use `GlassEffectContainer` when applying Liquid Glass effects on multiple views to achieve the best rendering performance." — [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)
- "Combine custom Liquid Glass effects to improve rendering performance"; "Performance test your app across platforms." — [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass)
- Glass samples "content from an area larger than itself"; "glass can not sample other glass, so having nearby glass elements in different containers will result in inconsistent behavior." — [WWDC25 323](https://developer.apple.com/videos/play/wwdc2025/323/)
- "limit Liquid Glass to the most important elements of your app. Where possible, use the system views and controls." — [WWDC25 284](https://developer.apple.com/videos/play/wwdc2025/284/)
- HIG: "Use Liquid Glass effects sparingly ... Limit these effects to the most important functional elements in your app." — [HIG Materials](https://developer.apple.com/design/human-interface-guidelines/materials)
- Container spacing sizes the shared sampling region; an oversized spacing value "makes the OS reserve one far bigger than the group needs." — [fresnel_ios](https://pub.dev/packages/fresnel_ios) (plugin author's finding, not Apple)
- "Every glass button or surface is its own platform view with its own compositing cost"; avoid dozens of glass surfaces in lists; simulator exaggerates glass artifacts. — [ios_liquid_glass](https://pub.dev/packages/ios_liquid_glass)
- Anecdotal: iPhone SE tester found iOS 26 with Liquid Glass "laggy"; outlets cite older A-series chips slowing with glass effects, Reduce Transparency as the common fix; battery-drain reports partly attributed to post-update indexing. Not controlled benchmarks. — [MacObserver](https://macobserver.com/tips/round-ups/i-tested-ios-26-on-iphone-se-with-liquid-glass-and-it-feels-laggy); [BGR](https://bgr.com/2047698/how-to-fix-ios-26-slowing-down-iphone-guide/); [SlashGear](https://www.slashgear.com/1982231/why-ios-26-is-draining-your-iphones-battery)
- Profiling references Apple points to: tech talk 10855 (UI animation hitches and the render loop), WWDC25 306 (Optimize SwiftUI performance with Instruments). — [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)

### Inferences
- Keep native glass to a handful of chrome surfaces per screen, grouped in one container, never per list row.
- Platform views force Flutter to split its layer tree around each native view; many glass views multiply that cost on top of the GPU sampling cost.
- Users on older devices who enable Reduce Transparency get cheaper, opaque glass automatically; the Flutter overlay should not add its own expensive blur.

### Gaps
- No Apple or benchmark data on per-element cost, or on A12-A14 specifically (iOS 26 supports A13+ iPhones per general knowledge **(unverified here)**).
- No measured battery cost of glass in third-party apps.

## 5. Interactive glass: press/touch response; automatic with `.interactive()` / `isInteractive`; does it need touches on the native view

### Takeaway
Yes, automatic: `.interactive()` (SwiftUI) or `UIGlassEffect.isInteractive = true` (UIKit) gives the system scale, bounce and shimmer. It reacts to touches the native view receives. A Flutter app that keeps gestures in Flutter (native view non-interactive, transparent hit test) will not get this response unless it drives a pressed state across a channel, which is what at least one plugin does; another plugin dropped native press response entirely.

### Cited Findings
- "On iOS, for custom controls or for containers with interactive elements, add the interactive modifier ... Glass reacts to user interaction by scaling, bouncing, and shimmering, matching the effect provided by toolbar buttons and sliders." — [WWDC25 323](https://developer.apple.com/videos/play/wwdc2025/323/)
- "Add `interactive(_:)` to custom components to make them react to touch and pointer interactions." — [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)
- UIKit: "To get that same kind of interactivity in your custom views, set isInteractive to true on the glassEffect." — [WWDC25 284](https://developer.apple.com/videos/play/wwdc2025/284/)
- fresnel_ios: hosting view `isUserInteractionEnabled = false` with `PlatformViewHitTestBehavior.transparent`; "Interactive glass is driven by an explicit `setPressed` call from Flutter's gesture arena", one method-channel message per press. — [fresnel_ios](https://pub.dev/packages/fresnel_ios)
- ios_liquid_glass: deprecated its `nativeInteractive` style; the native press response never triggers, so press feedback comes from Flutter. — [ios_liquid_glass](https://pub.dev/packages/ios_liquid_glass)
- liquid_glass_native embeds SwiftUI glass controls (interactive, in GlassEffectContainer) as platform views with per-control method channels. — [liquid_glass_native](https://pub.dev/packages/liquid_glass_native)
- Reduce Motion "disables any elastic properties for the material." — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)

### Inferences
- Choice: (a) let the native view take touches (native bounce/shimmer, but Flutter gestures/semantics on that area need bridging), or (b) keep touches in Flutter and draw press feedback in Flutter (scale the platform view or the overlay). Option (b) fits a Flutter-owned hit target and the hand-drawn overlay best.
- How fresnel_ios triggers the native shimmer from `setPressed` without a real touch is not documented on its page; inspect its source before relying on it.
- Under Reduce Motion, any Flutter-driven bounce should also be removed to match the system.

### Gaps
- No Apple API documented for programmatically triggering the interactive press state without real touches.
- Not verified whether `isInteractive` responds to touches forwarded through Flutter's `UiKitView` gesture recognizers (eager/gesture-arena forwarding).
