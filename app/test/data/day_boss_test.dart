import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/day_boss.dart';
import 'package:hearthrise/data/enums.dart';

import 'harness.dart';

void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() => h.db.close());

  test('ensureDayBoss makes one active boss, however often it runs', () async {
    await h.bosses.ensureDayBoss();
    await h.bosses.setPinned(dayBossId, isPinned: true);
    await h.bosses.ensureDayBoss();
    final all = await h.bosses.loadAll();
    expect(all, hasLength(1));
    expect(all.single.boss.id, dayBossId);
    expect(all.single.boss.title, 'The Day');
    expect(all.single.boss.status, BossStatus.active);
    expect(all.single.boss.isPinned, isTrue, reason: 'second run keeps edits');
  });

  test(
    'addQuickTask adds a one-time standalone task, creating the boss',
    () async {
      final id = await h.bosses.addQuickTask('Call the bank');
      final day = (await h.bosses.loadBoss(dayBossId))!;
      final task = day.standalone.single.task;
      expect(task.id, id);
      expect(task.title, 'Call the bank');
      expect(task.recurrence, Recurrence.none);
      expect(task.weight, Weight.light);
    },
  );

  test('addQuickTask makes a daily task only when asked', () async {
    await h.bosses.addQuickTask('Water plants', recurrence: Recurrence.daily);
    final day = (await h.bosses.loadBoss(dayBossId))!;
    expect(day.standalone.single.task.recurrence, Recurrence.daily);
  });

  test('a struck quick task stays today and is gone tomorrow', () async {
    final done = await h.bosses.addQuickTask('Call the bank');
    await h.bosses.addQuickTask('Book the room');
    await h.attempts.strike(done);
    var day = (await h.bosses.loadBoss(dayBossId))!;
    expect(day.allTasks, hasLength(2));
    expect(day.health, 0.5);

    h.clock.now = h.clock.now.add(const Duration(days: 1));
    day = (await h.bosses.loadBoss(dayBossId))!;
    expect(day.allTasks.map((t) => t.task.title), ['Book the room']);
    expect(day.health, 1);
  });

  test('a daily quick task comes back tomorrow', () async {
    final id = await h.bosses.addQuickTask(
      'Water plants',
      recurrence: Recurrence.daily,
    );
    await h.attempts.strike(id);
    h.clock.now = h.clock.now.add(const Duration(days: 1));
    final day = (await h.bosses.loadBoss(dayBossId))!;
    expect(day.allTasks.single.isStruck, isFalse);
  });

  test('health follows today, and refills tomorrow', () async {
    for (final t in ['a', 'b', 'c', 'd']) {
      await h.bosses.addQuickTask(t);
    }
    var day = (await h.bosses.loadBoss(dayBossId))!;
    expect(day.health, 1);
    await h.attempts.strike(day.allTasks.first.task.id);
    day = (await h.bosses.loadBoss(dayBossId))!;
    expect(day.health, 0.75);
    h.clock.now = h.clock.now.add(const Duration(days: 1));
    day = (await h.bosses.loadBoss(dayBossId))!;
    expect(day.health, 1);
  });

  test('it is never vanquished, even with every task struck', () async {
    final id = await h.bosses.addQuickTask('Stretch');
    await h.attempts.strike(id);
    final day = (await h.bosses.loadBoss(dayBossId))!;
    expect(day.health, 0);
    expect(day.isVanquished, isFalse);
  });

  test('it cannot be set aside, defeated or deleted', () async {
    await h.bosses.ensureDayBoss();
    for (final s in [BossStatus.waiting, BossStatus.defeated]) {
      expect(() => h.bosses.setStatus(dayBossId, s), throwsStateError);
    }
    await h.bosses.deleteBoss(dayBossId);
    expect(await h.bosses.loadBoss(dayBossId), isNotNull);
  });
}
