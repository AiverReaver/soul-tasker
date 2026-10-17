import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'diamond_pip.dart';
import 'nav_icon.dart';

/// Home's bottom bar: Bosses, Today, Bonfire, Relics. The selected item is
/// bone with a silk diamond on the bar's top edge; the rest are ash. Values
/// in, taps out.
class HearthNavBar extends StatelessWidget {
  const HearthNavBar({super.key, required this.selected, required this.onTap});

  static const labels = ['Bosses', 'Today', 'Bonfire', 'Relics'];

  final int selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      key: const ValueKey('nav-bar'),
      decoration: BoxDecoration(
        color: p.void_,
        border: Border(top: BorderSide(color: p.seam)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.sm,
            Space.xs,
            Space.sm,
            Space.xs,
          ),
          child: Row(
            children: [
              for (final (i, label) in labels.indexed)
                Expanded(child: _item(context, i, label, i == selected)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int i, String label, bool isSelected) {
    final p = context.palette;
    final color = isSelected ? p.bone : p.ash;
    return Semantics(
      button: true,
      selected: isSelected,
      excludeSemantics: true,
      label: label,
      child: InkWell(
        key: ValueKey('nav-item-$i'),
        onTap: () => onTap(i),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (isSelected)
                Positioned(
                  top: -Space.xs,
                  child: DiamondPip(color: p.silk, size: 7),
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NavIcon(key: ValueKey('nav-icon-$i'), index: i, color: color),
                  const SizedBox(height: Space.xs),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: color,
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
