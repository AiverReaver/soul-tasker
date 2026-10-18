import 'package:material_ui/material_ui.dart';

import '../core/deadlines.dart';
import '../core/theme.dart';
import 'glass_sheet.dart';
import 'time_choice_row.dart';

/// Move a promise later (plan D10): the first move is free, each later one
/// costs a flask. With none left the choices are shown but disabled.
class ExtendSheet extends StatelessWidget {
  const ExtendSheet({
    super.key,
    required this.options,
    required this.costsFlask,
    required this.flasks,
    required this.onExtend,
  });

  /// Only the presets later than the current deadline.
  final List<DeadlinePreset> options;
  final bool costsFlask;
  final int flasks;
  final ValueChanged<DeadlinePreset> onExtend;

  @override
  Widget build(BuildContext context) {
    final isBlocked = costsFlask && flasks == 0;
    final cost = !costsFlask
        ? 'Free, once.'
        : isBlocked
        ? 'No flask left to move it again.'
        : 'Costs a flask. You hold $flasks.';
    return GlassSheet(
      title: 'Move it later',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Space.sm,
        children: [
          Text(cost, style: Theme.of(context).textTheme.bodySmall),
          for (final p in options)
            TimeChoiceRow(
              label: p.label,
              isEnabled: !isBlocked,
              onTap: () => onExtend(p),
            ),
        ],
      ),
    );
  }
}
