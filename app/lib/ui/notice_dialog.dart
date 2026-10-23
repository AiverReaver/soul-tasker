import 'package:material_ui/material_ui.dart';

import 'glass_alert.dart';

/// A calm one-button notice. [onClose] is the only way out.
class NoticeDialog extends StatelessWidget {
  const NoticeDialog({super.key, required this.message, required this.onClose});

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => GlassAlert(
    body: message,
    actions: const ['OK'],
    onAction: (_) => onClose(),
  );
}
