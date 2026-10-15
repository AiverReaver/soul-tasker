import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/deadlines.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/commitment_dao.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/day_dao.dart';
import 'package:hearthrise/data/ember_dao.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/health_dao.dart';

import 'harness.dart';

void main() {
  late Harness h;
  late DayDao days;
  late HealthDao health;
  late CommitmentDao commits;
  late EmberDao embers;
  setUp(() {
    h = Harness(null, StepClock(DateTime(2026, 10, 13, 8)));
    days = DayDao(h.db, h.clock.call, h.attempts);
    health = HealthDao(h.db, h.clock.call, h.attempts);
    commits = CommitmentDao(h.db, h.clock.call);
    embers = EmberDao(h.db, h.clock.call);
  });
  tearDown(() => h.db.close());

  const day = '2026-10-13';

  Future<void> lose(int amount) =>
      health.record(-amount, HealthReason.miss, day, h.clock());
  Future<List<HealthEvent>> events(HealthReason reason) async => [
    for (final e in await h.db.select(h.db.healthEvents).get())
      if (e.reason == reason) e,
  ];
  Future<int> flasks() async => (await h.settings.read()).flasks;

  group('rest', () {
    test('restores health to full with one bonfireRestore event', () async {
      await lose(6);
      expect(await days.rest(), isTrue);
      expect(await health.health(day), 20);
      expect((await events(HealthReason.bonfireRestore)).single.amount, 6);
    });

    test('writes no restore when already full', () async {
      await days.rest();
      expect(await events(HealthReason.bonfireRestore), isEmpty);
    });

    test('is refused while fallen', () async {
      await lose(20);
      expect(await days.rest(), isFalse);
      expect(await h.db.select(h.db.dayLogs).get(), isEmpty);
    });
  });

  group('rise', () {
    test(
      'restores full, banks, adds no flask and does not cover the day',
      () async {
        final view = await h.seed();
        await h.attempts.strike(taskNamed(view, 'Read chapter 4').task.id);
        await (h.db.update(h.db.settings))
            .write(const SettingsCompanion(flasks: Value(1)));
        await lose(20);

        expect(await days.rise(), isTrue);

        expect(await health.health(day), 20);
        expect((await events(HealthReason.rise)).single.amount, 20);
        expect(await embers.tally(), const EmberTally(carried: 0, banked: 3));
        expect(await flasks(), 1);
        expect(await h.db.select(h.db.dayLogs).get(), isEmpty);
      },
    );

    test('can run again after a second death', () async {
      await lose(20);
      await days.rise();
      await lose(20);
      expect(await days.rise(), isTrue);
      expect(await events(HealthReason.rise), hasLength(2));
    });

    test('is a no-op when not fallen', () async {
      await lose(4);
      expect(await days.rise(), isFalse);
      expect(await events(HealthReason.rise), isEmpty);
    });

    test(
      'later deadlines cost again; earlier frozen ones stay frozen',
      () async {
        final id = await h.bosses.saveBoss(
          const BossDraft(
            title: 'A',
            resetOnFail: ResetOnFail.nothing,
            standalone: [
              TaskDraft(title: 'early', weight: Weight.light),
              TaskDraft(title: 'late', weight: Weight.light),
            ],
          ),
        );
        final tasks = (await h.reload(id)).allTasks;
        await commits.commit(tasks[0].task.id, DeadlinePreset.oneHour);
        await commits.commit(tasks[1].task.id, DeadlinePreset.tonight);
        await lose(20);
        h.clock.now = DateTime(2026, 10, 13, 10);
        await health.resolveDue();
        await days.rise();
        h.clock.now = DateTime(2026, 10, 13, 23, 30);
        await health.resolveDue();
        final outcomes = {
          for (final v in await commits.load(day))
            v.taskTitle: v.commitment.outcome,
        };
        expect(outcomes, {
          'early': CommitmentOutcome.frozen,
          'late': CommitmentOutcome.missed,
        });
        expect(await health.health(day), 18);
      },
    );
  });

  test('rest settles a passed deadline before restoring', () async {
    final view = await h.seed();
    await commits.commit(
      taskNamed(view, 'Read chapter 4').task.id,
      DeadlinePreset.oneHour,
    );
    h.clock.now = DateTime(2026, 10, 13, 20);
    expect(await days.rest(), isTrue);
    expect(
      (await commits.load(day)).single.commitment.outcome,
      CommitmentOutcome.missed,
    );
    expect(await health.health(day), 20);
  });

  test('rise settles a passed deadline before restoring', () async {
    final view = await h.seed();
    await commits.commit(
      taskNamed(view, 'Read chapter 4').task.id,
      DeadlinePreset.oneHour,
    );
    await lose(20);
    h.clock.now = DateTime(2026, 10, 13, 20);
    expect(await days.rise(), isTrue);
    expect(
      (await commits.load(day)).single.commitment.outcome,
      CommitmentOutcome.frozen,
    );
    expect(await health.health(day), 20);
  });
}
