import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/plan_pick_dao.dart';

import 'harness.dart';

void main() {
  late Harness h;
  late PlanPickDao picks;
  setUp(() {
    h = Harness();
    picks = PlanPickDao(h.db, h.bosses, h.clock.call);
  });
  tearDown(() => h.db.close());

  const day = '2026-10-13';

  group('candidates', () {
    test('open tasks of active bosses only, with the boss title', () async {
      final a = await h.seed();
      final waiting = await h.seed();
      await h.bosses.setStatus(waiting.boss.id, BossStatus.waiting);
      await h.attempts.strike(taskNamed(a, 'Flashcards').task.id);

      final list = await picks.candidates();
      final titles = list.map((c) => c.title);
      expect(titles, isNot(contains('Flashcards'))); // struck
      expect(titles, containsAll(['Read chapter 4', 'Walk', 'Book the room']));
      expect(list.map((c) => c.bossTitle).toSet(), {'The Certification'});
      // The waiting boss's tasks are absent: 4 open tasks, not 8.
      expect(list, hasLength(4));
    });
  });

  group('setPicks', () {
    test('stores up to three in order', () async {
      final a = await h.seed();
      final ids = [
        taskNamed(a, 'Walk').task.id,
        taskNamed(a, 'Read chapter 4').task.id,
        taskNamed(a, 'Book the room').task.id,
      ];
      await picks.setPicks(day, ids);
      final got = await picks.picksFor(day);
      expect(got.map((p) => p.task.id), ids);
    });

    test('throws on a fourth and stores nothing', () async {
      final a = await h.seed();
      final ids = [for (final t in a.allTasks) t.task.id];
      expect(ids.length, greaterThan(3));
      expect(() => picks.setPicks(day, ids), throwsArgumentError);
      expect(await picks.picksFor(day), isEmpty);
    });

    test('replaces an earlier set for the same day only', () async {
      final a = await h.seed();
      final walk = taskNamed(a, 'Walk').task.id;
      final read = taskNamed(a, 'Read chapter 4').task.id;
      await picks.setPicks(day, [walk]);
      await picks.setPicks('2026-10-14', [walk]);
      await picks.setPicks(day, [read]);

      expect((await picks.picksFor(day)).map((p) => p.task.id), [read]);
      expect((await picks.picksFor('2026-10-14')).map((p) => p.task.id), [
        walk,
      ]);
      await picks.setPicks(day, []);
      expect(await picks.picksFor(day), isEmpty);
    });

    test('deleting the boss removes its picks', () async {
      final a = await h.seed();
      await picks.setPicks(day, [taskNamed(a, 'Walk').task.id]);
      await h.bosses.deleteBoss(a.boss.id);
      expect(await picks.picksFor(day), isEmpty);
    });

    test('a deleted task is skipped; the plan row stays (D20)', () async {
      final a = await h.seed();
      final walk = taskNamed(a, 'Walk').task.id;
      final book = taskNamed(a, 'Book the room').task.id;
      await picks.setPicks(day, [walk, book]);
      await h.bosses.deleteTask(walk);
      expect((await picks.picksFor(day)).map((p) => p.task.id), [book]);
      expect(await h.db.select(h.db.dayPlans).get(), hasLength(1));
    });
  });

  test('picksFor reports whether each task is struck', () async {
    final a = await h.seed();
    final read = taskNamed(a, 'Read chapter 4').task.id;
    await picks.setPicks(day, [read, taskNamed(a, 'Walk').task.id]);
    expect((await picks.picksFor(day)).map((p) => p.isStruck), [false, false]);

    await h.attempts.strike(read);
    final got = await picks.picksFor(day);
    expect(got.map((p) => p.isStruck), [true, false]);
    expect(got.first.bossTitle, 'The Certification');
  });

  test('watchToday follows the picks and the strikes', () async {
    final a = await h.seed();
    final read = taskNamed(a, 'Read chapter 4').task.id;
    final seen = <List<PlannedTask>>[];
    final sub = picks.watchToday().listen(seen.add);
    addTearDown(sub.cancel);
    await pumpEventQueue(times: 50);
    expect(seen.last, isEmpty);

    await picks.setPicks(day, [read]);
    await pumpEventQueue(times: 50);
    expect(seen.last.single.isStruck, isFalse);

    await h.attempts.strike(read);
    await pumpEventQueue(times: 50);
    expect(seen.last.single.isStruck, isTrue);
  });
}
