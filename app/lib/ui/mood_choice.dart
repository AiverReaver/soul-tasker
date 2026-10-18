import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'needle_frame.dart';

/// "How did today go?": needle-cut segments, one per [labels] entry, and a
/// live [note] under them once one is picked. Values in, taps out.
class MoodChoice extends StatelessWidget {
  const MoodChoice({
    super.key,
    required this.labels,
    required this.selected,
    required this.note,
    required this.onChanged,
  });

  final List<String> labels;
  final int? selected;
  final String? note;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Space.sm,
      children: [
        Row(
          spacing: Space.sm,
          children: [
            for (final (i, label) in labels.indexed)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: i == selected,
                  label: label,
                  onTap: () => onChanged(i),
                  excludeSemantics: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(i),
                    child: NeedleFrame(
                      tier: Cut.md,
                      edge: i == selected ? p.silk : null,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: kMinTarget,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Space.xs,
                              vertical: Space.sm,
                            ),
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              style: text.bodyMedium!.copyWith(
                                color: i == selected ? p.bone : p.ash,
                                fontWeight: FontWeight.w600,
                              ),
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
        if (note != null)
          Text(note!, key: const ValueKey('mood-note'), style: text.bodyMedium),
      ],
    );
  }
}
