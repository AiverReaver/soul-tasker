import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/deadlines.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/commitment_dao.dart';
import 'package:hearthrise/data/day_dao.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/health_dao.dart';

import 'harness.dart';

/// Two phones with the same starting data, so system-made records written
/// for the same reason must get the same ids (Stage 7 plan D6).
class Phone {
  Phone() : h = Harness(null, StepClock(DateTime(2026, 10, 13, 8))) {
    days = DayDao(h.db, h.clock.call, h.attempts);
    health = HealthDao(h.db, h.clock.call, h.attempts);
    commits = CommitmentDao(h.db, h.clock.call);
  }

  final Harness h;
  late final DayDao days;
  late final HealthDao health;
  late final CommitmentDao commits;

  Future<void> seed() async {
    await h.bosses.saveBoss(
      const BossDraft(
        id: 'b1',
        title: 'The Garage',
        resetOnFail: ResetOnFail.nothing,
        phases: [
          PhaseDraft(
            id: 'p1',
            name: 'Clear',
            tasks: [
              TaskDraft(id: 't1', title: 'Sweep', weight: Weight.bossTier),
              TaskDraft(id: 't2', title: 'Bins', weight: Weight.bossTier),
              TaskDraft(id: 't3', title: 'Shelves', weight: Weight.bossTier),
              TaskDraft(id: 't4', title: 'Paint', weight: Weight.bossTier),
              TaskDraft(id: 't5', title: 'Walk', recurrence: Recurrence.daily),
            ],
          ),
        ],
      ),
    );
    await h.bosses.saveBoss(
      const BossDraft(
        id: 'b2',
        title: 'The Shelf',
        resetOnFail: ResetOnFail.nothing,
        phases: [
          PhaseDraft(
            id: 'p2',
            name: 'Build',
            tasks: [TaskDraft(id: 't6', title: 'Build')],
          ),
        ],
      ),
    );
  }

  Future<List<String>> ids(String table) async => [
    for (final r
        in await h.db.customSelect('SELECT id FROM $table ORDER BY id').get())
      r.read<String>('id'),
  ];

  Future<void> close() => h.db.close();
}

void main() {
  late Phone a;
  late Phone b;
  setUp(() async {
    a = Phone();
    b = Phone();
    await a.seed();
    await b.seed();
  });
  tearDown(() async {
    await a.close();
    await b.close();
  });

  Future<void> both(Future<void> Function(Phone p) run) async {
    await run(a);
    await run(b);
  }

  Future<void> expectSame(String table) async {
    final ids = await a.ids(table);
    expect(ids, isNotEmpty, reason: table);
    expect(await b.ids(table), ids, reason: table);
  }

  test('a strike earns under the same id; a commitment too', () async {
    await both((p) async {
      await p.commits.commit('t1', DeadlinePreset.tonight);
      await p.h.attempts.strike('t5');
      await p.h.attempts.strike('t1');
    });
    await expectSame('ember_events');
    await expectSame('commitments');
  });

  test('defeating the same boss gives one relic id', () async {
    await both((p) async {
      await p.h.attempts.strike('t6');
      await p.h.bosses.setStatus('b2', BossStatus.defeated);
    });
    await expectSame('relics');
  });

  test('a missed commitment loses health under the same id', () async {
    await both((p) async {
      await p.commits.commit('t1', DeadlinePreset.oneHour);
      p.h.clock.now = DateTime(2026, 10, 13, 10);
      await p.health.resolveDue();
    });
    await expectSame('health_events');
  });

  test('a bonfire restores health and a flask under the same ids', () async {
    await both((p) async {
      await p.commits.commit('t1', DeadlinePreset.oneHour);
      p.h.clock.now = DateTime(2026, 10, 13, 10);
      await p.health.resolveDue();
      await p.h.setFlasks(2);
      await p.days.rest();
    });
    final restores = {
      for (final e in await a.h.db.select(a.h.db.healthEvents).get())
        if (e.reason == HealthReason.bonfireRestore) e.id,
    };
    final restoresB = {
      for (final e in await b.h.db.select(b.h.db.healthEvents).get())
        if (e.reason == HealthReason.bonfireRestore) e.id,
    };
    expect(restores, hasLength(1));
    expect(restoresB, restores);
    String restoreFlask(List<dynamic> events) =>
        events.where((e) => e.kind == FlaskKind.restore).single.id as String;
    expect(
      restoreFlask(await b.h.db.select(b.h.db.flaskEvents).get()),
      restoreFlask(await a.h.db.select(a.h.db.flaskEvents).get()),
    );
  });

  test('a health death and the rise after it share ids', () async {
    await both((p) async {
      for (final t in ['t1', 't2', 't3', 't4']) {
        await p.commits.commit(t, DeadlinePreset.oneHour);
      }
      p.h.clock.now = DateTime(2026, 10, 13, 10);
      final due = await p.health.resolveDue();
      expect(due.deaths, hasLength(1));
      expect(await p.days.rise(), isTrue);
    });
    await expectSame('attempts');
    await expectSame('health_events');
  });

  test('a missed day fails each boss under the same id', () async {
    await both((p) async {
      p.h.clock.now = DateTime(2026, 10, 16, 12);
      expect(await p.days.resolve(), 2);
    });
    await expectSame('attempts');
  });

  test('a missed day resolved again after a merge adds nothing', () async {
    a.h.clock.now = DateTime(2026, 10, 16, 12);
    await a.days.resolve();
    final fall = (await a.h.db.select(a.h.db.attempts).get()).first;
    // The other phone's fall for the same boss and day arrives first.
    final view = (await a.h.reload(fall.bossId)).boss;
    await a.h.attempts.failBoss(
      fall.bossId,
      FallCause.missedDay,
      null,
      onDay: fall.day,
    );
    expect(await a.h.db.select(a.h.db.attempts).get(), hasLength(2));
    expect(
      (await a.h.reload(fall.bossId)).boss.attemptNumber,
      view.attemptNumber,
    );
  });
}
