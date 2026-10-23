import 'package:material_ui/material_ui.dart';

import '../core/deadlines.dart';
import '../core/theme.dart';
import 'glass_sheet.dart';
import 'glass_switch.dart';
import 'time_choice_row.dart';

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
    return GlassSheet(
      label: 'Promise by',
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Space.sm,
        children: [
          for (final p in DeadlinePreset.values)
            TimeChoiceRow(label: p.label, onTap: () => onCommit(p)),
          const SizedBox(height: Space.xs),
          _SwitchRow(
            label: 'Remind me 10 minutes before',
            value: remind,
            onChanged: onRemindChanged,
          ),
          if (isDaily)
            _SwitchRow(
              label: 'Every day',
              value: everyDay,
              onChanged: onEveryDayChanged,
            ),
          if (note case final note?) Text(note, style: text.bodySmall),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => onChanged(!value),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: kMinTarget),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          GlassSwitch(value: value, onChanged: onChanged, semanticLabel: label),
        ],
      ),
    ),
  );
}
