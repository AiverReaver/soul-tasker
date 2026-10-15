import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/deadlines.dart';
import 'package:hearthrise/data/commitment_dao.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/enums.dart';

import 'harness.dart';

void main() {
  late Harness h;
  late CommitmentDao commits;
  setUp(() {
    // 2026-10-13 08:00, ritual day 2026-10-13 (rollover 4).
    h = Harness(null, StepClock(DateTime(2026, 10, 13, 8)));
    commits = CommitmentDao(h.db, h.clock.call);
  });
  tearDown(() => h.db.close());

  Future<String> taskId(String title) async => (await h.bosses.loadAll())
      .expand((b) => b.allTasks)
      .firstWhere((t) => t.task.title == title)
      .task
      .id;

  Future<int> flasks() async => (await h.settings.read()).flasks;

  group('deadlineFor', () {
    test('one hour and three hours from now', () {
      final now = DateTime(2026, 10, 13, 8);
      expect(
        deadlineFor(DeadlinePreset.oneHour, now, rolloverHour: 4),
        DateTime(2026, 10, 13, 9),
      );
      expect(
        deadlineFor(DeadlinePreset.threeHours, now, rolloverHour: 4),
        DateTime(2026, 10, 13, 11),
      );
    });

    test('tonight is 23:00, or the rollover once 23:00 has passed', () {
      expect(
        deadlineFor(
          DeadlinePreset.tonight,
          DateTime(2026, 10, 13, 8),
          rolloverHour: 4,
        ),
        DateTime(2026, 10, 13, 23),
      );
      expect(
        deadlineFor(
          DeadlinePreset.tonight,
          DateTime(2026, 10, 13, 23, 30),
          rolloverHour: 4,
        ),
        DateTime(2026, 10, 14, 4),
      );
    });

    test('never past the end of the ritual day', () {
      // 02:30 belongs to the 13th; the day ends at 04:00 on the 14th.
      final late = DateTime(2026, 10, 14, 2, 30);
      expect(
        deadlineFor(DeadlinePreset.threeHours, late, rolloverHour: 4),
        DateTime(2026, 10, 14, 4),
      );
      expect(
        deadlineFor(DeadlinePreset.tonight, late, rolloverHour: 4),
        DateTime(2026, 10, 14, 4),
      );
    });
  });

  group('commit', () {
    test('writes one open commitment for today with the deadline', () async {
      await h.seed();
      final id = await commits.commit(
        await taskId('Read chapter 4'),
        DeadlinePreset.tonight,
        remind: true,
      );
      final row = (await commits.load('2026-10-13')).single;
      expect(row.commitment.id, id);
      expect(row.commitment.deadline, DateTime(2026, 10, 13, 23));
      expect(row.commitment.outcome, isNull);
      expect(row.commitment.remind, isTrue);
      expect(row.taskTitle, 'Read chapter 4');
      expect(row.bossTitle, 'The Certification');
      expect(row.weight, Weight.heavy);
    });

    test('the same task twice on one day is refused', () async {
      await h.seed();
      final task = await taskId('Read chapter 4');
      await commits.commit(task, DeadlinePreset.oneHour);
      expect(await commits.commit(task, DeadlinePreset.tonight), isNull);
      expect(await commits.load('2026-10-13'), hasLength(1));
    });

    test('a task of a waiting or defeated boss is refused', () async {
      final view = await h.seed();
      final task = await taskId('Read chapter 4');
      await h.bosses.setStatus(view.boss.id, BossStatus.waiting);
      expect(await commits.commit(task, DeadlinePreset.oneHour), isNull);
      await h.bosses.setStatus(view.boss.id, BossStatus.defeated);
      expect(await commits.commit(task, DeadlinePreset.oneHour), isNull);
    });
  });

  group('extend', () {
    test('first is free, second costs a flask', () async {
      await h.seed();
      final id = (await commits.commit(
        await taskId('Read chapter 4'),
        DeadlinePreset.oneHour,
      ))!;
      expect(await commits.extend(id, DeadlinePreset.threeHours), isTrue);
      expect(await flasks(), 3);
      expect(await commits.extend(id, DeadlinePreset.tonight), isTrue);
      expect(await flasks(), 2);
      final row = (await commits.load('2026-10-13')).single.commitment;
      expect(row.extensions, 2);
      expect(row.deadline, DateTime(2026, 10, 13, 23));
    });

    test('refused with no flask left, changing nothing', () async {
      await h.seed();
      await (h.db.update(h.db.settings))
          .write(const SettingsCompanion(flasks: Value(0)));
      final id = (await commits.commit(
        await taskId('Read chapter 4'),
        DeadlinePreset.oneHour,
      ))!;
      await commits.extend(id, DeadlinePreset.threeHours);
      final before = (await commits.load('2026-10-13')).single.commitment;
      expect(await commits.extend(id, DeadlinePreset.tonight), isFalse);
      final after = (await commits.load('2026-10-13')).single.commitment;
      expect(after.deadline, before.deadline);
      expect(after.extensions, 1);
    });

    test('a deadline not later than the current one is refused', () async {
      await h.seed();
      final id = (await commits.commit(
        await taskId('Read chapter 4'),
        DeadlinePreset.tonight,
      ))!;
      expect(await commits.extend(id, DeadlinePreset.oneHour), isFalse);
      expect(
        (await commits.load('2026-10-13')).single.commitment.extensions,
        0,
      );
    });

    test('after the deadline it is refused', () async {
      await h.seed();
      final id = (await commits.commit(
        await taskId('Read chapter 4'),
        DeadlinePreset.oneHour,
      ))!;
      h.clock.now = DateTime(2026, 10, 13, 10);
      expect(await commits.extend(id, DeadlinePreset.tonight), isFalse);
    });
  });

  test('waiting cancels that boss\'s open commitments only', () async {
    final view = await h.seed();
    final other = await h.bosses.saveBoss(
      const BossDraft(
        title: 'The Garden',
        resetOnFail: ResetOnFail.nothing,
        standalone: [TaskDraft(title: 'Dig')],
      ),
    );
    final mine = (await commits.commit(
      await taskId('Read chapter 4'),
      DeadlinePreset.oneHour,
    ))!;
    final theirs = (await commits.commit(
      taskNamed((await h.reload(other)), 'Dig').task.id,
      DeadlinePreset.oneHour,
    ))!;
    await h.bosses.setStatus(view.boss.id, BossStatus.waiting);
    final rows = {
      for (final r in await commits.load('2026-10-13'))
        r.commitment.id: r.commitment.outcome,
    };
    expect(rows[mine], CommitmentOutcome.cancelled);
    expect(rows[theirs], isNull);
  });

  test('loadNote counts promises from six on', () async {
    final id = await h.bosses.saveBoss(
      BossDraft(
        title: 'The Day',
        resetOnFail: ResetOnFail.nothing,
        standalone: [
          for (var i = 0; i < 6; i++)
            TaskDraft(
              title: 'Task $i',
              weight: i < 4 ? Weight.heavy : Weight.light,
            ),
        ],
      ),
    );
    final tasks = (await h.reload(id)).allTasks;
    for (final t in tasks.take(5)) {
      await commits.commit(t.task.id, DeadlinePreset.tonight);
    }
    expect(await commits.loadNote('2026-10-13'), isNull);
    await commits.commit(tasks.last.task.id, DeadlinePreset.tonight);
    expect(
      await commits.loadNote('2026-10-13'),
      const LoadNote(count: 6, heavy: 4),
    );
  });

  test('setStanding works on daily tasks only', () async {
    await h.seed();
    await commits.setStanding(await taskId('Walk'), 1200);
    final walk = taskNamed((await h.bosses.loadAll()).single, 'Walk').task;
    expect(walk.dailyDeadlineMinutes, 1200);
    expect(
      () async => commits.setStanding(await taskId('Read chapter 4'), 1200),
      throwsArgumentError,
    );
    await commits.setStanding(await taskId('Walk'), null);
    final cleared = taskNamed((await h.bosses.loadAll()).single, 'Walk').task;
    expect(cleared.dailyDeadlineMinutes, isNull);
  });
}
