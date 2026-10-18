import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/boss_view.dart';
import '../../data/enums.dart';
import '../../data/providers.dart';
import '../../ui/ember_tally.dart';
import '../../ui/foes_header.dart';
import '../../ui/glass_tab_bar.dart';
import '../../ui/filter_chips.dart';
import '../../ui/flash_line.dart';
import '../../ui/plan_banner.dart';
import '../../ui/thread_divider.dart';
import '../../ui/player_health_bar.dart';
import '../../core/commitment_resolver.dart';
import '../boss/task_row.dart';

/// The day's tasks for one boss, in Today order (plan §8.3): open daily
/// tasks, then the current phase, then standalone; struck dailies last.
List<TaskView> todayTasks(BossView view) {
  final daily = view.allTasks.where((t) => t.isDaily);
  return [
    ...daily.where((t) => !t.isStruck),
    ...?view.currentPhase?.tasks.where((t) => !t.isDaily && !t.isStruck),
    ...view.standalone.where((t) => !t.isDaily && !t.isStruck),
    ...daily.where((t) => t.isStruck),
  ];
}

/// Today: tasks from every active boss, grouped by boss, with a filter.
class TodayView extends ConsumerStatefulWidget {
  const TodayView({
    super.key,
    required this.bosses,
    required this.tapMode,
    this.leading = const [],
    this.onNewFoe,
  });

  final List<BossView> bosses;
  final bool tapMode;

  /// Shown above the list (Home's header and panels).
  final List<Widget> leading;

  /// When set, the title row carries a "New foe" button and the count line
  /// reads "N of M struck" (Home); otherwise Today's long form.
  final VoidCallback? onNewFoe;

  @override
  ConsumerState<TodayView> createState() => _TodayViewState();
}

class _TodayViewState extends ConsumerState<TodayView> {
  String? _filter;
  String? _flash;

  void _say(String message) {
    if (mounted) setState(() => _flash = message);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final active = widget.bosses
        .where((b) => b.boss.status == BossStatus.active)
        .toList();
    final tally = ref.watch(emberTallyProvider).value;
    final health = ref.watch(healthProvider).value;
    final picks = ref.watch(todayPicksProvider).value ?? const [];
    final struck = ref.watch(daySummaryProvider).value?.strikes ?? 0;
    final groups = [
      for (final b in active)
        if (_filter == null || _filter == b.boss.id) (b, todayTasks(b)),
    ].where((g) => g.$2.isNotEmpty).toList();

    final open = [
      for (final (_, tasks) in groups) ...tasks.where((t) => !t.isStruck),
    ].length;
    final isHome = widget.onNewFoe != null;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        isHome ? 0 : 20,
        0,
        isHome ? 0 : 20,
        GlassTabBar.clearance + Space.md,
      ),
      children: [
        ...widget.leading,
        if (health != null && !isHome)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.sm),
            child: PlayerHealthBar(health: health, max: kMaxHealthHalfPoints),
          ),
        if (tally != null && !isHome)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.sm),
            child: EmberTally(carried: tally.carried, banked: tally.banked),
          ),
        if (picks.isNotEmpty && !isHome)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.md),
            child: PlanBanner(
              items: [
                for (final p in picks)
                  PlanItem(
                    title: p.task.title,
                    bossTitle: p.bossTitle,
                    isDone: p.isStruck,
                  ),
              ],
            ),
          ),
        if (active.length > 1)
          FilterChips<String>(
            labels: {
              null: 'All',
              for (final b in active) b.boss.id: b.boss.title,
            },
            selected: _filter,
            onChanged: (id) => setState(() => _filter = id),
          ),
        FlashLine(_flash),
        if (isHome)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, Space.xs),
            child: FoesHeader(
              countLabel: '$struck of ${open + struck} struck',
              onNewFoe: widget.onNewFoe!,
            ),
          )
        else ...[
          Text('Today’s tasks', style: text.titleMedium),
          if (open + struck > 0)
            Padding(
              padding: const EdgeInsets.only(top: Space.xs, bottom: Space.sm),
              child: Text(
                '$struck of ${open + struck} struck · hold to strike',
                style: text.bodySmall,
              ),
            ),
        ],
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isHome ? 20 : 0),
          child: const ThreadDivider(),
        ),
        if (open == 0)
          Padding(
            padding: const EdgeInsets.only(top: Space.xl),
            child: Text(
              struck > 0
                  ? 'All tasks struck. Rest at the bonfire'
                  : 'Nothing stands in your way today.',
              textAlign: TextAlign.center,
              style: text.bodyLarge,
            ),
          ),
        for (final (boss, tasks) in groups)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isHome ? 20 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          boss.boss.title.toUpperCase(),
                          style: text.labelSmall,
                        ),
                      ),
                      if (!isHome)
                        Text(
                          '${tasks.where((t) => t.isStruck).length} of '
                          '${tasks.length} struck',
                          style: text.bodySmall,
                        ),
                    ],
                  ),
                ),
                for (final t in tasks)
                  TaskRow(
                    view: t,
                    tapMode: widget.tapMode,
                    onMessage: _say,
                    bossName: boss.boss.title,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
