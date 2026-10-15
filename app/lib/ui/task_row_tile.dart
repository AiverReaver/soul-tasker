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

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AnimatedOpacity(
      opacity: isDone ? 0.35 : 1,
      duration: motionOf(context, kSlowFade),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: const BoxConstraints(minHeight: kMinTarget),
        decoration: BoxDecoration(
          color: kSurface,
          border: Border.all(color: kAshDim.withValues(alpha: 0.3)),
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
            if (sweep case final sweep?)
              Positioned.fill(child: IgnorePointer(child: sweep)),
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
