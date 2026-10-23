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
import '../../ui/all_bosses_row.dart';
import '../boss_edit/new_foe_sheet.dart';
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
      percentToNext: level == null
          ? 0
          : (100 * (1 - level.toNext / (level.level * kLevelStep))).round(),
      onProfile: () => context.go('/profile'),
      onSettings: () => context.push('/settings'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final bosses = ref.watch(bossListProvider);
    final tapMode = ref.watch(settingsProvider).value?.tapMode ?? false;

    return Scaffold(
      body: SafeArea(
        child: switch (bosses) {
          AsyncData(:final value) =>
            widget.showToday
                ? Column(
                    children: [
                      _header(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, Space.sm),
                        child: BonfireCard(
                          isRested:
                              ref.watch(dayStatusProvider).value?.isRested ??
                              false,
                          onTap: () => context.go('/bonfire'),
                        ),
                      ),
                      Expanded(
                        child: TodayView(bosses: value, tapMode: tapMode),
                      ),
                    ],
                  )
                : TodayView(
                    bosses: value,
                    tapMode: tapMode,
                    leading: [
                      _header(),
                      ..._pinned(value),
                      AllBossesRow(
                        active: _count(value, BossStatus.active),
                        waiting: _count(value, BossStatus.waiting),
                        onTap: () => context.push('/bosses'),
                      ),
                    ],
                    onNewFoe: () => _newFoe(value),
                  ),
          AsyncError() => Center(
            child: Text('Could not load your bosses.', style: text.bodyLarge),
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  /// The Day is not counted: it is always there.
  int _count(List<BossView> bosses, BossStatus status) =>
      bosses.where((b) => b.boss.status == status && !b.isDay).length;

  Iterable<Widget> _pinned(List<BossView> bosses) sync* {
    final pinned = bosses.where(
      (b) => b.boss.isPinned && b.boss.status == BossStatus.active,
    );
    for (final b in pinned.take(1)) {
      yield Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: BossCard(view: b),
      );
    }
  }

  void _newFoe(List<BossView> bosses) {
    final active = bosses
        .where((b) => b.boss.status == BossStatus.active)
        .toList();
    if (active.isEmpty) {
      context.push('/boss/new');
      return;
    }
    showNewFoeSheet(context, ref, bosses: active);
  }
}
