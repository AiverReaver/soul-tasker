import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/boss_view.dart';
import '../../data/enums.dart';
import '../../data/providers.dart';
import '../../ui/boss_card_tile.dart';
import '../../ui/pinned_boss_panel.dart';
import '../shell/atmosphere.dart';

/// One boss on the home list (§6.1). Long-press for pin and status.
class BossCard extends ConsumerWidget {
  const BossCard({super.key, required this.view});

  final BossView view;

  String get _progress {
    if (!view.hasSegments) return 'Daily foes';
    final fighting = view.phases
        .where((p) => p.tasks.any((t) => t.isSegment))
        .toList();
    final current = view.currentPhase;
    return current == null
        ? 'All phases done'
        : 'Phase ${fighting.indexOf(current) + 1} of ${fighting.length}';
  }

  Future<void> _actions(BuildContext context, WidgetRef ref) async {
    final boss = view.boss;
    final dao = ref.read(bossDaoProvider);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.shell,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              minTileHeight: kMinTarget,
              title: Text(boss.isPinned ? 'Unpin' : 'Pin'),
              onTap: () {
                Navigator.pop(sheet);
                dao.setPinned(boss.id, isPinned: !boss.isPinned);
              },
            ),
            if (boss.status != BossStatus.defeated)
              ListTile(
                minTileHeight: kMinTarget,
                title: Text(
                  boss.status == BossStatus.active
                      ? 'Set waiting'
                      : 'Set active',
                ),
                onTap: () {
                  Navigator.pop(sheet);
                  dao.setStatus(
                    boss.id,
                    boss.status == BossStatus.active
                        ? BossStatus.waiting
                        : BossStatus.active,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boss = view.boss;
    if (boss.isPinned && boss.status == BossStatus.active) {
      return PinnedBossPanel(
        title: boss.title,
        subtitle: 'Attempt ${boss.attemptNumber} · $_progress',
        health: view.health,
        boilFrame: Atmosphere.boilFrameOf(context),
        onEnter: () => context.push('/boss/${boss.id}'),
        onLongPress: () => _actions(context, ref),
      );
    }
    return BossCardTile(
      title: boss.title,
      attemptNumber: boss.attemptNumber,
      progressLabel: _progress,
      health: view.health,
      isPinned: boss.isPinned,
      showHealth: boss.status == BossStatus.active && view.hasSegments,
      boilFrame: Atmosphere.boilFrameOf(context),
      onTap: () => context.push('/boss/${boss.id}'),
      onLongPress: () => _actions(context, ref),
    );
  }
}
