import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

/// The glass light's idle drift at [elapsed]: x = sin(0.7 t) × 0.8,
/// y = cos(0.5 t) × 0.5, so both axes stay inside −1 to 1.
Offset idleTilt(Duration elapsed) {
  final t = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
  return Offset(math.sin(0.7 * t) * 0.8, math.cos(0.5 * t) * 0.5);
}

/// Moves [current] toward [target] by 12% per 60 Hz frame, scaled by [dt]
/// so the easing looks the same at any frame rate.
Offset easeTilt(Offset current, Offset target, Duration dt) {
  const frame = Duration.microsecondsPerSecond / 60;
  final k = 1 - math.pow(0.88, dt.inMicroseconds / frame);
  return Offset.lerp(current, target, k.toDouble())!;
}

/// The glass light, shared by every glass surface on screen: one [Offset]
/// from −1 to 1 on each axis. `Atmosphere` owns the notifier; glass widgets
/// in `lib/ui/` read it with [GlassTilt.of], like they read `context.palette`.
class GlassTilt extends InheritedWidget {
  const GlassTilt({super.key, required this.notifier, required super.child});

  final ValueListenable<Offset> notifier;

  /// The tilt above [context], or a still zero. It does not rebuild the
  /// caller: listen to the result where the light is painted.
  static ValueListenable<Offset> of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<GlassTilt>()?.notifier ?? _still;

  static const _still = _StillTilt();

  @override
  bool updateShouldNotify(GlassTilt old) => notifier != old.notifier;
}

class _StillTilt implements ValueListenable<Offset> {
  const _StillTilt();

  @override
  Offset get value => Offset.zero;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}
