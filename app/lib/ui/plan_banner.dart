import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// One planned task in the banner.
@immutable
class PlanItem {
  const PlanItem({
    required this.title,
    required this.bossTitle,
    required this.isDone,
  });

  final String title;
  final String bossTitle;
  final bool isDone;
}

/// "Today's three": the tasks picked at last night's bonfire.
class PlanBanner extends StatelessWidget {
  const PlanBanner({
    super.key,
    required this.items,
    this.title = "TODAY'S THREE",
  });

  final List<PlanItem> items;
  final String title;

  static const _icon = 16.0;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final allDone = items.isNotEmpty && items.every((i) => i.isDone);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: text.labelSmall),
        const SizedBox(height: Space.sm),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.sm),
            child: Row(
              children: [
                if (item.isDone)
                  Icon(
                    Icons.check,
                    key: ValueKey('plan-done'),
                    size: _icon,
                    color: context.palette.ash,
                  )
                else
                  Icon(
                    Icons.circle_outlined,
                    size: _icon,
                    color: context.palette.dim,
                  ),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Text(
                    item.title,
                    style: text.bodyMedium?.copyWith(
                      color: item.isDone ? context.palette.ash : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (allDone) Text('The three are done.', style: text.bodySmall),
      ],
    );
  }
}
