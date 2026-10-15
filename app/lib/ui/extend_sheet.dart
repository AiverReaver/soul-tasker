import 'package:material_ui/material_ui.dart';

import '../core/deadlines.dart';
import '../core/theme.dart';

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
    final text = Theme.of(context).textTheme;
    final isBlocked = costsFlask && flasks == 0;
    final cost = !costsFlask
        ? 'Free, once.'
        : isBlocked
        ? 'No flask left to move it again.'
        : 'Costs a flask. You hold $flasks.';
    return Padding(
      padding: const EdgeInsets.all(Space.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Move it later', style: text.titleMedium),
          const SizedBox(height: Space.sm),
          Text(cost, style: text.bodySmall),
          for (final p in options)
            ListTile(
              minTileHeight: kMinTarget,
              enabled: !isBlocked,
              title: Text(p.label, style: text.bodyMedium),
              onTap: isBlocked ? null : () => onExtend(p),
            ),
        ],
      ),
    );
  }
}
