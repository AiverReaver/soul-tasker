import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'needle_frame.dart';

/// "Tomorrow’s foes": how many are chosen and the first titles, with a
/// chevron. Tapping opens the picker.
class TomorrowRow extends StatelessWidget {
  const TomorrowRow({
    super.key,
    required this.titles,
    required this.onTap,
    this.max = 3,
  });

  final List<String> titles;
  final VoidCallback onTap;
  final int max;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final count = '${titles.length} of $max chosen';
    final summary = titles.isEmpty
        ? count
        : '$count · ${titles.take(2).join(', ')}';
    return Semantics(
      button: true,
      label: 'Tomorrow’s foes, $summary',
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: NeedleFrame(
          tier: Cut.md,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: kMinTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.md,
                vertical: Space.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tomorrow’s foes',
                          style: text.bodyMedium!.copyWith(color: p.bone),
                        ),
                        Text(summary, style: text.bodySmall),
                      ],
                    ),
                  ),
                  Text(' ›', style: TextStyle(color: p.ash, fontSize: 22)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
