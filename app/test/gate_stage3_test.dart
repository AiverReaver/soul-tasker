import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/boss_view.dart';
import 'package:hearthrise/data/day_dao.dart';
import 'package:hearthrise/data/ember_dao.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/plan_pick_dao.dart';
import 'package:hearthrise/features/ritual/reminder_coordinator.dart';

import 'data/harness.dart';
import 'support/fake_reminders.dart';

// The Stage 3 gate, scripted (STAGE3_PLAN.md step 10): the do, rest, bank,
// plan loop over eight days with two active bosses and one waiting. Day n is
// 2026-10-(12 + n). The harness starts on day 1, the install day.
void main() {
  test('the daily ritual loop over eight days', () async {
    final h = Harness();
    addTearDown(h.db.close);
    final days = DayDao(h.db, h.clock.call, h.attempts);
    final embers = EmberDao(h.db, h.clock.call);
    final picks = PlanPickDao(h.db, h.bosses, h.clock.call);
    final reminders = FakeReminders();
    final coordinator = ReminderCoordinator(h.settings, reminders);

    final a = await h.seed();
    final b = await h.seed();
    final w = await h.seed();
    await h.bosses.setStatus(w.boss.id, BossStatus.waiting);

    String idOf(BossView view, String title) => taskNamed(view, title).task.id;
    void at(int day, [int hour = 12]) =>
        h.clock.now = DateTime(2026, 10, 12 + day, hour);
    Future<int> flasks() => h.flasks();
    Future<String?> lastResolved() async =>
        (await h.db.select(h.db.settings).getSingle()).lastResolvedDay;
    Future<int> banks() async => (await h.db.select(h.db.emberEvents).get())
        .where((e) => e.kind == EmberKind.bank)
        .length;
    Future<int> attemptNumber(String id) async =>
        (await h.reload(id)).boss.attemptNumber;
    Future<List<dynamic>> falls() async =>
        (await h.db.select(h.db.attempts).get())
            .where((r) => r.outcome == Outcome.fallen)
            .toList();

    // The reminder is on from the start.
    expect(await coordinator.enable(), isTrue);
    expect(reminders.calls, ['permission', 'schedule:1260']);

    // Day 1: strike a Heavy and a Light task, then rest with a lesson and
    // three picks for tomorrow.
    await h.attempts.strike(idOf(a, 'Read chapter 4')); // Heavy, 3
    await h.attempts.strike(idOf(a, 'Flashcards')); // Light, 1
    expect(await embers.tally(), const EmberTally(carried: 4, banked: 0));
    final planned = [
      idOf(a, 'Walk'),
      idOf(b, 'Read chapter 4'),
      idOf(a, 'Book the room'),
    ];
    expect(
      await days.rest(lesson: 'A good start.', pickTaskIds: planned),
      isTrue,
    );
    expect(await embers.tally(), const EmberTally(carried: 0, banked: 4));
    expect(await banks(), 1);
    expect(await flasks(), 3); // already at the cap
    expect((await picks.picksFor('2026-10-14')).map((p) => p.task.id), planned);

    // Day 2: strike one task, no rest.
    at(2);
    await h.attempts.strike(idOf(b, 'Read chapter 4'));
    expect((await embers.tally()).carried, 3);

    // Day 3, 05:00: open. Day 2 went unrested. The flask is used at the
    // prompt, so nothing falls.
    at(3, 5);
    var pending = await days.pending();
    expect(pending.days, ['2026-10-14']);
    expect(
      pending.bosses.map((x) => x.id),
      unorderedEquals([a.boss.id, b.boss.id]),
    );
    expect(await days.resolve(flasksToSpend: 1), 0);
    expect(await falls(), isEmpty);
    expect(await attemptNumber(a.boss.id), 1);
    expect(await attemptNumber(b.boss.id), 1);
    expect(await flasks(), 2);
    expect(await lastResolved(), '2026-10-14');

    // Day 3, later: strike a Light task, then rest. One more bank event, and
    // the flask is restored (2 plus 1). A second rest the same day does nothing.
    at(3);
    await h.attempts.strike(idOf(b, 'Flashcards'));
    expect((await embers.tally()).carried, 4);
    expect(await days.rest(), isTrue);
    expect(await embers.tally(), const EmberTally(carried: 0, banked: 8));
    expect(await banks(), 2);
    expect(await flasks(), 3);
    expect(await days.rest(), isFalse);
    expect(await banks(), 2);

    // Day 4: a light day with one strike, no rest.
    at(4);
    expect(await days.markLight(), isTrue);
    await h.attempts.strike(idOf(a, 'Walk'));
    expect((await embers.tally()).carried, 3);

    // Day 5, open: day 4 is covered, so nothing is pending and nothing falls.
    at(5);
    pending = await days.pending();
    expect(pending.days, isEmpty);
    expect(await days.resolve(), 0);
    expect(await falls(), isEmpty);
    // Day 5 and day 6 pass with no activity and no rest.

    // Day 7, 05:00: open. Days 5 and 6 are missed. The flask is declined: both
    // active bosses fall exactly once with one shared lesson. The waiting boss
    // is untouched, flasks and carried embers stay as they were.
    at(7, 5);
    pending = await days.pending();
    expect(pending.days, ['2026-10-17', '2026-10-18']);
    expect(await days.resolve(lesson: 'Plan the week.'), 2);
    final fallen = await falls();
    expect(fallen, hasLength(2));
    expect(
      fallen.map((r) => r.bossId),
      unorderedEquals([a.boss.id, b.boss.id]),
    );
    expect(fallen.map((r) => r.cause).toSet(), {FallCause.missedDay});
    expect(fallen.map((r) => r.lesson).toSet(), {'Plan the week.'});
    expect(await attemptNumber(a.boss.id), 2);
    expect(await attemptNumber(b.boss.id), 2);
    expect(await attemptNumber(w.boss.id), 1);
    expect(await flasks(), 3);
    expect((await embers.tally()).carried, 3);
    expect(await lastResolved(), '2026-10-18');

    // Day 7, after the fall: strike a task, then rest. The bonfire row is for
    // day 7, one bank event of 6, and the flask count stays at the cap.
    at(7);
    await h.attempts.strike(idOf(a, 'Walk'));
    expect((await embers.tally()).carried, 6);
    expect(await days.rest(), isTrue);
    expect(await embers.tally(), const EmberTally(carried: 0, banked: 14));
    expect(await banks(), 3);
    expect(await flasks(), 3);
    final logs = await h.db.select(h.db.dayLogs).get();
    expect(
      logs.where((l) => l.kind == DayKind.bonfire).map((l) => l.day),
      containsAll(['2026-10-13', '2026-10-15', '2026-10-19']),
    );

    // Day 8: strike a task, then rest at 01:00 on day 9's calendar date. The
    // rest belongs to day 8, nothing is pending, and day 9 is not judged yet.
    at(8);
    await h.attempts.strike(idOf(b, 'Walk'));
    h.clock.now = DateTime(2026, 10, 21, 1);
    expect(await days.rest(), isTrue);
    expect(
      (await h.db.select(h.db.dayLogs).get()).any(
        (l) => l.kind == DayKind.bonfire && l.day == '2026-10-20',
      ),
      isTrue,
    );
    expect(await embers.tally(), const EmberTally(carried: 0, banked: 17));
    expect(await flasks(), 3);
    expect((await days.pending()).days, isEmpty);
    h.clock.now = DateTime(2026, 10, 21, 5);
    expect((await days.pending()).days, isEmpty);

    // The reminder was scheduled once and never dropped.
    expect(reminders.calls, ['permission', 'schedule:1260']);
  });
}
