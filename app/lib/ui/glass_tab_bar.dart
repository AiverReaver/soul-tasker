import 'package:material_ui/material_ui.dart';

import '../core/palette.dart';
import '../core/theme.dart';
import 'diamond_pip.dart';
import 'glass_surface.dart';
import 'nav_icon.dart';

/// The floating tab pill: 62 px tall, 21 px in from the sides and 19 px
/// above the bottom inset. The selected tab is bone on the brighter glass
/// with a silk diamond; the rest are ash. Values in, taps out.
class GlassTabBar extends StatelessWidget {
  const GlassTabBar({
    super.key,
    required this.selected,
    required this.onTap,
    this.labels = const ['Home', 'Today', 'Bonfire', 'Profile'],
  });

  final int selected;
  final ValueChanged<int> onTap;
  final List<String> labels;

  /// Bottom padding tab screens add so content can scroll under the bar.
  static const clearance = 100.0;

  @override
  Widget build(BuildContext context) => MediaQuery.withClampedTextScaling(
    // The pill is a fixed 62 px, so its labels never grow.
    maxScaleFactor: 1.0,
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        21,
        0,
        21,
        19 + MediaQuery.paddingOf(context).bottom,
      ),
      child: GlassSurface(
        key: const ValueKey('nav-bar'),
        shape: const GlassShape.stadium(),
        child: SizedBox(
          height: 62,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              spacing: 2,
              children: [
                for (final (i, label) in labels.indexed)
                  Expanded(child: _tab(context, i, label)),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _tab(BuildContext context, int i, String label) {
    final p = context.palette;
    final isSelected = i == selected;
    final color = isSelected ? p.bone : p.ash;
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      onTap: () => onTap(i),
      excludeSemantics: true,
      child: GestureDetector(
        key: ValueKey('nav-item-$i'),
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(i),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: StadiumBorder(
              side: isSelected
                  ? const BorderSide(color: glassRing, width: .5)
                  : BorderSide.none,
            ),
            color: isSelected ? p.glassFillHi : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isSelected)
                Positioned(
                  top: 3,
                  child: DiamondPip(
                    key: const ValueKey('nav-diamond'),
                    color: p.silk,
                    size: 5,
                  ),
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  NavIcon(key: ValueKey('nav-icon-$i'), index: i, color: color),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      height: 13 / 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
