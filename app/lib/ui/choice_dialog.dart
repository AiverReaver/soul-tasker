import 'package:material_ui/material_ui.dart';

/// A short list of options in a dialog; tapping one reports it.
class ChoiceDialog<T> extends StatelessWidget {
  const ChoiceDialog({
    super.key,
    required this.title,
    required this.options,
    required this.onPicked,
  });

  final String title;

  /// Option value to its label, in display order.
  final Map<T, String> options;
  final ValueChanged<T> onPicked;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SimpleDialog(
      title: Text(title, style: text.titleMedium),
      children: [
        for (final e in options.entries)
          SimpleDialogOption(
            onPressed: () => onPicked(e.key),
            child: Text(e.value, style: text.bodyMedium),
          ),
      ],
    );
  }
}
