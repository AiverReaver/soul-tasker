import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import '../support/fake_reminders.dart';
import 'pump.dart';

final _title = find.byKey(const ValueKey('boss-title'));

Future<void> _next(WidgetTester tester) async {
  await tester.tap(find.text('Next'));
  await settle(tester);
}

/// Opens onboarding on a fresh database and walks to page [page] (1-based).
Future<void> _toPage(
  WidgetTester tester,
  int page, {
  String title = 'The Certification',
}) async {
  if (page > 1) await _next(tester);
  if (page > 2) {
    await tester.enterText(_title, title);
    await tester.pump();
    await _next(tester);
  }
  for (var p = 3; p < page; p++) {
    await _next(tester);
  }
}

void main() {
  testWidgets('a fresh database opens the welcome, not Home', (tester) async {
    final h = Harness();
    await pumpApp(tester, h, onboarded: false);
    expect(find.text("Failing is fine. Quitting isn't."), findsOneWidget);
    expect(find.text('HEARTHRISE'), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('an upgraded database opens Home', (tester) async {
    final h = Harness();
    await pumpApp(tester, h);
    expect(find.text('HEARTHRISE'), findsOneWidget);
    expect(find.text("Failing is fine. Quitting isn't."), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('Begin is disabled until the boss has a title', (tester) async {
    final h = Harness();
    await pumpApp(tester, h, onboarded: false);
    await _next(tester);
    final next = find.widgetWithText(TextButton, 'Next');
    expect(tester.widget<TextButton>(next).onPressed, isNull);
    await tester.enterText(_title, 'The Garage');
    await tester.pump();
    expect(tester.widget<TextButton>(next).onPressed, isNotNull);
    await tester.enterText(_title, '   ');
    await tester.pump();
    expect(tester.widget<TextButton>(next).onPressed, isNull);
    await tearDownApp(tester, h);
  });

  testWidgets('phases: two suggestions; rename, add up to three, remove', (
    tester,
  ) async {
    final h = Harness();
    await pumpApp(tester, h, onboarded: false);
    await _toPage(tester, 3);

    final fields = find.byWidgetPredicate(
      (w) => w is TextFormField && w.key.toString().contains('phase-'),
    );
    expect(fields, findsNWidgets(2));
    expect(find.text('Learn the pattern'), findsOneWidget);
    expect(find.text('The fight'), findsOneWidget);

    await tester.enterText(find.text('The fight'), 'The exam');
    await tester.tap(find.text('Add a phase'));
    await settle(tester);
    expect(fields, findsNWidgets(3));
    expect(find.text('Add a phase'), findsNothing);

    await tester.tap(find.byTooltip('Remove phase 1'));
    await settle(tester);
    expect(fields, findsNWidgets(2));
    expect(find.text('Learn the pattern'), findsNothing);
    expect(find.text('The exam'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('up to three daily foes; blank ones are dropped', (tester) async {
    final h = Harness();
    await pumpApp(tester, h, onboarded: false);
    await _toPage(tester, 4);

    final fields = find.byWidgetPredicate(
      (w) => w is TextFormField && w.key.toString().contains('daily-'),
    );
    expect(fields, findsNWidgets(1));
    await tester.enterText(fields.first, 'Walk');
    await tester.tap(find.text('Add a daily foe'));
    await settle(tester);
    await tester.tap(find.text('Add a daily foe'));
    await settle(tester);
    expect(fields, findsNWidgets(3));
    expect(find.text('Add a daily foe'), findsNothing);
    await tester.enterText(fields.at(2), 'Stretch');
    await _next(tester);
    await tester.tap(find.text('Begin'));
    await settle(tester);

    final tasks = await h.db.select(h.db.tasks).get();
    expect(tasks.map((t) => t.title).toList()..sort(), ['Stretch', 'Walk']);
    await tearDownApp(tester, h);
  });

  testWidgets('the last page shows the gentle line and the reminder time', (
    tester,
  ) async {
    final h = Harness();
    await pumpApp(tester, h, onboarded: false);
    await _toPage(tester, 5);
    expect(
      find.text('Gentle mode: nothing is lost but health.'),
      findsOneWidget,
    );
    expect(find.text('9:00 PM'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets(
    'turning the reminder on asks permission; denial still finishes',
    (tester) async {
      final h = Harness();
      final reminders = FakeReminders(grants: false);
      await pumpApp(tester, h, onboarded: false, reminders: reminders);
      await _toPage(tester, 5);

      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.tap(find.text('Begin'));
      await settle(tester);

      expect(reminders.calls, contains('permission'));
      expect(reminders.calls, isNot(contains('schedule:1260')));
      expect((await h.settings.read()).reminderEnabled, isFalse);
      expect((await h.settings.device()).onboarded, isTrue);
      expect(find.text('HEARTHRISE'), findsOneWidget);
      await tearDownApp(tester, h);
    },
  );

  testWidgets('a granted reminder is scheduled', (tester) async {
    final h = Harness();
    final reminders = FakeReminders();
    await pumpApp(tester, h, onboarded: false, reminders: reminders);
    await _toPage(tester, 5);

    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.tap(find.text('Begin'));
    await settle(tester);

    expect(
      reminders.calls,
      containsAllInOrder(['permission', 'schedule:1260']),
    );
    expect((await h.settings.read()).reminderEnabled, isTrue);
    await tearDownApp(tester, h);
  });

  testWidgets('Begin saves the boss, sets onboarded, lands on Home', (
    tester,
  ) async {
    final h = Harness();
    await pumpApp(tester, h, onboarded: false);
    await _toPage(tester, 3);
    await _next(tester);
    await tester.enterText(
      find.byWidgetPredicate(
        (w) => w is TextFormField && w.key.toString().contains('daily-'),
      ),
      'Walk',
    );
    await _next(tester);
    await tester.tap(find.text('Begin'));
    await settle(tester);

    final bosses = await h.bosses.loadAll();
    expect(bosses, hasLength(1));
    final boss = bosses.single;
    expect(boss.boss.title, 'The Certification');
    expect(boss.phases.map((p) => p.phase.name), [
      'Learn the pattern',
      'The fight',
    ]);
    final walk = boss.standalone.single.task;
    expect(walk.title, 'Walk');
    expect(walk.weight, Weight.light);
    expect(walk.recurrence, Recurrence.daily);
    expect((await h.settings.device()).onboarded, isTrue);

    expect(find.text('The Certification'), findsOneWidget);
    await tester.tap(find.text('Today'));
    await settle(tester);
    expect(find.text('Walk · daily'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('Skip on any page lands on the empty Home, once', (tester) async {
    final h = Harness();
    await pumpApp(tester, h, onboarded: false);
    await _next(tester);
    await tester.tap(find.text('Skip'));
    await settle(tester);

    expect(find.text('No boss stands before you.'), findsOneWidget);
    expect((await h.settings.device()).onboarded, isTrue);
    expect(await h.bosses.loadAll(), isEmpty);
    await tearDownApp(tester, h);

    // The next start does not show it again.
    await pumpApp(tester, h, onboarded: null);
    expect(find.text("Failing is fine. Quitting isn't."), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
    await h.db.close();
  });

  testWidgets('the happy path takes at most 12 taps and entries', (
    tester,
  ) async {
    final h = Harness();
    await pumpApp(tester, h, onboarded: false);
    var steps = 0;
    Future<void> tap(Finder f) async {
      steps++;
      await tester.tap(f);
      await settle(tester);
    }

    Future<void> type(Finder f, String text) async {
      steps++;
      await tester.enterText(f, text);
      await tester.pump();
    }

    await tap(find.text('Next'));
    await type(_title, 'The Certification');
    await tap(find.text('Next'));
    await tap(find.text('Next'));
    await type(
      find.byWidgetPredicate(
        (w) => w is TextFormField && w.key.toString().contains('daily-'),
      ),
      'Walk',
    );
    await tap(find.text('Next'));
    await tap(find.text('Begin'));

    expect(steps, lessThanOrEqualTo(12));
    expect(find.text('The Certification'), findsOneWidget);
    await tearDownApp(tester, h);
  });
}
