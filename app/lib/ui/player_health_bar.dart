import 'package:material_ui/material_ui.dart';

import '../core/deadlines.dart';
import '../core/theme.dart';

/// The player's health as a row of pips, one per point, half filled for a
/// half point (§5.12). [health] and [max] are in half points.
class PlayerHealthBar extends StatelessWidget {
  const PlayerHealthBar({super.key, required this.health, required this.max});

  final int health;
  final int max;

  static const _width = 14.0;
  static const _height = 6.0;

  @override
  Widget build(BuildContext context) {
    final label = 'Health ${formatHealth(health)} of ${formatHealth(max)}';
    return Semantics(
      label: health == 0 ? 'Fallen. $label' : label,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < max ~/ 2; i++)
            Padding(
              padding: const EdgeInsets.only(right: Space.xs),
              child: _pip(context, (health - i * 2).clamp(0, 2)),
            ),
        ],
      ),
    );
  }

  /// [halves] is 0, 1 or 2.
  Widget _pip(BuildContext context, int halves) => Container(
    key: ValueKey(switch (halves) {
      2 => 'health-full',
      1 => 'health-half',
      _ => 'health-empty',
    }),
    width: _width,
    height: _height,
    decoration: BoxDecoration(border: Border.all(color: context.palette.dim)),
    child: FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: halves / 2,
      child: ColoredBox(color: context.palette.shard),
    ),
  );
}
