import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/day_dao.dart';
import 'package:hearthrise/data/ember_dao.dart';
import 'package:hearthrise/data/enums.dart';

import 'harness.dart';

void main() {
  late Harness h;
  late DayDao days;
  late EmberDao embers;
  setUp(() {
    h = Harness();
    days = DayDao(h.db, h.clock.call, h.attempts);
    embers = EmberDao(h.db, h.clock.call);
  });
  tearDown(() => h.db.close());

  Future<int> flasks() async => (await h.settings.watch().first).flasks;
  Future<List<DayLog>> logs() => h.db.select(h.db.dayLogs).get();
  void nextDay() => h.clock.now = DateTime(
    h.clock.now.year,
    h.clock.now.month,
    h.clock.now.day + 1,
    12,
  );

  group('rest', () {
    test('writes a bonfire row, banks the carried embers, saves the lesson '
        '(trimmed)', () async {
      final view = await h.seed();
      await h.attempts.strike(taskNamed(view, 'Read chapter 4').task.id);

      expect(await days.rest(lesson: '  Start earlier.  '), isTrue);

      final row = (await logs()).single;
      expect(row.kind, DayKind.bonfire);
      expect(row.day, '2026-10-13');
      expect(row.lesson, 'Start earlier.');
      expect(await embers.tally(), const EmberTally(carried: 0, banked: 3));
    });

    test(
      'keeps at most 120 characters; an empty lesson becomes null',
      () async {
        await days.rest(lesson: 'x' * 200);
        expect((await logs()).single.lesson, hasLength(120));

        nextDay();
        await days.rest(lesson: '   ');
        final second = (await logs()).firstWhere((l) => l.day == '2026-10-14');
        expect(second.lesson, isNull);
      },
    );

    test('restores one flask, up to the cap of 3', () async {
      expect(await flasks(), 3);
      await days.rest();
      expect(await flasks(), 3);

      await days.skipToday(); // day 13 already rested: no-op
      nextDay();
      await days.skipToday(); // day 14: spends one
      expect(await flasks(), 2);
      nextDay();
      await days.rest(); // day 15: +1
      expect(await flasks(), 3);
    });

    test('a second rest on the same day does nothing (D9)', () async {
      final view = await h.seed();
      await days.rest();
      await h.attempts.strike(taskNamed(view, 'Flashcards').task.id);
      expect(await days.rest(), isFalse);
      expect(await logs(), hasLength(1));
      expect((await embers.tally()).carried, 1);
    });

    test('a rest at 01:00 belongs to the previous day', () async {
      h.clock.now = DateTime(2026, 10, 14, 1);
      await days.rest();
      expect((await logs()).single.day, '2026-10-13');
    });
  });

  group('rest with a plan', () {
    test('saves the picks for the next day (D11)', () async {
      final view = await h.seed();
      final ids = [
        taskNamed(view, 'Walk').task.id,
        taskNamed(view, 'Book the room').task.id,
      ];
      await days.rest(pickTaskIds: ids);

      final rows = await h.db.select(h.db.planPicks).get();
      expect(rows.map((r) => r.day).toSet(), {'2026-10-14'});
      expect(rows.map((r) => r.taskId), ids);
    });

    test('a fourth pick throws and the rest is not written', () async {
      final view = await h.seed();
      final ids = [for (final t in view.allTasks.take(4)) t.task.id];
      await expectLater(days.rest(pickTaskIds: ids), throwsArgumentError);
      expect(await logs(), isEmpty);
      expect(await flasks(), 3);
    });

    test('a rest at 01:00 plans for the calendar day it falls on', () async {
      final view = await h.seed();
      h.clock.now = DateTime(2026, 10, 14, 1);
      await days.rest(pickTaskIds: [taskNamed(view, 'Walk').task.id]);
      final row = (await h.db.select(h.db.planPicks).get()).single;
      expect(row.day, '2026-10-14');
    });
  });

  group('summary', () {
    test('counts the day, lists its lessons and carries the embers', () async {
      final view = await h.seed();
      await h.attempts.strike(taskNamed(view, 'Flashcards').task.id);
      await h.attempts.strike(taskNamed(view, 'Read chapter 4').task.id);
      await h.attempts.tried(taskNamed(view, 'Walk').task.id);
      await h.attempts.fall(view.boss.id, 'Start earlier.');

      final s = await days.summary();
      expect(s.strikes, 2);
      expect(s.tried, 1);
      expect(s.falls, 1);
      expect(s.lessons, ['Start earlier.']);
      expect(s.embers.carried, 1 + 3 + 2); // Light, Heavy, tried Heavy
    });

    test('leaves out other days, and follows the rollover hour', () async {
      final view = await h.seed();
      h.clock.now = DateTime(2026, 10, 14, 1);
      await h.attempts.strike(taskNamed(view, 'Flashcards').task.id);
      h.clock.now = DateTime(2026, 10, 14, 3); // still day 13
      expect((await days.summary()).strikes, 1);
      h.clock.now = DateTime(2026, 10, 14, 5); // day 14
      expect((await days.summary()).strikes, 0);
    });
  });

  group('skipToday', () {
    test('spends one flask and writes a flask row', () async {
      expect(await days.skipToday(), isTrue);
      expect(await flasks(), 2);
      final row = (await logs()).single;
      expect(row.kind, DayKind.flask);
      expect(row.day, '2026-10-13');
    });

    test('fails with no flask left, and never goes below 0', () async {
      for (var i = 0; i < 3; i++) {
        expect(await days.skipToday(), isTrue);
        nextDay();
      }
      expect(await flasks(), 0);
      expect(await days.skipToday(), isFalse);
      expect(await flasks(), 0);
      expect(await logs(), hasLength(3));
    });

    test('is a no-op when the day is already covered', () async {
      await days.rest();
      expect(await days.skipToday(), isFalse);
      expect(await flasks(), 3);

      nextDay();
      await days.skipToday();
      expect(await days.skipToday(), isFalse);
      expect(await flasks(), 2);
    });
  });

  test('markLight writes a light row once', () async {
    expect(await days.markLight(), isTrue);
    expect(await days.markLight(), isFalse);
    final row = (await logs()).single;
    expect(row.kind, DayKind.light);
    expect(await flasks(), 3);
  });

  test('watchToday reports what covers today and the flasks left', () async {
    final seen = <DayStatus>[];
    final sub = days.watchToday().listen(seen.add);
    addTearDown(sub.cancel);
    await pumpEventQueue(times: 50);
    expect(seen.last.kinds, isEmpty);
    expect(seen.last.flasks, 3);

    await days.skipToday();
    await pumpEventQueue(times: 50);
    expect(seen.last.kinds, {DayKind.flask});
    expect(seen.last.flasks, 2);
    expect(seen.last.isRested, isFalse);

    await days.rest();
    await pumpEventQueue(times: 50);
    expect(seen.last.isRested, isTrue);
  });
}
