import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import '../core/weathering.dart';
import 'relic_emblem.dart';

/// One relic in the hall: emblem, name, and the day it was won.
class RelicTile extends StatelessWidget {
  const RelicTile({
    super.key,
    required this.name,
    required this.weathering,
    required this.dateLabel,
    required this.onTap,
  });

  final String name;
  final Weathering weathering;
  final String dateLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: '$name, $dateLabel',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: kMinTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.sm),
            child: Row(
              children: [
                RelicEmblem(weathering: weathering, size: 48),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: text.titleMedium),
                      Text(dateLabel, style: text.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
