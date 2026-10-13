import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/boss_view.dart';
import '../../data/enums.dart';
import '../../ui/flash_line.dart';
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
  const TodayView({super.key, required this.bosses, required this.tapMode});

  final List<BossView> bosses;
  final bool tapMode;

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
    final groups = [
      for (final b in active)
        if (_filter == null || _filter == b.boss.id) (b, todayTasks(b)),
    ].where((g) => g.$2.isNotEmpty).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, Space.xl),
      children: [
        if (active.length > 1)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip('All', null),
                for (final b in active) _chip(b.boss.title, b.boss.id),
              ],
            ),
          ),
        FlashLine(_flash),
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: Space.xl),
            child: Text(
              'Nothing stands in your way today.',
              textAlign: TextAlign.center,
              style: text.bodyLarge,
            ),
          ),
        for (final (boss, tasks) in groups) ...[
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 6),
            child: Text(boss.boss.title.toUpperCase(), style: text.labelSmall),
          ),
          for (final t in tasks)
            TaskRow(view: t, tapMode: widget.tapMode, onMessage: _say),
        ],
      ],
    );
  }

  Widget _chip(String label, String? id) => Padding(
    padding: const EdgeInsets.only(right: Space.sm),
    child: ChoiceChip(
      label: Text(label),
      selected: _filter == id,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      onSelected: (_) => setState(() => _filter = id),
    ),
  );
}
