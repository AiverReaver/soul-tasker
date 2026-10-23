import 'package:material_ui/material_ui.dart';

import 'glass_alert.dart';

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
  Widget build(BuildContext context) => GlassAlert(
    title: 'A quiet nudge each evening?',
    body: 'One gentle reminder to come back to the bonfire.',
    actions: const ['Yes, remind me', 'Not now'],
    onAction: (i) => i == 0 ? onAccept() : onDecline(),
  );
}
