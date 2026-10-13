import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/boss_view.dart';
import '../../data/enums.dart';
import '../../data/providers.dart';
import '../boss/boss_health_bar.dart';

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
      backgroundColor: kSurface,
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
    final text = Theme.of(context).textTheme;
    final boss = view.boss;
    final isActive = boss.status == BossStatus.active;
    return Semantics(
      label:
          'Boss ${boss.title}, attempt ${boss.attemptNumber}, '
          '${(view.health * 100).round()} percent health',
      button: true,
      excludeSemantics: true,
      child: Card(
        color: kSurface,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: kAshDim.withValues(alpha: 0.3)),
        ),
        child: InkWell(
          onTap: () => context.push('/boss/${boss.id}'),
          onLongPress: () => _actions(context, ref),
          child: Padding(
            padding: const EdgeInsets.all(Space.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(boss.title, style: text.titleMedium)),
                    if (boss.isPinned) Text('Pinned', style: text.bodySmall),
                  ],
                ),
                const SizedBox(height: Space.xs),
                Text(
                  'Attempt ${boss.attemptNumber} · $_progress',
                  style: text.bodySmall,
                ),
                if (isActive && view.hasSegments) ...[
                  const SizedBox(height: Space.sm),
                  BossHealthBar(view: view, height: 6),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
