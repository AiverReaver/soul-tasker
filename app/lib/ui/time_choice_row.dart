import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'needle_frame.dart';

/// A tappable time on a promise or move-later sheet: a needle-cut row.
/// Disabled it dims and ignores taps.
class TimeChoiceRow extends StatelessWidget {
  const TimeChoiceRow({
    super.key,
    required this.label,
    required this.onTap,
    this.isEnabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      enabled: isEnabled,
      label: label,
      excludeSemantics: true,
      onTap: isEnabled ? onTap : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isEnabled ? onTap : null,
        child: NeedleFrame(
          tier: Cut.md,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: kMinTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium!
                      .copyWith(color: isEnabled ? p.bone : p.dim),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
