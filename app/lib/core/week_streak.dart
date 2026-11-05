import 'package:flutter/foundation.dart' show immutable;

import 'missed_days.dart';

/// One day of the Monday-to-Sunday row.
@immutable
class WeekDayMark {
  const WeekDayMark(this.label, {required this.isKept, required this.isToday});

  final String label;
  final bool isKept;
  final bool isToday;
}

/// The unbroken run of kept days, and this week's row.
@immutable
class WeekStreak {
  const WeekStreak({required this.days, required this.week});

  final int days;
  final List<WeekDayMark> week;

  int get keptThisWeek => week.where((d) => d.isKept).length;
}

/// Reads [kept] (days as `YYYY-MM-DD`) from [today]. Today has not ended, so
/// leaving it open does not break the run.
WeekStreak weekStreakOn({required String today, required Set<String> kept}) {
  var days = 0;
  var d = kept.contains(today) ? today : shiftDay(today, -1);
  while (kept.contains(d)) {
    days++;
    d = shiftDay(d, -1);
  }
  final monday = shiftDay(today, 1 - DateTime.parse(today).weekday);
  return WeekStreak(
    days: days,
    week: [
      for (final (i, label) in const [
        'M',
        'T',
        'W',
        'T',
        'F',
        'S',
        'S',
      ].indexed)
        WeekDayMark(
          label,
          isKept: kept.contains(shiftDay(monday, i)),
          isToday: shiftDay(monday, i) == today,
        ),
    ],
  );
}
