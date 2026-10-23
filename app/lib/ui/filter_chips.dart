import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'needle_frame.dart';

/// A scrolling row of needle-cut chips to filter by one value. [labels] maps
/// each value (null for "All") to its text, in display order.
class FilterChips<T> extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.padding = EdgeInsets.zero,
  });

  final Map<T?, String> labels;
  final T? selected;
  final ValueChanged<T?> onChanged;

  /// Inset of the scrolling row, so the first chip lines up with the page.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        spacing: Space.sm,
        children: [
          for (final e in labels.entries)
            Semantics(
              button: true,
              selected: e.key == selected,
              label: e.value,
              onTap: () => onChanged(e.key),
              excludeSemantics: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(e.key),
                child: NeedleFrame(
                  tier: Cut.md,
                  edge: e.key == selected ? p.silk : null,
                  fill: e.key == selected ? p.raised : null,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: kMinTarget),
                    child: Center(
                      widthFactor: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Space.md,
                        ),
                        child: Text(
                          e.value,
                          style: text.bodyMedium!.copyWith(
                            color: e.key == selected ? p.bone : p.ash,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
