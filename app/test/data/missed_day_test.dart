import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/attempt_dao.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/day_dao.dart';
import 'package:hearthrise/data/enums.dart';

import 'harness.dart';

/// Fails the second boss it is asked to fail.
class _Throwing extends AttemptDao {
  _Throwing(super.db, super.bosses, super.clock);

  int calls = 0;

  @override
  Future<String> failBoss(
    String bossId,
    FallCause cause,
    String? lesson, {
    String? onDay,
    DateTime? at,
  }) async {
    if (++calls == 2) throw StateError('boom');
    return super.failBoss(bossId, cause, lesson, onDay: onDay, at: at);
  }
}

void main() {
  late Harness h;
  late DayDao days;
  setUp(() {
    h = Harness();
    days = DayDao(h.db, h.clock.call, h.attempts);
  });
  tearDown(() => h.db.close());

  // The harness starts on 2026-10-13 12:00, which is lastResolvedDay (D12).
  void at(int day, [int hour = 12]) =>
      h.clock.now = DateTime(2026, 10, day, hour);

  Future<List<Attempt>> falls() async =>
      (await h.db.select(h.db.attempts).get())
          .where((a) => a.outcome == Outcome.fallen)
          .toList();
  Future<int> attemptNumber(String id) async =>
      (await h.reload(id)).boss.attemptNumber;

  group('pending', () {
    test(
      'lists the missed days and only the bosses that would fall (D4)',
      () async {
        final a = await h.seed();
        final waiting = await h.seed();
        await h.bosses.setStatus(waiting.boss.id, BossStatus.waiting);
        final defeated = await h.seed();
        await h.bosses.setStatus(defeated.boss.id, BossStatus.defeated);
        at(14);
        await h.seed(); // created on the missed day itself
        at(15);

        final p = await days.pending();
        expect(p.days, ['2026-10-14']);
        expect(p.bosses.map((b) => b.id), [a.boss.id]);
        expect(p.flasks, 3);
      },
    );

    test('is empty on the install day and the day after (D12)', () async {
      await h.seed();
      expect((await days.pending()).days, isEmpty);
      at(14);
      expect((await days.pending()).days, isEmpty);
      at(15);
      expect((await days.pending()).days, ['2026-10-14']);
    });

    test('a rested day is not pending', () async {
      await h.seed();
      at(14);
      await days.rest();
      at(15);
      expect((await days.pending()).days, isEmpty);
    });
  });

  group('resolve', () {
    test('fails every active boss once with one shared lesson', () async {
      final a = await h.seed(reset: ResetOnFail.wholeBoss);
      await h.attempts.strike(taskNamed(a, 'Flashcards').task.id);
      final b = await h.seed();
      at(15);

      expect(await days.resolve(lesson: 'Plan the week.'), 2);

      final rows = await falls();
      expect(rows, hasLength(2));
      expect(rows.map((r) => r.cause).toSet(), {FallCause.missedDay});
      expect(rows.map((r) => r.lesson).toSet(), {'Plan the week.'});
      expect(rows.map((r) => r.day).toSet(), {'2026-10-14'});
      expect(await attemptNumber(a.boss.id), 2);
      expect(await attemptNumber(b.boss.id), 2);
      // The boss's own reset applies: whole boss reopens the struck task.
      expect(
        taskNamed(await h.reload(a.boss.id), 'Flashcards').isStruck,
        isFalse,
      );
    });

    test('a boss that died by health on the missed day is not failed again '
        '(Stage 4 D14)', () async {
      final a = await h.seed();
      final b = await h.seed();
      at(14);
      await h.attempts.failBoss(
        a.boss.id,
        FallCause.healthDeath,
        null,
        onDay: '2026-10-14',
      );
      at(15);

      expect((await days.pending()).bosses.map((x) => x.id), [b.boss.id]);
      expect(await days.resolve(lesson: 'Rest.'), 1);
      expect(await attemptNumber(a.boss.id), 2);
      expect(await attemptNumber(b.boss.id), 2);
    });

    test('a skipped lesson still resolves', () async {
      await h.seed();
      at(15);
      expect(await days.resolve(), 1);
      expect((await falls()).single.lesson, isNull);
    });

    test('several missed days cost one attempt per boss (D2)', () async {
      final a = await h.seed();
      at(17);
      expect((await days.pending()).days, hasLength(3));
      await days.resolve();
      expect(await attemptNumber(a.boss.id), 2);
      expect(await falls(), hasLength(1));
    });

    test(
      'flasks cover the oldest days first; the rest still fall once',
      () async {
        final a = await h.seed();
        at(16); // missed: 14 and 15
        expect(await days.resolve(flasksToSpend: 1), 1);

        final flaskRows = (await h.db.select(h.db.dayLogs).get()).where(
          (l) => l.kind == DayKind.flask,
        );
        expect(flaskRows.map((l) => l.day), ['2026-10-14']);
        expect(await h.flasks(), 2);
        expect((await falls()).single.day, '2026-10-15');
        expect(await attemptNumber(a.boss.id), 2);
      },
    );

    test('enough flasks means no fall at all', () async {
      final a = await h.seed();
      at(16);
      expect(await days.resolve(flasksToSpend: 2), 0);
      expect(await falls(), isEmpty);
      expect(await attemptNumber(a.boss.id), 1);
      expect(await h.flasks(), 1);
    });

    test('never spends more flasks than it has', () async {
      await h.seed();
      at(18); // four missed days, three flasks
      await days.resolve(flasksToSpend: 9);
      expect(await h.flasks(), 0);
      expect(await falls(), hasLength(1));
    });

    test(
      'advances lastResolvedDay to yesterday, and a second run is a no-op',
      () async {
        await h.seed();
        at(15);
        await days.resolve();
        expect((await h.settings.device()).lastResolvedDay, '2026-10-14');

        expect(await days.resolve(), 0);
        expect(await falls(), hasLength(1));
        expect((await days.pending()).days, isEmpty);
      },
    );

    test('with no active boss it only advances the day', () async {
      final w = await h.seed();
      await h.bosses.setStatus(w.boss.id, BossStatus.waiting);
      at(15);
      expect(await days.resolve(), 0);
      expect(await falls(), isEmpty);
      expect((await h.settings.device()).lastResolvedDay, '2026-10-14');
    });

    test('an exception part-way leaves nothing changed', () async {
      final throwing = _Throwing(h.db, h.bosses, h.clock.call);
      final d = DayDao(h.db, h.clock.call, throwing);
      final a = await h.seed();
      final b = await h.seed();
      at(16);

      await expectLater(d.resolve(flasksToSpend: 1), throwsStateError);

      expect(await falls(), isEmpty);
      expect(await attemptNumber(a.boss.id), 1);
      expect(await attemptNumber(b.boss.id), 1);
      expect(await h.db.select(h.db.dayLogs).get(), isEmpty);
      expect(await h.flasks(), 3);
      expect((await h.settings.device()).lastResolvedDay, '2026-10-13');
    });
  });
}
