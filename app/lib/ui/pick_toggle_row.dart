import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'diamond_pip.dart';
import 'needle_frame.dart';

/// One foe offered for tomorrow: weight pips, title, "{boss} · {weight}" and
/// a diamond checkbox. A chosen row has a silk edge and a raised fill.
class PickToggleRow extends StatelessWidget {
  const PickToggleRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.pips,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final int pips;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$title, $subtitle',
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: NeedleFrame(
          tier: Cut.md,
          edge: isSelected ? p.silk : null,
          fill: isSelected ? p.raised : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: kMinTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.md,
                vertical: Space.sm,
              ),
              child: Row(
                spacing: Space.sm + 4,
                children: [
                  Column(
                    spacing: 4,
                    children: [
                      for (var i = 0; i < pips; i++)
                        DiamondPip(color: isSelected ? p.silk : p.dim),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: text.bodyMedium!.copyWith(color: p.bone),
                        ),
                        Text(subtitle, style: text.bodySmall),
                      ],
                    ),
                  ),
                  DiamondPip(
                    color: isSelected ? p.silk : p.dim,
                    size: isSelected ? 12 : 8,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
