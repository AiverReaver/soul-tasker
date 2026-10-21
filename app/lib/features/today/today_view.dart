import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/roman.dart';
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
import '../../ui/task_group_header.dart';
import '../../core/commitment_resolver.dart';
import '../boss/task_row.dart';

/// One run of rows under a label: a boss's dailies, its current chapter, or
/// its tasks beyond the chapters.
class TodayGroup {
  const TodayGroup(this.label, this.tasks, this.count);

  final String label;
  final List<TaskView> tasks;

  /// "N of M" struck, over every task of the group.
  final String count;
}

/// The day's groups for one boss, in Today order (plan §8.3): dailies, then
/// the current chapter, then standalone. Open rows lead each group; struck
/// dailies stay at its foot. A task in [lingering] was struck a moment ago:
/// it keeps its open slot while its strike animation plays.
List<TodayGroup> todayGroups(
  BossView view, {
  Set<String> lingering = const {},
}) {
  bool isOpen(TaskView t) => !t.isStruck || lingering.contains(t.task.id);
  TodayGroup? group(String label, List<TaskView> all) {
    final shown = [
      ...all.where(isOpen),
      ...all.where((t) => !isOpen(t) && t.isDaily),
    ];
    if (shown.isEmpty) return null;
    return TodayGroup(
      label,
      shown,
      '${all.where((t) => t.isStruck).length} of ${all.length}',
    );
  }

  final title = view.boss.title;
  final current = view.currentPhase;
  return [
    group('$title · daily', view.allTasks.where((t) => t.isDaily).toList()),
    if (current != null)
      group(
        '$title · Chapter ${romanNumeral(view.currentPhaseNumber!)} · '
        '${current.phase.name}',
        current.tasks.where((t) => !t.isDaily).toList(),
      ),
    group(title, view.standalone.where((t) => !t.isDaily).toList()),
  ].nonNulls.toList();
}

/// How long a freshly struck row keeps its slot: the strike's beats and the
/// dust that follows.
const strikeLinger = Duration(milliseconds: 1500);

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
  final _lingering = <String>{};
  final _timers = <Timer>[];

  @override
  void didUpdateWidget(TodayView old) {
    super.didUpdateWidget(old);
    final wasOpen = {
      for (final b in old.bosses)
        for (final t in b.allTasks)
          if (!t.isStruck) t.task.id,
    };
    for (final b in widget.bosses) {
      for (final t in b.allTasks) {
        if (t.isStruck && wasOpen.contains(t.task.id)) {
          final id = t.task.id;
          _lingering.add(id);
          _timers.add(
            Timer(strikeLinger, () {
              if (mounted) setState(() => _lingering.remove(id));
            }),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

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
        if (_filter == null || _filter == b.boss.id)
          ...todayGroups(b, lingering: _lingering),
    ];

    final open = [for (final g in groups) ...g.tasks.where((t) => !t.isStruck)]
        .length;
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
            padding: EdgeInsets.symmetric(horizontal: isHome ? 20 : 0),
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
        for (final g in groups)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isHome ? 20 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TaskGroupHeader(label: g.label, count: g.count),
                for (final t in g.tasks)
                  TaskRow(
                    key: ValueKey(t.task.id),
                    view: t,
                    tapMode: widget.tapMode,
                    onMessage: _say,
                    compact: true,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
