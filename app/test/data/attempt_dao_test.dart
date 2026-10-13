import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/enums.dart';

import 'harness.dart';

void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() => h.db.close());

  group('strike', () {
    test('one-time task stays struck; daily task resets at rollover', () async {
      final view = await h.seed();
      await h.attempts.strike(taskNamed(view, 'Flashcards').task.id);
      await h.attempts.strike(taskNamed(view, 'Walk').task.id);

      var after = await h.reload(view.boss.id);
      expect(taskNamed(after, 'Flashcards').isStruck, isTrue);
      expect(taskNamed(after, 'Walk').isStruck, isTrue);
      expect(after.health, closeTo(2 / 3, 1e-9));

      h.clock.now = h.clock.now.add(const Duration(days: 1));
      after = await h.reload(view.boss.id);
      expect(taskNamed(after, 'Flashcards').isStruck, isTrue);
      expect(taskNamed(after, 'Walk').isStruck, isFalse);
    });

    test('striking twice records one strike', () async {
      final view = await h.seed();
      final id = taskNamed(view, 'Flashcards').task.id;
      await h.attempts.strike(id);
      await h.attempts.strike(id);
      expect(await h.db.select(h.db.attempts).get(), hasLength(1));
    });

    test('draining the last segment is vanquished, even with daily and '
        'standalone tasks open (D3)', () async {
      final view = await h.seed();
      final results = [
        for (final t in view.segments) await h.attempts.strike(t.task.id),
      ];
      expect(results.map((r) => r.isVanquished), [false, false, true]);
      expect((await h.reload(view.boss.id)).isVanquished, isTrue);
    });

    test('a boss with only daily tasks is never vanquished', () async {
      final id = await h.bosses.saveBoss(
        const BossDraft(
          title: 'Run daily',
          resetOnFail: ResetOnFail.nothing,
          phases: [
            PhaseDraft(
              name: 'Habit',
              tasks: [TaskDraft(title: 'Run', recurrence: Recurrence.daily)],
            ),
          ],
        ),
      );
      final view = await h.reload(id);
      final result = await h.attempts.strike(view.allTasks.single.task.id);
      expect(result.isVanquished, isFalse);
      expect((await h.reload(id)).hasSegments, isFalse);
    });
  });

  group('fall', () {
    test('raises the counter and keeps a trimmed lesson', () async {
      final view = await h.seed();
      await h.attempts.fall(view.boss.id, '  Rushed the second phase.  ');

      final after = await h.reload(view.boss.id);
      expect(after.boss.attemptNumber, 2);
      expect(after.lastLesson, 'Rushed the second phase.');
    });

    test(
      'a skipped lesson keeps the older one; empty is stored as null',
      () async {
        final view = await h.seed();
        await h.attempts.fall(view.boss.id, 'Sleep more.');
        await h.attempts.fall(view.boss.id, '   ');

        final after = await h.reload(view.boss.id);
        expect(after.boss.attemptNumber, 3);
        expect(after.lastLesson, 'Sleep more.');
        final falls = await h.db.select(h.db.attempts).get();
        expect(falls.last.lesson, isNull);
        expect(falls.last.cause, FallCause.declared);
      },
    );

    test('long lessons are cut to 120 characters', () async {
      final view = await h.seed();
      await h.attempts.fall(view.boss.id, 'x' * 200);
      expect((await h.reload(view.boss.id)).lastLesson, hasLength(120));
    });
  });

  group('reset on a failed attempt', () {
    Future<void> strikeAll(Harness h, String bossId) async {
      final view = await h.reload(bossId);
      for (final t in view.allTasks) {
        if (t.task.title != 'Sit the exam') await h.attempts.strike(t.task.id);
      }
    }

    test('nothing keeps all progress', () async {
      final view = await h.seed();
      await strikeAll(h, view.boss.id);
      await h.attempts.fall(view.boss.id, null);

      final after = await h.reload(view.boss.id);
      expect(taskNamed(after, 'Read chapter 4').isStruck, isTrue);
      expect(taskNamed(after, 'Book the room').isStruck, isTrue);
    });

    test('current phase reopens that phase only, not standalone', () async {
      final view = await h.seed(reset: ResetOnFail.currentPhase);
      await h.attempts.strike(taskNamed(view, 'Read chapter 4').task.id);
      await h.attempts.strike(taskNamed(view, 'Book the room').task.id);
      await h.attempts.fall(view.boss.id, null);

      final after = await h.reload(view.boss.id);
      expect(taskNamed(after, 'Read chapter 4').isStruck, isFalse);
      expect(taskNamed(after, 'Book the room').isStruck, isTrue);
    });

    test('current phase leaves finished earlier phases done', () async {
      final view = await h.seed(reset: ResetOnFail.currentPhase);
      await strikeAll(h, view.boss.id); // Learn is done; Fight is current.
      await h.attempts.fall(view.boss.id, null);

      final after = await h.reload(view.boss.id);
      expect(after.phases.first.isDone, isTrue);
    });

    test(
      'whole boss reopens every one-time task, standalone too (D9)',
      () async {
        final view = await h.seed(reset: ResetOnFail.wholeBoss);
        await strikeAll(h, view.boss.id);
        await h.attempts.fall(view.boss.id, null);

        final after = await h.reload(view.boss.id);
        expect(taskNamed(after, 'Read chapter 4').isStruck, isFalse);
        expect(taskNamed(after, 'Book the room').isStruck, isFalse);
        expect(after.health, 1);
      },
    );

    test('a reopened task can be struck again in the new attempt', () async {
      final view = await h.seed(reset: ResetOnFail.wholeBoss);
      final id = taskNamed(view, 'Read chapter 4').task.id;
      await h.attempts.strike(id);
      await h.attempts.fall(view.boss.id, null);
      await h.attempts.strike(id);

      expect(
        taskNamed(await h.reload(view.boss.id), 'Read chapter 4').isStruck,
        isTrue,
      );
    });

    test('resets never delete history', () async {
      final view = await h.seed(reset: ResetOnFail.wholeBoss);
      await strikeAll(h, view.boss.id);
      final before = (await h.db.select(h.db.attempts).get()).length;
      await h.attempts.fall(view.boss.id, null);
      expect(await h.db.select(h.db.attempts).get(), hasLength(before + 1));
    });
  });

  group('rule of three (D11)', () {
    test('task prompts on the 3rd and 6th try, not the 4th or 5th', () async {
      final view = await h.seed();
      final id = taskNamed(view, 'Read chapter 4').task.id;
      final prompts = [for (var i = 0; i < 6; i++) await h.attempts.tried(id)];
      expect(prompts, [false, false, true, false, false, true]);
    });

    test('a strike restarts the task count', () async {
      final view = await h.seed();
      final id = taskNamed(view, 'Walk').task.id;
      await h.attempts.tried(id);
      await h.attempts.tried(id);
      await h.attempts.strike(id);
      final prompts = [for (var i = 0; i < 3; i++) await h.attempts.tried(id)];
      expect(prompts, [false, false, true]);
    });

    test('phase prompts on the 3rd fall at the same phase', () async {
      final view = await h.seed();
      final prompts = [
        for (var i = 0; i < 3; i++) await h.attempts.fall(view.boss.id, null),
      ];
      expect(prompts, [false, false, true]);
    });

    test('a fall at a different phase starts a new run', () async {
      final view = await h.seed();
      await h.attempts.fall(view.boss.id, null);
      await h.attempts.fall(view.boss.id, null);
      // Finish phase 1 so the next fall happens at phase 2.
      for (final t in view.segments.take(2)) {
        await h.attempts.strike(t.task.id);
      }
      expect(await h.attempts.fall(view.boss.id, null), isFalse);
      expect(await h.attempts.fall(view.boss.id, null), isFalse);
      expect(await h.attempts.fall(view.boss.id, null), isTrue);
    });
  });

  group('history on delete (D10)', () {
    test('deleting a task keeps its attempts with a null reference', () async {
      final view = await h.seed();
      final id = taskNamed(view, 'Flashcards').task.id;
      await h.attempts.tried(id);
      await h.bosses.deleteTask(id);

      final rows = await h.db.select(h.db.attempts).get();
      expect(rows.single.taskId, isNull);
      expect(rows.single.bossId, view.boss.id);
    });

    test('deleting a phase keeps falls and lessons; breaks the run', () async {
      final view = await h.seed();
      await h.attempts.fall(view.boss.id, 'First.');
      await h.attempts.fall(view.boss.id, 'Second.');

      final draft = BossDraft.fromView(view);
      await h.bosses.saveBoss(draft.copyWith(phases: [draft.phases.last]));
      final after = await h.reload(view.boss.id);

      expect(after.boss.attemptNumber, 3);
      expect(after.lastLesson, 'Second.');
      // The two earlier falls lost their phase, so the run restarts.
      expect(await h.attempts.fall(view.boss.id, null), isFalse);
    });
  });
}
