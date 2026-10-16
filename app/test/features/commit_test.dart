import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/deadlines.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/commitment_dao.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:material_ui/material_ui.dart' show Offset, Scrollable;

import '../data/harness.dart';
import 'pump.dart';

void main() {
  late Harness h;
  late CommitmentDao commits;
  setUp(() {
    h = Harness(null, StepClock(DateTime(2026, 10, 13, 8)));
    commits = CommitmentDao(h.db, h.clock.call);
  });

  Future<void> openToday(WidgetTester tester) async {
    await pumpApp(tester, h);
    await tester.tap(find.text('Today'));
    await settle(tester);
  }

  Future<void> menu(WidgetTester tester, String task, String item) async {
    await tester.ensureVisible(find.byTooltip('Actions for $task'));
    await settle(tester);
    await tester.tap(find.byTooltip('Actions for $task'));
    await settle(tester);
    await tester.tap(find.text(item));
    await settle(tester);
  }

  testWidgets('promise from Today: the row shows its deadline', (tester) async {
    await h.seed();
    await openToday(tester);

    await menu(tester, 'Read chapter 4', 'Promise by…');
    await tester.tap(find.text('Tonight'));
    await settle(tester);

    final row = (await commits.load('2026-10-13')).single;
    expect(row.taskTitle, 'Read chapter 4');
    expect(find.text('by 11:00 PM'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('the sixth promise shows the calm note and still commits', (
    tester,
  ) async {
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
    await openToday(tester);

    await menu(tester, 'Task 5', 'Promise by…');
    await tester.tap(find.text('Tonight'));
    await settle(tester);

    expect(await commits.load('2026-10-13'), hasLength(6));
    // The flash line sits above the list; scroll back to it.
    await tester.drag(find.byType(Scrollable).last, const Offset(0, 2000));
    await settle(tester);
    expect(
      find.text('That is six promises, four of them heavy.'),
      findsOneWidget,
    );
    await tearDownApp(tester, h);
  });

  testWidgets('move it later: first free, then a flask', (tester) async {
    final view = await h.seed();
    final task = taskNamed(view, 'Read chapter 4').task.id;
    await commits.commit(task, DeadlinePreset.oneHour);
    await openToday(tester);

    await menu(tester, 'Read chapter 4', 'Move it later');
    expect(find.text('Free, once.'), findsOneWidget);
    await tester.tap(find.text('In 3 hours'));
    await settle(tester);
    await menu(tester, 'Read chapter 4', 'Move it later');
    expect(find.text('Costs a flask. You hold 3.'), findsOneWidget);
    await tester.tap(find.text('Tonight'));
    await settle(tester);

    expect(await h.flasks(), 2);
    final row = (await commits.load('2026-10-13')).single.commitment;
    expect(row.extensions, 2);
    await tearDownApp(tester, h);
  });

  testWidgets('Today shows health, and it drops after a Tried', (tester) async {
    final view = await h.seed();
    await commits.commit(
      taskNamed(view, 'Read chapter 4').task.id,
      DeadlinePreset.tonight,
    );
    await openToday(tester);
    expect(find.bySemanticsLabel('Health 10 of 10'), findsOneWidget);

    await menu(tester, 'Read chapter 4', 'Mark as tried');

    expect(find.bySemanticsLabel('Health 9 of 10'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('a waiting boss offers no promise', (tester) async {
    final view = await h.seed();
    await h.bosses.setStatus(view.boss.id, BossStatus.waiting);
    await pumpApp(tester, h, location: '/boss/${view.boss.id}');

    await tester.tap(find.byTooltip('Actions for Read chapter 4'));
    await settle(tester);
    expect(find.text('Promise by…'), findsNothing);
    expect(find.text('Edit'), findsOneWidget);
    await tester.tapAt(Offset.zero);
    await settle(tester);
    await tearDownApp(tester, h);
  });
}
