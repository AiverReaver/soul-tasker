import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// The line after a strike: "It is done." with a way to call it a try
/// ("Only partly") or take it back ("Undo"). Sits inside a snack bar.
class StrikeDoneBar extends StatelessWidget {
  const StrikeDoneBar({
    super.key,
    required this.onPartly,
    required this.onUndo,
  });

  final VoidCallback onPartly;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final action = TextButton.styleFrom(
      foregroundColor: context.palette.silk,
      minimumSize: const Size(kMinTarget, kMinTarget),
    );
    return Row(
      children: [
        const Expanded(child: Text('It is done.')),
        TextButton(
          style: action,
          onPressed: onPartly,
          child: const Text('Only partly'),
        ),
        TextButton(style: action, onPressed: onUndo, child: const Text('Undo')),
      ],
    );
  }
}
