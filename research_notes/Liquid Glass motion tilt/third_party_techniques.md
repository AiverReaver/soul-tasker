# Third-party techniques for motion-reactive Liquid Glass / glassmorphism highlights

Method note: package versions/licences/platforms come from the pub.dev JSON API (queried 2026-10-18). Motion code was read from cloned repos / extracted pub archives. WebFetch/WebSearch summaries were treated as secondary and cross-checked where possible.

## 1. Flutter packages: which ones are motion-reactive?

### Takeaway
Only `liquid_glass_widgets` ships a motion hook (`GlassMotionScope`, light angle from a stream), and its documented gyro mapping is naive (angular rate used as an angle). `liquid_glass_renderer` has no motion code and its newest dev line removes the configurable light angle. Tilt/holographic packages (`flutter_tilt`, `holographic_card_flutter`) show the practical sensors_plus patterns.

### Cited Findings
- `liquid_glass_widgets` 1.13.0 (published 2026-10-14), MIT, needs Flutter >=3.41.0 / Dart >=3.5.0, platforms android/ios/web/macos/windows/linux — [pub.dev API](https://pub.dev/api/packages/liquid_glass_widgets); repo [github.com/sdegenaar/liquid_glass_widgets](https://github.com/sdegenaar/liquid_glass_widgets) (cloned at 730e4a9).
- Its README advertises "Gyroscope lighting — `GlassMotionScope` drives specular highlights from any `Stream<double>`" and shows `gyroscopeEvents.map((e) => e.y * 0.5)` — [README](https://raw.githubusercontent.com/sdegenaar/liquid_glass_widgets/main/README.md). README names the parameter `stream:`, but the actual source names it `lightAngle:` (README/source mismatch).
- Source of `GlassMotionScope` (`lib/widgets/shared/glass_motion_scope.dart`): subscribes to a `Stream<double>` of **radians**, `setState`s on every event, and overrides `lightAngle` in the `GlassTheme` for both light and dark variants. No smoothing, clamping, or rate limiting inside the widget. Doc comment: "hook up to `sensors_plus` gyroscope data or any animation" — [source](https://github.com/sdegenaar/liquid_glass_widgets/blob/main/lib/widgets/shared/glass_motion_scope.dart).
  ```dart
  // from the doc comment in glass_motion_scope.dart
  GlassMotionScope(
    lightAngle: gyroscopeEvents.map((e) => e.y * 0.5),
    child: child,
  )
  ```
- Default light angle in that package is `0.75 * pi` (about 135 deg, "upper-left, matches iOS 26") — `lib/theme/glass_theme_data.dart` line 289 in the clone above.
- sensors_plus defines `GyroscopeEvent` x/y/z as **rate of rotation in rad/s** — [gyroscope_event.dart](https://github.com/fluttercommunity/plus_plugins/blob/main/packages/sensors_plus/sensors_plus_platform_interface/lib/src/gyroscope_event.dart). So `e.y * 0.5` is a velocity, not a tilt angle: highlight jumps while the phone rotates and returns to the fixed value when the phone stops. This is my reading of the units; the package does not state it.
- `liquid_glass_renderer` pub latest is 0.2.0-dev.4 (2025-11-13), MIT, Flutter >=3.32.4, pub tags android/ios/macos only (Impeller required) — [pub.dev API](https://pub.dev/api/packages/liquid_glass_renderer); repo [whynotmake-it/flutter_liquid_glass](https://github.com/whynotmake-it/flutter_liquid_glass). Grep of the main branch finds no sensors/gyro/accelerometer/tilt code.
- Repo main (pubspec `1.0.0-dev.1`, not on pub as of query) is a rewrite on Flutter GPU, min Flutter 3.47.0: "`lightAngle` and `ambientStrength` are removed; the light direction is no longer configurable"; `lightIntensity` becomes `highlight` ("`1` now matches the iOS 27 glint on an iPhone") — [CHANGELOG](https://github.com/whynotmake-it/flutter_liquid_glass/blob/main/packages/liquid_glass_renderer/CHANGELOG.md). Its apple_match notes say the light was fixed at pi/2 "Apple's top-light" — `example/tool/apple_match/MODEL_DESIGN.md` in the repo. Implication: the 0.2.x pub line has `lightAngle`/`lightIntensity` you could drive; the 1.0 line does not.
- `liquid_glass_widgets` vendors and extends the `liquid_glass_renderer` shader pipeline (MIT, attributed) — README "Acknowledgements" section, same README link.
- `flutter_tilt` 4.1.0 (2026-07-29), MIT, depends `sensors_plus >=6.1.0 <8.0.0`, all six platforms — [pub.dev API](https://pub.dev/api/packages/flutter_tilt), [repo](https://github.com/fluttercandies/flutter_tilt). Defaults in `tilt_config.dart`: `sensorFactor = 10.0`, `enableSensorRevert = true`, `sensorRevertFactor = 0.05` (damping, 0-1), `sensorMoveDuration = 50 ms`. Pattern (from `tilt_sensor_input_source.dart`): subscribe `gyroscopeEventStream()` with default interval, store latest `Offset(event.y, event.x)`, and a periodic `Timer` (frame duration from an `fps` param) pushes the latest value to the controller (decouples sensor rate from render rate). It subscribes `accelerometerEventStream()` separately to infer device orientation (largest-magnitude axis of x/y/z, sign gives portraitUp/Down or landscapeLeft/Right, gated by `MediaQuery.orientation`).
- `holographic_card_flutter` 0.1.4 (2025-05-15), MIT, uses `sensors_plus ^3.0.0` (old; uses deprecated `gyroscopeEvents`) and a `FragmentProgram` (`holographic_shader.frag.glsl`) — [pub.dev API](https://pub.dev/api/packages/holographic_card_flutter), [repo](https://github.com/SirAntonySir/holographic_card_flutter). Motion code (`lib/src/holographic_card.dart`): throttle to 16 ms, per-event exponential smoothing with `gyroSmoothing = 0.85`, `gyroSensitivity` 0.3 (widget) / 0.5 (config), then a 16 ms AnimationController lerps displayed offset toward target by 0.1 per tick:
  ```dart
  _targetGyroscopeOffset = Offset(
    _targetGyroscopeOffset.dx * s + (yFactor * event.y * sens) * (1 - s),
    _targetGyroscopeOffset.dy * s + (xFactor * event.x * sens) * (1 - s));   // s = 0.85
  // each tick:
  _gyroscopeOffset += (_targetGyroscopeOffset - _gyroscopeOffset) * 0.1;
  ```
  Note it too feeds angular velocity (rad/s) straight in as an offset (no integration), and ticks `setState` on every frame.
- Other tilt packages seen in search (not read): `gyroscopic_card`, `scratch_3d_card` — [search result](https://pub.dev/documentation/holographic_card_flutter/latest/) context only; treat as unverified.

### Inferences
- For a drift-free highlight, a Flutter implementation should derive a tilt **angle** (from accelerometer gravity vector, or a fused estimate) rather than reuse the `e.y * 0.5` pattern; none of the surveyed packages does this.
- If Hearthrise uses `liquid_glass_renderer` 0.2.x, `lightAngle` can be driven; if it moves to the 1.0 Flutter-GPU line, the light is fixed and motion would need a custom overlay highlight painted above the glass.

### Gaps
- Did not read the shader source of `liquid_glass_widgets` to see how `lightAngle` becomes a highlight vector, nor measure rebuild cost of `setState` per sensor event.
- `flutter_tilt` default `fps` value not found (grep returned nothing); not confirmed.
- `flutter_sensors` (1.0.1, 2022-01-24, MIT, android/ios, SDK <3.0.0 constraint) is stale and unmaintained — [pub.dev API](https://pub.dev/api/packages/flutter_sensors); no reason to prefer it over sensors_plus.

## 2. sensors_plus API, rates, platforms

### Takeaway
sensors_plus 7.1.1 (BSD-3-Clause, android/ios/web only) exposes `accelerometerEventStream`/`gyroscopeEventStream`/`userAccelerometerEventStream` with `samplingPeriod`; the old `*Events` getters are deprecated. `gameInterval` is 20 ms (50 Hz), `uiInterval` ~66.7 ms, `normalInterval` 200 ms.

### Cited Findings
- Version 7.1.1, published 2026-10-01, BSD-3-Clause, SDK >=3.3.0, Flutter >=3.19.0, platforms android/ios/web (no desktop), Flutter Favorite — [pub.dev API](https://pub.dev/api/packages/sensors_plus), [package page](https://pub.dev/packages/sensors_plus).
- API in source: `accelerometerEventStream({samplingPeriod})`, `gyroscopeEventStream(...)`, `userAccelerometerEventStream(...)`, `magnetometerEventStream(...)`, `barometerEventStream(...)`; the getters `accelerometerEvents`, `gyroscopeEvents`, etc. are `@Deprecated('Use ...EventStream() instead.')` — [sensors_plus.dart](https://github.com/fluttercommunity/plus_plugins/blob/main/packages/sensors_plus/sensors_plus/lib/sensors_plus.dart). (README still shows the deprecated names; WebFetch of the pub page also reported only those.)
- `SensorInterval`: `normalInterval` 200 ms, `uiInterval` 66 ms 667 us, `gameInterval` 20 ms, `fastestInterval` Duration.zero — [sensor_interval.dart](https://github.com/fluttercommunity/plus_plugins/blob/main/packages/sensors_plus/sensors_plus_platform_interface/lib/src/sensor_interval.dart).
- Units: accelerometer m/s^2 including gravity (upright device reads about y = 9.8); gyroscope rad/s; `UserAccelerometerEvent` has gravity filtered out — [README](https://github.com/fluttercommunity/plus_plugins/blob/main/packages/sensors_plus/sensors_plus/README.md).
- README notes: on web the sampling rate cannot be set; on Android the requested rate is not guaranteed; pass `onError` for devices lacking a sensor — [README](https://github.com/fluttercommunity/plus_plugins/blob/main/packages/sensors_plus/sensors_plus/README.md) (via WebFetch summary of pub page; confirm wording in README).

### Inferences
- The default `normalInterval` (5 Hz) is too slow for a highlight; `gameInterval` (50 Hz) or `fastestInterval` plus a Ticker-driven smoother is what the surveyed packages implicitly need. `holographic_card_flutter` and `flutter_tilt` both use the default interval and re-sample at about 60 Hz in a timer/controller instead (flutter_tilt confirmed; holographic uses deprecated getter = default interval).

### Gaps
- No source found giving iOS CoreMotion update rate actually delivered per `SensorInterval` value, or battery cost.

## 3. Web: DeviceOrientation tilt demos, permission flow, ranges

### Takeaway
Standard recipe: feature-detect `DeviceOrientationEvent.requestPermission`, call it from a click, listen to `deviceorientation`, read `gamma` (left-right, -90..90) and `beta` (front-back, -180..180), calibrate a zero point, clamp to a small angle window, map to CSS custom properties. I found no public liquid-glass web demo that is tilt-driven; the closest are tilt libraries with gyro support.

### Cited Findings
- iOS-style permission flow (MDN example): feature-detect `typeof DeviceOrientationEvent.requestPermission !== "function"` (no permission needed / unavailable), call it inside a click handler, `await` result `"granted"|"denied"`, only then `addEventListener("deviceorientation", ...)`. Requires secure context (HTTPS) and transient user activation, else rejects `NotAllowedError`; optional `absolute=true` also covers the magnetometer; not Baseline — [MDN requestPermission](https://developer.mozilla.org/en-US/docs/Web/API/DeviceOrientationEvent/requestPermission_static).
- Axis ranges: beta -180..180 (front-back), gamma -90..90 (left-right), alpha 0..360 — [MDN DeviceOrientationEvent](https://developer.mozilla.org/docs/Web/API/DeviceOrientationEvent), [W3C spec](https://www.w3.org/TR/2024/WD-orientation-event-20240504/).
- `vanilla-tilt.js` 1.8.1 (MIT) gyro mode: listens to `deviceorientation`, ignores null gamma/beta, **calibrates a zero point by averaging the first N events** (`gyroscopeSamples: 10`: `zero = (new + last)/2`), then maps `(gamma - zero)` and `(beta - zero)` across a window `gyroscopeMin/MaxAngleX/Y = -45..+45` degrees to element position, then computes tilt with `max: 15` degrees and glare opacity via `max-glare`; updates via `requestAnimationFrame` (cancelling the pending one) — [source](https://github.com/micku7zu/vanilla-tilt.js/blob/master/src/vanilla-tilt.js) (cloned; lines ~151-200 and 421-442). Defaults: `max: 15`, `gyroscope: true`, `gyroscopeSamples: 10`, `max-glare: 1`.
  ```js
  const angleX = event.gamma - (minAngleX + gammazero);   // minAngleX = -45
  const posX = angleX / (totalAngleX / this.width);        // total = 90 deg across element width
  ```
- `parallax.js` (wagerfield) options: `frictionX/Y` default 0.1 (easing 0-1; 1 = instant), `scalarX/Y` default 10, `limitX/Y` default false, `calibrateX` default false, `calibrateY` default true (caches initial axis value, measures relative) — [README](https://raw.githubusercontent.com/wagerfield/parallax/master/README.md) (via WebFetch; defaults for calibration threshold/delay not documented there).
- `liquidGL` 2.0.1 (WebGL glass, jsDelivr README) has a tilt feature with `tiltEase` default 400 ms; specifics of whether tilt is gyro or pointer not confirmed — [README](https://cdn.jsdelivr.net/npm/liquid-gl@2.0.1/README.md).
- SVG/CSS liquid-glass libraries found (`liquid-glass-js` by eamonliu: SVG feDisplacementMap, chromatic aberration, specular computed from surface normal; `archisvaze/liquid-glass`: SVG + Three.js engines; Aave "Building Glass for the Web"; ekino "Liquid Glass in CSS and SVG") — none mention deviceorientation — [liquid-glass-js](https://cdn.jsdelivr.net/npm/liquid-glass-js@0.1.0/README.md), [Aave](https://aave.com/design/building-glass-for-the-web), [ekino](https://medium.com/ekino-france/liquid-glass-in-css-and-svg-839985fcb88d).
- Throttling/clamp guidance (blog-level, weak): throttle to ~20 updates/s and clamp to roughly +-20-30 deg — [OpenReplay](https://blog.openreplay.com/understanding-device-orientation-api/), [hackmd](https://hackmd.io/@davelange/H1tBBnbZp) (from search-result summary, not read in full).

### Inferences
- Pointer fallback is the norm in tilt libs (vanilla-tilt handles mouse + gyro with the same normalised position); desktop/Android-without-permission falls back to pointer.
- Window of +-45 deg (vanilla-tilt) is generous; handheld phone use rarely exceeds +-30 deg, so +-20-30 matches blog guidance.

### Gaps
- No CodePen/GitHub demo found of tilt-driven SVG `feSpecularLighting` or GLSL liquid glass; no first-hand code for light-source position moved by gamma/beta.
- Did not verify landscape handling on web (`screen.orientation.angle` swap of beta/gamma); no source read.
- Did not retrieve Chrome Android permission behaviour.

## 4. Apple's own behaviour / native

### Takeaway
Apple states Liquid Glass "responds to motion with specular highlights", but no authoritative source says which sensor or mapping is used. Treat any specific claim (gyroscope, ray tracing, ranges) as unverified.

### Cited Findings
- Apple newsroom wording as reproduced by outlets: material uses real-time rendering and "responds to movement with specular highlights" — [MacTech reprint](https://www.mactech.com/2025/06/09/apple-debuts-its-broadest-software-design-ever-with-liquid-glass/amp/). Primary Apple newsroom page was not directly retrieved.
- A DEV article says blur layers "react to device gyroscopes" but also makes unsupported claims (Neural Engine ray tracing, conversion stats) — low reliability — [DEV](https://dev.to/startup-consultant/liquid-glass-design-how-to-prepare-your-app-for-ios-26-development-52m0).
- A guide warns specular/motion response does not render correctly in the iOS Simulator (needs a real device) — [Atelier Socle](https://www.atelier-socle.com/en/articles/swiftui-liquid-glass-guide) (search-result summary; not read in full).
- Design-agency commentary: highlights usually appear from a light source near the top-left — secondary interpretation, not Apple language — [STRV](https://strv.com/blog/liquid-glass-and-the-future-of-design).
- `UIInterpolatingMotionEffect` (native tilt mapping API, `minimumRelativeValue`/`maximumRelativeValue`, typical +-20 pt in docs/examples) — [Apple docs](https://developer.apple.com/documentation/uikit/uiinterpolatingmotioneffect). **The fetch returned only the page title; the description is from model knowledge, not verified from the page.**

### Inferences
- Static highlight direction in Apple look is upper-left (liquid_glass_widgets default 135 deg; renderer rewrite fixed at pi/2 "top light"), so a motion-reactive version should perturb around that baseline rather than rotate freely.

### Gaps
- No WWDC25 session text or Apple doc retrieved confirming the motion-highlight mechanism, travel range, or smoothing.
- No native/Metal open-source reproduction of tilt-driven Liquid Glass found in this pass (no search targeted GitHub code search for `CMMotionManager` + glass).

## 5. Smoothing, deadzones, damping, orientation handling (gathered values)

### Takeaway
Observed values: exponential smoothing alpha 0.85 retained / 0.15 new (holographic_card_flutter), second-stage lerp 0.1/frame, flutter_tilt revert factor 0.05 and 50 ms move duration, vanilla-tilt zero-calibration over 10 samples with +-45 deg window and 15 deg max tilt, parallax.js friction 0.1. No deadzone constants were found in any surveyed source.

### Cited Findings
- Retain/new smoothing 0.85/0.15 per event, then 0.1 lerp per 16 ms tick — holographic_card_flutter (see section 1 snippet), [repo](https://github.com/SirAntonySir/holographic_card_flutter).
- `sensorRevertFactor = 0.05`, `sensorMoveDuration = 50 ms`, `sensorFactor = 10` — flutter_tilt `tilt_config.dart`, [repo](https://github.com/fluttercandies/flutter_tilt).
- Rate: sensor stream throttled/resampled to about 60 Hz (16 ms) in both Flutter tilt packages; sensors_plus `gameInterval` = 20 ms — see sections 1-2.
- Orientation: flutter_tilt reads the accelerometer to pick one of four `DeviceOrientation` values by dominant axis, gated by `MediaQuery.of(context).orientation` — [tilt_sensor_input_source.dart](https://github.com/fluttercandies/flutter_tilt) (pub archive 4.1.0). The remap of axes per orientation is in code I did not read in full (output truncated at the handler).
- Calibration: vanilla-tilt averages the first 10 orientation events for zero; parallax.js caches initial value (`calibrateX/Y`).
- Mapping window examples: +-45 deg gamma/beta to full element travel (vanilla-tilt); blog guidance +-20-30 deg.

### Inferences
- A reasonable synthesis for Dart: tilt angle from accelerometer gravity (`atan2`) or a complementary filter (gyro integral plus accelerometer low-pass, alpha about 0.98) then one-pole smoothing `y += (x - y) * k` with k about 0.1-0.15 at 60 Hz, mapped over +-25-30 deg. These numbers are my synthesis; none of the surveyed code implements a complementary filter or deadzone.

### Gaps
- No complementary-filter or deadzone implementation found in any Flutter or web package surveyed.
- No source gave a measured "full highlight travel" for Apple's look.
- Landscape axis swapping for Flutter not verified end to end.
