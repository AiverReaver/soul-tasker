import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// The home entry to the bonfire: an invitation, then a quiet "Rested".
class BonfireCard extends StatelessWidget {
  const BonfireCard({super.key, required this.isRested, required this.onTap});

  final bool isRested;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: kSurface,
      borderRadius: BorderRadius.circular(Space.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(Space.sm),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: kMinTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.md,
              vertical: Space.sm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department_outlined,
                  color: isRested ? kTextMuted : kAsh,
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
    );
  }
}
