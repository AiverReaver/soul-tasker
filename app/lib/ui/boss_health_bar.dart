import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// Segmented boss health bar (§8.1). One segment per one-time phase task,
/// wider gaps between phases. Struck segments drain slowly.
class BossHealthBar extends StatelessWidget {
  const BossHealthBar({
    super.key,
    required this.groups,
    required this.health,
    this.height = 10,
  });

  /// Alive flag per segment, grouped by phase.
  final List<List<bool>> groups;

  /// Remaining health, 0..1 (spoken label).
  final double health;
  final double height;

  static const _taskGap = 2.0;
  static const _phaseGap = 8.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Boss health ${(health * 100).round()} percent',
      child: Row(
        children: [
          for (final (i, group) in groups.indexed) ...[
            if (i > 0) const SizedBox(width: _phaseGap),
            Expanded(
              flex: group.length,
              child: Row(
                children: [
                  for (final (j, isAlive) in group.indexed) ...[
                    if (j > 0) const SizedBox(width: _taskGap),
                    Expanded(
                      child: _Segment(isAlive: isAlive, height: height),
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
