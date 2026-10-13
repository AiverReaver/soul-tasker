import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/boss_view.dart';

/// Segmented boss health bar (§8.1). One segment per one-time phase task,
/// wider gaps between phases. Struck segments drain slowly.
class BossHealthBar extends StatelessWidget {
  const BossHealthBar({super.key, required this.view, this.height = 10});

  final BossView view;
  final double height;

  static const _taskGap = 2.0;
  static const _phaseGap = 8.0;

  @override
  Widget build(BuildContext context) {
    final groups = [
      for (final p in view.phases)
        [
          for (final t in p.tasks)
            if (t.isSegment) t,
        ],
    ].where((g) => g.isNotEmpty).toList();

    return Semantics(
      label: 'Boss health ${(view.health * 100).round()} percent',
      child: Row(
        children: [
          for (final (i, group) in groups.indexed) ...[
            if (i > 0) const SizedBox(width: _phaseGap),
            Expanded(
              flex: group.length,
              child: Row(
                children: [
                  for (final (j, task) in group.indexed) ...[
                    if (j > 0) const SizedBox(width: _taskGap),
                    Expanded(
                      child: _Segment(isAlive: !task.isStruck, height: height),
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
  const _Segment({required this.isAlive, required this.height});

  final bool isAlive;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: kAshDim.withValues(alpha: 0.25),
      alignment: Alignment.centerLeft,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: isAlive ? 1 : 0),
        duration: motionOf(context, Motion.drain),
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
