import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'carved_frame.dart';

/// The home entry to the bonfire: an invitation, then a quiet "Rested".
class BonfireCard extends StatelessWidget {
  const BonfireCard({super.key, required this.isRested, required this.onTap});

  final bool isRested;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    // Lit, the one crimson on screen, until you have rested tonight.
    return CarvedFrame(
      isLit: !isRested,
      padding: EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          splashColor: kEmber.withValues(alpha: 0.12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: kMinTarget + Space.md),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.md + Space.xs,
                vertical: Space.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department_outlined,
                    color: isRested ? kTextMuted : kEmber,
                  ),
                  const SizedBox(width: Space.md),
                  Text(
                    isRested ? 'Rested' : 'Rest at the bonfire',
                    style: text.bodyMedium?.copyWith(
                      color: isRested ? kTextMuted : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
