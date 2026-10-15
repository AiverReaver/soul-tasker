import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'ember_button.dart';

/// Offered once, right after the first rest: a quiet nudge each evening.
class ReminderInvite extends StatelessWidget {
  const ReminderInvite({
    super.key,
    required this.onAccept,
    required this.onDecline,
  });

  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AlertDialog(
      backgroundColor: kSurface,
      title: Text('A quiet nudge each evening?', style: text.titleMedium),
      content: Text(
        'One gentle reminder to come back to the bonfire.',
        style: text.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: onDecline,
          child: const Text('Not now', style: TextStyle(color: kTextMuted)),
        ),
        EmberButton(label: 'Yes, remind me', onPressed: onAccept),
      ],
    );
  }
}
