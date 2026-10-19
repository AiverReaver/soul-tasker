import 'package:material_ui/material_ui.dart';

import 'action_row.dart';
import 'glass_sheet.dart';

/// What the Boss actions sheet can ask for.
enum BossAction { leave, resume, edit, pin, victory, failed }

/// The ⋯ sheet on the Boss screen (Q2b). Pops the chosen [BossAction].
class BossActionsSheet extends StatelessWidget {
  const BossActionsSheet({
    super.key,
    required this.bossName,
    required this.isActive,
    required this.isWaiting,
    required this.isPinned,
    this.isDay = false,
  });

  final String bossName;

  /// Fighting now; [isWaiting] is set aside. Neither: defeated.
  final bool isActive;
  final bool isWaiting;
  final bool isPinned;

  /// The Day: always active, so no leave, victory or fall.
  final bool isDay;

  @override
  Widget build(BuildContext context) {
    Widget row(String label, BossAction action) =>
        ActionRow(label: label, onTap: () => Navigator.pop(context, action));
    return GlassSheet(
      label: 'Boss actions',
      title: bossName,
      closeLabel: 'Close',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          if (isActive && !isDay) row('Leave for now', BossAction.leave),
          if (isWaiting) row('Set active', BossAction.resume),
          row('Edit', BossAction.edit),
          row(isPinned ? 'Unpin' : 'Pin', BossAction.pin),
          if (!isDay && (isActive || isWaiting))
            row('Declare victory', BossAction.victory),
          if (isActive && !isDay) row('This attempt failed', BossAction.failed),
        ],
      ),
    );
  }
}
