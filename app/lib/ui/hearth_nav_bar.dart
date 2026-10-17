import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'diamond_pip.dart';

/// Home's bottom bar: Bosses, Today, Bonfire, Relics. [selected] is lit in
/// silk with a diamond; the rest are ash. Values in, taps out.
class HearthNavBar extends StatelessWidget {
  const HearthNavBar({super.key, required this.selected, required this.onTap});

  static const labels = ['Bosses', 'Today', 'Bonfire', 'Relics'];

  final int selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.shell,
        border: Border(top: BorderSide(color: p.seam)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (final (i, label) in labels.indexed)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: i == selected,
                  excludeSemantics: true,
                  label: label,
                  child: InkWell(
                    key: ValueKey('nav-item-$i'),
                    onTap: () => onTap(i),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 56),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DiamondPip(
                            color: i == selected ? p.silk : Colors.transparent,
                            size: 5,
                          ),
                          const SizedBox(height: Space.sm),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: i == selected ? p.silk : p.ash,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
