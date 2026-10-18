import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/boss_view.dart';
import '../../data/providers.dart';
import '../../ui/glass_action_row.dart';
import '../../ui/glass_sheet.dart';
import '../../ui/needle_text_field.dart';

enum _Choice { change, split, rest, keepGoing }

/// "Same path, same result. What will you change?" (§5.10, plan §8.7).
/// [task] is null for the phase-level prompt.
Future<void> showRuleOfThree(
  BuildContext context,
  WidgetRef ref, {
  required String bossId,
  TaskView? task,
  required ValueChanged<String> onMessage,
}) async {
  final choice = await showGlassSheet<_Choice>(
    context,
    (_) => const _RuleOfThreeSheet(),
  );
  if (!context.mounted) return;

  switch (choice) {
    case _Choice.change:
      context.push('/boss/$bossId/edit');
    case _Choice.split when task != null:
      final titles = await showGlassSheet<List<String>>(
        context,
        (_) => _SplitSheet(original: task.task.title),
      );
      if (titles != null) {
        await ref.read(bossDaoProvider).splitTask(task.task.id, titles);
      }
    case _Choice.split:
      context.push('/boss/$bossId/edit');
    case _Choice.rest:
      onMessage('Return when ready.');
    case _Choice.keepGoing || null:
      break;
  }
}

class _RuleOfThreeSheet extends StatelessWidget {
  const _RuleOfThreeSheet();

  @override
  Widget build(BuildContext context) {
    return GlassSheet(
      title: 'Same path, same result. What will you change?',
      closeLabel: 'Close',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          GlassActionRow(
            label: 'Change the approach',
            onTap: () => Navigator.pop(context, _Choice.change),
          ),
          GlassActionRow(
            label: 'Split into smaller tasks',
            onTap: () => Navigator.pop(context, _Choice.split),
          ),
          GlassActionRow(
            label: 'Rest first',
            onTap: () => Navigator.pop(context, _Choice.rest),
          ),
          GlassActionRow(
            label: 'Keep going',
            onTap: () => Navigator.pop(context, _Choice.keepGoing),
          ),
        ],
      ),
    );
  }
}

/// Collects 2 to 5 smaller task titles (plan §6.4).
class _SplitSheet extends StatefulWidget {
  const _SplitSheet({required this.original});

  final String original;

  @override
  State<_SplitSheet> createState() => _SplitSheetState();
}

class _SplitSheetState extends State<_SplitSheet> {
  static const _min = 2;
  static const _max = 5;

  final _fields = [TextEditingController(), TextEditingController()];

  @override
  void dispose() {
    for (final f in _fields) {
      f.dispose();
    }
    super.dispose();
  }

  List<String> get _titles => [
    for (final f in _fields)
      if (f.text.trim().isNotEmpty) f.text.trim(),
  ];

  @override
  Widget build(BuildContext context) => GlassSheet(
    title: 'Split "${widget.original}"',
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Space.sm,
        children: [
          for (final (i, field) in _fields.indexed)
            NeedleTextField(
              controller: field,
              caption: 'Smaller task ${i + 1}',
              autofocus: i == 0,
              onChanged: (_) => setState(() {}),
            ),
          if (_fields.length < _max)
            TextButton(
              onPressed: () =>
                  setState(() => _fields.add(TextEditingController())),
              child: const Text('Add another'),
            ),
          if (_titles.length >= _min)
            GlassActionRow(
              label: 'Split',
              onTap: () => Navigator.pop(context, _titles),
            ),
        ],
      ),
    ),
  );
}
