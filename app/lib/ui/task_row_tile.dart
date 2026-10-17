import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// A task row: ember fill that grows with [progress], title, weight label and
/// an optional [sweep] overlay. Pure presentation; hold logic lives in
/// `features/strike/hold_to_strike.dart`.
class TaskRowTile extends StatelessWidget {
  const TaskRowTile({
    super.key,
    required this.title,
    required this.weightLabel,
    required this.isDone,
    required this.progress,
    this.sweep,
    this.trailing,
    this.deadline,
  });

  final String title;
  final String weightLabel;
  final bool isDone;

  /// Hold progress, 0..1.
  final double progress;

  /// Drawn over the fill while a strike lands; null when idle.
  final Widget? sweep;
  final Widget? trailing;

  /// The commitment's chip, when the task is promised today.
  final Widget? deadline;

  /// Past this much of the hold the charge is full: the row glints white.
  static const readyAt = 0.85;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final isReady = !isDone && progress >= readyAt;
    // The slash sits outside the done-row fade so the cut lands at full
    // strength, and its flecks may fly past the row's edge.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _row(context, text, isReady),
        if (sweep case final sweep?)
          Positioned.fill(
            top: 4,
            bottom: 4,
            child: IgnorePointer(child: sweep),
          ),
      ],
    );
  }

  Widget _row(BuildContext context, TextTheme text, bool isReady) {
    return AnimatedOpacity(
      opacity: isDone ? 0.35 : 1,
      duration: motionOf(context, kSlowFade),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: const BoxConstraints(minHeight: kMinTarget),
        decoration: BoxDecoration(
          color: kSurface,
          border: Border.all(
            color: isReady ? kDust : kAshDim.withValues(alpha: 0.45),
          ),
          boxShadow: isReady
              ? [
                  BoxShadow(
                    color: kDust.withValues(alpha: 0.45),
                    blurRadius: 22,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Ember fill grows across the row during the hold.
            Positioned.fill(
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: isDone ? 1 : progress,
                child: ColoredBox(
                  color: kEmber.withValues(alpha: isDone ? 0.08 : 0.25),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: trailing == null ? 16 : 0,
                top: trailing == null ? 14 : 0,
                bottom: trailing == null ? 14 : 0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: text.bodyMedium?.copyWith(
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        decorationColor: kEmber,
                      ),
                    ),
                  ),
                  ?deadline,
                  Text(weightLabel, style: text.bodySmall),
                  ?trailing,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
