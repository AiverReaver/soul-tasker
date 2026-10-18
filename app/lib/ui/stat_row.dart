import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

class Stat {
  const Stat(this.value, this.label);

  final String value;
  final String label;
}

/// Equal columns, each a value over its label, split by seam hairlines.
class StatRow extends StatelessWidget {
  const StatRow({super.key, required this.stats});

  final List<Stat> stats;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    stats[i].value,
                    style: text.bodyLarge?.copyWith(
                      fontSize: 17,
                      height: 24 / 17,
                      fontWeight: FontWeight.w600,
                      color: p.text,
                    ),
                  ),
                  Text(stats[i].label, style: text.bodySmall),
                ],
              ),
            ),
            if (i < stats.length - 1)
              SizedBox(
                key: ValueKey('stat-divider-$i'),
                width: 1,
                child: ColoredBox(color: p.seam),
              ),
          ],
        ],
      ),
    );
  }
}
