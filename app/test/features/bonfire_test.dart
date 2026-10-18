import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/database.dart' show SignalEvent;
import 'package:hearthrise/data/plan_pick_dao.dart';
import 'package:hearthrise/data/boss_view.dart';
import 'package:hearthrise/data/day_dao.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/providers.dart';
import 'package:hearthrise/ui/ember_button.dart';
import 'package:hearthrise/ui/pick_toggle_row.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/glass_circle_button.dart';
import 'package:hearthrise/ui/thread_divider.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import '../support/recording_haptics.dart';
import 'pump.dart';

void main() {
  late Harness h;
  late BossView view;
  late PlanPickDao plans;
  setUp(() async {
    h = Harness();
    view = await h.seed();
    plans = PlanPickDao(h.db, h.bosses, h.clock.call);
  });

  Finder restButton() => find.widgetWithText(EmberButton, 'Rest at the hearth');

  Future<List<SignalEvent>> moods() async => [
    for (final e in await h.db.select(h.db.signalEvents).get())
      if (e.kind == SignalKind.mood) e,
  ];

  testWidgets('shows the D9 parts in order', (tester) async {
    await pumpApp(tester, h, location: '/bonfire', tall: true);

    expect(find.text('BONFIRE'), findsOneWidget);
    expect(find.text('Rest a while.'), findsOneWidget);
    expect(
      find.text('Night 1 at the hearth. Tell it how the day went.'),
      findsOneWidget,
    );
    expect(find.text('How did today go?'), findsOneWidget);
    for (final l in ['Fought well', 'Held on', 'I fell']) {
      expect(find.text(l), findsOneWidget);
    }
    expect(find.text('Flasks restored'), findsOneWidget);
    expect(find.text('One thing for tomorrow'), findsOneWidget);
    expect(find.text('Write before noon'), findsOneWidget);
    expect(find.text('Tomorrow’s tasks'), findsOneWidget);
    expect(find.text('0 of 3 chosen'), findsOneWidget);
    expect(restButton(), findsOneWidget);
    // The day summary, ember tally, health bar and accuracy line are gone.
    expect(find.text('Struck 1'), findsNothing);
    expect(find.textContaining('kept'), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('reference layout: back button, centred title, full-width rest', (
    tester,
  ) async {
    await pumpApp(tester, h, location: '/bonfire', tall: true);
    expect(find.byType(GlassCircleButton), findsOneWidget);
    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    final title = tester.getCenter(find.text('Rest a while.'));
    expect(title.dx, closeTo(width / 2, 1));
    expect(tester.getSize(restButton()).width, greaterThan(width - 60));
    expect(find.byType(ThreadDivider), findsOneWidget);
    final subtitle = tester.widget<Text>(
      find.text('Night 1 at the hearth. Tell it how the day went.'),
    );
    expect(subtitle.style?.color, Biome.pharloom.palette.ash);
    await tearDownApp(tester, h);
  });

  testWidgets('a mood pick changes the note and writes a mood signal', (
    tester,
  ) async {
    await h.attempts.strike(taskNamed(view, 'Flashcards').task.id);
    await pumpApp(tester, h, location: '/bonfire', tall: true);

    await tester.tap(find.text('Fought well'));
    await settle(tester);
    expect(find.text('1 task struck. The Warden felt it.'), findsOneWidget);

    await tester.tap(find.text('Held on'));
    await settle(tester);
    expect(find.text('Holding on is a kind of winning.'), findsOneWidget);

    await tester.tap(find.text('I fell'));
    await settle(tester);
    expect(find.text('You fell. Rise. Embers are kept.'), findsOneWidget);

    expect([for (final e in await moods()) e.value], [0, 1, 2]);
    await tearDownApp(tester, h);
  });

  testWidgets('Rest saves the lesson, banks, and goes Home', (tester) async {
    await h.attempts.strike(taskNamed(view, 'Flashcards').task.id);
    await h.settings.setReminder(enabled: true, minutes: 1260);
    final haptics = RecordingHaptics();
    await pumpApp(
      tester,
      h,
      location: '/bonfire',
      tall: true,
      overrides: [haptics.asOverride],
    );

    expect(
      find.text('One gentle reminder tomorrow at 9:00 PM.'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField), 'Plan earlier.');
    await tester.ensureVisible(restButton());
    await tester.tap(restButton());
    await settle(tester);

    final log = (await h.db.select(h.db.dayLogs).get()).single;
    expect(log.kind, DayKind.bonfire);
    expect(log.lesson, 'Plan earlier.');
    final embers = await h.db.select(h.db.emberEvents).get();
    expect(embers.where((e) => e.kind == EmberKind.bank).single.amount, 1);
    expect(haptics.events, contains('medium'));
    expect(find.text('Today’s tasks'), findsOneWidget); // Home
    expect(restButton(), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('reopening after a rest is read-only (D9)', (tester) async {
    await DayDao(h.db, h.clock.call, h.attempts).rest();
    await pumpApp(tester, h, location: '/bonfire', tall: true);

    expect(find.text('You have rested.'), findsOneWidget);
    expect(restButton(), findsNothing);
    expect(find.byType(TextField), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('the Bonfire tab opens the bonfire', (tester) async {
    await pumpApp(tester, h);

    await tester.tap(find.text('Bonfire'));
    await settle(tester);
    expect(find.text('BONFIRE'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  group('Tomorrow’s tasks (Q5)', () {
    Future<void> open(WidgetTester tester) async {
      await pumpApp(tester, h, location: '/bonfire', tall: true);
      await tester.ensureVisible(find.text('Tomorrow’s tasks'));
      await tester.tap(find.text('Tomorrow’s tasks'));
      await settle(tester);
    }

    Future<List<String>> saved() async => [
      for (final p in await plans.tomorrow()) p.task.title,
    ];

    testWidgets('lists open tasks; struck ones are not offered', (
      tester,
    ) async {
      await h.attempts.strike(taskNamed(view, 'Flashcards').task.id);
      await open(tester);
      expect(find.text('Tomorrow’s three'), findsOneWidget);
      expect(find.text('Read chapter 4'), findsOneWidget);
      expect(find.text('Flashcards'), findsNothing);
      await tearDownApp(tester, h);
    });

    testWidgets('toggling updates the count; a fourth is blocked', (
      tester,
    ) async {
      await open(tester);
      for (final t in ['Read chapter 4', 'Walk', 'Sit the exam']) {
        await tester.tap(find.text(t));
        await settle(tester);
      }
      expect(find.text('3 of 3 chosen'), findsOneWidget);

      await tester.tap(find.text('Book the room'));
      await settle(tester);
      expect(find.text('Three is enough for one day.'), findsOneWidget);
      expect(find.text('3 of 3 chosen'), findsOneWidget);
      final picked = tester
          .widgetList<PickToggleRow>(find.byType(PickToggleRow))
          .where((r) => r.isSelected);
      expect(picked, hasLength(3));
      await tearDownApp(tester, h);
    });

    testWidgets('Set tomorrow saves the picks and the row shows them', (
      tester,
    ) async {
      await open(tester);
      await tester.tap(find.text('Walk'));
      await tester.tap(find.text('Read chapter 4'));
      await settle(tester);
      await tester.tap(find.text('Set tomorrow'));
      await settle(tester);

      expect(await saved(), ['Walk', 'Read chapter 4']);
      final container = ProviderScope.containerOf(
        tester.element(find.text('BONFIRE')),
      );
      expect(
        [
          for (final p in await container.read(tomorrowPicksProvider.future))
            p.task.title,
        ],
        ['Walk', 'Read chapter 4'],
      );
      expect(find.text('Tomorrow’s three'), findsNothing);
      expect(find.text('2 of 3 chosen · Walk, Read chapter 4'), findsOneWidget);
      await tearDownApp(tester, h);
    });

    testWidgets('Cancel saves nothing', (tester) async {
      await open(tester);
      await tester.tap(find.text('Walk'));
      await settle(tester);
      await tester.tap(find.text('Cancel'));
      await settle(tester);

      expect(await saved(), isEmpty);
      expect(find.text('0 of 3 chosen'), findsOneWidget);
      await tearDownApp(tester, h);
    });
  });
}
