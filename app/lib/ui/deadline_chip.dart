import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'needle_frame.dart';

/// A commitment's deadline or outcome beside its task. Ember when due within
/// the hour, muted otherwise; never red (§5.8).
class DeadlineChip extends StatelessWidget {
  const DeadlineChip({super.key, required this.label, required this.isSoon});

  final String label;
  final bool isSoon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: Space.sm),
    child: NeedleFrame(
      tier: Cut.sm,
      edge: isSoon ? context.palette.silk : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 2),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSoon ? context.palette.silk : context.palette.ash,
          ),
        ),
      ),
    ),
  );
}
