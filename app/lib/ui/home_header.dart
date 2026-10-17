import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'diamond_pip.dart';

/// "Morning.", "Afternoon." or "Evening." for a local [hour].
String greetingFor(int hour) => hour >= 5 && hour < 12
    ? 'Morning.'
    : hour >= 12 && hour < 17
    ? 'Afternoon.'
    : 'Evening.';

/// Home's top: the date, a serif greeting, banked embers and the level with
/// its five-bar meter. Values in, nothing out.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.dateLine,
    required this.greeting,
    required this.embers,
    required this.level,
    required this.levelBars,
  });

  final String dateLine;
  final String greeting;
  final int embers;
  final int level;

  /// 0 to 5 lit bars.
  final int levelBars;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, Space.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateLine, style: text.labelSmall),
          const SizedBox(height: Space.xs),
          Text(greeting, style: text.displaySmall),
          const SizedBox(height: Space.sm),
          Row(
            children: [
              DiamondPip(color: p.silk),
              const SizedBox(width: Space.sm),
              Text('$embers', style: text.bodyMedium),
              const Spacer(),
              Text('Level $level', style: text.bodySmall),
              const SizedBox(width: Space.sm),
              for (var i = 0; i < 5; i++)
                Padding(
                  key: ValueKey('level-slot-$i'),
                  padding: const EdgeInsets.only(left: 2),
                  child: Container(
                    key: ValueKey(
                      i < levelBars ? 'level-bar-on' : 'level-bar-off',
                    ),
                    width: 10,
                    height: 4,
                    color: i < levelBars
                        ? p.silk
                        : p.dim.withValues(alpha: 0.35),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
