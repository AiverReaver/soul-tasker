import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/boss_view.dart';
import '../../data/enums.dart';
import '../../data/providers.dart';
import 'boss_card.dart';

/// Every boss: active ones first, waiting ones folded below (C3 restyles it).
class BossesScreen extends ConsumerWidget {
  const BossesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('All bosses')),
    body: SafeArea(
      child: switch (ref.watch(bossListProvider)) {
        AsyncData(:final value) => _BossList(bosses: value),
        AsyncError() => const Center(
          child: Text('Could not load your bosses.'),
        ),
        _ => const SizedBox.shrink(),
      },
    ),
  );
}

class _BossList extends StatelessWidget {
  const _BossList({required this.bosses});

  final List<BossView> bosses;

  List<BossView> _with(BossStatus status) =>
      bosses.where((b) => b.boss.status == status).toList();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final active = _with(BossStatus.active);
    final waiting = _with(BossStatus.waiting);
    final newBoss = TextButton(
      onPressed: () => context.push('/boss/new'),
      child: const Text('Name a new boss'),
    );

    // Defeated bosses live on as relics, not on Home (Stage 5 plan D8).
    if (active.isEmpty && waiting.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No boss stands before you.', style: text.bodyLarge),
            const SizedBox(height: Space.md),
            newBoss,
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, Space.xl),
      children: [
        for (final b in active) BossCard(view: b),
        const SizedBox(height: Space.sm),
        newBoss,
        if (waiting.isNotEmpty) _section(context, 'Waiting', waiting),
      ],
    );
  }

  Widget _section(BuildContext context, String title, List<BossView> list) {
    final text = Theme.of(context).textTheme;
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      shape: const Border(),
      collapsedShape: const Border(),
      title: Text(
        '${title.toUpperCase()} (${list.length})',
        style: text.labelSmall,
      ),
      children: [for (final b in list) BossCard(view: b)],
    );
  }
}
