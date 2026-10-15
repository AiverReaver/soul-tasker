import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/haptics.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/features/fallen/fallen_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import '../support/recording_haptics.dart';
import 'pump.dart';

const _heavy = 'HapticFeedbackType.heavyImpact';

Future<void> _declareFall(WidgetTester tester) async {
  await tester.scrollUntilVisible(find.text('This attempt failed'), 200);
  await tester.tap(find.text('This attempt failed'));
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
    expect(find.text('Rest, then rise.'), findsOneWidget);
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

    await tester.tap(find.text('Skip'));
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
    await tester.tap(find.text('Skip'));
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
}
