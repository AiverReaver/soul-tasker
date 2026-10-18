import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../core/glass_tilt.dart';

/// A gravity reading, in any unit: only its direction is used.
typedef Gravity = (double x, double y, double z);

/// Where gravity readings come from. A fake in tests.
abstract interface class TiltSource {
  Stream<Gravity> get gravity;
}

/// The phone's accelerometer, at the UI rate (about 15 Hz). Gravity is enough
/// for a decorative light, and needs no Android permission at this rate.
class SensorsTiltSource implements TiltSource {
  const SensorsTiltSource();

  @override
  Stream<Gravity> get gravity =>
      accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval)
          .map((e) => (e.x, e.y, e.z));
}

/// Turns gravity readings into the glass light, blended over the idle drift.
///
/// Apple publishes no numbers for its motion-reactive light, so these are
/// tuning values: see V41_PLAN.md D3b.
class TiltController {
  TiltController(this._source);

  final TiltSource _source;
  StreamSubscription<Gravity>? _sub;

  static const _sensorTau = 0.15; // seconds: smooths the raw readings
  static const _neutralTau = 10.0; // seconds: the held pose becomes centre
  static const _fadeSeconds = 0.8;
  static const _silence = Duration(seconds: 1);

  Duration _now = Duration.zero;
  Duration? _lastEvent;
  Gravity? _gravity;
  Offset _neutral = Offset.zero;
  bool _hasNeutral = false;
  bool _isFlat = false;
  double _weight = 0;

  bool get isListening => _sub != null;

  void start() {
    if (_sub != null) return;
    _hasNeutral = false; // a resume re-centres on the pose it finds
    _gravity = null;
    _lastEvent = null;
    _sub = _source.gravity.listen(_onSample, onError: (_) {});
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    _weight = 0;
  }

  void _onSample(Gravity g) {
    final last = _lastEvent;
    final dt = last == null ? 0.0 : (_now - last).inMicroseconds / 1e6;
    _lastEvent = _now;
    final prev = _gravity;
    final a = prev == null ? 1.0 : 1 - math.exp(-dt / _sensorTau);
    final f = prev == null
        ? g
        : (
            prev.$1 + (g.$1 - prev.$1) * a,
            prev.$2 + (g.$2 - prev.$2) * a,
            prev.$3 + (g.$3 - prev.$3) * a,
          );
    _gravity = f;
    _isFlat = isFlatGravity(f.$1, f.$2, f.$3);
    if (_isFlat) return;
    final angles = gravityAngles(f.$1, f.$2, f.$3);
    if (!_hasNeutral) {
      _neutral = angles;
      _hasNeutral = true;
      return;
    }
    final k = 1 - math.exp(-dt / _neutralTau);
    _neutral = Offset(
      _neutral.dx + angleDelta(angles.dx, _neutral.dx) * k,
      _neutral.dy + angleDelta(angles.dy, _neutral.dy) * k,
    );
  }

  /// The light for the frame at [now] ([dt] after the last one), with [idle]
  /// as the drift it falls back to.
  Offset step(Duration now, Duration dt, Offset idle) {
    _now = now;
    final g = _gravity;
    final last = _lastEvent;
    final hasSignal =
        g != null && last != null && now - last < _silence && !_isFlat;
    final move = dt.inMicroseconds / 1e6 / _fadeSeconds;
    _weight = (_weight + (hasSignal ? move : -move)).clamp(0.0, 1.0);
    if (g == null || _weight == 0) return idle;
    final tilt = tiltFromAngles(gravityAngles(g.$1, g.$2, g.$3), _neutral);
    return blendTilt(idle, tilt, _weight);
  }
}
