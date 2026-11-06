import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'needle_frame.dart';
import 'shard_meter.dart';

/// The Day's panel on its boss screen: the name, what it is for, and its
/// health, one shard per task of today still [open] out of [total].
class DayPanel extends StatelessWidget {
  const DayPanel({super.key, required this.open, required this.total});

  final int open;
  final int total;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final note = text.bodySmall!.copyWith(color: p.ash);
    return NeedleFrame(
      key: const ValueKey('day-panel'),
      edge: p.deep,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [p.raised2, p.shell],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text('The Day', style: text.displaySmall),
                  Text(
                    'Quick tasks live here. It refills every morning.',
                    style: text.bodyMedium!.copyWith(color: p.ash),
                  ),
                ],
              ),
              if (total == 0)
                Text(
                  'Nothing here yet. Add a quick task and it fights here '
                  'today.',
                  style: note,
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('Day health', style: text.labelSmall),
                        ),
                        Text('$open / $total open', style: text.bodySmall),
                      ],
                    ),
                    ShardMeter(
                      filled: open,
                      total: total,
                      semanticLabel:
                          'Day health: $open of $total tasks still open',
                    ),
                    Text(
                      'Health is today’s tasks still open. Strike them all '
                      'and it empties. It never ends in victory or a fall.',
                      style: note,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
