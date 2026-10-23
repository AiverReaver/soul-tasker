import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// Five rows, one per [Biome]: its name and a strip of four swatches (void,
/// shell, silk, bone). The selected row has a silk edge.
class BiomeChoiceRow extends StatelessWidget {
  const BiomeChoiceRow({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Biome selected;
  final ValueChanged<Biome> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Biome', style: text.bodyMedium),
        const SizedBox(height: Space.sm),
        for (final b in Biome.values)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.sm),
            child: Semantics(
              button: true,
              selected: b == selected,
              child: InkWell(
                onTap: () => onChanged(b),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  key: ValueKey('biome-${b.name}'),
                  constraints: const BoxConstraints(minHeight: kMinTarget),
                  padding: const EdgeInsets.symmetric(horizontal: Space.md),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: b == selected ? p.silk : p.seam),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(b.label, style: text.bodyMedium)),
                      Row(
                        key: ValueKey('swatches-${b.name}'),
                        children: [
                          for (final c in [
                            b.palette.void_,
                            b.palette.shell,
                            b.palette.silk,
                            b.palette.bone,
                          ])
                            Container(
                              width: 20,
                              height: 20,
                              margin: const EdgeInsets.only(left: Space.xs),
                              decoration: BoxDecoration(
                                color: c,
                                border: Border.all(color: p.seam),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
