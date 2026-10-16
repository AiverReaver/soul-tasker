import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/clock.dart';
import '../../core/deadlines.dart';
import '../../core/reminders.dart';
import '../../core/theme.dart';
import '../../data/boss_view.dart';
import '../../data/commitment_dao.dart';
import '../../data/providers.dart';
import '../../ui/commit_sheet.dart';
import '../../ui/extend_sheet.dart';

/// "That is six promises, four of them heavy." (plan D17).
String loadNoteText(LoadNote note) =>
    'That is ${countWord(note.count)} promises, '
    '${countWord(note.heavy)} of them heavy.';

/// Asks for a deadline and promises [view]'s task. Says the calm note after
/// a heavy commit, never blocking it.
Future<void> showCommitSheet(
  BuildContext context,
  WidgetRef ref,
  TaskView view, {
  required ValueChanged<String> onMessage,
}) async {
  final dao = ref.read(commitmentDaoProvider);
  final reminders = ref.read(remindersProvider);
  final hour = await ref.read(databaseProvider).rolloverHour();
  final today = dayOf(ref.read(clockProvider)(), rolloverHour: hour);
  final before = await dao.loadNote(today);
  if (!context.mounted) return;
  var remind = false;
  var everyDay = false;
  final preset = await showModalBottomSheet<DeadlinePreset>(
    context: context,
    backgroundColor: kSurface,
    builder: (sheet) => StatefulBuilder(
      builder: (sheet, setState) => SafeArea(
        child: CommitSheet(
          title: view.task.title,
          isDaily: view.isDaily,
          remind: remind,
          everyDay: everyDay,
          note: before == null ? null : loadNoteText(before),
          onRemindChanged: (v) => setState(() => remind = v),
          onEveryDayChanged: (v) => setState(() => everyDay = v),
          onCommit: (p) => Navigator.pop(sheet, p),
        ),
      ),
    ),
  );
  if (preset == null) return;
  if (remind && !await reminders.requestPermission()) {
    remind = false;
    onMessage('No reminder without permission.');
  }
  final id = await dao.commit(view.task.id, preset, remind: remind);
  if (id == null) return onMessage('Already promised today.');
  if (everyDay) {
    final c = (await dao.load(today)).firstWhere((v) => v.commitment.id == id);
    final at = c.commitment.deadline;
    await dao.setStanding(view.task.id, at.hour * 60 + at.minute);
  }
  final note = await dao.loadNote(today);
  onMessage(note == null ? 'Promised.' : loadNoteText(note));
}

/// Offers the presets later than the current deadline (plan D10).
Future<void> showExtendSheet(
  BuildContext context,
  WidgetRef ref,
  String taskId, {
  required ValueChanged<String> onMessage,
}) async {
  final dao = ref.read(commitmentDaoProvider);
  final view = (await dao.watchToday().first)[taskId];
  if (view == null || !context.mounted) return;
  final c = view.commitment;
  final now = ref.read(clockProvider)();
  final hour = await ref.read(databaseProvider).rolloverHour();
  final flasks = await ref.read(flaskDaoProvider).count();
  if (!context.mounted) return;
  final options = [
    for (final p in DeadlinePreset.values)
      if (deadlineFor(p, now, rolloverHour: hour).isAfter(c.deadline)) p,
  ];
  if (options.isEmpty) return onMessage('It cannot move later today.');
  final preset = await showModalBottomSheet<DeadlinePreset>(
    context: context,
    backgroundColor: kSurface,
    builder: (sheet) => SafeArea(
      child: ExtendSheet(
        options: options,
        costsFlask: c.extensions >= 1,
        flasks: flasks,
        onExtend: (p) => Navigator.pop(sheet, p),
      ),
    ),
  );
  if (preset == null) return;
  final moved = await dao.extend(c.id, preset);
  onMessage(moved ? 'Moved later.' : 'It cannot move later.');
}
