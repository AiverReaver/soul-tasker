import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/boss_view.dart';
import '../../data/enums.dart';
import '../../data/providers.dart';
import '../today/today_view.dart';
import 'boss_card.dart';
import 'settings_sheet.dart';

enum _Tab { bosses, today }

/// Home (§6.1): the boss list and the Today view.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  _Tab _tab = _Tab.bosses;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final bosses = ref.watch(bossListProvider);
    final tapMode = ref.watch(settingsProvider).value?.tapMode ?? false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackground,
        title: Text('HEARTHRISE', style: text.labelSmall),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.tune, color: kTextMuted),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              backgroundColor: kSurface,
              builder: (_) => const SettingsSheet(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SegmentedButton<_Tab>(
                segments: const [
                  ButtonSegment(value: _Tab.bosses, label: Text('Bosses')),
                  ButtonSegment(value: _Tab.today, label: Text('Today')),
                ],
                selected: {_tab},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _tab = s.single),
              ),
            ),
            const SizedBox(height: Space.sm),
            Expanded(
              child: switch (bosses) {
                AsyncData(:final value) =>
                  _tab == _Tab.bosses
                      ? _BossList(bosses: value)
                      : TodayView(bosses: value, tapMode: tapMode),
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
    final defeated = _with(BossStatus.defeated);
    final newBoss = TextButton(
      onPressed: () => context.push('/boss/new'),
      child: const Text('Name a new boss'),
    );

    if (bosses.isEmpty) {
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
        if (defeated.isNotEmpty) _section(context, 'Vanquished', defeated),
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
