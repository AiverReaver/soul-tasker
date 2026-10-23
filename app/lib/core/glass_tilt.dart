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

/// The tilt that moves the light across its full width, in radians.
const _fullTilt = 22 * math.pi / 180;

/// A wobble this small, in radians, does not move the light.
const _deadzone = 1.5 * math.pi / 180;

/// Roll (x) and pitch (y) of the phone from its gravity vector, in radians.
/// Any units work: only the direction of gravity matters.
Offset gravityAngles(double gx, double gy, double gz) =>
    Offset(math.atan2(gx, math.sqrt(gy * gy + gz * gz)), math.atan2(gy, gz));

/// True when the phone lies on a table, face up or down. Its tilt says
/// nothing about how it is held, so the light falls back to the idle drift.
bool isFlatGravity(double gx, double gy, double gz) =>
    gz.abs() / math.sqrt(gx * gx + gy * gy + gz * gz) > 0.95;

/// Wraps [a] into −π…π.
double _wrap(double a) => math.atan2(math.sin(a), math.cos(a));

double _axis(double delta) {
  final d = _wrap(delta);
  if (d.abs() <= _deadzone) return 0;
  return ((d.abs() - _deadzone) / (_fullTilt - _deadzone)).clamp(0, 1) * d.sign;
}

/// The light for a phone at [angles], against the pose it is usually held
/// in ([neutral]): −1…1 on each axis, with a small deadzone.
Offset tiltFromAngles(Offset angles, Offset neutral) =>
    Offset(_axis(angles.dx - neutral.dx), _axis(angles.dy - neutral.dy));

/// Angle difference [a] − [b] the short way round, in radians.
double angleDelta(double a, double b) => _wrap(a - b);

/// [idle] at [weight] 0, [tilt] at 1.
Offset blendTilt(Offset idle, Offset tilt, double weight) =>
    Offset.lerp(idle, tilt, weight)!;

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
