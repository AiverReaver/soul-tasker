import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// Carried embers (at risk until the bonfire) and banked embers (safe).
/// Until the first rest ([banked] is 0) it shows one number and says what
/// embers are, so a new player meets one term, not two.
class EmberTally extends StatelessWidget {
  const EmberTally({super.key, required this.carried, required this.banked});

  final int carried;
  final int banked;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    if (banked == 0) {
      return Wrap(
        spacing: Space.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Embers $carried',
            style: style?.copyWith(color: context.palette.silk),
          ),
          Text(
            'Earned by striking. Rest to keep them.',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: context.palette.ash),
          ),
        ],
      );
    }
    // Wraps rather than overflows at large text sizes.
    return Wrap(
      spacing: Space.lg,
      children: [
        Text(
          'Carried $carried',
          style: style?.copyWith(color: context.palette.silk),
        ),
        Text(
          'Banked $banked',
          style: style?.copyWith(color: context.palette.ash),
        ),
      ],
    );
  }
}
