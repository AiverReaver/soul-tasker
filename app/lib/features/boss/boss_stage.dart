import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../ui/boss_art.dart';
import '../shell/atmosphere.dart';

/// The boss on its screen: hand-drawn, boiling with the atmosphere, and
/// struck white whenever its [health] drops. The flash waits for the row's
/// slash to reach its hit-stop, so both land on the same beat. [stamp] sets
/// the "Struck" stamp on it; [felled] has it kneel when a phase's last foe
/// falls.
class BossStage extends StatefulWidget {
  const BossStage({
    super.key,
    required this.health,
    this.stamp = false,
    this.felled = false,
  });

  /// Remaining health, 0..1.
  final double health;

  /// Stamp "Struck" on the boss: 700 ms in 4 held steps, ending at -5 degrees.
  final bool stamp;

  /// The kneel: 1.4 s in 7 held steps to half opacity.
  final bool felled;

  @override
  State<BossStage> createState() => _BossStageState();
}

class _BossStageState extends State<BossStage> with TickerProviderStateMixin {
  // Wait, burn white, then recoil and settle on fives.
  static const _run = Duration(milliseconds: 700);
  static const _whiteFrom = 0.25, _recoilFrom = 0.45;

  late final AnimationController _hit = AnimationController(
    vsync: this,
    duration: _run,
  );
  late final AnimationController _stamp = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final AnimationController _kneel = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  /// Held steps: the value snaps to n ths, like a redrawn cel.
  static double _held(double v, int steps) =>
      v >= 1 ? 1 : (v * steps).floor() / steps;

  @override
  void initState() {
    super.initState();
    // Already stamped or kneeling on first show: rest at the end.
    if (widget.stamp) _stamp.value = 1;
    if (widget.felled) _kneel.value = 1;
  }

  void _play(AnimationController c) {
    if (motionOf(context, c.duration!) > Duration.zero) {
      c.forward(from: 0);
    } else {
      c.value = 1;
    }
  }

  @override
  void didUpdateWidget(BossStage old) {
    super.didUpdateWidget(old);
    if (widget.stamp && !old.stamp) _play(_stamp);
    if (!widget.stamp && old.stamp) _stamp.value = 0;
    if (widget.felled && !old.felled) _play(_kneel);
    if (!widget.felled && old.felled) _kneel.value = 0;
    if (widget.health < old.health && motionOf(context, _run) > Duration.zero) {
      _hit.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _hit.dispose();
    _stamp.dispose();
    _kneel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boil = Atmosphere.boilFrameOf(context);
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_hit, _kneel]),
        builder: (context, _) {
          final t = _hit.value;
          final isStruck = _hit.isAnimating;
          final isWhite = isStruck && t >= _whiteFrom && t < _recoilFrom;
          // Thrown back, then drawn back upright in five held steps.
          final settle = ((t - _recoilFrom) / (1 - _recoilFrom) * 5).ceil();
          final recoil = isStruck && t >= _recoilFrom
              ? 14 * (1 - settle.clamp(0, 5) / 5)
              : 0.0;
          final k = _held(_kneel.value, 7);
          return Opacity(
            key: const ValueKey('boss-felled'),
            opacity: 1 - 0.5 * k,
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..translateByDouble(0, 16 * k, 0, 1)
                ..scaleByDouble(1 + 0.04 * k, 1 - 0.14 * k, 1, 1),
              child: Transform.translate(
                offset: Offset(recoil, 0),
                child: Transform.rotate(
                  angle: recoil * 0.004,
                  alignment: Alignment.bottomCenter,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      BossArt(
                        boilFrame: boil,
                        hit: isWhite ? 1 : 0,
                        width: 165,
                      ),
                      if (widget.stamp) _stampMark(context),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// The italic "Struck": in at 1.6 and -8 degrees, down to 0.94 by 30%, then
  /// resting at -5 degrees, all on four held steps.
  Widget _stampMark(BuildContext context) => AnimatedBuilder(
    animation: _stamp,
    builder: (context, _) {
      final p = context.palette;
      final v = _held(_stamp.value, 4);
      final land = (v / 0.3).clamp(0.0, 1.0);
      final scale = v < 0.3 ? 1.6 + (0.94 - 1.6) * land : 1.0;
      final degrees = -8 + 3 * land;
      const size = 52.0;
      final base = Theme.of(context).textTheme.displaySmall!
          .copyWith(fontSize: size, fontStyle: FontStyle.italic);
      return Opacity(
        opacity: v == 0 ? 0 : 1,
        child: Transform.rotate(
          key: const ValueKey('boss-stamp-rotate'),
          angle: degrees * math.pi / 180,
          child: Transform.scale(
            key: const ValueKey('boss-stamp-scale'),
            scale: scale,
            child: Stack(
              children: [
                Text(
                  'Struck',
                  style: base.copyWith(
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 1.5
                      ..color = p.ink,
                  ),
                ),
                Text('Struck', style: base.copyWith(color: p.bone)),
              ],
            ),
          ),
        ),
      );
    },
  );
}
