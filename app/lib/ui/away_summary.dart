import 'package:material_ui/material_ui.dart';

import '../core/deadlines.dart';
import '../core/theme.dart';

/// One passed deadline in the away summary.
@immutable
class AwayRow {
  const AwayRow({
    required this.id,
    required this.title,
    required this.cost,
    this.isDone = false,
  });

  final String id;
  final String title;

  /// What it cost, such as "−2 health" or "frozen".
  final String cost;

  /// Already done late: no action left.
  final bool isDone;
}

/// Deadlines that passed while the app was closed, in one calm summary
/// instead of a wall of penalties (§5.12, plan D19).
class AwaySummary extends StatelessWidget {
  const AwaySummary({
    super.key,
    required this.rows,
    required this.onDoneLate,
    required this.onClose,
  });

  final List<AwayRow> rows;
  final ValueChanged<String> onDoneLate;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final heading = rows.length == 1
        ? 'While you were away, a deadline passed.'
        : 'While you were away, ${countWord(rows.length)} deadlines passed.';
    return AlertDialog(
      backgroundColor: context.palette.shell,
      title: Text(heading, style: text.titleMedium),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final r in rows)
              Row(
                children: [
                  Expanded(child: Text(r.title, style: text.bodyMedium)),
                  Text(r.cost, style: text.bodySmall),
                  if (!r.isDone)
                    TextButton(
                      onPressed: () => onDoneLate(r.id),
                      child: const Text('Done late'),
                    ),
                ],
              ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: onClose, child: const Text('Go on'))],
    );
  }
}
