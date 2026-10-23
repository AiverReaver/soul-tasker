import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'needle_frame.dart';

/// A settings row that picks one of a few options: needle-cut segments side
/// by side, the chosen one with a silk edge.
class SettingChoiceRow<T> extends StatelessWidget {
  const SettingChoiceRow({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String title;

  /// Option value to its label, in display order.
  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: text.bodyMedium),
        const SizedBox(height: Space.sm),
        Row(
          spacing: Space.sm,
          children: [
            for (final e in options.entries)
              Expanded(
                child: Semantics(
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
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: kMinTarget,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(Space.xs),
                            child: Text(
                              e.value,
                              textAlign: TextAlign.center,
                              style: text.bodyMedium!.copyWith(
                                color: e.key == selected ? p.bone : p.ash,
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
      ],
    );
  }
}
