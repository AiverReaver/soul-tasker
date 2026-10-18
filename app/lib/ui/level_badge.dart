import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'diamond_pip.dart';
import 'stroke_icon.dart';

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
    this.isTrailing = false,
  });

  final int level;
  final int embers;

  /// How far toward the next level, for the spoken label.
  final int percentToNext;

  /// 0 to 5 lit bars.
  final int bars;

  /// The Profile size: a bigger diamond, numeral and bars.
  final bool isLarge;

  /// Home's form: a flame before the embers, numbers right-aligned, the
  /// diamond last.
  final bool isTrailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    final scale = isLarge ? 1.8 : 1.0;
    // The diamond is rotated 45°, so its layout box is its diagonal.
    final diamond = SizedBox.square(
      dimension: 26 * scale * 1.4142,
      child: Stack(
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
    );
    final numbers = Column(
      crossAxisAlignment: isTrailing
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 3,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            if (isTrailing)
              StrokeIcon(
                path: StrokeIcons.flame,
                color: p.silk,
                size: 14,
                strokeWidth: 1.8,
              ),
            Text('$embers', style: text.bodyMedium),
          ],
        ),
        Row(
          spacing: 2,
          children: [
            for (var i = 0; i < 5; i++)
              KeyedSubtree(
                key: ValueKey('level-slot-$i'),
                child: SizedBox(
                  key: ValueKey(i < bars ? 'level-bar-on' : 'level-bar-off'),
                  width: 10 * scale,
                  height: 4 * scale,
                  child: ColoredBox(
                    color: i < bars ? p.silk : p.dim.withValues(alpha: 0.35),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
    return Semantics(
      label: 'Level $level, $percentToNext percent to level ${level + 1}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: isTrailing ? 10 : Space.sm,
        children: isTrailing ? [numbers, diamond] : [diamond, numbers],
      ),
    );
  }
}
