import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import '../core/week_streak.dart';
import 'needle_frame.dart';

/// The streak on Home: the unbroken count over this week's seven diamonds.
class WeekStreakCard extends StatelessWidget {
  const WeekStreakCard({super.key, required this.streak});

  final WeekStreak streak;

  String get _count => switch (streak.days) {
    0 => 'Begins today',
    1 => '1 day unbroken',
    final n => '$n days unbroken',
  };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    return Semantics(
      label: 'Streak: $_count. ${streak.keptThisWeek} of 7 days kept this week',
      excludeSemantics: true,
      child: NeedleFrame(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Row(
                children: [
                  Expanded(child: Text('STREAK', style: text.labelSmall)),
                  Text(_count, style: text.bodySmall!.copyWith(color: p.text)),
                ],
              ),
              Row(
                children: [
                  for (final day in streak.week)
                    Expanded(
                      child: Column(
                        spacing: 6,
                        children: [
                          Text(
                            day.label,
                            style: text.labelSmall!.copyWith(
                              letterSpacing: 0,
                              color: day.isToday ? p.bone : p.ash,
                            ),
                          ),
                          _DayDiamond(day),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayDiamond extends StatelessWidget {
  const _DayDiamond(this.day);

  final WeekDayMark day;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Transform.rotate(
      angle: math.pi / 4,
      child: SizedBox.square(
        dimension: 11,
        child: DecoratedBox(
          key: day.isToday ? const ValueKey('day-today-ring') : null,
          decoration: BoxDecoration(
            border: day.isToday ? Border.all(color: p.bone) : null,
          ),
          child: Center(
            child: SizedBox.square(
              dimension: 7,
              child: DecoratedBox(
                key: ValueKey(day.isKept ? 'day-kept' : 'day-open'),
                decoration: BoxDecoration(
                  color: day.isKept ? p.silk : null,
                  border: day.isKept ? null : Border.all(color: p.dim),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
