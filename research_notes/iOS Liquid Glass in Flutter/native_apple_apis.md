# Native Apple Liquid Glass APIs (iOS 26+) for SwiftUI and UIKit

Method note: The primary source for signatures is the iOS SDK installed on this Mac. It is Xcode 27.1 (build 27A9275), iPhoneOS27.1.sdk. Signatures below were read from its headers and `.swiftinterface` files, not from blogs. Paths are abbreviated as follows:
- `SDK/UIKit/Headers` = `/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.1.sdk/System/Library/Frameworks/UIKit.framework/Headers`
- `SDK/SwiftUICore.swiftinterface` = `.../SwiftUICore.framework/Modules/SwiftUICore.swiftmodule/arm64e-apple-ios.swiftinterface`
- `SDK/SwiftUI.swiftinterface` = `.../SwiftUI.framework/Modules/SwiftUI.swiftmodule/arm64e-apple-ios.swiftinterface`
- `SDK/UIKit.swiftinterface` = `.../UIKit.framework/Modules/UIKit.swiftmodule/arm64e-apple-ios.swiftinterface`

The glass API surface in the 27.1 SDK is the same set introduced in iOS 26. No iOS 27-only glass properties appear in `UIGlassEffect.h` or in the SwiftUI `Glass` struct.

## SwiftUI: signatures and behavior of glassEffect, Glass, containers, IDs, unions, transitions, button styles; allowed shapes

### Takeaway
SwiftUI exposes `glassEffect(_ glass: Glass = .regular, in shape: some Shape = DefaultGlassEffectShape())`. The 27.1 SDK has no `isEnabled:` parameter. The default shape is a capsule, and any `Shape` is accepted. `Glass` has three variants (`.regular`, `.clear`, `.identity`) and two modifiers (`tint(_:)`, `interactive(_:)`). Grouping, morphing and merging need `GlassEffectContainer`, `glassEffectID(_:in:)`, `glassEffectUnion(id:namespace:)` and `glassEffectTransition(_:)`. All of these are `@available(iOS 26.0, ...)` and `@available(visionOS, unavailable)`.

