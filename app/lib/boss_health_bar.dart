import 'package:flutter/material.dart';

import 'models.dart';
import 'theme.dart';

/// Segmented boss health bar (§8.1). One segment per task, wider gaps
/// between phases. Struck segments drain slowly instead of vanishing.
class BossHealthBar extends StatelessWidget {
  const BossHealthBar({super.key, required this.boss});

  final Boss boss;

  static const _taskGap = 2.0;
  static const _phaseGap = 8.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Boss health ${(boss.health * 100).round()} percent',
      child: Row(
        children: [
          for (var p = 0; p < boss.phases.length; p++) ...[
            if (p > 0) const SizedBox(width: _phaseGap),
            Expanded(
              flex: boss.phases[p].tasks.length,
              child: Row(
                children: [
                  for (var t = 0; t < boss.phases[p].tasks.length; t++) ...[
                    if (t > 0) const SizedBox(width: _taskGap),
                    Expanded(
                      child: _Segment(isAlive: !boss.phases[p].tasks[t].isDone),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.isAlive});

  final bool isAlive;

  static const _height = 10.0;
  static const _drain = Motion.drain;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      color: kAshDim.withValues(alpha: 0.25),
      alignment: Alignment.centerLeft,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: isAlive ? 1 : 0),
        duration: _drain,
        curve: Curves.easeInOut,
        builder: (context, value, _) => FractionallySizedBox(
          widthFactor: value,
          heightFactor: 1,
          child: const ColoredBox(color: kBossHealth),
        ),
      ),
    );
  }
}
