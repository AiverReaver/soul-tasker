import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import '../data/enums.dart';
import 'relic_tile.dart';

/// What the hall needs to draw one relic.
class HallEntry {
  const HallEntry({
    required this.id,
    required this.name,
    required this.weathering,
    required this.dateLabel,
  });

  final String id;
  final String name;
  final Weathering weathering;
  final String dateLabel;
}

/// The relics, most recent first, or one quiet line when there are none.
class HallOfRelics extends StatelessWidget {
  const HallOfRelics({super.key, required this.entries, required this.onOpen});

  final List<HallEntry> entries;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.md),
        child: Text(
          'No foes vanquished yet. The first relic awaits.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return Column(
      children: [
        for (final e in entries)
          RelicTile(
            name: e.name,
            weathering: e.weathering,
            dateLabel: e.dateLabel,
            onTap: () => onOpen(e.id),
          ),
      ],
    );
  }
}
