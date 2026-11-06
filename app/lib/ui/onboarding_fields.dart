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
