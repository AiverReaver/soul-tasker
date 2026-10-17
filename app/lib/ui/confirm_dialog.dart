import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// A calm yes/no dialog body. Pops true only on the action button.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.question,
    required this.action,
  });

  final String question;
  final String action;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(question, style: Theme.of(context).textTheme.bodyLarge),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Not yet', style: TextStyle(color: context.palette.ash)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(action),
        ),
      ],
    );
  }
}
