import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/week_streak.dart';

void main() {
  // 2026-11-05 is a Thursday.
  const thu = '2026-11-05';

  test('counts kept days back from today', () {
    final s = weekStreakOn(today: thu, kept: {'2026-11-03', '2026-11-04', thu});
    expect(s.days, 3);
  });

  test('a today not yet kept does not break it', () {
    final s = weekStreakOn(today: thu, kept: {'2026-11-03', '2026-11-04'});
    expect(s.days, 2);
  });

  test('a missed day ends it', () {
    final s = weekStreakOn(today: thu, kept: {'2026-11-02', '2026-11-04'});
    expect(s.days, 1);
    expect(weekStreakOn(today: thu, kept: const {}).days, 0);
  });

  test('it runs past the start of the week and across a month', () {
    final s = weekStreakOn(
      today: '2026-11-02',
      kept: {'2026-10-30', '2026-10-31', '2026-11-01', '2026-11-02'},
    );
    expect(s.days, 4);
  });

  test('the week runs Monday to Sunday and marks today', () {
    final s = weekStreakOn(today: thu, kept: {'2026-11-02', '2026-11-04'});
    expect(s.week.map((d) => d.label), ['M', 'T', 'W', 'T', 'F', 'S', 'S']);
    expect(s.week.map((d) => d.isKept), [
      true,
      false,
      true,
      false,
      false,
      false,
      false,
    ]);
    expect(s.week.indexWhere((d) => d.isToday), 3);
    expect(s.week.where((d) => d.isToday), hasLength(1));
  });

  test('on a Sunday the week ends today', () {
    final s = weekStreakOn(today: '2026-11-08', kept: const {});
    expect(s.week.last.isToday, isTrue);
  });
}
