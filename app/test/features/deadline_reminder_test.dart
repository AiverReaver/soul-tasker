import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/deadlines.dart';
import 'package:hearthrise/core/local_reminders.dart';
import 'package:hearthrise/core/reminder_text.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/commitment_dao.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/enums.dart';

import '../data/harness.dart';
import '../support/fake_reminders.dart';
import 'pump.dart';

void main() {
  late Harness h;
  late CommitmentDao commits;
  late FakeReminders reminders;
  late String task;
  setUp(() async {
    h = Harness(null, StepClock(DateTime(2026, 10, 13, 8)));
    commits = CommitmentDao(h.db, h.clock.call);
    reminders = FakeReminders();
    final view = await h.seed();
    task = taskNamed(view, 'Read chapter 4').task.id;
  });

  Future<Commitment> only() async =>
      (await commits.load('2026-10-13')).single.commitment;

  testWidgets('a promise with a reminder is scheduled 10 minutes before', (
    tester,
  ) async {
    await pumpApp(tester, h, reminders: reminders);
    await commits.commit(task, DeadlinePreset.tonight, remind: true);
    await settle(tester);

    final c = await only();
    expect(reminders.once.keys, [c.id]);
    expect(reminders.once[c.id]!.at, DateTime(2026, 10, 13, 22, 50));
    // The task title, never the boss title (plan D20).
    expect(reminders.once[c.id]!.body, 'Read chapter 4');
    await tearDownApp(tester, h);
  });

  testWidgets('no reminder unless asked, or once its time has passed', (
    tester,
  ) async {
    await pumpApp(tester, h, reminders: reminders);
    await commits.commit(task, DeadlinePreset.tonight);
    await settle(tester);
    expect(reminders.once, isEmpty);

    // 03:55 still belongs to the 13th; the deadline is capped at 04:00, so
    // ten minutes before it has already passed.
    h.clock.now = DateTime(2026, 10, 14, 3, 55);
    final boss = (await h.bosses.loadAll()).single.boss.id;
    await commits.commit(
      taskNamed(await h.reload(boss), 'Flashcards').task.id,
      DeadlinePreset.oneHour,
      remind: true,
    );
    await settle(tester);
    expect(reminders.once, isEmpty);
    await tearDownApp(tester, h);
  });

  testWidgets('a strike removes it; an extension moves it', (tester) async {
    await pumpApp(tester, h, reminders: reminders);
    final id = (await commits.commit(
      task,
      DeadlinePreset.oneHour,
      remind: true,
    ))!;
    await settle(tester);
    final first = reminders.once[id]!.at;

    await commits.extend(id, DeadlinePreset.tonight);
    await settle(tester);
    expect(reminders.once[id]!.at, isNot(first));
    expect(reminders.once[id]!.at, DateTime(2026, 10, 13, 22, 50));

    await h.attempts.strike(task);
    await settle(tester);
    expect(reminders.once, isEmpty);
    await tearDownApp(tester, h);
  });

  testWidgets('Tried and a waiting boss remove it', (tester) async {
    await pumpApp(tester, h, reminders: reminders);
    await commits.commit(task, DeadlinePreset.tonight, remind: true);
    await settle(tester);
    await h.attempts.tried(task);
    await settle(tester);
    expect(reminders.once, isEmpty);

    final boss = (await h.bosses.loadAll()).single.boss.id;
    final flash = taskNamed(await h.reload(boss), 'Flashcards').task.id;
    await commits.commit(flash, DeadlinePreset.tonight, remind: true);
    await settle(tester);
    expect(reminders.once, hasLength(1));
    await h.bosses.setStatus(boss, BossStatus.waiting);
    await settle(tester);
    expect(reminders.once, isEmpty);
    await tearDownApp(tester, h);
  });

  testWidgets('a missed deadline removes it', (tester) async {
    await pumpApp(tester, h, reminders: reminders);
    await commits.commit(task, DeadlinePreset.oneHour, remind: true);
    await settle(tester);
    expect(reminders.once, hasLength(1));
    h.clock.now = DateTime(2026, 10, 13, 9, 30);
    await tester.pump(kDeadlineTick);
    await settle(tester);
    expect(reminders.once, isEmpty);
    await tearDownApp(tester, h);
  });

  testWidgets('renaming the task reschedules it with the new title', (
    tester,
  ) async {
    await pumpApp(tester, h, reminders: reminders);
    final id = (await commits.commit(
      task,
      DeadlinePreset.tonight,
      remind: true,
    ))!;
    await settle(tester);
    final boss = (await h.bosses.loadAll()).single;
    final draft = BossDraft.fromView(boss);
    await h.bosses.saveBoss(
      draft.copyWith(
        phases: [
          for (final p in draft.phases)
            p.copyWith(
              tasks: [
                for (final t in p.tasks)
                  t.title == 'Read chapter 4'
                      ? t.copyWith(title: 'Read chapter five')
                      : t,
              ],
            ),
        ],
      ),
    );
    await settle(tester);
    expect(reminders.once[id]!.body, 'Read chapter five');
    await tearDownApp(tester, h);
  });

  test('the title is fixed; ids are stable and never the daily one', () {
    expect(kDeadlineReminderTitle, 'A promise is due soon.');
    expect(reminderIdFor('abc'), reminderIdFor('abc'));
    expect(reminderIdFor('abc'), isNot(reminderIdFor('abd')));
    expect(reminderIdFor('abc'), isNot(1));
  });

  testWidgets('deleting the task cancels its reminder', (tester) async {
    await pumpApp(tester, h, reminders: reminders);
    await commits.commit(task, DeadlinePreset.tonight, remind: true);
    await settle(tester);
    expect(reminders.once, hasLength(1));
    await h.bosses.deleteTask(task);
    await settle(tester);
    expect(reminders.once, isEmpty);
    await tearDownApp(tester, h);
  });
}
