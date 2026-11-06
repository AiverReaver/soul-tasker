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
import '../boss_edit/new_foe_sheet.dart';
import '../../ui/home_header.dart';
import '../../ui/week_streak_card.dart';
import '../today/today_view.dart';
import 'boss_card.dart';

/// Whether Today shows the bonfire card: in the evening (17:00 to 05:00,
/// the "Evening." greeting), once every task of the day is struck, or after
/// the rest, when it reads "Rested" (first-session audit #9).
bool showsBonfireCard({
  required int hour,
  required bool isRested,
  required int total,
  required int struck,
}) => isRested || hour >= 17 || hour < 5 || (total > 0 && struck == total);

/// Today (§6.1): the one main screen. Home and the Today tab merged here;
/// bosses have their own tab (first-session audit #9).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Widget _header() {
    final now = ref.watch(clockProvider)();
    final profile = ref.watch(profileProvider).value;
    // Earned embers show at once; resting banks them.
    final tally = ref.watch(emberTallyProvider).value;
    final level = profile?.level;
    // Bars fill with the share of this level's embers already earned.
    final bars = level == null
        ? 0
        : (5 * (1 - level.toNext / (level.level * kLevelStep))).round();
    return HomeHeader(
      dateLine: formatDayLabel(dayOf(now)),
      greeting: greetingFor(now.hour),
      embers: tally == null ? 0 : tally.carried + tally.banked,
      level: level?.level ?? 1,
      levelBars: bars.clamp(0, 5),
      percentToNext: level == null
          ? 0
          : (100 * (1 - level.toNext / (level.level * kLevelStep))).round(),
      onSettings: () => context.push('/settings'),
    );
  }

  Iterable<Widget> _bonfire(List<BossView> bosses) sync* {
    final isRested = ref.watch(dayStatusProvider).value?.isRested ?? false;
    final groups = [
      for (final b in bosses)
        if (b.boss.status == BossStatus.active) ...todayGroups(b),
    ];
    final show = showsBonfireCard(
      hour: ref.watch(clockProvider)().hour,
      isRested: isRested,
      total: groups.fold(0, (n, g) => n + g.total),
      struck: groups.fold(0, (n, g) => n + g.struck),
    );
    if (!show) return;
    yield Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, Space.sm),
      child: BonfireCard(
        isRested: isRested,
        onTap: () => context.push('/bonfire'),
      ),
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
          AsyncData(:final value) => TodayView(
            bosses: value,
            tapMode: tapMode,
            leading: [_header(), ..._bonfire(value), ..._pinned(value)],
            // Below the list, so the tasks sit high (audit #9).
            trailing: [
              if (ref.watch(weekStreakProvider).value case final streak?)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, Space.lg, 20, 6),
                  child: WeekStreakCard(streak: streak),
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
