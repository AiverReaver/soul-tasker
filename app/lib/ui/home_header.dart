import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'glass_circle_button.dart';
import 'level_badge.dart';
import 'stroke_icon.dart';

/// "Morning.", "Afternoon." or "Evening." for a local [hour].
String greetingFor(int hour) => hour >= 5 && hour < 12
    ? 'Morning.'
    : hour >= 12 && hour < 17
    ? 'Afternoon.'
    : 'Evening.';

/// Home's top: the date and a serif greeting on the left, the profile and
/// settings circles on the right, then the level badge. Values in, taps out.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.dateLine,
    required this.greeting,
    required this.embers,
    required this.level,
    required this.levelBars,
    required this.percentToNext,
    required this.onProfile,
    required this.onSettings,
  });

  final String dateLine;
  final String greeting;
  final int embers;
  final int level;

  /// 0 to 5 lit bars.
  final int levelBars;
  final int percentToNext;
  final VoidCallback onProfile;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    return Padding(
      key: const ValueKey('home-header'),
      padding: const EdgeInsets.fromLTRB(20, Space.sm, 20, Space.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Space.sm,
        children: [
          Row(
            children: [
              Expanded(child: Text('Hearthrise', style: text.labelSmall)),
              GlassCircleButton(
                icon: StrokeIcons.profile,
                semanticLabel: 'Your profile',
                onTap: onProfile,
              ),
              const SizedBox(width: Space.sm),
              GlassCircleButton(
                icon: StrokeIcons.settings,
                semanticLabel: 'Settings',
                onTap: onSettings,
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Space.xs,
                  children: [
                    Text(
                      dateLine,
                      style: text.bodyMedium!.copyWith(
                        color: p.ash,
                        fontSize: 14,
                      ),
                    ),
                    Text(greeting, style: text.displaySmall),
                  ],
                ),
              ),
              LevelBadge(
                level: level,
                embers: embers,
                percentToNext: percentToNext,
                bars: levelBars,
                isTrailing: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
