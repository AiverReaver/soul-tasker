import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/deadlines.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/commitment_dao.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/enums.dart';

import 'harness.dart';

void main() {
  late Harness h;
  late CommitmentDao commits;
  late List<String> tasks;
  setUp(() async {
    h = Harness(null, StepClock(DateTime(2026, 10, 13, 8)));
    commits = CommitmentDao(h.db, h.clock.call);
    final id = await h.bosses.saveBoss(
      BossDraft(
        title: 'A',
        resetOnFail: ResetOnFail.nothing,
        standalone: [for (var i = 0; i < 6; i++) TaskDraft(title: 'T$i')],
      ),
    );
    tasks = [for (final t in (await h.reload(id)).allTasks) t.task.id];
  });
  tearDown(() => h.db.close());

  Future<void> set(String day, CommitmentOutcome? o) async {
    for (final v in await commits.load(day)) {
      if (v.commitment.outcome == null) {
        await (h.db.update(h.db.commitments)
              ..where((c) => c.id.equals(v.commitment.id)))
            .write(CommitmentsCompanion(outcome: Value(o)));
        return;
      }
    }
  }

  test('record counts made and kept; cancelled is not made', () async {
    for (final t in tasks.take(4)) {
      await commits.commit(t, DeadlinePreset.tonight);
    }
    await set('2026-10-13', CommitmentOutcome.kept);
    await set('2026-10-13', CommitmentOutcome.missed);
    await set('2026-10-13', CommitmentOutcome.cancelled);
    final r = await commits.record('2026-10-13');
    expect(r.made, 3);
    expect(r.kept, 1);
  });

  test('an extended promise that was kept counts as kept', () async {
    final id = (await commits.commit(tasks[0], DeadlinePreset.oneHour))!;
    await commits.extend(id, DeadlinePreset.tonight);
    await h.attempts.strike(tasks[0]);
    expect((await commits.record('2026-10-13')).kept, 1);
  });

  test('record reports health lost and whether the player fell', () async {
    await commits.commit(tasks[0], DeadlinePreset.tonight);
    await h.attempts.tried(tasks[0]);
    final r = await commits.record('2026-10-13');
    expect(r.healthLost, 2);
    expect(r.fell, isFalse);
  });

  test('week sums the last seven days, today included', () async {
    await commits.commit(tasks[0], DeadlinePreset.tonight);
    await set('2026-10-13', CommitmentOutcome.kept);
    h.clock.now = DateTime(2026, 10, 19, 8);
    await commits.commit(tasks[1], DeadlinePreset.tonight);
    var w = await commits.week('2026-10-19');
    expect((w.made, w.kept), (2, 1));
    w = await commits.week('2026-10-20');
    expect((w.made, w.kept), (1, 0));
  });
}
