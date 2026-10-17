import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// The underlined one-line input used by onboarding and the bonfire.
InputDecoration inscriptionDecoration(HearthPalette p, String hint) =>
    InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: p.ash),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: p.dim)),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: p.silk),
      ),
    );

/// A single labelled line of text. The caller keeps the value.
class LineField extends StatelessWidget {
  const LineField({
    super.key,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.initialValue = '',
    this.maxLength = 80,
  });

  final String label;
  final String hint;
  final String initialValue;
  final int maxLength;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: text.bodySmall),
        TextFormField(
          initialValue: initialValue,
          maxLength: maxLength,
          style: text.bodyLarge,
          cursorColor: context.palette.silk,
          decoration: inscriptionDecoration(context.palette, hint),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// One editable line in a [NameListEditor]; [id] keeps its field stable when
/// others are removed.
class NameListItem {
  const NameListItem({required this.id, required this.text});

  final int id;
  final String text;
}

/// A short list of names to edit, add to (up to [max]) and remove from.
/// [keyPrefix] names the fields for tests: `<keyPrefix>-<id>`.
class NameListEditor extends StatelessWidget {
  const NameListEditor({
    super.key,
    required this.items,
    required this.keyPrefix,
    required this.hint,
    required this.removeLabel,
    required this.addLabel,
    required this.max,
    required this.onChanged,
    required this.onRemove,
    required this.onAdd,
    this.autofocusId,
  });

  final List<NameListItem> items;
  final String keyPrefix;
  final String hint;

  /// Tooltip prefix for the remove button: "Remove phase" gives
  /// "Remove phase 1".
  final String removeLabel;
  final String addLabel;
  final int max;
  final void Function(int id, String text) onChanged;
  final ValueChanged<int> onRemove;
  final VoidCallback onAdd;

  /// The row (by id) that takes focus when it appears, e.g. one just added.
  final int? autofocusId;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, item) in items.indexed)
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: ValueKey('$keyPrefix-${item.id}'),
                  initialValue: item.text,
                  autofocus: item.id == autofocusId,
                  maxLength: 60,
                  style: text.bodyLarge,
                  cursorColor: context.palette.silk,
                  decoration: inscriptionDecoration(
                    context.palette,
                    hint,
                  ).copyWith(counterText: ''),
                  onChanged: (t) => onChanged(item.id, t),
                ),
              ),
              IconButton(
                tooltip: '$removeLabel ${i + 1}',
                constraints: const BoxConstraints(
                  minWidth: kMinTarget,
                  minHeight: kMinTarget,
                ),
                icon: Icon(Icons.close, color: context.palette.ash),
                onPressed: () => onRemove(item.id),
              ),
            ],
          ),
        if (items.length < max)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onAdd,
              style: TextButton.styleFrom(
                minimumSize: const Size(kMinTarget, kMinTarget),
              ),
              child: Text(addLabel),
            ),
          ),
      ],
    );
  }
}
