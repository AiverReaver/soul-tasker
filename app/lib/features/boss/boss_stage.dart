import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../ui/boss_art.dart';
import '../shell/atmosphere.dart';

/// The boss on its screen: hand-drawn, boiling with the atmosphere, and
/// struck white whenever its [health] drops. The flash waits for the row's
/// slash to reach its hit-stop, so both land on the same beat.
class BossStage extends StatefulWidget {
  const BossStage({super.key, required this.health});

  /// Remaining health, 0..1.
  final double health;

  @override
  State<BossStage> createState() => _BossStageState();
}

class _BossStageState extends State<BossStage>
    with SingleTickerProviderStateMixin {
  // Wait, burn white, then recoil and settle on fives.
  static const _run = Duration(milliseconds: 700);
  static const _whiteFrom = 0.25, _recoilFrom = 0.45;

  late final AnimationController _hit = AnimationController(
    vsync: this,
    duration: _run,
  );

  @override
  void didUpdateWidget(BossStage old) {
    super.didUpdateWidget(old);
    if (widget.health < old.health && motionOf(context, _run) > Duration.zero) {
      _hit.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _hit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boil = Atmosphere.boilFrameOf(context);
    return Center(
      child: AnimatedBuilder(
        animation: _hit,
        builder: (context, _) {
          final t = _hit.value;
          final isStruck = _hit.isAnimating;
          final isWhite = isStruck && t >= _whiteFrom && t < _recoilFrom;
          // Thrown back, then drawn back upright in five held steps.
          final settle = ((t - _recoilFrom) / (1 - _recoilFrom) * 5).ceil();
          final recoil = isStruck && t >= _recoilFrom
              ? 14 * (1 - settle.clamp(0, 5) / 5)
              : 0.0;
          return Transform.translate(
            offset: Offset(recoil, 0),
            child: Transform.rotate(
              angle: recoil * 0.004,
              alignment: Alignment.bottomCenter,
              child: BossArt(boilFrame: boil, hit: isWhite ? 1 : 0, width: 165),
            ),
          );
        },
      ),
    );
  }
}
