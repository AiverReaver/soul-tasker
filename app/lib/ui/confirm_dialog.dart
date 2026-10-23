import 'package:material_ui/material_ui.dart';

import 'glass_alert.dart';

/// A calm yes/no alert. Pops true only on the action row.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.question,
    required this.action,
  });

  final String question;
  final String action;

  @override
  Widget build(BuildContext context) => GlassAlert(
    body: question,
    actions: [action, 'Not yet'],
    onAction: (i) => Navigator.pop(context, i == 0),
  );
}
