import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/deadlines.dart';
import 'package:hearthrise/data/commitment_dao.dart';
import 'package:hearthrise/data/day_dao.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/health_dao.dart';

import 'harness.dart';

/// The attempt number re-derived from the falls equals the counter that
/// `failBoss` keeps, after every way to fall (Stage 7 plan D7).
void main() {
  late Harness h;
  setUp(() => h = Harness(null, StepClock(DateTime(2026, 10, 13, 8))));
  tearDown(() => h.db.close());

  Future<Map<String, int>> counters() async => {
    for (final b in await h.db.select(h.db.bosses).get()) b.id: b.attemptNumber,
  };

  Future<void> expectRecountMatches() async {
    final before = await counters();
    await h.bosses.recomputeAttemptNumbers();
    expect(await counters(), before);
  }

  test('a new boss is on attempt 1', () async {
    await h.seed();
    await expectRecountMatches();
  });

  for (final reset in ResetOnFail.values) {
    test('declared falls with reset ${reset.name}', () async {
      final view = await h.seed(reset: reset);
      await h.attempts.strike(taskNamed(view, 'Read chapter 4').task.id);
      await h.attempts.fall(view.boss.id, 'Too much.');
      await h.attempts.fall(view.boss.id, null);
      expect((await counters())[view.boss.id], 3);
      await expectRecountMatches();
    });
  }

  test('a health death', () async {
    final view = await h.seed();
    final commits = CommitmentDao(h.db, h.clock.call);
    final health = HealthDao(h.db, h.clock.call, h.attempts);
    for (final t in view.allTasks.take(4)) {
      await commits.commit(t.task.id, DeadlinePreset.oneHour);
    }
    await health.record(-10, HealthReason.miss, '2026-10-13', h.clock());
    h.clock.now = DateTime(2026, 10, 13, 10);
    expect((await health.resolveDue()).deaths, hasLength(1));
    await expectRecountMatches();
  });

  test('a missed day', () async {
    await h.seed();
    await h.seed();
    h.clock.now = DateTime(2026, 10, 16, 12);
    expect(await DayDao(h.db, h.clock.call, h.attempts).resolve(), 2);
    await expectRecountMatches();
  });

  test('a wrong counter is put right', () async {
    final view = await h.seed();
    await h.attempts.fall(view.boss.id, null);
    await h.db.customStatement('UPDATE bosses SET attempt_number = 9');
    await h.bosses.recomputeAttemptNumbers();
    expect((await counters())[view.boss.id], 2);
  });
}
