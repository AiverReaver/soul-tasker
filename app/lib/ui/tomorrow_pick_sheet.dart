import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'glass_action_row.dart';
import 'glass_sheet.dart';
import 'pick_toggle_row.dart';

/// One foe in [TomorrowPickSheet].
class PickOption {
  const PickOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.pips,
  });

  final String id;
  final String title;

  /// "{boss} · {weight}".
  final String subtitle;
  final int pips;
}

/// "Tomorrow’s three": a glass sheet body listing the foes waiting. Values in,
/// taps out; the host keeps [picked] and [flash].
class TomorrowPickSheet extends StatelessWidget {
  const TomorrowPickSheet({
    super.key,
    required this.options,
    required this.picked,
    required this.flash,
    required this.onToggle,
    required this.onSet,
    this.max = 3,
  });

  final List<PickOption> options;
  final Set<String> picked;
  final String? flash;
  final ValueChanged<String> onToggle;
  final VoidCallback onSet;
  final int max;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GlassSheet(
      title: 'Tomorrow’s three',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Space.md,
        children: [
          Text(
            'Choose up to three foes to face tomorrow. '
            'Keeping them is what counts.',
            style: text.bodyMedium,
          ),
          Row(
            children: [
              Expanded(child: Text('Foes waiting', style: text.labelSmall)),
              Text('${picked.length} of $max chosen', style: text.labelSmall),
            ],
          ),
          if (flash != null) Text(flash!, style: text.bodySmall),
          for (final o in options)
            PickToggleRow(
              title: o.title,
              subtitle: o.subtitle,
              pips: o.pips,
              isSelected: picked.contains(o.id),
              onTap: () => onToggle(o.id),
            ),
          GlassActionRow(label: 'Set tomorrow', onTap: onSet),
        ],
      ),
    );
  }
}
