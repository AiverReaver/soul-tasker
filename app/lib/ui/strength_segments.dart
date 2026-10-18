import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'diamond_pip.dart';
import 'needle_frame.dart';

/// One choice in [StrengthSegments].
class StrengthOption {
  const StrengthOption({
    required this.label,
    required this.pips,
    required this.note,
  });

  final String label;

  /// One diamond per weight step.
  final int pips;

  /// "+3 embers".
  final String note;
}

/// A row of needle-cut segments to pick a foe's strength: label, pips and
/// the embers it earns. Values in, taps out.
class StrengthSegments extends StatelessWidget {
  const StrengthSegments({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<StrengthOption> options;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return Row(
      spacing: Space.sm,
      children: [
        for (final (i, o) in options.indexed)
          Expanded(
            child: Semantics(
              button: true,
              selected: i == selected,
              label: '${o.label}, ${o.note}',
              onTap: () => onChanged(i),
              excludeSemantics: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: NeedleFrame(
                  tier: Cut.md,
                  edge: i == selected ? p.silk : null,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 72),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Space.sm),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 4,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 4,
                            children: [
                              for (var k = 0; k < o.pips; k++)
                                DiamondPip(
                                  color: i == selected ? p.silk : p.dim,
                                ),
                            ],
                          ),
                          Text(
                            o.label,
                            style: text.bodyMedium!.copyWith(
                              color: i == selected ? p.bone : p.ash,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(o.note, style: text.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
