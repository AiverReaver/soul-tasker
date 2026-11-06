import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/ui/ember_button.dart';
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
}

final _step = find.byKey(const ValueKey('next-step'));

void main() {
  testWidgets('a fresh database opens the welcome, not Home', (tester) async {
    final h = Harness();
    await pumpApp(tester, h, onboarded: false);
    expect(find.text("Failing is fine. Quitting isn't."), findsOneWidget);
    expect(find.byKey(const ValueKey('home-header')), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('the welcome says what the app is, above the line', (
    tester,
  ) async {
    final h = Harness();
    await pumpApp(tester, h, onboarded: false);
    final pitch = find.text(
      'Turn the goal you keep avoiding into a boss. '
      'Fight it a little every day.',
    );
    expect(pitch, findsOneWidget);
    final line = find.text("Failing is fine. Quitting isn't.");
    expect(tester.getTopLeft(pitch).dy, lessThan(tester.getTopLeft(line).dy));
    await tearDownApp(tester, h);
  });

  testWidgets('Skip stays put when Next is disabled on the boss page', (
    tester,
  ) async {
    final h = Harness();
    await pumpApp(tester, h, onboarded: false);
    final skipOnWelcome = tester.getCenter(find.text('Skip'));
    await _next(tester);
    expect(find.text('Name your first boss.'), findsOneWidget);
    // A thumb aimed at Next must not land on Skip (audit: 0 bosses saved).
    expect(tester.getCenter(find.text('Skip')), skipOnWelcome);
    await tearDownApp(tester, h);
  });

  testWidgets('an upgraded database opens Home', (tester) async {
    final h = Harness();
    await pumpApp(tester, h);
    expect(find.byKey(const ValueKey('home-header')), findsOneWidget);
    expect(find.text("Failing is fine. Quitting isn't."), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('Begin is disabled until the boss has a title', (tester) async {
    final h = Harness();
    await pumpApp(tester, h, onboarded: false);
    await _next(tester);
    VoidCallback? next() => tester
        .widget<EmberButton>(find.widgetWithText(EmberButton, 'Next'))
        .onPressed;
    expect(next(), isNull);
    await tester.enterText(_title, 'The Garage');
    await tester.pump();
    expect(next(), isNotNull);
    await tester.enterText(_title, '   ');
    await tester.pump();
    expect(next(), isNull);
    await tearDownApp(tester, h);
  });

  testWidgets('the boss title does not keep focus on the next page', (
    tester,
  ) async {
    final h = Harness();
    await pumpApp(tester, h, onboarded: false);
    await _toPage(tester, 3, title: 'Run a 10K');
    expect(find.text("What's the very next step?"), findsOneWidget);
    expect(tester.testTextInput.hasAnyClients, isFalse);
    await tearDownApp(tester, h);
  });

  testWidgets('no chapters, dailies or reminder in onboarding', (tester) async {
    final h = Harness();
    await pumpApp(tester, h, onboarded: false);
    await _toPage(tester, 3);
    expect(find.text('Add a chapter'), findsNothing);
    expect(find.text('Add a daily task'), findsNothing);
    expect(find.text('Evening reminder'), findsNothing);
    expect(find.text('Begin'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('Begin saves the next step as a one-time task with health', (
    tester,
  ) async {
    final h = Harness();
    await pumpApp(tester, h, onboarded: false);
    await _toPage(tester, 3);
    await tester.enterText(_step, 'Book the exam');
    await tester.pump();
    await tester.tap(find.text('Begin'));
    await settle(tester);

    final boss = (await h.bosses.loadAll()).single;
    expect(boss.boss.title, 'The Certification');
    // In a chapter, so it is a health segment (audit #7: no health before).
    expect(boss.phases.single.phase.name, 'First steps');
    final task = boss.phases.single.tasks.single.task;
    expect(task.title, 'Book the exam');
    expect(task.recurrence, Recurrence.none);
    expect(boss.segments, hasLength(1));
    expect(boss.standalone, isEmpty);
    expect((await h.settings.device()).onboarded, isTrue);

    expect(find.text('All bosses · 1 active'), findsOneWidget);
    await tester.tap(find.text('Today'));
    await settle(tester);
    expect(find.text('Book the exam'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('the next step is optional: Begin saves the title alone', (
    tester,
  ) async {
    final h = Harness();
    await pumpApp(tester, h, onboarded: false);
    await _toPage(tester, 3);
    await tester.tap(find.text('Begin'));
    await settle(tester);
    final boss = (await h.bosses.loadAll()).single;
    expect(boss.boss.title, 'The Certification');
    expect(boss.phases, isEmpty);
    expect(boss.standalone, isEmpty);
    await tearDownApp(tester, h);
  });

  testWidgets('every page says which step it is, with diamonds', (
    tester,
  ) async {
    var h = Harness();
    await pumpApp(tester, h, onboarded: false);
    for (var n = 1; n <= 3; n++) {
      await _toPage(tester, n);
      expect(find.text('Step $n of 3'), findsOneWidget);
      expect(find.byKey(const ValueKey('step-on')), findsNWidgets(n));
      expect(find.byKey(const ValueKey('step-off')), findsNWidgets(3 - n));
      await tearDownApp(tester, h);
      h = Harness();
      await pumpApp(tester, h, onboarded: false);
    }
    await tearDownApp(tester, h);
  });

  testWidgets('Skip jumps to page 3; Skip there lands on the empty Home', (
    tester,
  ) async {
    final h = Harness();
    await pumpApp(tester, h, onboarded: false);
    await _next(tester);
    await tester.tap(find.text('Skip'));
    await settle(tester);

    expect(find.text("What's the very next step?"), findsOneWidget);
    expect(find.text('Step 3 of 3'), findsOneWidget);
    expect((await h.settings.device()).onboarded, isFalse);

    await tester.tap(find.text('Skip'));
    await settle(tester);
    expect(find.text('Nothing stands in your way today.'), findsOneWidget);
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

  testWidgets('Skip on the last page keeps the boss and its next step', (
    tester,
  ) async {
    final h = Harness();
    await pumpApp(tester, h, onboarded: false);
    await _toPage(tester, 3);
    await tester.enterText(_step, 'Book the exam');
    await tester.pump();
    await tester.tap(find.text('Skip'));
    await settle(tester);

    final boss = (await h.bosses.loadAll()).single;
    expect(boss.boss.title, 'The Certification');
    expect(boss.phases.single.tasks.single.task.title, 'Book the exam');
    expect((await h.settings.device()).onboarded, isTrue);
    await tearDownApp(tester, h);
  });

  testWidgets('the happy path takes five taps and entries, no permission ask', (
    tester,
  ) async {
    final h = Harness();
    final reminders = FakeReminders();
    await pumpApp(tester, h, onboarded: false, reminders: reminders);
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
    await type(_step, 'Book the exam');
    await tap(find.text('Begin'));

    expect(steps, 5);
    expect(find.text('All bosses · 1 active'), findsOneWidget);
    expect(reminders.calls, isNot(contains('permission')));
    await tearDownApp(tester, h);
  });
}
