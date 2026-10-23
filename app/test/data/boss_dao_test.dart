import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/enums.dart';

import 'harness.dart';

void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() => h.db.close());

  test('saves a boss with chapters, tasks and standalone tasks', () async {
    final view = await h.seed();

    expect(view.boss.attemptNumber, 1);
    expect(view.phases.map((p) => p.phase.name), ['Learn', 'Fight']);
    expect(view.phases.first.tasks.map((t) => t.task.title), [
      'Read chapter 4',
      'Flashcards',
      'Walk',
    ]);
    expect(view.standalone.single.task.title, 'Book the room');
    // D1: daily and standalone tasks are not segments.
    expect(view.segments.map((t) => t.task.title), [
      'Read chapter 4',
      'Flashcards',
      'Sit the exam',
    ]);
    expect(view.currentPhase!.phase.name, 'Learn');
  });

  test('rejects a draft without a title or tasks', () {
    expect(
      () => h.bosses.saveBoss(
        const BossDraft(title: ' ', resetOnFail: ResetOnFail.nothing),
      ),
      throwsArgumentError,
    );
  });

  test('edit reorders chapters, moves a task, deletes removed rows', () async {
    final view = await h.seed();
    final draft = BossDraft.fromView(view);
    final learn = draft.phases[0];
    final fight = draft.phases[1];
    final moved = learn.tasks.first;

    final id = await h.bosses.saveBoss(
      draft.copyWith(
        title: 'Renamed',
        phases: [
          fight.copyWith(tasks: [...fight.tasks, moved]),
          learn.copyWith(tasks: learn.tasks.skip(1).toList()),
        ],
        standalone: const [],
      ),
    );
    final after = await h.reload(id);

    expect(after.boss.title, 'Renamed');
    expect(after.phases.map((p) => p.phase.name), ['Fight', 'Learn']);
    expect(after.phases.first.tasks.map((t) => t.task.title), [
      'Sit the exam',
      'Read chapter 4',
    ]);
    expect(after.phases.first.tasks.last.task.id, moved.id);
    expect(after.standalone, isEmpty);
  });

  test('deleting a chapter removes its tasks', () async {
    final view = await h.seed();
    final draft = BossDraft.fromView(view);
    await h.bosses.saveBoss(draft.copyWith(phases: [draft.phases.first]));

    final after = await h.reload(view.boss.id);
    expect(after.phases, hasLength(1));
    expect(
      after.allTasks.map((t) => t.task.title),
      isNot(contains('Sit the exam')),
    );
  });

  test('home order: pinned, then most recently fought, then newest', () async {
    final a = await h.seed();
    final b = await h.seed();
    final c = await h.seed();

    await h.attempts.strike(taskNamed(a, 'Flashcards').task.id);
    await h.bosses.setPinned(c.boss.id, isPinned: true);

    final order = (await h.bosses.loadAll()).map((v) => v.boss.id);
    expect(order, [c.boss.id, a.boss.id, b.boss.id]);
  });

  test('defeat records the defeat time and is final (Stage 5 D2)', () async {
    final view = await h.seed();
    await h.bosses.setStatus(view.boss.id, BossStatus.waiting);
    await h.bosses.setStatus(view.boss.id, BossStatus.active);
    expect((await h.reload(view.boss.id)).boss.defeatedAt, isNull);

    await h.bosses.setStatus(view.boss.id, BossStatus.defeated);
    final boss = (await h.reload(view.boss.id)).boss;
    expect(boss.status, BossStatus.defeated);
    expect(boss.defeatedAt, isNotNull);
    expect(
      () => h.bosses.setStatus(view.boss.id, BossStatus.active),
      throwsStateError,
    );
  });

  test('split hides the original and inserts lighter tasks after it', () async {
    final view = await h.seed();
    final original = taskNamed(view, 'Read chapter 4');

    await h.bosses.splitTask(original.task.id, ['Pages 1-10', 'Pages 11-20']);
    final after = await h.reload(view.boss.id);

    expect(after.phases.first.tasks.map((t) => t.task.title), [
      'Pages 1-10',
      'Pages 11-20',
      'Flashcards',
      'Walk',
    ]);
    expect(after.phases.first.tasks.first.task.weight, Weight.light);
    expect(after.segments, hasLength(4));
  });

  test('split needs 2 to 5 titles', () async {
    final view = await h.seed();
    final id = taskNamed(view, 'Read chapter 4').task.id;
    expect(() => h.bosses.splitTask(id, ['One']), throwsArgumentError);
  });

  test('saving after a split keeps the hidden original', () async {
    final view = await h.seed();
    final original = taskNamed(view, 'Read chapter 4');
    await h.bosses.splitTask(original.task.id, ['A', 'B']);

    await h.bosses.saveBoss(BossDraft.fromView(await h.reload(view.boss.id)));
    final rows = await h.db.select(h.db.tasks).get();
    expect(rows.where((t) => t.id == original.task.id), hasLength(1));
  });

  test('deleting a boss removes chapters, tasks and attempts', () async {
    final view = await h.seed();
    await h.attempts.strike(taskNamed(view, 'Flashcards').task.id);
    await h.bosses.deleteBoss(view.boss.id);

    expect(await h.db.select(h.db.phases).get(), isEmpty);
    expect(await h.db.select(h.db.tasks).get(), isEmpty);
    expect(await h.db.select(h.db.attempts).get(), isEmpty);
  });

  test('settings row exists with defaults and updates', () async {
    var s = await h.settings.watch().first;
    expect(s.tapMode, isFalse);
    expect(s.defaultResetOnFail, ResetOnFail.nothing);

    await h.settings.setTapMode(true);
    await h.settings.setDefaultReset(ResetOnFail.wholeBoss);
    s = await h.settings.watch().first;
    expect(s.tapMode, isTrue);
    expect(s.defaultResetOnFail, ResetOnFail.wholeBoss);
  });

  test('haptics default on and the choice persists', () async {
    expect((await h.settings.watch().first).haptics, isTrue);

    await h.settings.setHaptics(false);
    expect((await h.settings.watch().first).haptics, isFalse);

    await h.settings.setHaptics(true);
    expect((await h.settings.watch().first).haptics, isTrue);
  });
}
