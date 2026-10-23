import 'package:material_ui/material_ui.dart';

import '../core/deadlines.dart';
import '../core/theme.dart';
import 'glass_alert.dart';
import 'needle_frame.dart';

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

/// Deadlines that passed while the app was closed, in one calm glass alert
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
    final p = context.palette;
    final title = rows.length == 1
        ? 'A deadline passed.'
        : '${_capital(countWord(rows.length))} deadlines passed.';
    return GlassAlert(
      label: 'While you were away',
      title: title,
      onAction: (_) => onClose(),
      actions: const ['Go on'],
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 280),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Space.sm,
            children: [
              for (final r in rows)
                NeedleFrame(
                  tier: Cut.md,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Space.md,
                      vertical: Space.xs,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                r.title,
                                style: text.bodyMedium!.copyWith(color: p.bone),
                              ),
                            ),
                            Text(r.cost, style: text.bodySmall),
                          ],
                        ),
                        if (!r.isDone)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => onDoneLate(r.id),
                              child: const Text('Done late'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _capital(String s) => s[0].toUpperCase() + s.substring(1);
}
