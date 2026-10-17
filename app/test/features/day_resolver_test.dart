import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/enums.dart';

import '../data/harness.dart';
import 'pump.dart';

// The harness starts on 2026-10-13 12:00, the install day (D12). Jumping to
// the 15th makes the 14th a missed day.
void main() {
  late Harness h;
  late String bossId;
  setUp(() async {
    h = Harness();
    bossId = (await h.seed()).boss.id;
  });

  void jumpTo(int day) => h.clock.now = DateTime(2026, 10, day, 12);
  Future<void> setFlasks(int n) => h.setFlasks(n);
  Future<List<Attempt>> falls() async =>
      (await h.db.select(h.db.attempts).get())
          .where((a) => a.outcome == Outcome.fallen)
          .toList();

  testWidgets('shows nothing when no day was missed', (tester) async {
    await pumpApp(tester, h);
    expect(find.text('Fallen.'), findsNothing);
    expect(find.text('Use a flask'), findsNothing);
    await tearDownApp(tester, h);
  });

  group('with no flask left', () {
    setUp(() => setFlasks(0));

    testWidgets('the fallen moment appears and the lesson lands on the boss', (
      tester,
    ) async {
      jumpTo(15);
      await pumpApp(tester, h);
      expect(find.text('Fallen.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Plan the week.');
      await tester.tap(find.text('Rise'));
      await settle(tester);

      final rows = await falls();
      expect(rows.single.lesson, 'Plan the week.');
      expect(rows.single.cause, FallCause.missedDay);
      expect((await h.reload(bossId)).boss.attemptNumber, 2);
      expect(find.text('Fallen.'), findsNothing);
      await tearDownApp(tester, h);
    });

    testWidgets('skipping the lesson still resolves', (tester) async {
      jumpTo(15);
      await pumpApp(tester, h);
      await tester.tap(find.text('Rest first'));
      await settle(tester);

      expect((await falls()).single.lesson, isNull);
      await tearDownApp(tester, h);
    });
  });

  group('with flasks', () {
    testWidgets('using a flask means no fall', (tester) async {
      jumpTo(15);
      await pumpApp(tester, h);
      expect(find.text('Use a flask'), findsOneWidget);

      await tester.tap(find.text('Use a flask'));
      await settle(tester);

      expect(find.text('Fallen.'), findsNothing);
      expect(await falls(), isEmpty);
      expect(await h.flasks(), 2);
      expect((await h.reload(bossId)).boss.attemptNumber, 1);
      await tearDownApp(tester, h);
    });

    testWidgets('letting it fall goes to the fallen moment', (tester) async {
      jumpTo(15);
      await pumpApp(tester, h);
      await tester.tap(find.text('Let it fall'));
      await settle(tester);
      expect(find.text('Fallen.'), findsOneWidget);

      await tester.tap(find.text('Rest first'));
      await settle(tester);
      expect(await falls(), hasLength(1));
      expect(await h.flasks(), 3);
      await tearDownApp(tester, h);
    });

    testWidgets('one flask for two missed days: one is covered, one falls', (
      tester,
    ) async {
      await setFlasks(1);
      jumpTo(16);
      await pumpApp(tester, h);

      await tester.tap(find.text('Use a flask'));
      await settle(tester);
      expect(find.text('Fallen.'), findsOneWidget);
      await tester.tap(find.text('Rest first'));
      await settle(tester);

      expect(await falls(), hasLength(1));
      expect(await h.flasks(), 0);
      final flaskDays = (await h.db.select(h.db.dayLogs).get())
          .where((l) => l.kind == DayKind.flask)
          .map((l) => l.day);
      expect(flaskDays, ['2026-10-14']);
      await tearDownApp(tester, h);
    });
  });

  testWidgets('resuming after rollover resolves the missed day', (
    tester,
  ) async {
    await setFlasks(0);
    await pumpApp(tester, h);
    expect(find.text('Fallen.'), findsNothing);

    jumpTo(15);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await settle(tester);

    expect(find.text('Fallen.'), findsOneWidget);
    await tester.tap(find.text('Rest first'));
    await settle(tester);
    expect(await falls(), hasLength(1));
    await tearDownApp(tester, h);
  });

  testWidgets('leaving before the lesson is saved offers it again', (
    tester,
  ) async {
    await setFlasks(0);
    jumpTo(15);
    await pumpApp(tester, h);
    expect(find.text('Fallen.'), findsOneWidget);

    // The app is killed on the fallen screen: nothing was written.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
    expect(await falls(), isEmpty);
    expect((await h.settings.device()).lastResolvedDay, '2026-10-13');

    await pumpApp(tester, h);
    expect(find.text('Fallen.'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('a resolved day is never shown twice', (tester) async {
    await setFlasks(0);
    jumpTo(15);
    await pumpApp(tester, h);
    await tester.tap(find.text('Rest first'));
    await settle(tester);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await settle(tester);

    expect(find.text('Fallen.'), findsNothing);
    expect(await falls(), hasLength(1));
    await tearDownApp(tester, h);
  });

  testWidgets('with no boss to fall, the day is advanced quietly', (
    tester,
  ) async {
    await h.bosses.setStatus(bossId, BossStatus.waiting);
    jumpTo(15);
    await pumpApp(tester, h);

    expect(find.text('Fallen.'), findsNothing);
    expect(find.text('Use a flask'), findsNothing);
    expect((await h.settings.device()).lastResolvedDay, '2026-10-14');
    await tearDownApp(tester, h);
  });
}
