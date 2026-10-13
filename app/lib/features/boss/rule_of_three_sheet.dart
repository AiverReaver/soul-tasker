import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/boss_view.dart';
import '../../data/providers.dart';

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
  final choice = await showModalBottomSheet<_Choice>(
    context: context,
    backgroundColor: kSurface,
    builder: (context) => const _RuleOfThreeSheet(),
  );
  if (!context.mounted) return;

  switch (choice) {
    case _Choice.change:
      context.push('/boss/$bossId/edit');
    case _Choice.split when task != null:
      final titles = await showModalBottomSheet<List<String>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: kSurface,
        builder: (_) => _SplitSheet(original: task.task.title),
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
    final text = Theme.of(context).textTheme;
    Widget option(_Choice choice, String label) => ListTile(
      minTileHeight: kMinTarget,
      title: Text(label, style: text.bodyMedium),
      onTap: () => Navigator.pop(context, choice),
    );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, Space.lg, 8, Space.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.md),
              child: Text(
                'Same path, same result. What will you change?',
                style: text.titleMedium,
              ),
            ),
            const SizedBox(height: Space.md),
            option(_Choice.change, 'Change the approach'),
            option(_Choice.split, 'Split into smaller foes'),
            option(_Choice.rest, 'Rest first'),
            option(_Choice.keepGoing, 'Keep going'),
          ],
        ),
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
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        Space.lg,
        20,
        MediaQuery.viewInsetsOf(context).bottom + Space.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Split "${widget.original}"', style: text.titleMedium),
          for (final (i, field) in _fields.indexed)
            TextField(
              controller: field,
              autofocus: i == 0,
              maxLength: 80,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(hintText: 'Smaller foe ${i + 1}'),
            ),
          if (_fields.length < _max)
            TextButton(
              onPressed: () =>
                  setState(() => _fields.add(TextEditingController())),
              child: const Text('Add another'),
            ),
          FilledButton(
            onPressed: _titles.length >= _min
                ? () => Navigator.pop(context, _titles)
                : null,
            child: const Text('Split'),
          ),
        ],
      ),
    );
  }
}
