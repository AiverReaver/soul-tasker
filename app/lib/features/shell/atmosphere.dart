import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/glass_tilt.dart';
import '../../ui/pharloom_backdrop.dart';

/// The app's one ambient clock. It drifts the backdrop's motes and steps
/// the boil of hand-drawn ink, and eases the shared [GlassTilt] along its
/// idle drift. It holds still under reduced motion and when
/// [isStill] (tests), so nothing waits on a loop that never ends.
class Atmosphere extends StatefulWidget {
  const Atmosphere({super.key, required this.child, this.isStill = false});

  final Widget child;
  final bool isStill;

  static const loop = Duration(seconds: 42);

  /// How long ink holds one drawing before the next hand takes over.
  static const boilStep = Duration(milliseconds: 140);

  /// Which of three boil drawings ink is on now: 0 while still, and outside
  /// any atmosphere.
  static int boilFrameOf(BuildContext context) {
    final clock = context
        .dependOnInheritedWidgetOfExactType<_Clock>()
        ?.notifier;
    if (clock == null) return 0;
    final ms = clock.value * loop.inMilliseconds;
    return (ms ~/ boilStep.inMilliseconds) % 3;
  }

  @override
  State<Atmosphere> createState() => _AtmosphereState();
}

class _AtmosphereState extends State<Atmosphere> with TickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: Atmosphere.loop,
  );
  final _tilt = ValueNotifier(Offset.zero);
  late final Ticker _tiltTicker = createTicker(_driftTilt);
  Duration _lastTick = Duration.zero;

  void _driftTilt(Duration elapsed) {
    _tilt.value = easeTilt(_tilt.value, idleTilt(elapsed), elapsed - _lastTick);
    _lastTick = elapsed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(Atmosphere old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.isStill || MediaQuery.disableAnimationsOf(context)) {
      _clock
        ..stop()
        ..value = 0;
      _tiltTicker.stop();
      _tilt.value = Offset.zero;
    } else if (!_clock.isAnimating) {
      _clock.repeat();
      _lastTick = Duration.zero;
      _tiltTicker.start();
    }
  }

  @override
  void dispose() {
    _tiltTicker.dispose();
    _tilt.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GlassTilt(
    notifier: _tilt,
    child: _Clock(
      notifier: _clock,
      child: AnimatedBuilder(
        animation: _clock,
        builder: (context, child) =>
            PharloomBackdrop(drift: _clock.value, child: child!),
        child: widget.child,
      ),
    ),
  );
}

class _Clock extends InheritedNotifier<AnimationController> {
  const _Clock({required super.notifier, required super.child});
}
