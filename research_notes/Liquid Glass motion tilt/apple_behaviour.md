# Apple iOS 26 Liquid Glass: response to device motion

## Does Liquid Glass use device motion (gyro/accelerometer) for highlights?

### Takeaway
Yes, Apple says so, but only qualitatively: the WWDC25 "Meet Liquid Glass" transcript says lighting "in some cases" responds to device motion. Apple names no sensor, API, angle, damping or frame rate; no CoreMotion or reverse-engineering writeup was found.

### Cited Findings
- WWDC25 session 219 transcript (verbatim): "And in some cases, the lighting responds to device motion, making it feel like Liquid Glass is aware of its position in the real world." Followed by: "These behaviors make the interface feel alive and directly connected to the physical world and device input." — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- The same transcript never uses the words tilt, gyroscope, shimmer or specular. Closest: "Light sources inside of this environment shine on the material producing highlights that respond to geometry just as you'd expect." — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- Apple press release (per prior project report) says the material "dynamically reacts to movement with specular highlights"; this is where "specular" and "movement" come from, not the session. — [Apple Newsroom](https://www.apple.com/newsroom/2025/06/apple-introduces-a-delightful-and-elegant-new-software-design/) (quoted in project report, not re-fetched here)
- Apple also says lights "move in space" on system interactions such as locking/unlocking, "causing light to travel around the material, defining its silhouette." That is an event-driven animation, not sensor-driven. — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- Hands-on: Apple Magazine says on app icons "The dynamic lighting shifts as users tilt their iPhones, recalculating reflections in real time"; default light from top-left; highlight on one edge, deeper shadow on the opposite edge; "kinetic response" on compatible devices. No gyroscope mention. Developer-test angles quoted: -45 or -139 degrees (unexplained). — [Apple Magazine](https://applemagazine.com/liquid-glass-ios-26-the-optical-illusion-making-some-iphone-screens-tilt/)
- Android Authority (via search summary; page returned 403): dark-mode icons get an upper-left highlight that can look skewed; specular highlights shift as the iPhone moves, "less noticeable in motion than in static screenshots"; claims users not in Low Power Mode see this. — [Android Authority](https://www.androidauthority.com/liquid-glass-vertigo-3598657/)
- TechRadar (via search summary): Reddit users reported dizziness/eye strain, mostly with dark wallpapers and Dark/Clear/Tinted icons; workaround Reduce Transparency. — [TechRadar](https://www.techradar.com/phones/ios/ios-26-users-say-liquid-glass-is-causing-eye-strain-and-vertigo-here-are-the-possible-fixes)
- 9to5Mac on iOS 26.2: the Measure Level tool gained Liquid Glass circles, chromatic aberration and grid distortion; this is a sensor-driven UI, but the article does not say the glass effect itself is motion-driven. — [9to5Mac](https://9to5mac.com/2025/11/12/ios-26-2-adds-a-cool-liquid-glass-effect-to-the-native-level-tool/)

### Inferences
- Tilt-reactive highlight is real but limited: Apple's "in some cases" plus hands-on reports centered on home-screen icons suggest it is not uniform across all components. Which components (tab bar, buttons, sheets, switches) tilt-react is unverified.
- Rim light likely shifts across the edge as the device tilts, with a fixed upper-left default light; this is consistent with reports, not documented.
- Tilt, not scrolling, is plausibly the driver behind vertigo complaints (Apple Magazine claims static tilt fools the vestibular system); that is the article's argument, not evidence.

### Gaps
- No Apple source naming CoreMotion, gyroscope or accelerometer for Liquid Glass.
- No magnitude (degrees of shift per degree of tilt), smoothing, damping or frame-rate numbers; no reverse-engineering writeup found (searched UIGlassEffect/CoreMotion).
- Which UI components react to tilt: unverified. Hands-on evidence covers app icons only.
- Low Power Mode disabling the effect: only Android Authority's claim via summary; unconfirmed. Page not readable.
- Not checked: HIG Materials page and SwiftUI Glass / UIGlassEffect docs for motion text; WWDC25 sessions 284 (UIKit), 323 (SwiftUI) transcripts; Reddit/HN/Mastodon threads directly.

## Touch/press response vs motion-driven

### Takeaway
Touch response is well documented in words: glass "instantly flexes and energizes with light", glow spreads from the fingertip to nearby glass. Reduce Motion tones down effects and kills elasticity. Scroll-driven behaviour is separate (edge effect, tab bar minimize).

### Cited Findings
- "Liquid Glass responds to interaction by instantly flexing and energizing with light." "...gel-like flexibility..." — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- "Starting right under your fingertips, the glow spreads throughout the element and onto any Liquid Glass elements nearby..." — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- Flexing to larger sizes (menu from a toolbar button) changes material characteristics to simulate thicker material. — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- "Reduced Motion decreases the intensity of some effects and disables any elastic properties for the material." Applied automatically with system settings. — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- Reduce Transparency makes glass frostier; Increase Contrast goes mostly black/white with border (see earlier project report). — [WWDC25 219 index](https://nonstrict.eu/wwdcindex/wwdc2025/219/)
- A developer guide advises against animating Liquid Glass elements unnecessarily because adaptive behaviours cost compute; a guide says effects render incorrectly in the Simulator, so test motion on a device. — [Atelier Socle](https://www.atelier-socle.com/en/articles/swiftui-liquid-glass-guide) (via search summary, weak)

### Inferences
- Reduce Motion's effect on the tilt highlight specifically is not stated; the wording "intensity of some effects" leaves it open. Safe design choice: disable tilt under Reduce Motion.

### Gaps
- No press-animation numbers (duration, spring, scale) from Apple.
- Whether Reduce Motion freezes the tilt highlight: no source.
- Parallax or lensing tied to motion: nothing found; Apple's lensing is described as geometry/content-based, not motion-based.

## Third-party recreations (context only)

### Takeaway
Recreation packages treat gyro-driven highlights as an add-on, which implies the community believes the real effect is sensor-driven, but they are not evidence of how Apple does it.

### Cited Findings
- A Flutter package drives specular highlights from any stream of values (gyroscope-ready) and lists device-tilt via sensors_plus as planned. — [pub.dev liquid_glass_widgets](https://pub.dev/documentation/liquid_glass_widgets/1.11.0/) (via search summary)
- LiquidGlassKit (UIKit recreation) uses directional specular streaks tied to surface normals and the private CABackdropLayer; no motion claim seen. — [LiquidGlassKit](https://upd.dev/DnV1eX/LiquidGlassKit) (via search summary)

### Inferences
- A Flutter implementation could feed accelerometer/gyro (sensors_plus) into a rim-light angle, low-pass filtered, gated by Reduce Motion.

### Gaps
- Source code of those packages was not read.