### Cited Findings
- Exact declaration: `@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) @available(visionOS, unavailable) nonisolated public func glassEffect(_ glass: Glass = .regular, in shape: some Shape = DefaultGlassEffectShape()) -> some View` — [SDK/SwiftUICore.swiftinterface line 3084](file:///Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.1.sdk/System/Library/Frameworks/SwiftUICore.framework/Modules/SwiftUICore.swiftmodule/arm64e-apple-ios.swiftinterface); [Apple docs glassEffect(_:in:)](https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:))
- Apple's doc page has no `isEnabled` parameter and lists no deprecated variant. The task brief names `.glassEffect(_:in:isEnabled:)`, but that form is not in the shipping SDK. — [Apple docs glassEffect(_:in:)](https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:))
- Behavior, per Apple: the system "Renders a shape anchored behind a view with the Liquid Glass material" and "Applies the foreground effects of Liquid Glass over a view". The default is the `regular` variant with a `Capsule` shape. Glass is anchored to the view's bounds, padding included. — [Apple docs glassEffect(_:in:)](https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:))
- `public struct DefaultGlassEffectShape : Shape { public init() }`. Apple calls it "The default shape applied by glass effects, a capsule." — [SDK/SwiftUICore.swiftinterface line 3089](file:///Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.1.sdk/System/Library/Frameworks/SwiftUICore.framework/Modules/SwiftUICore.swiftmodule/arm64e-apple-ios.swiftinterface); [Apple: Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views)
- Shapes: the parameter is `some Shape`, so any SwiftUI `Shape` conformer works, including custom paths. Apple's examples use `Capsule`, `Circle` and rounded rectangles. Apple publishes no list of allowed shapes. — [SDK/SwiftUICore.swiftinterface](file:///Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.1.sdk/System/Library/Frameworks/SwiftUICore.framework/Modules/SwiftUICore.swiftmodule/arm64e-apple-ios.swiftinterface); [Apple: Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views)
- `public struct Glass : Equatable, Sendable { static var regular; static var clear; static var identity; func tint(_ color: Color?) -> Glass; func interactive(_ isEnabled: Bool = true) -> Glass }` — [SDK/SwiftUICore.swiftinterface line 7372](file:///Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.1.sdk/System/Library/Frameworks/SwiftUICore.framework/Modules/SwiftUICore.swiftmodule/arm64e-apple-ios.swiftinterface)
- `Glass` is `Equatable`, so it can be stored and diffed. `tint` takes an optional `Color`, and `nil` clears the tint. — same source
- Usage example: `.glassEffect(.regular.tint(.orange).interactive())`. "Assign a tint color to suggest prominence." `interactive(_:)` "applies the same responsive and fluid reactions that PrimitiveButtonStyle.glass provides to standard buttons." — [Apple: Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views)
- `GlassEffectContainer<Content: View>`: `public init(spacing: CGFloat? = nil, @ContentBuilder content: () -> Content)`, MainActor. — [SDK/SwiftUICore.swiftinterface line 11658](file:///Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.1.sdk/System/Library/Frameworks/SwiftUICore.framework/Modules/SwiftUICore.swiftmodule/arm64e-apple-ios.swiftinterface)
- Container purpose: use it "when applying Liquid Glass effects on multiple views to achieve the best rendering performance". It "also allows views with Liquid Glass effects to blend their shapes together and to morph". A larger `spacing` makes effects merge sooner. A spacing larger than the inner HStack/VStack spacing makes shapes "blend together at rest". — [Apple: Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views)
- `glassEffectID(_ id: (some Hashable & Sendable)?, in namespace: Namespace.ID) -> some View`. It drives morphing during view-hierarchy transitions inside a container. IDs come from `@Namespace`. — [SDK/SwiftUICore.swiftinterface line 22665](file:///Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.1.sdk/System/Library/Frameworks/SwiftUICore.framework/Modules/SwiftUICore.swiftmodule/arm64e-apple-ios.swiftinterface); [Apple: Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views)
- `glassEffectUnion(id: (some Hashable & Sendable)?, namespace: Namespace.ID) -> some View`. It "combines all effects with a similar shape, Liquid Glass effect, and ID into a single shape". It is useful for views created dynamically or placed outside a stack. — [SDK/SwiftUICore.swiftinterface line 12779](file:///Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.1.sdk/System/Library/Frameworks/SwiftUICore.framework/Modules/SwiftUICore.swiftmodule/arm64e-apple-ios.swiftinterface); [Apple: Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views)
- `GlassEffectTransition` has three static members: `.matchedGeometry`, `.materialize` and `.identity`. It is applied with `glassEffectTransition(_:)`. The default is `matchedGeometry` for effects within the container spacing. Use `materialize` for effects farther apart than the spacing. The ID and transition modifiers "only affect their content during view hierarchy transitions or animations." — [SDK/SwiftUICore.swiftinterface line 3518](file:///Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.1.sdk/System/Library/Frameworks/SwiftUICore.framework/Modules/SwiftUICore.swiftmodule/arm64e-apple-ios.swiftinterface); [Apple: Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views)
- Modifier order: "Apply the glassEffect(_:in:) modifier after other modifiers that affect the appearance of the view." — [Apple: Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views)
- Button styles: `PrimitiveButtonStyle.glass` (`GlassButtonStyle`) and `.glassProminent` (`GlassProminentButtonStyle`) exist. The SDK also has `static func glass(_ glass: Glass) -> Self` and `GlassButtonStyle.init(_ glass: Glass)`, so a custom `Glass`, such as `.clear`, can drive a button style. — [SDK/SwiftUI.swiftinterface lines 1439-1469, 4334-4359](file:///Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.1.sdk/System/Library/Frameworks/SwiftUI.framework/Modules/SwiftUI.swiftmodule/arm64e-apple-ios.swiftinterface)
- Related: `backgroundExtensionEffect()` and `backgroundExtensionEffect(isEnabled:)` are in SwiftUI. They mirror content under sidebars and glass chrome. — [SDK/SwiftUI.swiftinterface line 15403](file:///Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.1.sdk/System/Library/Frameworks/SwiftUI.framework/Modules/SwiftUI.swiftmodule/arm64e-apple-ios.swiftinterface)

### Inferences
- `Glass.identity` is the natural way to toggle glass off without changing the view tree. Pass `.identity` instead of `.regular`. This replaces the `isEnabled:` flag the brief mentions, which the shipping SDK lacks.
- For a Flutter host, the SwiftUI path (UIHostingController) is the only one that gives morphing (`glassEffectID`) and union. UIKit offers only container merging by proximity.

### Gaps
- I could not confirm whether an `isEnabled:` overload existed in an early iOS 26 beta and was later removed. The shipping SDK and Apple's docs show none.
- Apple publishes no list of shape restrictions. Behavior with self-intersecting or very complex custom paths is undocumented.

## UIKit: UIGlassEffect, UIGlassContainerEffect, UIVisualEffectView, cornerConfiguration, materialize animation

### Takeaway
UIKit glass is a `UIVisualEffect` subclass used with `UIVisualEffectView`. `UIGlassEffect(style: .regular | .clear)` has `tintColor` and `isInteractive`. `UIGlassContainerEffect` has `spacing`. Shape comes from the new `UIView.cornerConfiguration` (iOS 26), and the default shape is a capsule. To materialize, set `effect` inside `UIView.animate`. To dematerialize, set `effect = nil`. Do not animate `alpha`.

### Cited Findings
- Header (ObjC): `typedef NS_ENUM(NSInteger, UIGlassEffectStyle) { UIGlassEffectStyleRegular, UIGlassEffectStyleClear } API_AVAILABLE(ios(26.0)) API_UNAVAILABLE(visionos, watchos) NS_SWIFT_NAME(UIGlassEffect.Style);` — [SDK/UIKit/Headers/UIGlassEffect.h](file:///Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.1.sdk/System/Library/Frameworks/UIKit.framework/Headers/UIGlassEffect.h)
- `@interface UIGlassEffect : UIVisualEffect` has `@property (nonatomic, getter=isInteractive) BOOL interactive;`, `@property (nonatomic, copy, nullable) UIColor *tintColor;` and `+ (UIGlassEffect *)effectWithStyle:(UIGlassEffectStyle)style NS_SWIFT_NAME(init(style:));`. There is no `.identity` style in UIKit. — same header
- `@interface UIGlassContainerEffect : UIVisualEffect` has `@property (nonatomic) CGFloat spacing;`, documented as "the distance between elements at which they begin to merge". The header says to nest glass `UIVisualEffectView`s in the container view's `contentView`. The container "will render all glass elements in one combined view, behind the visual effect view's `contentView`." — same header
- `UIVisualEffectView.contentView`: "Do not add subviews directly to UIVisualEffectView, use this view instead." — [SDK/UIKit/Headers/UIVisualEffectView.h line 30](file:///Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.1.sdk/System/Library/Frameworks/UIKit.framework/Headers/UIVisualEffectView.h)
- Corner API (iOS 26, tvOS 26, visionOS 26): `@interface UIView (CornerConfiguration)` adds `@property (nonatomic, copy, nonnull) UICornerConfiguration *cornerConfiguration` and `- (CGFloat)effectiveRadiusForCorner:(UIRectCorner)corner` (Swift `effectiveRadius(corner:)`). — [SDK/UIKit/Headers/UIView.h lines 767-780](file:///Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.1.sdk/System/Library/Frameworks/UIKit.framework/Headers/UIView.h)
- Swift `UICornerConfiguration` (struct, refined for Swift) has `.corners(radius:)`, `.corners(topLeftRadius:topRightRadius:bottomLeftRadius:bottomRightRadius:)`, `.capsule(maximumRadius: Double? = nil)`, `.uniformCorners(radius:)`, `.uniformEdges(topRadius:bottomRadius:)`, `.uniformEdges(leftRadius:rightRadius:)`, `.uniformTopRadius(_:bottomLeftRadius:bottomRightRadius:)`, and the matching bottom, left and right variants. — [SDK/UIKit.swiftinterface line 3065](file:///Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.1.sdk/System/Library/Frameworks/UIKit.framework/Modules/UIKit.swiftmodule/arm64e-apple-ios.swiftinterface)
- Swift `UICornerRadius` has `.fixed(_ radius: Double)` and `.containerConcentric(minimum: CGFloat? = nil)`. It is `ExpressibleByFloatLiteral` and `ExpressibleByIntegerLiteral`, so `.corners(radius: 16)` compiles. The ObjC names are `+fixedRadius:`, `+containerConcentricRadius` and `+containerConcentricRadiusWithMinimum:`. — [SDK/UIKit.swiftinterface line 279](file:///Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.1.sdk/System/Library/Frameworks/UIKit.framework/Modules/UIKit.swiftmodule/arm64e-apple-ios.swiftinterface); [SDK/UIKit/Headers/UICornerRadius.h](file:///Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.1.sdk/System/Library/Frameworks/UIKit.framework/Headers/UICornerRadius.h)
- Name conflict: the WWDC25 session code shows `effectView.cornerConfiguration = .fixed(8)` and `.containerRelative()`. Those names are not in the shipping SDK, which uses `.corners(radius: .fixed(8))` and `.containerConcentric()`. Treat the WWDC snippets as beta-era names. — [WWDC25 284 Build a UIKit app with the new design](https://developer.apple.com/videos/play/wwdc2025/284/); contradicted by [SDK/UIKit.swiftinterface](file:///Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.1.sdk/System/Library/Frameworks/UIKit.framework/Modules/UIKit.swiftmodule/arm64e-apple-ios.swiftinterface)
- Materialize: "create a UIVisualEffectView, create a new UIGlassEffect, in an animation block, set the effect", e.g. `UIView.animate { effectView.effect = glassEffect }`. Dematerialize with `UIView.animate { effectView.effect = nil }`. "Always prefer setting the effect property over the alpha to ensure that the glass dematerializes or materializes with the appropriate animation." — [WWDC25 284](https://developer.apple.com/videos/play/wwdc2025/284/)
- Default shape: "By default, the glass is in a capsule shape. To customize the shape, use the new cornerConfiguration API." Container-concentric corners adapt their radius as the view moves toward or away from its container's corner. — [WWDC25 284](https://developer.apple.com/videos/play/wwdc2025/284/)
- Tint change: create a new `UIGlassEffect` with `tintColor` and animate `effectView.effect` to it. "Tinted glass color, automatically adapts to a vibrant version." — [WWDC25 284](https://developer.apple.com/videos/play/wwdc2025/284/)
- Interactive: `glassEffect.isInteractive = true` gives the scale and bounce of system buttons on touch. — [WWDC25 284](https://developer.apple.com/videos/play/wwdc2025/284/)
- Adaptation: glass follows `userInterfaceStyle`. "A larger size is more opaque. A smaller size is clearer, and switches between light and dark mode automatically, to increase contrast." — [WWDC25 284](https://developer.apple.com/videos/play/wwdc2025/284/)
- Container merge and split: animate frames to overlap to merge. To split, add views at the same frame inside `UIView.performWithoutAnimation`, then animate them apart. The container "enforces a uniform adaptation". — [WWDC25 284](https://developer.apple.com/videos/play/wwdc2025/284/)
- Buttons: `UIButtonConfiguration` has `glassButtonConfiguration`, `prominentGlassButtonConfiguration`, `clearGlassButtonConfiguration` and `prominentClearGlassButtonConfiguration`, all iOS 26 and tvOS 26. — [SDK/UIKit/Headers/UIButtonConfiguration.h lines 93-96](file:///Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.1.sdk/System/Library/Frameworks/UIKit.framework/Headers/UIButtonConfiguration.h)
- New animation option `UIViewAnimationOptionFlushUpdates` (iOS 26) flushes pending property invalidations around animation scopes. — [SDK/UIKit/Headers/UIView.h line 111](file:///Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.1.sdk/System/Library/Frameworks/UIKit.framework/Headers/UIView.h)

### Inferences
- UIKit has no `glassEffectID` or union equivalent. It has proximity merging via `UIGlassContainerEffect.spacing` only. The fresnel package author reached the same conclusion and chose SwiftUI for that reason ([fresnel](https://pub.dev/packages/fresnel)).
- For a platform view driven over a method channel, the minimum native surface is a `UIVisualEffectView`. Its parameters are `effect` (style, tint, interactive), `cornerConfiguration` and frame, plus an animated set of `effect`.

### Gaps
- The default `UIGlassContainerEffect.spacing` value is not documented in the header or the session.
- No header documents arbitrary path shapes for UIKit glass. The UIKit shape API covers corners and capsules only. Whether `layer.mask` or `maskView` on a glass view is supported is unverified.

## Availability: #available, runtime behavior on iOS 15-18, UIDesignRequiresCompatibility

### Takeaway
Every glass symbol is annotated `API_AVAILABLE(ios(26.0))` (SwiftUI: `@available(iOS 26.0, *)`), so using one needs `if #available(iOS 26, *)`. Apps built with the iOS 26 SDK can still deploy to older iOS. `UIDesignRequiresCompatibility = YES` opts an app out of the new design, but only for apps linked against the iOS 26 SDK. Apple's docs say the key is ignored when building for iOS 27 or later. This Mac already has the 27.1 SDK, so the opt-out does nothing for builds made here.

### Cited Findings
- Annotations: `UIGlassEffect` and `UIGlassContainerEffect` are `API_AVAILABLE(ios(26.0)) API_UNAVAILABLE(visionos, watchos)`. `UICornerConfiguration`, `UICornerRadius` and `UIView.cornerConfiguration` are `API_AVAILABLE(ios(26.0), tvos(26.0), visionos(26.0))`. SwiftUI glass APIs are `@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) @available(visionOS, unavailable)`. — [SDK/UIKit/Headers/UIGlassEffect.h](file:///Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.1.sdk/System/Library/Frameworks/UIKit.framework/Headers/UIGlassEffect.h); [SDK/SwiftUICore.swiftinterface](file:///Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.1.sdk/System/Library/Frameworks/SwiftUICore.framework/Modules/SwiftUICore.swiftmodule/arm64e-apple-ios.swiftinterface)
- UIKit glass is unavailable on visionOS. — same header
- `UIDesignRequiresCompatibility` (Boolean, introduced iOS, iPadOS, macOS and tvOS 26.0): "If YES, the system runs the app using a compatibility mode for UI elements. The compatibility mode displays the app as it looks when built against previous versions of the SDKs." Absence of the key, or NO, is the default. Warning: "Temporarily use this key while reviewing and refining your app's UI". — [Apple docs UIDesignRequiresCompatibility](https://developer.apple.com/documentation/bundleresources/information-property-list/uidesignrequirescompatibility)
- "The system ignores this key when you build for iOS 27 or later, iPadOS 27 or later, Mac Catalyst 27 or later, macOS 27 or later, or tvOS 27 or later." — [Apple docs UIDesignRequiresCompatibility](https://developer.apple.com/documentation/bundleresources/information-property-list/uidesignrequirescompatibility)
- Apple DTS, June 2026: "The system ignores this key only when the application is linked against the iOS 27 SDK or later." It "does not refer to setting the deployment target to iOS 27 or running the application on an iOS 27 device." Apps linked against the iOS 26 SDK keep the key honored on iOS 27 devices. — [Apple Developer Forums thread 832543](https://origin-devforums.apple.com/forums/thread/832543)
- WWDC25 statement: "We intend this option to be removed in the next major release." It is quoted in the same thread. — [Apple Developer Forums thread 832543](https://origin-devforums.apple.com/forums/thread/832543)
- The same DTS reply cites TN3187: the UIScene lifecycle "will be required when building with the latest SDK" in the release after iOS 26. — [Apple Developer Forums thread 832543](https://origin-devforums.apple.com/forums/thread/832543)
- Apple will not confirm App Store SDK cutoff dates before announcing them. A widely repeated "April 2027" deadline is unconfirmed. — [Apple Developer Forums thread 839939](https://developer.apple.com/forums/thread/839939)

### Inferences
- These points are standard Apple weak-linking behavior, not specific to glass:
  - Building with the 26 or 27 SDK and a deployment target of iOS 15 works.
  - Referencing glass symbols outside `#available` is a compile error, not a runtime crash.
  - On iOS 15-18 the `#available` branch is skipped.
  - A UIKit fallback such as `UIBlurEffect(style: .systemMaterial)` is the usual substitute.
  - The `NSClassFromString("UIGlassEffect")` runtime check returns nil on older OSes.
- SDK and OS combinations:
  - iOS 26 SDK build on iOS 26 or 27: system chrome adopts Liquid Glass automatically unless the key is YES.
  - iOS 27 SDK build: the new design is always on.
  - An app on iOS 18 or earlier never shows Liquid Glass, whatever SDK built it.

### Gaps
- I did not verify Flutter's own tooling minimums for the 27 SDK.

## Does native glass sample content rendered by another layer (Metal/CAMetalLayer, FlutterView)?

### Takeaway
Apple documents no statement on this. The only evidence is third-party: one Flutter package reports that SwiftUI `.glassEffect` hosted in a platform view under Flutter content "samples and refracts Flutter-rendered content beneath it", tested on an iOS 26.1 simulator only. Glass refracts what is composited behind it in the window. Whether Flutter pixels end up behind the platform view depends on Flutter's platform-view composition, so treat this as unverified until tested on a device.

### Cited Findings
- fresnel (pub.dev): native path is "SwiftUI `.glassEffect()` in a `UIHostingController`, hosted in a `UiKitView`". The platform view renders only the material, and "Content stays an ordinary Flutter subtree composited above it". Verified on an iPhone 17 Pro simulator (iOS 26.1, Flutter 3.44.8, Xcode 26.1.1): "native SwiftUI glass samples and refracts Flutter-rendered content beneath it." Simulator only, no device result. — [fresnel](https://pub.dev/packages/fresnel)
- fresnel known issue: a Flutter `BackdropFilter` in the same scene "makes the platform view stop rendering entirely", with no error or log. The cause is not established, see the package's KNOWN_ISSUES.md #1. The package therefore fixes the render path per route. — [fresnel](https://pub.dev/packages/fresnel)
- real_liquid_glass hosts `UIGlassEffect` or `NSGlassEffectView` "in a platform view beneath your Flutter content". `LiquidGlassGroup` shares one `UIGlassContainerEffect`, so "N containers in a group cost one platform view". Non-interactive glass "never intercepts touches". The package does not explicitly confirm refraction of Flutter pixels. — [real_liquid_glass](https://pub.dev/packages/real_liquid_glass)
- Pre-glass precedent: Apple forum discussion shows `UIVisualEffectView` blur working over an `MTKView`/`CAMetalLayer`. A stopped Metal layer keeps showing its last drawable, which the blur keeps sampling. — [Apple Developer Forums thread 62286](https://developer.apple.com/forums/thread/62286)
- Masked or clipped superviews can prevent a backdrop effect from sampling. In the iOS 10-era fix, the mask was applied to the effect view itself. — [Apple Developer Forums thread 50854](https://developer.apple.com/forums/thread/50854?page=4)

### Inferences
- `UIVisualEffectView` effects are backdrop effects composited by the render server. They should sample the window's composited pixels behind the view, whatever produced them (CALayer, CAMetalLayer, video). `CAMetalLayer.framebufferOnly` limits app-side shader sampling, not render-server backdrop capture, so it is not expected to matter. This is inference, not documented.
- For glass to refract Flutter UI, the Flutter pixels must be in a layer behind the glass view. With Flutter's iOS hybrid composition, content painted before the platform view goes into the base FlutterView layer behind it, which is good. Content painted after it goes into overlay layers above it, which the glass cannot refract but does sit visually on top of.

### Gaps
- No Apple source confirms Liquid Glass refraction of CAMetalLayer content.
- No device (non-simulator) test of Flutter content refracted by native glass was found.
- The root cause of the BackdropFilter-suppresses-platform-view bug is unknown, and I found no upstream flutter/flutter issue for it.

## Can arbitrary custom content be layered on top of a glass view; does glass apply vibrancy or tint to contentView subviews?

### Takeaway
Yes. Put subviews in `UIVisualEffectView.contentView`. Apple says labels "automatically become vibrant" based on `textColor`. In SwiftUI, `glassEffect` draws the material behind the view and "applies the foreground effects of Liquid Glass over" the view's content. Exactly how custom drawn layers (CAShapeLayer strokes, images) are treated is not documented.

### Cited Findings
- "To add content, like labels and images, use the visualEffectView's contentView. The label automatically becomes vibrant, based on its textColor. This ensures legibility against a wide variety of backgrounds." — [WWDC25 284](https://developer.apple.com/videos/play/wwdc2025/284/)
- "Depending on the colors behind, the glass and its content will switch to light or dark mode automatically, when using dynamic colors." — [WWDC25 284](https://developer.apple.com/videos/play/wwdc2025/284/)
- To remove content on glass, animate the content's `alpha` to 0. To change glass tint, animate a new effect alongside `textColor`. — [WWDC25 284](https://developer.apple.com/videos/play/wwdc2025/284/)
- SwiftUI: the system "Applies the foreground effects of Liquid Glass over a view". — [Apple docs glassEffect(_:in:)](https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:))
- In the Flutter packages above, content is drawn by Flutter above the platform view, not inside `contentView`. Native vibrancy therefore does not apply to Flutter-drawn content. — [fresnel](https://pub.dev/packages/fresnel)

### Inferences
- Content drawn with dynamic system colors (`.label`, `.secondaryLabel`) gets automatic light/dark adaptation. Fixed colors and bitmap images likely render as-is. This matches pre-26 `UIVibrancyEffect` behavior, but Apple does not state it for glass.
- If a Flutter app draws strokes over native glass, it must choose its own contrast colors. It gets no vibrancy, because the content is not in `contentView`.

### Gaps
- No Apple source details how glass treats `CALayer` drawing, `UIImageView` with template vs. original rendering, or custom `draw(_:)` content in `contentView`.

## Limitations: glass-on-glass, number of glass views, offscreen rendering

### Takeaway
Apple's limits are qualitative:
- Limit how many glass effects are on screen at once.
- Group multiple glass effects in a container for performance.
- Avoid glass overlapping glass. Nested glass inside a container is allowed and adapts.

There is no published numeric cap and no statement about offscreen rendering.

### Cited Findings
- "Creating too many Liquid Glass effect containers and applying too many effects to views outside of containers can degrade performance. Limit the use of Liquid Glass effects onscreen at the same time." — [Apple: Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views)
- Containers achieve "the best rendering performance". — same source
- Maps "removes the buttons" when a sheet expands, which "prevents glass elements from overlapping other glass elements, and keeps the illusion of a single floating layer of glass intact." — [WWDC25 284](https://developer.apple.com/videos/play/wwdc2025/284/)
- "When adding glass to an existing glass container, it adapts its appearance automatically." The example sets `container.effect = UIGlassEffect()` and adds a glass `effectView` to its `contentView`. — [WWDC25 284](https://developer.apple.com/videos/play/wwdc2025/284/)
- "Liquid Glass is distinct from other visual effects, like UIBlurEffect". It is "an interactive layer", so limit it "to the most important elements". — [WWDC25 284](https://developer.apple.com/videos/play/wwdc2025/284/)
- Use `regular` by default and reserve `clear` for controls over photos or video, per a package summary of Apple guidance (secondary source). — [real_liquid_glass](https://pub.dev/packages/real_liquid_glass)

### Inferences
- In Flutter, each native glass surface is one platform view, and each costs extra compositing layers. That cost adds to Apple's per-effect cost. Grouping many glass shapes into one native container (one platform view) is the cheaper design, as real_liquid_glass does.

### Gaps
- No published maximum count of glass views, and no frame-time or memory figures.
- No Apple statement on offscreen-pass cost or on snapshot behavior (e.g. `drawHierarchy`, screenshots of glass).
- The HIG Materials page was not fetched within this research budget, so its exact wording on glass-on-glass is not quoted here.
