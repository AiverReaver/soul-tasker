import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'boss_health_bar.dart';

/// One boss on the home list (§6.1). Pure presentation: values in, taps out.
class BossCardTile extends StatelessWidget {
  const BossCardTile({
    super.key,
    required this.title,
    required this.attemptNumber,
    required this.progressLabel,
    required this.health,
    required this.isPinned,
    required this.onTap,
    required this.onLongPress,
    this.healthGroups,
  });

  final String title;
  final int attemptNumber;
  final String progressLabel;
  final double health;
  final bool isPinned;

  /// Health bar segments; null hides the bar.
  final List<List<bool>>? healthGroups;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final groups = healthGroups;
    return Semantics(
      label:
          'Boss $title, attempt $attemptNumber, '
          '${(health * 100).round()} percent health',
      button: true,
      excludeSemantics: true,
      child: Card(
        color: kSurface,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: kAshDim.withValues(alpha: 0.3)),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(Space.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(title, style: text.titleMedium)),
                    if (isPinned) Text('Pinned', style: text.bodySmall),
                  ],
                ),
                const SizedBox(height: Space.xs),
                Text(
                  'Attempt $attemptNumber · $progressLabel',
                  style: text.bodySmall,
                ),
                if (groups != null) ...[
                  const SizedBox(height: Space.sm),
                  BossHealthBar(groups: groups, health: health, height: 6),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
