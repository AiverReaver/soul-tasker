import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/clock.dart';
import '../../core/deadlines.dart';
import '../../core/theme.dart';
import '../../data/boss_view.dart';
import '../../data/enums.dart';
import '../../data/providers.dart';
import '../../ui/confirm_dialog.dart';
import '../../ui/deadline_chip.dart';
import '../commit/commit_flow.dart';
import '../fallen/health_fall.dart';
import '../strike/boss_vanish.dart';
import '../strike/hold_to_strike.dart';
import 'rule_of_three_sheet.dart';

enum _Action { promise, extend, tried, edit, delete }

/// A task with hold-to-strike and its "..." menu. Shared by the boss screen
/// and Today, so strike, tried and their prompts behave the same in both.
class TaskRow extends ConsumerWidget {
  const TaskRow({
    super.key,
    required this.view,
    required this.tapMode,
    required this.onMessage,
    this.canCommit = true,
    this.bossName,
  });

  final TaskView view;

  /// False for a waiting or defeated boss (Stage 4 plan D11).
  final bool canCommit;
  final bool tapMode;

  /// Opens the row's meta line; omit where the boss is obvious.
  final String? bossName;

  /// Shows a quiet one-line message on the host screen.
  final ValueChanged<String> onMessage;

  String get _bossId => view.task.bossId;

  Future<void> _strike(BuildContext context, WidgetRef ref) async {
    final health = ref.read(healthDaoProvider);
    final wasAlive = !await health.isDeadToday();
    final result = await ref.read(attemptDaoProvider).strike(view.task.id);
    // Settling a passed deadline first can deal the final blow.
    if (wasAlive && await health.isDeadToday()) {
      final day = await health.today();
      if (context.mounted) await showHealthFall(context, ref, day);
    }
    if (!context.mounted) return;
    if (!result.isVanquished) return onMessage('It is done.');
    await confirmDefeat(context, ref, _bossId);
  }

  Future<void> _act(BuildContext context, WidgetRef ref, _Action action) async {
    switch (action) {
      case _Action.promise:
        await showCommitSheet(context, ref, view, onMessage: onMessage);
      case _Action.extend:
        await showExtendSheet(context, ref, view.task.id, onMessage: onMessage);
      case _Action.tried:
        final health = ref.read(healthDaoProvider);
        final wasAlive = !await health.isDeadToday();
        final prompt = await ref.read(attemptDaoProvider).tried(view.task.id);
        onMessage('You tried. That counts.');
        // A broken promise can deal the final blow (plan D7).
        if (wasAlive && await health.isDeadToday()) {
          final day = await health.today();
          if (context.mounted) await showHealthFall(context, ref, day);
        }
        if (prompt && context.mounted) {
          await showRuleOfThree(
            context,
            ref,
            bossId: _bossId,
            task: view,
            onMessage: onMessage,
          );
        }
      case _Action.edit:
        context.push('/boss/$_bossId/edit');
      case _Action.delete:
        final ok = await confirm(
          context,
          'Delete "${view.task.title}"?',
          action: 'Delete',
        );
        if (ok) await ref.read(bossDaoProvider).deleteTask(view.task.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = view.task;
    final promise = ref
        .watch(todayCommitmentsProvider)
        .value?[task.id]
        ?.commitment;
    final now = ref.read(clockProvider)();
    final label = promise == null
        ? null
        : deadlineLabel(promise.outcome, promise.deadline, now);
    final canExtend =
        promise != null &&
        promise.outcome == null &&
        now.isBefore(promise.deadline);
    return HoldToStrike(
      key: ValueKey(task.id),
      title: task.recurrence == Recurrence.daily
          ? '${task.title} · daily'
          : task.title,
      weight: task.weight,
      isDone: view.isStruck,
      bossName: bossName,
      tapMode: tapMode,
      onStrike: () => _strike(context, ref),
      onTried: () => _act(context, ref, _Action.tried),
      deadline: label == null
          ? null
          : DeadlineChip(label: label.text, isSoon: label.isSoon),
      menu: PopupMenuButton<_Action>(
        tooltip: 'Actions for ${task.title}',
        iconColor: context.palette.ash,
        onSelected: (a) => _act(context, ref, a),
        itemBuilder: (_) => [
          if (canCommit && promise == null && !view.isStruck)
            const PopupMenuItem(
              value: _Action.promise,
              child: Text('Promise by…'),
            ),
          if (canExtend)
            const PopupMenuItem(
              value: _Action.extend,
              child: Text('Move it later'),
            ),
          if (!view.isStruck)
            const PopupMenuItem(
              value: _Action.tried,
              child: Text('Mark as tried'),
            ),
          const PopupMenuItem(value: _Action.edit, child: Text('Edit')),
          const PopupMenuItem(value: _Action.delete, child: Text('Delete')),
        ],
      ),
    );
  }
}

/// Asks "Mark this boss as defeated?" (D3), then defeats the boss and opens
/// the victory screen (Stage 5 plan D6).
Future<void> confirmDefeat(
  BuildContext context,
  WidgetRef ref,
  String bossId,
) async {
  final ok = await confirm(
    context,
    'Mark this boss as defeated?',
    action: 'Defeated',
  );
  if (!ok) return;
  final name = (await ref.read(bossDaoProvider).loadBoss(bossId))?.boss.title;
  await ref.read(bossDaoProvider).setStatus(bossId, BossStatus.defeated);
  if (name != null && context.mounted) await showBossVanish(context, name);
  final relicId = await ref.read(relicDaoProvider).idForBoss(bossId);
  if (relicId != null && context.mounted) {
    await context.push('/victory/$relicId');
  }
}

/// A calm yes/no dialog. Returns true only on the action button.
Future<bool> confirm(
  BuildContext context,
  String question, {
  required String action,
}) async {
  final answer = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(question: question, action: action),
  );
  return answer ?? false;
}
