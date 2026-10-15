import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// The one ember-coloured action on a ritual screen ("Rest", "Rise").
class EmberButton extends StatelessWidget {
  const EmberButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  static const _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(kMinTarget, kMinTarget),
      ),
      child: Text(
        label,
        style: const TextStyle(color: kEmber, fontSize: _fontSize),
      ),
    );
  }
}
