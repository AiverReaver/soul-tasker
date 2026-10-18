import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'diamond_pip.dart';

/// The level on Home: a silk diamond holding a serif numeral, the banked
/// embers and five bars that fill toward the next level.
class LevelBadge extends StatelessWidget {
  const LevelBadge({
    super.key,
    required this.level,
    required this.embers,
    required this.percentToNext,
    required this.bars,
    this.isLarge = false,
  });

  final int level;
  final int embers;

  /// How far toward the next level, for the spoken label.
  final int percentToNext;

  /// 0 to 5 lit bars.
  final int bars;

  /// The Profile size: a bigger diamond, numeral and bars.
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    final scale = isLarge ? 1.8 : 1.0;
    return Semantics(
      label: 'Level $level, $percentToNext percent to level ${level + 1}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Space.sm,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              DiamondPip(color: p.silk, size: 26 * scale),
              Text(
                '$level',
                style: text.titleMedium!.copyWith(
                  color: p.onSilk,
                  fontSize: 16 * scale,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 3,
            children: [
              Text('$embers', style: text.bodyMedium),
              Row(
                spacing: 2,
                children: [
                  for (var i = 0; i < 5; i++)
                    KeyedSubtree(
                      key: ValueKey('level-slot-$i'),
                      child: SizedBox(
                        key: ValueKey(
                          i < bars ? 'level-bar-on' : 'level-bar-off',
                        ),
                        width: 10 * scale,
                        height: 4 * scale,
                        child: ColoredBox(
                          color: i < bars
                              ? p.silk
                              : p.dim.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
