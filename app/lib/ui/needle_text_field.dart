import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'needle_frame.dart';

/// A one-line text field inside a needle-cut frame, with a small [caption]
/// above it. The caller owns [controller].
class NeedleTextField extends StatelessWidget {
  const NeedleTextField({
    super.key,
    required this.controller,
    required this.caption,
    this.hint,
    this.autofocus = false,
    this.maxLength = 80,
    this.onChanged,
  });

  final TextEditingController controller;
  final String caption;
  final String? hint;
  final bool autofocus;
  final int maxLength;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Space.xs + 2,
      children: [
        Text(caption, style: text.labelSmall),
        NeedleFrame(
          tier: Cut.md,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.md),
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              maxLength: maxLength,
              onChanged: onChanged,
              style: text.bodyLarge,
              cursorColor: p.silk,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: p.ash),
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
