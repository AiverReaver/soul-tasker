import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/deadlines.dart';
import 'package:hearthrise/data/attempt_dao.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/commitment_dao.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/health_dao.dart';
import 'package:hearthrise/core/ids.dart';

import 'harness.dart';

class _ThrowingAttempts extends AttemptDao {
  _ThrowingAttempts(super.db, super.bosses, super.clock);

  @override
  Future<String> failBoss(
    String bossId,
    FallCause cause,
    String? lesson, {
    String? onDay,
    DateTime? at,
  }) => throw StateError('boom');
}

void main() {
  late Harness h;
  late CommitmentDao commits;
  late HealthDao health;
  setUp(() {
    h = Harness(null, StepClock(DateTime(2026, 10, 13, 8)));
    commits = CommitmentDao(h.db, h.clock.call);
    health = HealthDao(h.db, h.clock.call, h.attempts);
  });
  tearDown(() => h.db.close());

  /// A boss with [weights.length] standalone tasks named T0, T1, ...
  Future<String> boss(String title, List<Weight> weights) => h.bosses.saveBoss(
    BossDraft(
      title: title,
      resetOnFail: ResetOnFail.nothing,
      standalone: [
        for (final (i, w) in weights.indexed)
          TaskDraft(title: '$title T$i', weight: w),
      ],
    ),
  );

  Future<String> task(String title) async => (await h.bosses.loadAll())
      .expand((b) => b.allTasks)
      .firstWhere((t) => t.task.title == title)
      .task
      .id;

  Future<void> loss(int amount, DateTime at, {String day = '2026-10-13'}) => h
      .db
      .into(h.db.healthEvents)
      .insert(
        HealthEventsCompanion.insert(
          id: newId(),
          amount: -amount,
          reason: HealthReason.miss,
          day: day,
          at: at,
        ),
      );

  Future<Map<String, CommitmentOutcome?>> outcomes(String day) async => {
    for (final v in await commits.load(day)) v.taskTitle: v.commitment.outcome,
  };

  Future<List<Attempt>> deathsOf(String bossId) async => [
    for (final a in await h.bosses.loadAttempts(bossId: bossId))
      if (a.cause == FallCause.healthDeath) a,
  ];

  group('health', () {
    test('full with no events, falls with losses, clamps at 0', () async {
      expect(await health.health('2026-10-13'), 20);
      await loss(6, DateTime(2026, 10, 13, 9));
      expect(await health.health('2026-10-13'), 14);
      await loss(30, DateTime(2026, 10, 13, 10));
      expect(await health.health('2026-10-13'), 0);
      expect(await health.isDead('2026-10-13'), isTrue);
    });

    test('full again the next day with nothing written', () async {
      await loss(6, DateTime(2026, 10, 13, 9));
      expect(await health.health('2026-10-14'), 20);
      expect(await h.db.select(h.db.healthEvents).get(), hasLength(1));
    });

    test(
      'overkill, rise, then a later loss ends at max minus that loss',
      () async {
        await loss(18, DateTime(2026, 10, 13, 9));
        await loss(6, DateTime(2026, 10, 13, 10));
        await h.db
            .into(h.db.healthEvents)
            .insert(
              HealthEventsCompanion.insert(
                id: newId(),
                amount: 20,
                reason: HealthReason.rise,
                day: '2026-10-13',
                at: DateTime(2026, 10, 13, 11),
              ),
            );
        await loss(2, DateTime(2026, 10, 13, 12));
        expect(await health.health('2026-10-13'), 18);
      },
    );
  });

  group('resolveDue', () {
    test('writes misses at the deadline time and leaves others open', () async {
      await boss('A', [Weight.heavy, Weight.light]);
      await commits.commit(await task('A T0'), DeadlinePreset.oneHour);
      await commits.commit(await task('A T1'), DeadlinePreset.tonight);
      h.clock.now = DateTime(2026, 10, 13, 12);

      final r = await health.resolveDue();

      expect(r.settled.single.taskTitle, 'A T0');
      expect(await outcomes('2026-10-13'), {
        'A T0': CommitmentOutcome.missed,
        'A T1': null,
      });
      final e = (await h.db.select(h.db.healthEvents).get()).single;
      expect(e.amount, -4);
      expect(e.reason, HealthReason.miss);
      final deadline = (await commits.load('2026-10-13')).first.commitment;
      expect(e.at, deadline.deadline);
      expect(await health.health('2026-10-13'), 16);
    });

    test('a death fails only the final-blow boss, at its deadline', () async {
      final a = await boss('A', List.filled(4, Weight.heavy));
      final b = await boss('B', [Weight.heavy]);
      for (var i = 0; i < 4; i++) {
        await commits.commit(await task('A T$i'), DeadlinePreset.oneHour);
      }
      h.clock.now = DateTime(2026, 10, 13, 8, 30);
      await commits.commit(await task('B T0'), DeadlinePreset.oneHour);
      h.clock.now = DateTime(2026, 10, 13, 18);

      final r = await health.resolveDue();

      expect(r.deaths.single.bossId, b);
      expect(await deathsOf(a), isEmpty);
      final fall = (await deathsOf(b)).single;
      final finalBlow = (await commits.load('2026-10-13'))
          .firstWhere((v) => v.taskTitle == 'B T0')
          .commitment;
      expect(fall.at, finalBlow.deadline);
      expect(fall.day, '2026-10-13');
      expect(fall.lesson, isNull);
      expect((await h.reload(b)).boss.attemptNumber, 2);
      expect((await h.reload(a)).boss.attemptNumber, 1);
      expect(r.deaths.single.attemptId, fall.id);
    });

    test('running twice changes nothing the second time', () async {
      await boss('A', [Weight.heavy]);
      await commits.commit(await task('A T0'), DeadlinePreset.oneHour);
      h.clock.now = DateTime(2026, 10, 13, 12);
      await health.resolveDue();
      final r = await health.resolveDue();
      expect(r.settled, isEmpty);
      expect(await h.db.select(h.db.healthEvents).get(), hasLength(1));
    });

    test('an exception mid-way leaves nothing changed', () async {
      await boss('A', List.filled(5, Weight.heavy));
      for (var i = 0; i < 5; i++) {
        await commits.commit(await task('A T$i'), DeadlinePreset.oneHour);
      }
      final throwing = HealthDao(
        h.db,
        h.clock.call,
        _ThrowingAttempts(h.db, h.bosses, h.clock.call),
      );
      h.clock.now = DateTime(2026, 10, 13, 12);
      await expectLater(throwing.resolveDue(), throwsStateError);
      expect(await h.db.select(h.db.healthEvents).get(), isEmpty);
      final open = await (h.db.select(
        h.db.commitments,
      )..where((c) => c.outcome.isNull())).get();
      expect(open, hasLength(5));
    });

    test('a standing daily deadline makes one commitment per day', () async {
      await h.seed();
      await commits.setStanding(await task('Walk'), 20 * 60);
      await health.resolveDue();
      await health.resolveDue();
      final today = (await commits.load('2026-10-13')).single.commitment;
      expect(today.deadline, DateTime(2026, 10, 13, 20));
      h.clock.now = DateTime(2026, 10, 14, 8);
      await health.resolveDue();
      expect(await commits.load('2026-10-14'), hasLength(1));
      // Yesterday's was missed when the day was settled.
      expect(
        (await commits.load('2026-10-13')).single.commitment.outcome,
        CommitmentOutcome.missed,
      );
    });

    test('a waiting boss gets no standing commitment', () async {
      final view = await h.seed();
      await commits.setStanding(await task('Walk'), 20 * 60);
      await h.bosses.setStatus(view.boss.id, BossStatus.waiting);
      await health.resolveDue();
      expect(await commits.load('2026-10-13'), isEmpty);
    });

    test('earlier days resolve against that day, not today', () async {
      await boss('A', [Weight.heavy]);
      await commits.commit(await task('A T0'), DeadlinePreset.oneHour);
      h.clock.now = DateTime(2026, 10, 14, 9);
      await health.resolveDue();
      expect(await health.health('2026-10-13'), 16);
      expect(await health.health('2026-10-14'), 20);
    });

    test(
      'a delayed run uses each deadline time; the first to reach 0 dies',
      () async {
        final a = await boss('A', List.filled(6, Weight.heavy));
        for (var i = 0; i < 6; i++) {
          h.clock.now = DateTime(2026, 10, 13, 8 + i);
          await commits.commit(await task('A T$i'), DeadlinePreset.oneHour);
        }
        h.clock.now = DateTime(2026, 10, 13, 22);
        final r = await health.resolveDue();
        expect(r.settled.map((s) => s.outcome), [
          ...List.filled(5, CommitmentOutcome.missed),
          CommitmentOutcome.frozen,
        ]);
        final events = await (h.db.select(
          h.db.healthEvents,
        )..orderBy([(e) => OrderingTerm.asc(e.at)])).get();
        expect(events.map((e) => e.at.hour), [9, 10, 11, 12, 13]);
        expect((await deathsOf(a)).single.at.hour, 13);
      },
    );

    test('a strike after an unsettled deadline settles it first', () async {
      await boss('A', [Weight.heavy]);
      final id = await task('A T0');
      await commits.commit(id, DeadlinePreset.oneHour);
      h.clock.now = DateTime(2026, 10, 13, 12);
      await h.attempts.strike(id);
      expect(
        (await commits.load('2026-10-13')).single.commitment.outcome,
        CommitmentOutcome.lateStrike,
      );
      expect(await health.health('2026-10-13'), 16);
    });

    test('a Tried that reaches 0 is a death on that boss', () async {
      final a = await boss('A', [Weight.heavy]);
      await loss(19, DateTime(2026, 10, 13, 7));
      final id = await task('A T0');
      await commits.commit(id, DeadlinePreset.tonight);
      await h.attempts.tried(id);
      expect(await health.isDead('2026-10-13'), isTrue);
      expect(await deathsOf(a), hasLength(1));
    });
  });

  test(
    'addLesson fills a health-death fall once and never replaces it',
    () async {
      final a = await boss('A', [Weight.heavy]);
      final id = await h.attempts.failBoss(a, FallCause.healthDeath, null);
      await h.attempts.addLesson([id], '  Promise less.  ');
      await h.attempts.addLesson([id], 'Something else.');
      expect((await deathsOf(a)).single.lesson, 'Promise less.');
    },
  );

  test('watchHealth follows events and the rollover hour', () async {
    final seen = <int>[];
    final sub = health.watchHealth().listen(seen.add);
    await pumpEventQueue();
    await loss(4, DateTime(2026, 10, 13, 7));
    await pumpEventQueue();
    // At 03:00 with rollover 4 the day is the 13th; with rollover 2 the 14th.
    h.clock.now = DateTime(2026, 10, 14, 3);
    await h.settings.setRolloverHour(2);
    await pumpEventQueue();
    await sub.cancel();
    expect(seen, [20, 16, 20]);
  });
}
