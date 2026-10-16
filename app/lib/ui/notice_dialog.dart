import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// A calm one-button notice. [onClose] is the only way out.
class NoticeDialog extends StatelessWidget {
  const NoticeDialog({super.key, required this.message, required this.onClose});

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: kSurface,
    content: Text(message, style: Theme.of(context).textTheme.bodyLarge),
    actions: [TextButton(onPressed: onClose, child: const Text('OK'))],
  );
}
