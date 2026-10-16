import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/deadlines.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/commitment_dao.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/day_dao.dart';
import 'package:hearthrise/data/ember_dao.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/health_dao.dart';

import 'data/harness.dart';

// The Stage 4 gate, scripted (STAGE4_PLAN.md step 12): the beginner's first
// day from §5.12. Nine promises, six Heavy; three kept, five Heavy misses in
// a row, a fall after the fifth, the ninth frozen; then a calmer day two.
// The install day is 2026-10-13; day 1 is the 14th, day 2 the 15th.
void main() {
  test('the beginner\'s first day plays out as §5.12 says', () async {
    final h = Harness();
    addTearDown(h.db.close);
    final commits = CommitmentDao(h.db, h.clock.call);
    final health = HealthDao(h.db, h.clock.call, h.attempts);
    final days = DayDao(h.db, h.clock.call, h.attempts);
    final embers = EmberDao(h.db, h.clock.call);

    Future<String> boss(String title, List<(String, Weight)> tasks) =>
        h.bosses.saveBoss(
          BossDraft(
            title: title,
            resetOnFail: ResetOnFail.nothing,
            standalone: [
              for (final (t, w) in tasks) TaskDraft(title: t, weight: w),
            ],
          ),
        );
    final a = await boss('A', [
      for (var i = 0; i < 3; i++) ('Light $i', Weight.light),
      for (var i = 0; i < 4; i++) ('Heavy A$i', Weight.heavy),
      for (var i = 0; i < 5; i++) ('Day two $i', Weight.heavy),
    ]);
    final b = await boss('B', [
      ('Heavy B0', Weight.heavy),
      ('Heavy B1', Weight.heavy),
    ]);
    final ids = {
      for (final id in [a, b])
        for (final t in (await h.reload(id)).allTasks) t.task.title: t.task.id,
    };
    void at(int day, int hour, [int minute = 0]) =>
        h.clock.now = DateTime(2026, 10, 13 + day, hour, minute);
    Future<int> attemptNumber(String id) async =>
        (await h.reload(id)).boss.attemptNumber;
    Future<Commitment> promise(String day, String title) async =>
        (await commits.load(day))
            .firstWhere((v) => v.taskTitle == title)
            .commitment;
    const day1 = '2026-10-14';
    const day2 = '2026-10-15';

    // 1. Day 1, morning: nine promises. Heavy deadlines are staggered so the
    // misses land in order: A0..A3, then B0, then B1 last.
    at(1, 8);
    for (var i = 0; i < 3; i++) {
      await commits.commit(ids['Light $i']!, DeadlinePreset.tonight);
    }
    for (final (i, title) in [
      'Heavy A0',
      'Heavy A1',
      'Heavy A2',
      'Heavy A3',
      'Heavy B0',
    ].indexed) {
      at(1, 8, i * 10);
      await commits.commit(ids[title]!, DeadlinePreset.oneHour);
    }
    at(1, 8, 50);
    await commits.commit(ids['Heavy B1']!, DeadlinePreset.threeHours);
    expect(await commits.loadNote(day1), const LoadNote(count: 9, heavy: 6));
    expect(await health.health(day1), 20);

    // 2. The three Light promises are kept.
    for (var i = 0; i < 3; i++) {
      await h.attempts.strike(ids['Light $i']!);
    }
    expect((await commits.record(day1)).kept, 3);
    expect(await health.health(day1), 20);

    // 3. Five Heavy deadlines pass one after another: 10, 8, 6, 4, 2, 0.
    final seen = <int>[];
    for (final title in [
      'Heavy A0',
      'Heavy A1',
      'Heavy A2',
      'Heavy A3',
      'Heavy B0',
    ]) {
      final due = (await promise(day1, title)).deadline;
      h.clock.now = due.add(const Duration(minutes: 1));
      await health.resolveDue();
      seen.add(await health.health(day1));
    }
    expect(seen, [16, 12, 8, 4, 0]);
    // Only the final blow's boss falls, by health.
    expect(await attemptNumber(b), 2);
    expect(await attemptNumber(a), 1);
    final death = (await h.bosses.loadAttempts(bossId: b)).single;
    expect(death.cause, FallCause.healthDeath);
    expect(death.day, day1);

    // 4. The ninth passes while fallen: frozen, no loss.
    final eventsBefore = (await h.db.select(h.db.healthEvents).get()).length;
    at(1, 12);
    await health.resolveDue();
    expect((await promise(day1, 'Heavy B1')).outcome, CommitmentOutcome.frozen);
    expect(await h.db.select(h.db.healthEvents).get(), hasLength(eventsBefore));
    expect(await health.health(day1), 0);

    // 5. The fallen screen's numbers: nine promised, three kept. Gentle mode
    // drops nothing: the three Light embers are still carried.
    final record = await commits.record(day1);
    expect((record.made, record.kept, record.fell), (9, 3, true));
    expect(await embers.tally(), const EmberTally(carried: 3, banked: 0));

    // 6. The frozen ninth, struck late: Tried embers, no health back.
    await h.attempts.strike(ids['Heavy B1']!);
    expect(
      (await promise(day1, 'Heavy B1')).outcome,
      CommitmentOutcome.lateStrike,
    );
    expect(await embers.tally(), const EmberTally(carried: 5, banked: 0));
    expect(await health.health(day1), 0);

    // 7. No rest while fallen; Rise restores and banks, no flask; then rest.
    at(1, 20);
    expect(await days.rest(), isFalse);
    expect(await days.rise(), isTrue);
    expect(await health.health(day1), 20);
    expect(await embers.tally(), const EmberTally(carried: 0, banked: 5));
    expect(await h.flasks(), 3);
    expect(await days.rest(lesson: 'Promise less.'), isTrue);

    // 8. Day 2: full health with nothing written; five promises.
    final events = (await h.db.select(h.db.healthEvents).get()).length;
    at(2, 8);
    expect(await health.health(day2), 20);
    expect(await h.db.select(h.db.healthEvents).get(), hasLength(events));
    for (var i = 0; i < 5; i++) {
      await commits.commit(ids['Day two $i']!, DeadlinePreset.tonight);
    }
    final day1Record = await commits.record(day1);
    expect((day1Record.made, day1Record.kept), (9, 3));
    var week = await commits.week(day2);
    expect((week.made, week.kept), (14, 3));

    // 9. Four kept, one Tried: 4 of 5 today, 7 of 14 this week, health 9.
    for (var i = 0; i < 4; i++) {
      await h.attempts.strike(ids['Day two $i']!);
    }
    await h.attempts.tried(ids['Day two 4']!);
    final day2Record = await commits.record(day2);
    expect((day2Record.made, day2Record.kept), (5, 4));
    week = await commits.week(day2);
    expect((week.made, week.kept), (14, 7));
    expect(await health.health(day2), 18);
  });
}
