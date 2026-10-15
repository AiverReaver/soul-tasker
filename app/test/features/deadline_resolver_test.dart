import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/deadlines.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/commitment_dao.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/ember_dao.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/health_dao.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import 'pump.dart';

// Starts 2026-10-14 08:00, the day after install, so no missed day is
// pending unless a test jumps further.
void main() {
  late Harness h;
  late CommitmentDao commits;
  late HealthDao health;
  setUp(() {
    h = Harness(null, StepClock(DateTime(2026, 10, 13, 12)));
    h.clock.now = DateTime(2026, 10, 14, 8);
    commits = CommitmentDao(h.db, h.clock.call);
    health = HealthDao(h.db, h.clock.call, h.attempts);
  });

  Future<String> boss(String title, int heavy) => h.bosses.saveBoss(
    BossDraft(
      title: title,
      resetOnFail: ResetOnFail.nothing,
      standalone: [
        for (var i = 0; i < heavy; i++) TaskDraft(title: '$title T$i'),
      ],
    ),
  );
  Future<List<String>> tasksOf(String id) async => [
    for (final t in (await h.reload(id)).allTasks) t.task.id,
  ];
  Future<void> promiseAll(List<String> ids) async {
    for (final t in ids) {
      await commits.commit(t, DeadlinePreset.oneHour);
    }
  }

  Future<List<Attempt>> falls(FallCause cause) async => [
    for (final a in await h.db.select(h.db.attempts).get())
      if (a.cause == cause) a,
  ];

  testWidgets('nothing due: nothing shown', (tester) async {
    await boss('A', 1);
    await pumpApp(tester, h);
    expect(find.textContaining('While you were away'), findsNothing);
    expect(find.text('Fallen.'), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('two passed deadlines: one summary; done late earns embers', (
    tester,
  ) async {
    final a = await boss('A', 2);
    await promiseAll(await tasksOf(a));
    h.clock.now = DateTime(2026, 10, 14, 12);
    await pumpApp(tester, h);

    expect(
      find.text('While you were away, two deadlines passed.'),
      findsOneWidget,
    );
    expect(find.text('−2 health'), findsNWidgets(2));
    await tester.tap(find.text('Done late').first);
    await settle(tester);
    await tester.tap(find.text('Go on'));
    await settle(tester);

    final outcomes = [
      for (final v in await commits.load('2026-10-14')) v.commitment.outcome,
    ];
    expect(outcomes, contains(CommitmentOutcome.lateStrike));
    expect(
      await EmberDao(h.db, h.clock.call).tally(),
      const EmberTally(carried: 2, banked: 0),
    );
    expect(await health.health('2026-10-14'), 12);
    await tearDownApp(tester, h);
  });

  testWidgets('a deadline passing while open is caught within one tick', (
    tester,
  ) async {
    final a = await boss('A', 1);
    await promiseAll(await tasksOf(a));
    await pumpApp(tester, h);

    h.clock.now = DateTime(2026, 10, 14, 9, 30);
    await tester.pump(kDeadlineTick);
    await settle(tester);

    expect(find.text('A deadline passed: A T0.'), findsOneWidget);
    expect(find.textContaining('While you were away'), findsNothing);
    expect(await health.health('2026-10-14'), 16);
    await tearDownApp(tester, h);
  });

  testWidgets('a death shows the numbers; the lesson lands on the fall', (
    tester,
  ) async {
    final a = await boss('A', 5);
    await promiseAll(await tasksOf(a));
    h.clock.now = DateTime(2026, 10, 14, 12);
    await pumpApp(tester, h);
    await tester.tap(find.text('Go on'));
    await settle(tester);

    expect(find.text('Fallen.'), findsOneWidget);
    expect(find.text('Five promised, none kept.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Promise less.');
    await tester.tap(find.text('Rise'));
    await settle(tester);

    final fall = (await falls(FallCause.healthDeath)).single;
    expect(fall.lesson, 'Promise less.');
    await tearDownApp(tester, h);
  });

  testWidgets('a death and a missed day: one fallen moment, one lesson', (
    tester,
  ) async {
    // Bosses from the install day, so the 14th can fail them (D4).
    h.clock.now = DateTime(2026, 10, 13, 13);
    final a = await boss('A', 5);
    await boss('B', 1);
    h.clock.now = DateTime(2026, 10, 14, 8);
    await promiseAll(await tasksOf(a));
    await (h.db.update(h.db.settings))
        .write(const SettingsCompanion(flasks: Value(0)));
    // The 14th passes with no rest; open on the 15th.
    h.clock.now = DateTime(2026, 10, 15, 12);
    await pumpApp(tester, h);
    await tester.tap(find.text('Go on'));
    await settle(tester);

    expect(find.text('Fallen.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'One bad day.');
    await tester.tap(find.text('Rise'));
    await settle(tester);
    expect(find.text('Fallen.'), findsNothing);

    final death = (await falls(FallCause.healthDeath)).single;
    final missed = await falls(FallCause.missedDay);
    expect(death.lesson, 'One bad day.');
    // A died by health on the 14th, so only B falls for the missed day.
    expect(missed.map((m) => m.lesson), ['One bad day.']);
    await tearDownApp(tester, h);
  });

  testWidgets('the timer stops in the background and restarts on resume', (
    tester,
  ) async {
    final a = await boss('A', 1);
    await promiseAll(await tasksOf(a));
    await pumpApp(tester, h);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    h.clock.now = DateTime(2026, 10, 14, 9, 30);
    await tester.pump(kDeadlineTick * 3);
    expect(await health.health('2026-10-14'), 20);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await settle(tester);
    expect(await health.health('2026-10-14'), 16);
    expect(
      find.text('While you were away, a deadline passed.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Go on'));
    await settle(tester);
    await tearDownApp(tester, h);
  });

  testWidgets('a Tried that empties health shows the fallen moment', (
    tester,
  ) async {
    final a = await boss('A', 1);
    final task = (await tasksOf(a)).single;
    await commits.commit(task, DeadlinePreset.tonight);
    await health.record(-19, HealthReason.miss, '2026-10-14', h.clock());
    await pumpApp(tester, h);
    await tester.tap(find.text('Today'));
    await settle(tester);

    await tester.tap(find.byTooltip('Actions for A T0'));
    await settle(tester);
    await tester.tap(find.text('Mark as tried'));
    await settle(tester);

    expect(find.text('Fallen.'), findsOneWidget);
    expect(find.text('One promised, none kept.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Smaller steps.');
    await tester.tap(find.text('Rise'));
    await settle(tester);
    expect(
      (await falls(FallCause.healthDeath)).single.lesson,
      'Smaller steps.',
    );
    await tearDownApp(tester, h);
  });

  testWidgets('a death settled inside a later Tried shows the fallen moment', (
    tester,
  ) async {
    final a = await boss('A', 6);
    final ts = await tasksOf(a);
    await promiseAll(ts.take(5).toList());
    await pumpApp(tester, h);
    await tester.tap(find.text('Today'));
    await settle(tester);

    // The deadlines pass between ticks; the strike settles them first.
    h.clock.now = DateTime(2026, 10, 14, 9, 30);
    await tester.ensureVisible(find.byTooltip('Actions for A T5'));
    await settle(tester);
    await tester.tap(find.byTooltip('Actions for A T5'));
    await settle(tester);
    await tester.tap(find.text('Mark as tried'));
    await settle(tester);

    expect(find.text('Fallen.'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await settle(tester);
    // Skipped: not offered again in this run.
    await tester.pump(kDeadlineTick);
    await settle(tester);
    expect(find.text('Fallen.'), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('a fall left without its lesson is offered on the next open', (
    tester,
  ) async {
    final a = await boss('A', 5);
    await promiseAll(await tasksOf(a));
    h.clock.now = DateTime(2026, 10, 14, 12);
    // Settled, then the app was killed before the fallen moment.
    await health.resolveDue();
    await pumpApp(tester, h);

    expect(find.text('Fallen.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Next time.');
    await tester.tap(find.text('Rise'));
    await settle(tester);
    expect((await falls(FallCause.healthDeath)).single.lesson, 'Next time.');
    await tearDownApp(tester, h);
  });
}
