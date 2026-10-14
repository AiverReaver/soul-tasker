import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// A settings row that picks one of a few options, shown side by side.
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: Space.sm),
        SegmentedButton<T>(
          segments: [
            for (final e in options.entries)
              ButtonSegment(value: e.key, label: Text(e.value)),
          ],
          selected: {selected},
          showSelectedIcon: false,
          onSelectionChanged: (s) => onChanged(s.single),
        ),
      ],
    );
  }
}
