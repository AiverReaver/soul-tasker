import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/level.dart';
import '../../core/theme.dart';
import '../../data/boss_view.dart';
import '../../data/enums.dart';
import '../../data/providers.dart';
import '../../core/clock.dart';
import '../../ui/bonfire_card.dart';
import '../../ui/home_header.dart';
import '../today/today_view.dart';
import 'boss_card.dart';

/// Home (§6.1): the boss list and the Today view.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.showToday = false});

  /// The Today tab; the bottom bar (HearthShell) switches it by route.
  final bool showToday;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Widget _header() {
    final now = ref.watch(clockProvider)();
    final profile = ref.watch(profileProvider).value;
    final level = profile?.level;
    // Bars fill with the share of this level's embers already earned.
    final bars = level == null
        ? 0
        : (5 * (1 - level.toNext / (level.level * kLevelStep))).round();
    return HomeHeader(
      dateLine: formatDayLabel(dayOf(now)),
      greeting: greetingFor(now.hour),
      embers: profile?.banked ?? 0,
      level: level?.level ?? 1,
      levelBars: bars.clamp(0, 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final bosses = ref.watch(bossListProvider);
    final tapMode = ref.watch(settingsProvider).value?.tapMode ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text('HEARTHRISE', style: text.labelSmall),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: Icon(Icons.person_outline, color: context.palette.ash),
            onPressed: () => context.go('/profile'),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: Icon(Icons.tune, color: context.palette.ash),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, Space.sm),
              child: BonfireCard(
                isRested: ref.watch(dayStatusProvider).value?.isRested ?? false,
                onTap: () => context.go('/bonfire'),
              ),
            ),
            const SizedBox(height: Space.sm),
            Expanded(
              child: switch (bosses) {
                AsyncData(:final value) =>
                  widget.showToday
                      ? TodayView(bosses: value, tapMode: tapMode)
                      : _BossList(bosses: value),
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
