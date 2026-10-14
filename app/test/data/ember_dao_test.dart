import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/boss_view.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/ember_dao.dart';

import 'harness.dart';

void main() {
  late Harness h;
  late EmberDao embers;
  late BossView view;
  setUp(() async {
    h = Harness();
    embers = EmberDao(h.db, h.clock.call);
    view = await h.seed();
  });
  tearDown(() => h.db.close());

  String idOf(String title) => taskNamed(view, title).task.id;
  Future<EmberTally> tally() => embers.tally();

  group('earning', () {
    test('a strike earns 1, 3 or 6 by weight', () async {
      await h.attempts.strike(idOf('Flashcards')); // Light
      expect((await tally()).carried, 1);
      await h.attempts.strike(idOf('Read chapter 4')); // Heavy
      expect((await tally()).carried, 4);
      await h.attempts.strike(idOf('Sit the exam')); // Boss-tier
      expect((await tally()).carried, 10);
    });

    test('a try earns half, rounded up: 1, 2, 3', () async {
      await h.attempts.tried(idOf('Flashcards'));
      expect((await tally()).carried, 1);
      await h.attempts.tried(idOf('Read chapter 4'));
      expect((await tally()).carried, 3);
      await h.attempts.tried(idOf('Sit the exam'));
      expect((await tally()).carried, 6);
    });

    test('a fall earns nothing', () async {
      await h.attempts.fall(view.boss.id, 'Start earlier.');
      expect((await tally()).carried, 0);
      expect(await h.db.select(h.db.emberEvents).get(), isEmpty);
    });

    test('striking a struck task earns nothing more', () async {
      await h.attempts.strike(idOf('Flashcards'));
      await h.attempts.strike(idOf('Flashcards'));
      expect((await tally()).carried, 1);
      expect(await h.db.select(h.db.emberEvents).get(), hasLength(1));
    });

    test('the event records the boss, the task and the day', () async {
      await h.attempts.strike(idOf('Flashcards'));
      final e = (await h.db.select(h.db.emberEvents).get()).single;
      expect(e.kind, EmberKind.earn);
      expect(e.amount, 1);
      expect(e.bossId, view.boss.id);
      expect(e.taskId, idOf('Flashcards'));
      expect(e.day, '2026-10-13');
    });

    test('deleting the boss keeps the event with null references', () async {
      await h.attempts.strike(idOf('Flashcards'));
      await h.bosses.deleteBoss(view.boss.id);
      final e = (await h.db.select(h.db.emberEvents).get()).single;
      expect(e.bossId, isNull);
      expect(e.taskId, isNull);
      expect((await tally()).carried, 1);
    });
  });

  group('banking', () {
    test('moves carried to banked once, as one bank event', () async {
      await h.attempts.strike(idOf('Flashcards'));
      await h.attempts.strike(idOf('Read chapter 4'));

      expect(await embers.bank(), 4);
      expect(await tally(), const EmberTally(carried: 0, banked: 4));
      final banks = (await h.db.select(h.db.emberEvents).get()).where(
        (e) => e.kind == EmberKind.bank,
      );
      expect(banks.single.amount, 4);
    });

    test('with nothing carried it writes no event', () async {
      expect(await embers.bank(), 0);
      await h.attempts.strike(idOf('Flashcards'));
      await embers.bank();
      expect(await embers.bank(), 0);
      expect(await h.db.select(h.db.emberEvents).get(), hasLength(2));
    });

    test('earning after a bank starts a new carried total', () async {
      await h.attempts.strike(idOf('Flashcards'));
      await embers.bank();
      await h.attempts.strike(idOf('Read chapter 4'));
      expect(await tally(), const EmberTally(carried: 3, banked: 1));
    });

    test('nothing is ever subtracted: a fall leaves both totals', () async {
      await h.attempts.strike(idOf('Read chapter 4'));
      await embers.bank();
      await h.attempts.strike(idOf('Flashcards'));
      await h.attempts.fall(view.boss.id, null);
      expect(await tally(), const EmberTally(carried: 1, banked: 3));
    });
  });

  test('watchTally follows strikes and banks', () async {
    final seen = <EmberTally>[];
    final sub = embers.watchTally().listen(seen.add);
    addTearDown(sub.cancel);
    await pumpEventQueue(times: 50);
    expect(seen.last, const EmberTally(carried: 0, banked: 0));

    await h.attempts.strike(idOf('Flashcards'));
    await pumpEventQueue(times: 50);
    expect(seen.last, const EmberTally(carried: 1, banked: 0));

    await embers.bank();
    await pumpEventQueue(times: 50);
    expect(seen.last, const EmberTally(carried: 0, banked: 1));
  });
}
