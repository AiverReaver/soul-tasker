import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/haptics.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/features/fallen/fallen_screen.dart';
import 'package:hearthrise/ui/ember_button.dart';
import 'package:hearthrise/ui/snapping_thread.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import '../support/recording_haptics.dart';
import '../support/boss_actions.dart';
import 'pump.dart';

const _heavy = 'HapticFeedbackType.heavyImpact';

Future<void> _declareFall(WidgetTester tester) async {
  await tapBossAction(tester, 'This attempt failed', settleAfter: false);
}

/// Lowest opacity among the fade transitions around the fallen text.
double _opacity(WidgetTester tester) => tester
    .widgetList<FadeTransition>(
      find.ancestor(
        of: find.text('Fallen.'),
        matching: find.byType(FadeTransition),
      ),
    )
    .map((f) => f.opacity.value)
    .reduce((a, b) => a < b ? a : b);

/// Opens the fallen screen from a plain button and records what it pops.
Future<List<String?>> _openFromButton(WidgetTester tester) async {
  final popped = <String?>[];
  await tester.pumpWidget(
    MaterialApp(
      theme: buildTheme(),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async => popped.add(
              await FallenScreen.show(context, Haptics(() => false)),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return popped;
}

void main() {
  testWidgets('shows the quiet copy and one heavy haptic through the boss '
      'screen', (tester) async {
    final sent = recordPlatformHaptics();
    final h = Harness();
    final view = await h.seed();
    await pumpApp(tester, h, location: '/boss/${view.boss.id}');

    await _declareFall(tester);
    await settle(tester);

    expect(find.text('Fallen.'), findsOneWidget);
    final title = tester.widget<Text>(find.text('Fallen.'));
    expect(title.style?.fontSize, 60);
    expect(title.style?.letterSpacing, greaterThan(2));
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold).last).backgroundColor,
      Biome.pharloom.palette.voidfall,
    );
    expect(find.widgetWithText(EmberButton, 'Rise'), findsOneWidget);
    expect(
      find.text('Attempt 1 ends. The Certification remains, and so do you.'),
      findsOneWidget,
    );
    expect(find.text('What did this teach you?'), findsOneWidget);
    expect(sent, [_heavy]);
    await tearDownApp(tester, h);
  });

  testWidgets('sends no haptic with haptics off, through the boss screen', (
    tester,
  ) async {
    final sent = recordPlatformHaptics();
    final h = Harness();
    final view = await h.seed();
    await h.settings.setHaptics(false);
    await pumpApp(tester, h, location: '/boss/${view.boss.id}');

    await _declareFall(tester);
    await settle(tester);

    expect(find.text('Fallen.'), findsOneWidget);
    expect(sent, isEmpty);
    await tearDownApp(tester, h);
  });

  testWidgets('Skip pops null', (tester) async {
    final popped = await _openFromButton(tester);

    await tester.tap(find.text('Rest first. Write it tomorrow.'));
    await tester.pumpAndSettle();

    expect(popped, [null]);
  });

  testWidgets('Rise pops the trimmed lesson', (tester) async {
    final popped = await _openFromButton(tester);

    await tester.enterText(find.byType(TextField), '  Start earlier.  ');
    await tester.tap(find.text('Rise'));
    await tester.pumpAndSettle();

    expect(popped, ['Start earlier.']);
  });

  testWidgets('the screen dims in slowly', (tester) async {
    final h = Harness();
    final view = await h.seed();
    await pumpApp(tester, h, location: '/boss/${view.boss.id}');

    await _declareFall(tester);
    await tester.pump();
    await tester.pump(Motion.dim * 0.25);

    expect(_opacity(tester), inExclusiveRange(0, 1));

    await tester.pumpAndSettle();
    expect(_opacity(tester), 1);
    await tearDownApp(tester, h);
  });

  testWidgets('reduced motion opens it instantly', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final h = Harness();
    final view = await h.seed();
    await pumpApp(tester, h, location: '/boss/${view.boss.id}');

    await _declareFall(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.text('Fallen.'), findsOneWidget);
    expect(_opacity(tester), 1);
    await tearDownApp(tester, h);
  });

  testWidgets('the numbers, accuracy and grace lines show only when given', (
    tester,
  ) async {
    Future<void> open(FallenRecord? record) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => FallenScreen.show(
                  context,
                  Haptics(() => false),
                  record: record,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    await open(null);
    expect(find.textContaining('promised'), findsNothing);
    expect(find.textContaining('This week'), findsNothing);
    await tester.tap(find.text('Rest first. Write it tomorrow.'));
    await tester.pumpAndSettle();

    await open(
      const FallenRecord(
        promised: 9,
        kept: 3,
        weekMade: 9,
        weekKept: 3,
        isGraceWeek: true,
      ),
    );
    expect(find.text('Nine promised, three kept.'), findsOneWidget);
    expect(find.text('Today: 3 of 9 kept. This week: 3 of 9.'), findsOneWidget);
    expect(
      find.text('Your first week: nothing is lost but health.'),
      findsOneWidget,
    );
  });

  testWidgets('with a story: the attempt line, health, embers and helper', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => FallenScreen.show(
                context,
                Haptics(() => false),
                story: const FallenStory(
                  attempt: 3,
                  bossTitle: 'The Certification',
                  health: 4,
                  maxHealth: 10,
                  embers: 1240,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(
      find.text('Attempt 3 ends. The Certification remains, and so do you.'),
      findsOneWidget,
    );
    expect(find.text('Rest, then rise.'), findsNothing);
    expect(find.text('2 / 5'), findsOneWidget);
    expect(find.text('1,240'), findsOneWidget);
    expect(find.text('Embers kept'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Fallen.')).style?.letterSpacing, 8);
    expect(tester.widget<TextField>(find.byType(TextField)).minLines, 3);
    expect(
      find.text('You will see it at the start of attempt 4.'),
      findsOneWidget,
    );
    expect(find.byType(SnappingThread), findsOneWidget);
  });

  testWidgets('with the keyboard up the screen scrolls, Rise is reachable '
      'and return closes the keyboard', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final popped = await _openFromButton(tester);

    await tester.showKeyboard(find.byType(TextField));
    tester.view.viewInsets = const FakeViewPadding(bottom: 336);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.textInputAction, TextInputAction.done);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(tester.testTextInput.isVisible, isFalse);

    await tester.ensureVisible(find.widgetWithText(EmberButton, 'Rise'));
    await tester.tap(find.widgetWithText(EmberButton, 'Rise'));
    await tester.pumpAndSettle();
    expect(popped, ['']);
  });

  testWidgets('tapping outside the lesson field closes the keyboard', (
    tester,
  ) async {
    await _openFromButton(tester);
    await tester.showKeyboard(find.byType(TextField));
    await tester.pump();
    expect(tester.testTextInput.isVisible, isTrue);

    await tester.tap(find.text('Fallen.'));
    await tester.pumpAndSettle();
    expect(tester.testTextInput.isVisible, isFalse);
  });

  testWidgets('opened inside a tab, it covers the whole app, tab bar too', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(
          body: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (context) => TextButton(
                onPressed: () =>
                    FallenScreen.show(context, Haptics(() => false)),
                child: const Text('open'),
              ),
            ),
          ),
          bottomNavigationBar: const Text('tab bar'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(
      find.ancestor(
        of: find.byType(FallenScreen),
        matching: find.byType(Navigator),
      ),
      findsOneWidget,
    );
  });
}
