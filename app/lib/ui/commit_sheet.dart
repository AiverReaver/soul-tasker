import 'package:material_ui/material_ui.dart';

import '../core/deadlines.dart';
import '../core/theme.dart';

/// Promise a task by a deadline (§5.12). Switch values come in from the
/// container; tapping a deadline commits.
class CommitSheet extends StatelessWidget {
  const CommitSheet({
    super.key,
    required this.title,
    required this.isDaily,
    required this.remind,
    required this.everyDay,
    required this.onRemindChanged,
    required this.onEveryDayChanged,
    required this.onCommit,
    this.note,
  });

  final String title;

  /// Daily tasks can keep the deadline every day (plan D12).
  final bool isDaily;
  final bool remind;
  final bool everyDay;

  /// The calm note for a heavy day; null for none.
  final String? note;
  final ValueChanged<bool> onRemindChanged;
  final ValueChanged<bool> onEveryDayChanged;
  final ValueChanged<DeadlinePreset> onCommit;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(Space.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Promise: $title', style: text.titleMedium),
          const SizedBox(height: Space.sm),
          Text('By when?', style: text.bodySmall),
          for (final p in DeadlinePreset.values)
            ListTile(
              minTileHeight: kMinTarget,
              title: Text(p.label, style: text.bodyMedium),
              onTap: () => onCommit(p),
            ),
          SwitchListTile(
            value: remind,
            onChanged: onRemindChanged,
            title: Text('Remind me 10 minutes before', style: text.bodyMedium),
          ),
          if (isDaily)
            SwitchListTile(
              value: everyDay,
              onChanged: onEveryDayChanged,
              title: Text('Every day', style: text.bodyMedium),
            ),
          if (note case final note?)
            Padding(
              padding: const EdgeInsets.only(top: Space.sm),
              child: Text(note, style: text.bodySmall),
            ),
        ],
      ),
    );
  }
}
