import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/boss_view.dart';
import '../../data/enums.dart';
import '../../data/providers.dart';
import '../../ui/collapsible_section.dart';
import '../../ui/glass_tab_bar.dart';
import '../../ui/glass_pill_button.dart';
import 'boss_card.dart';

/// Every boss: the pinned one first, then the other active ones, with the
/// waiting bosses folded below (D10).
class BossesScreen extends ConsumerWidget {
  const BossesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, Space.sm, 20, Space.md),
            // A root tab: no back button (audit #9).
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'All bosses',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          Expanded(
            child: switch (ref.watch(bossListProvider)) {
              AsyncData(:final value) => _BossList(bosses: value),
              AsyncError() => const Center(
                child: Text('Could not load your bosses.'),
              ),
              _ => const SizedBox.shrink(),
            },
          ),
        ],
      ),
    ),
  );
}

class _BossList extends StatefulWidget {
  const _BossList({required this.bosses});

  final List<BossView> bosses;

  @override
  State<_BossList> createState() => _BossListState();
}

class _BossListState extends State<_BossList> {
  bool _showWaiting = false;

  // The Day lives on Home, not in this list.
  List<BossView> _with(BossStatus status) =>
      widget.bosses.where((b) => b.boss.status == status && !b.isDay).toList();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final active = _with(BossStatus.active);
    final waiting = _with(BossStatus.waiting);
    final newBossButton = GlassPillButton(
      label: 'Name a new boss',
      onTap: () => context.push('/boss/new'),
    );
    final newBoss = Align(
      alignment: Alignment.centerLeft,
      child: newBossButton,
    );

    // Defeated bosses live on as relics, not here (Stage 5 plan D8).
    if (active.isEmpty && waiting.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No boss stands before you.', style: text.bodyLarge),
            const SizedBox(height: Space.md),
            newBossButton,
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        GlassTabBar.clearance + Space.md,
      ),
      children: [
        for (final b in active) BossCard(view: b),
        const SizedBox(height: Space.sm),
        newBoss,
        if (waiting.isNotEmpty)
          CollapsibleSection(
            title: 'Waiting (${waiting.length})',
            isExpanded: _showWaiting,
            onToggle: () => setState(() => _showWaiting = !_showWaiting),
            child: Column(
              children: [for (final b in waiting) BossCard(view: b)],
            ),
          ),
      ],
    );
  }
}
