import 'package:material_ui/material_ui.dart';

import 'action_row.dart';
import 'glass_sheet.dart';

/// What the Foe actions sheet can ask for.
enum FoeAction { promise, extend, tried, edit, delete }

/// Opens the Foe actions sheet; pops the chosen [FoeAction], or null.
Future<FoeAction?> showGlassFoeActions(
  BuildContext context, {
  required String title,
  required bool canPromise,
  required bool canExtend,
  required bool canTry,
}) => showGlassSheet<FoeAction>(
  context,
  (_) => FoeActionsSheet(
    title: title,
    canPromise: canPromise,
    canExtend: canExtend,
    canTry: canTry,
  ),
);

/// Tap a foe row: its actions. Rows appear only when they apply.
class FoeActionsSheet extends StatelessWidget {
  const FoeActionsSheet({
    super.key,
    required this.title,
    required this.canPromise,
    required this.canExtend,
    required this.canTry,
  });

  final String title;

  /// Open and not yet promised.
  final bool canPromise;

  /// Promised and still movable.
  final bool canExtend;

  /// Open, so it can be marked as tried.
  final bool canTry;

  @override
  Widget build(BuildContext context) {
    Widget row(String label, FoeAction action) =>
        ActionRow(label: label, onTap: () => Navigator.pop(context, action));
    return GlassSheet(
      label: 'Task actions',
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          if (canPromise) row('Promise by…', FoeAction.promise),
          if (canExtend) row('Move it later', FoeAction.extend),
          if (canTry) row('Mark as tried', FoeAction.tried),
          row('Edit', FoeAction.edit),
          row('Delete', FoeAction.delete),
        ],
      ),
    );
  }
}
