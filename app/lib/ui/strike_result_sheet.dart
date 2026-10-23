import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'glass_sheet.dart';
import 'needle_frame.dart';

/// Asks how a landed strike went, after the beats have played. Pops true for
/// a clean strike, false for a real try; Cancel or a tap outside pops null.
Future<bool?> showStrikeResultSheet(BuildContext context, String title) =>
    showGlassSheet<bool>(context, (_) => StrikeResultSheet(title: title));

class StrikeResultSheet extends StatelessWidget {
  const StrikeResultSheet({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => GlassSheet(
    label: 'How did the strike land?',
    title: title,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Space.sm + 4,
      children: [
        _Choice(
          label: 'Clean strike',
          note: 'Done in full. Promise kept.',
          isTinted: true,
          onTap: () => Navigator.pop(context, true),
        ),
        _Choice(
          label: 'A real try',
          note: 'Part done. Effort still earns embers.',
          onTap: () => Navigator.pop(context, false),
        ),
      ],
    ),
  );
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.onTap,
    required this.note,
    this.isTinted = false,
  });

  final String label;
  final String note;
  final VoidCallback onTap;
  final bool isTinted;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: NeedleFrame(
          tier: Cut.md,
          edge: isTinted ? p.silk : null,
          fill: isTinted ? p.silk : null,
          child: SizedBox(
            height: 68,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isTinted ? p.onSilk : p.bone,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  note,
                  style: TextStyle(
                    color: isTinted ? p.onSilk : p.ash,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
