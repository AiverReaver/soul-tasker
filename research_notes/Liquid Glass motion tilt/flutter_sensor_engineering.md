# Flutter tilt-sensor engineering (gyro/accelerometer-driven decorative UI)

## 1. sensors_plus: version, API, platforms, intervals, permissions, testing

### Takeaway
sensors_plus 7.1.1 (checked Oct 2026) supports Android, iOS and partial Web only (no desktop). Use `accelerometerEventStream(samplingPeriod: ...)`; ask for `uiInterval` (~15 Hz) or `gameInterval` (50 Hz), never `fastestInterval`. iOS needs `NSMotionUsageDescription` in Info.plist or the plugin crashes. `HIGH_SAMPLING_RATE_SENSORS` is only needed above 200 Hz, so not needed here.

### Cited Findings
- Version 7.1.1, published "16 days ago"; platforms Android, iOS, Web; macOS/Linux/Windows not supported. Requires Flutter 3.19+, Dart 3.3+, iOS 12+, Java 17, Kotlin 2.2.0, AGP 8.12.1+, Gradle 8.13+ — [pub.dev/packages/sensors_plus](https://pub.dev/packages/sensors_plus)
- 7.0.0 was breaking (Android toolchain bump: AGP 8.12.1+, Gradle 8.13+, Kotlin 2.2.0); 7.1.0 moved to Kotlin DSL and updated iOS SwiftPM for Flutter 3.44; 6.1.0 added iOS SwiftPM; 6.0.0 (breaking) made `NSMotionUsageDescription` required on iOS, added platform timestamps to events — [changelog](https://pub.dev/packages/sensors_plus/changelog)
- Current API: `accelerometerEventStream({Duration samplingPeriod = SensorInterval.normalInterval})`, `gyroscopeEventStream`, `userAccelerometerEventStream` (gravity removed), `magnetometerEventStream`, `barometerEventStream`. Old getters `accelerometerEvents` etc. are deprecated (the pub.dev page text still shows them in examples) — [sensors_plus.dart source](https://raw.githubusercontent.com/fluttercommunity/plus_plugins/main/packages/sensors_plus/sensors_plus/lib/sensors_plus.dart)
- `SensorInterval`: `normalInterval` = 200 ms (5 Hz), `uiInterval` = 66.667 ms (~15 Hz), `gameInterval` = 20 ms (50 Hz), `fastestInterval` = Duration.zero — [sensor_interval.dart](https://raw.githubusercontent.com/fluttercommunity/plus_plugins/main/packages/sensors_plus/sensors_plus_platform_interface/lib/src/sensor_interval.dart)
- Android: delivery rate "not guaranteed"; varies by Android version, hardware, vendor. Some low-end devices lack sensors, so add `onError` — [README](https://raw.githubusercontent.com/fluttercommunity/plus_plugins/main/packages/sensors_plus/sensors_plus/README.md)
- iOS: must add `NSMotionUsageDescription` to Info.plist; "not doing so will crash your app when it attempts to access motion data" (README wording). Barometer ignores sampling period (uses CMAltimeter) — [README](https://raw.githubusercontent.com/fluttercommunity/plus_plugins/main/packages/sensors_plus/sensors_plus/README.md)
- Web: sampling rate cannot be set (ignored); magnetometer/barometer unsupported — [README](https://raw.githubusercontent.com/fluttercommunity/plus_plugins/main/packages/sensors_plus/sensors_plus/README.md)
- Android 12+ (targetSdk 31+): `registerListener()` capped at 200 Hz for motion sensors; above that needs `HIGH_SAMPLING_RATE_SENSORS` or a `SecurityException` is thrown. Sensors always capped if user disabled mic access toggle. sensors_plus README does not mention this permission — [Android sensors overview](https://developer.android.com/develop/sensors-and-location/sensors/sensors_overview)
- Android `SENSOR_DELAY_*`: NORMAL 200 ms, UI 60 ms, GAME 20 ms, FASTEST 0. Delay is a hint. "Choose the largest delay that still meets your needs": larger delay uses less CPU/power — [Android docs](https://developer.android.com/develop/sensors-and-location/sensors/sensors_overview)
- Android docs: always unregister listeners (e.g. onPause); system does not disable sensors when screen turns off; sensors can drain battery in hours. Android 9+ background apps receive no events from continuous sensors — [Android docs](https://developer.android.com/develop/sensors-and-location/sensors/sensors_overview)
- Apple side (from a general-knowledge answer, Apple's page did not render for the fetcher; verify): `NSMotionUsageDescription` formally covers Motion & Fitness data (CMMotionActivityManager, CMPedometer); raw CMMotionManager accelerometer/gyro historically need no prompt. Multiple third-party skill docs say the key is nonetheless "effectively required" and raw sensors show no prompt — [tessl core-motion summary](https://tessl.io/registry/dpearson2699/swift-ios-skills/3.9.0/files/skills/core-motion/SKILL.md) (third-party, not Apple)
- Apple (unverified, general knowledge): simulator has no Core Motion sensor data; availability checks fail, test on device; one CMMotionManager per app — [Apple CMMotionManager](https://developer.apple.com/documentation/coremotion/cmmotionmanager)

### Inferences
- Add the `NSMotionUsageDescription` string regardless (plugin requirement since 6.0.0); no runtime prompt is expected for raw accelerometer on iOS, but confirm on a real device.
- A 50 Hz `gameInterval` request is far below Android's 200 Hz cap, so `HIGH_SAMPLING_RATE_SENSORS` is unnecessary. Decorative tilt does not need >30 Hz; `uiInterval` (~15 Hz) plus Dart-side per-frame smoothing (Ticker at display rate) is likely enough and cheapest. Interpolating between 15 Hz samples via the ease step removes steppiness.
- Emulators/simulators: Android emulator offers virtual sensors (Extended controls) — not verified from a source here; iOS Simulator delivers none, so the stream may emit nothing or error. Design for "no events ever": idle drift must be the default state, and it must work on Web/desktop where there is no stream or the stream errors (catch with `onError`, and gate with `kIsWeb`/platform checks).
- Testing in flutter_test: inject a `Stream<AccelerometerEvent>`-like source (a small `TiltSource` interface, constructor-injected, defaulting to the sensors_plus stream) and drive it with a `StreamController`. No sensors_plus mocking needed. `AccelerometerEvent(x, y, z, timestamp)` is constructible in tests (6.0.0 added timestamp; check constructor signature in the installed version). Fixed clock/`dt` passed in makes the filter deterministic.

### Gaps
- Real measured delivery rates per platform for each SensorInterval (no authoritative source found; Android docs say hint only). Measure on device via event timestamps.
- Quantified battery cost of accelerometer at 15 vs 50 Hz: no source found; only qualitative "larger delay = less power".
- Whether iOS plugin actually honours samplingPeriod for accelerometer (README only discusses barometer); no GitHub issue found.
- Android emulator virtual sensors and iOS Simulator behaviour: no primary source fetched (Apple page did not render).
- Apple's official statement on NSMotionUsageDescription scope: not retrieved.

## 2. Best signal for a "tilt light", gravity-to-tilt math, recentring

### Takeaway
Accelerometer gravity vector (low-pass filtered) is the best fit: one stream, no integration drift, gives absolute pitch/roll, and is cheap. Gyro integration drifts and needs fusion; platform fused orientation is not exposed by sensors_plus. Use a slow-adapting neutral pose for recentring.

### Cited Findings
- `accelerometerEvents` includes gravity; `userAccelerometerEvents` has gravity filtered out; gyroscope gives device rotation rate — [pub.dev](https://pub.dev/packages/sensors_plus)
- Apple's `CMDeviceMotion` fuses sensors into attitude/gravity (not exposed by sensors_plus) — [Apple CMMotionManager](https://developer.apple.com/documentation/coremotion/cmmotionmanager) (general-knowledge summary, unverified)

### Inferences
(All math below is my own derivation/standard practice, not from a fetched source; unit-test it.)
- Signal choice: for a light highlight that follows how the phone is held, use gravity from `accelerometerEventStream`. Gyro measures rate; integrating it drifts, and complementary fusion adds code for little benefit with a decorative effect. Skip gyro.
- Axes (device frame, portrait; Android convention, iOS values in sensors_plus are normalised to the same sign convention per the watchOS package note): at rest, accel ≈ gravity reaction. Flat face-up: (0, 0, +9.8). Upright portrait: (0, +9.8, 0).
- Normalise: g = (x,y,z)/|(x,y,z)|; skip sample if |a| is far from 9.8 (e.g. outside 7 to 12.5) because shaking/free-fall makes it meaningless.
- Roll (left/right tilt): `roll = atan2(gx, sqrt(gy²+gz²))`; pitch (forward/back): `pitch = atan2(gy, gz)` has a singularity when flat-ish; the safer form is `pitch = atan2(-gy... )` relative to a rest angle: compute pitch from `atan2(gy, gz)` in the range of normal holding (phone tilted 30 to 60 degrees from flat, gz stays positive-ish and well-conditioned). Handle wrap by taking the difference to the neutral and wrapping into (-pi, pi].
- Resting hold angle: store neutral = (rollN, pitchN) rather than hard-coding 30 to 45 degrees; the tilt is `dRoll = wrap(roll - rollN)`, `dPitch = wrap(pitch - pitchN)`.
- Normalise: `tx = clamp(dRoll / range, -1, 1)`, `ty = clamp(dPitch / range, -1, 1)` with range about 20 to 25 degrees (0.35 to 0.45 rad) for "full" deflection so subtle hand movement gives full range only on deliberate tilt.
- Auto-recentre: slowly pull neutral toward current pose with a very long time constant (about 8 to 15 s) and only while the phone is still (|gyro| not available, so use variance of recent gravity below threshold). Alternatively let the neutral track at tau of 10 s always; the user then sees tilt as a high-pass signal, which also fixes different people's hold angles. Reset neutral on resume from background.
- Flat on a table: gz ≈ 1 and gx, gy ≈ 0, so roll/pitch are noisy and tiny; they do not blow up with the formulas above, but if the neutral was learned in hand, flat reads as a large pitch offset. Detect flat (`|gz| > 0.95`, i.e. within ~18 degrees of horizontal) and fade tilt output to 0 and fall back to idle drift; do not recalibrate neutral while flat. Also fade to idle if the phone is face-down (gz < 0) or upside-down.
- Screen orientation: if the app allows landscape, swap/negate axes by orientation; simplest is to lock portrait for the effect or fall back to idle drift in landscape.

### Gaps
- No primary source fetched for gravity-to-tilt formulas or complementary-filter articles; formulas above are standard but unverified by citation. Unit-test with known poses.
- Exact sign conventions for iOS vs Android in sensors_plus not verified; test on both devices.

## 3. Smoothing, deadzone, clamp, frame-rate independence, feel

### Takeaway
Filter in two stages: sensor-rate low-pass on gravity, then a per-frame critically-damped or exponential approach on the output with alpha derived from dt. Slow time constants (about 0.15 to 0.4 s) feel Apple-like.

### Cited Findings
- None fetched directly. Android docs advise keeping sensor callbacks short and doing filtering outside — [Android docs](https://developer.android.com/develop/sensors-and-location/sensors/sensors_overview)

### Inferences
(Standard techniques; my recommendations, not from a cited source.)
- Frame-rate independent exponential smoothing: `alpha = 1 - exp(-dt / tau)`; `value += (target - value) * alpha`. Use dt from the Ticker's elapsed delta (clamp dt to ≤ 0.1 s after a pause).
- Stage 1 (gravity): tau about 0.1 to 0.2 s (removes hand tremor and sensor noise). At 15 Hz sampling (dt ≈ 0.067) that is alpha about 0.3 to 0.5 per sample; at 50 Hz (dt = 0.02) alpha about 0.1 to 0.18. Compute from timestamps instead of hard-coding.
- Stage 2 (display): tau about 0.25 to 0.4 s for a slow, soft, Apple-like parallax; a spring (stiffness ~60, damping ~ critical) gives gentle overshoot-free settle if preferred.
- Deadzone: about 1 to 2 degrees (or 0.03 to 0.05 of normalised range) with soft knee, i.e. subtract the deadzone and rescale, not a hard cut, to avoid a visible jump.
- Clamp output to [-1,1]; apply a soft curve (e.g. `tanh` or `x*(1.5-0.5x²)`) near the limits so the light does not hit a wall.
- Subtle: keep the visual amplitude small (light shifts a few percent of widget size); depth comes from slow response, not big excursions.
- Blend with idle drift: `out = lerp(idle(t), tilt, w)` where `w` eases 0↔1 over about 0.6 to 1.0 s depending on sensor availability, flat-on-table, reduce motion, and recent-event freshness (no event for >1 s sets w to 0). Idle drift = slow Lissajous, e.g. `(sin(0.13t)*0.35, cos(0.09t)*0.25)`.

### Gaps
- No cited source for "Apple-like" timing constants; values are design judgement to tune on device.

## 4. Accessibility, lifecycle, battery, privacy, user setting

### Takeaway
Honour both `MediaQuery.disableAnimations` and (on iOS) `reduceMotion`; they are separate flags in Flutter. Cancel the stream when backgrounded or the screen is hidden, since neither OS reliably does it for you. Offer an in-app toggle; no data leaves the device.

### Cited Findings
- `MediaQueryData.disableAnimations` is read-only bool: platform asks animations be "disabled or reduced as much as possible"; framework animation APIs (AnimationController) honour it, but custom animations must check it themselves — [MediaQueryData.disableAnimations](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html)
- Flutter docs/PR: `disableAnimations` corresponds to Android's "Remove animations"; iOS "Reduce Motion" is exposed separately as `dart:ui AccessibilityFeatures.reduceMotion`, which is iOS-only: "requesting that certain animations be simplified and parallax effects removed" — [reduceMotion API](https://api.flutter.dev/flutter/dart-ui/AccessibilityFeatures/reduceMotion.html); [Flutter commit adding MediaQueryData.reduceMotion, dated 2026-07-31](https://flutter.googlesource.com/mirrors/flutter/+/5b75e35fafa71ee952283051cc37b60f8e7a4f4b%5E)
- A forum report states that with iOS Reduce Motion on, `MediaQuery.disableAnimations` returned false while Android returned true — [itsallwidgets forum](https://forum.itsallwidgets.com/t/should-flutter-honor-ioss-reduce-motion-option-in-accessibility-settings/4657)
- Android: unregister sensor listeners in onPause; sensors not auto-disabled on screen off; background apps (API 28+) receive no continuous-sensor events — [Android docs](https://developer.android.com/develop/sensors-and-location/sensors/sensors_overview)
- Generic guidance: cancel the stream subscription (e.g. in `dispose()`) and pick the lowest interval you can — [all_device_sensors docs](https://pub.dev/documentation/all_device_sensors/1.0.1/) (weak, generic source)
- Parallax is the motion type Apple's Reduce Motion targets ("parallax effects removed" in Flutter's own doc above).

### Inferences
- Treat tilt-driven light as parallax: if `disableAnimations || reduceMotion` is true, output a static neutral (0,0) with no idle drift (or a very slow fade-only alternative, e.g. fixed highlight position), and do not subscribe to sensors at all. Because `MediaQueryData.reduceMotion` may not yet be in the stable channel (the commit is dated July 2026; version not confirmed), read `WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.reduceMotion` directly and re-evaluate on `didChangeAccessibilityFeatures` (WidgetsBindingObserver).
- Lifecycle: use `WidgetsBindingObserver.didChangeAppLifecycleState`; cancel the sensor subscription on `inactive/paused/hidden`, resubscribe on `resumed`, and reset the neutral. Also stop when the tilt widget is not visible (route covered, tab not selected): use `TickerMode`/route-aware state, and stop the Ticker too so no frames are scheduled.
- Battery/thermal: 15 Hz accelerometer is negligible next to the screen; real cost is repaint at display refresh. Stop the Ticker when the value has settled and there is no idle drift needed (e.g. when reduced motion), and consider lowering idle drift to 30 fps. Pause on `ProcessInfo.thermalState`/low-power mode only if exposed (not in sensors_plus; no source found).
- Privacy: accelerometer used only locally, never logged or sent; mention in the privacy policy / Info.plist string (e.g. "Motion is used to tilt the light on cards. It never leaves your device.").
- Setting: a persisted "Motion effects" toggle (On / Off, default On unless reduce motion); when off, do not subscribe.

### Gaps
- Whether `MediaQueryData.reduceMotion` is merged into stable Flutter and which version: the commit page gives no release number. Check installed Flutter SDK source.
- Verification that `disableAnimations` is false on iOS with Reduce Motion enabled in current Flutter is only from one older forum post; test on device.
- No Apple HIG/WWDC source fetched for Reduce Motion and parallax guidance.

## 5. Performance: rebuilds, repaint, BackdropFilter

### Takeaway
Publish tilt through a `ValueNotifier<Offset>` and let `CustomPainter(repaint: notifier)` (or `ValueListenableBuilder` around a tiny subtree) redraw only the highlight; isolate with `RepaintBoundary`; keep `BackdropFilter` areas small and static, grouped, and clipped.

### Cited Findings
- Localize `setState`; pass unchanging subtrees as `child` to `AnimatedBuilder` so the framework stops traversal; keep `build()` cheap — [Flutter performance best practices](https://docs.flutter.dev/perf/best-practices)
- `saveLayer()` is costly on mobile GPUs; avoid `Opacity` wrappers (use alpha colours or `AnimatedOpacity`), and clipping is costly in animations — [Flutter performance best practices](https://docs.flutter.dev/perf/best-practices)
- `BackdropFilter` is "relatively expensive, especially if the filter is non-local, such as a blur"; wrap in `ClipRect` to bound the area; `BackdropFilter.grouped` / `BackdropKey` combines several filters into one backdrop operation; `ImageFiltered` is cheaper for a single widget — [BackdropFilter API](https://api.flutter.dev/flutter/widgets/BackdropFilter-class.html)
- Frame budget: aim for ≤8 ms on each of UI and raster threads on 60 Hz — [Flutter performance best practices](https://docs.flutter.dev/perf/best-practices)

### Inferences
- Architecture: `TiltController` (owns subscription, filter, Ticker, `ValueNotifier<Offset>`) in `lib/features/` or a provider; widgets in `lib/ui/` stay stateless and receive a `ValueListenable<Offset>` (or `Listenable`) as a value. This matches the repo rule: no providers inside `lib/ui/`.
- Use `CustomPainter(repaint: tilt)` so only paint (not build/layout) runs per frame; add `RepaintBoundary` around the animated highlight layer so it does not dirty the glass blur beneath/above it.
- Important interaction: if the moving highlight sits inside or under a `BackdropFilter` region, every frame re-runs the blur (the backdrop changed). Keep the moving light above the blur layer in its own RepaintBoundary, or move the highlight only in a layer that the blur does not sample.
- Do not notify when change is below a small epsilon (e.g. 0.002) to avoid pointless repaints.
- Verify in profile mode with DevTools (repaint rainbow, saveLayer count) on a real device.

### Gaps
- No measured cost numbers for BackdropFilter on specific devices (not found).
- Docs did not give explicit RepaintBoundary guidance (the fetched summary used general knowledge); confirm against [RepaintBoundary API](https://api.flutter.dev/flutter/widgets/RepaintBoundary-class.html).
