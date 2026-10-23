import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/clock.dart';
import '../../core/roman.dart';
import '../../core/days_left.dart';
import '../../data/boss_view.dart';
import '../../data/day_boss.dart';
import '../../data/enums.dart';
import '../../data/providers.dart';
import '../../ui/boss_card_actions_sheet.dart';
import '../../ui/boss_card_tile.dart';
import '../../ui/glass_sheet.dart';
import '../../ui/pinned_boss_panel.dart';
import '../shell/atmosphere.dart';

/// The card's progress line: The Day counts today's tasks; other bosses
/// name their chapter.
String bossProgressLabel(BossView view) {
  if (view.isDay) {
    final all = view.allTasks;
    if (all.isEmpty) return 'No tasks today';
    return '${all.where((t) => t.isStruck).length} of ${all.length} struck today';
  }
  if (!view.hasSegments) return 'Daily tasks';
  final fighting = view.phases
      .where((p) => p.tasks.any((t) => t.isSegment))
      .toList();
  final current = view.currentPhase;
  return current == null
      ? 'All chapters done'
      : 'Chapter ${romanNumeral(fighting.indexOf(current) + 1)} of '
            '${romanNumeral(fighting.length)}';
}

/// One boss on the home list (§6.1). Long-press for pin and status.
class BossCard extends ConsumerWidget {
  const BossCard({super.key, required this.view});

  final BossView view;

  Future<void> _actions(BuildContext context, WidgetRef ref) async {
    final boss = view.boss;
    final dao = ref.read(bossDaoProvider);
    final isActive = boss.status == BossStatus.active;
    final choice = await showGlassSheet<BossCardAction>(
      context,
      (_) => BossCardActionsSheet(
        title: boss.title,
        isPinned: boss.isPinned,
        // The Day always stays active; a won boss stays won.
        statusLabel: boss.id == dayBossId || boss.status == BossStatus.defeated
            ? null
            : isActive
            ? 'Set waiting'
            : 'Set active',
      ),
    );
    switch (choice) {
      case BossCardAction.pin:
        await dao.setPinned(boss.id, isPinned: !boss.isPinned);
      case BossCardAction.status:
        await dao.setStatus(
          boss.id,
          isActive ? BossStatus.waiting : BossStatus.active,
        );
      case null:
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boss = view.boss;
    if (boss.isPinned && boss.status == BossStatus.active) {
      return PinnedBossPanel(
        title: boss.title,
        subtitle: [
          bossProgressLabel(view),
          'Attempt ${boss.attemptNumber}',
          ?daysLeftLabel(boss.targetDate, ref.read(clockProvider)()),
        ].join(' · '),
        health: view.health,
        boilFrame: Atmosphere.boilFrameOf(context),
        onEnter: () => context.push('/boss/${boss.id}'),
        onLongPress: () => _actions(context, ref),
      );
    }
    return BossCardTile(
      title: boss.title,
      attemptNumber: boss.attemptNumber,
      progressLabel: bossProgressLabel(view),
      health: view.health,
      isPinned: boss.isPinned,
      showHealth: boss.status == BossStatus.active && view.hasSegments,
      boilFrame: Atmosphere.boilFrameOf(context),
      onTap: () => context.push('/boss/${boss.id}'),
      onLongPress: () => _actions(context, ref),
    );
  }
}
