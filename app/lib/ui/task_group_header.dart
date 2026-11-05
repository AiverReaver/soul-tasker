import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// The label above a run of task rows: "THE CERTIFICATION · CHAPTER II ·
/// LEARN", a hairline, then "N of M" struck. The rows below leave out the
/// boss and chapter because this says them once. With [onTap], the label
/// opens its boss.
class TaskGroupHeader extends StatelessWidget {
  const TaskGroupHeader({
    super.key,
    required this.label,
    required this.count,
    this.onTap,
  });

  final String label;
  final String count;
  final VoidCallback? onTap;

  static const _gap = 10.0;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    final countStyle = text.bodySmall!.copyWith(fontSize: 12);
    final countWidth = (TextPainter(
      text: TextSpan(text: count, style: countStyle),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout()).width;
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 6),
      child: LayoutBuilder(
        builder: (context, box) => Row(
          spacing: _gap,
          children: [
            // Not a Flexible: that would split the width evenly with the
            // hairline. The cap leaves room for the count; a longer label
            // wraps, never clips.
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: math.max(0, box.maxWidth - countWidth - 2 * _gap),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: Semantics(
                  button: onTap != null,
                  child: Text(label.toUpperCase(), style: text.labelSmall),
                ),
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: p.seam,
                child: const SizedBox(height: 1),
              ),
            ),
            Text(count, style: countStyle),
          ],
        ),
      ),
    );
  }
}
