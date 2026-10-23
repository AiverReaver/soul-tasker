import 'package:material_ui/material_ui.dart';

import 'action_row.dart';
import 'glass_sheet.dart';

/// What a long-press on a boss card can ask for.
enum BossCardAction { pin, status }

/// Long-press a boss card: pin or unpin it, and change its status when
/// [statusLabel] says how. Pops the chosen [BossCardAction].
class BossCardActionsSheet extends StatelessWidget {
  const BossCardActionsSheet({
    super.key,
    required this.title,
    required this.isPinned,
    this.statusLabel,
  });

  final String title;
  final bool isPinned;

  /// "Set waiting" or "Set active"; null hides the row.
  final String? statusLabel;

  @override
  Widget build(BuildContext context) {
    Widget row(String label, BossCardAction action) =>
        ActionRow(label: label, onTap: () => Navigator.pop(context, action));
    return GlassSheet(
      label: 'Boss',
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          row(isPinned ? 'Unpin' : 'Pin', BossCardAction.pin),
          if (statusLabel case final label?) row(label, BossCardAction.status),
        ],
      ),
    );
  }
}
