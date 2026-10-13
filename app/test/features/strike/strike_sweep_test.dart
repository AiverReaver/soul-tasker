import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/features/strike/hold_to_strike.dart';
import 'package:hearthrise/features/strike/strike_sweep.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/recording_haptics.dart';

const _frame = Duration(milliseconds: 16);

Widget _host(
  Weight weight, {
  bool tapMode = false,
  bool isDone = false,
  bool reduceMotion = false,
}) => ProviderScope(
  overrides: [RecordingHaptics().asOverride],
  child: MaterialApp(
    theme: buildTheme(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
      child: child!,
    ),
    home: Scaffold(
      body: HoldToStrike(
        title: 'The task',
        weight: weight,
        isDone: isDone,
        tapMode: tapMode,
        onStrike: () {},
      ),
    ),
  ),
);

Future<void> _holdFor(WidgetTester tester, Duration duration) async {
  var elapsed = Duration.zero;
  while (elapsed < duration) {
    await tester.pump(_frame);
    elapsed += _frame;
  }
}

/// Holds the row until the strike has just landed.
Future<void> _strikeByHold(WidgetTester tester, Weight weight) async {
  final gesture = await tester.startGesture(
    tester.getCenter(find.text('The task')),
  );
  await tester.pump();
  await _holdFor(tester, weight.holdDuration + _frame * 2);
  await gesture.up();
  await tester.pump(_frame);
}

void main() {
  final sweep = find.byKey(kStrikeSweepKey);

  testWidgets('a strike sweeps, and the sweep is gone after its duration', (
    tester,
  ) async {
    await tester.pumpWidget(_host(Weight.heavy));
    expect(sweep, findsNothing);

    await _strikeByHold(tester, Weight.heavy);
    expect(sweep, findsOneWidget);

    await tester.pump(sweepDuration(Weight.heavy) + _frame);
    expect(sweep, findsNothing);
  });

  testWidgets('Boss-tier sweeps longer than Heavy', (tester) async {
    expect(
      sweepDuration(Weight.bossTier),
      greaterThan(sweepDuration(Weight.heavy)),
    );

    await tester.pumpWidget(_host(Weight.bossTier));
    await _strikeByHold(tester, Weight.bossTier);
    await tester.pump(sweepDuration(Weight.heavy) + _frame);
    expect(sweep, findsOneWidget, reason: 'still going past the Heavy length');

    await tester.pump(sweepDuration(Weight.bossTier));
    expect(sweep, findsNothing);
  });

  testWidgets('tap mode sweeps too', (tester) async {
    await tester.pumpWidget(_host(Weight.heavy, tapMode: true));

    await tester.tap(find.text('The task'));
    await tester.pump(_frame);
    expect(sweep, findsOneWidget);

    await tester.pump(sweepDuration(Weight.heavy) + _frame);
    expect(sweep, findsNothing);
  });

  testWidgets('reduced motion shows no sweep', (tester) async {
    await tester.pumpWidget(_host(Weight.heavy, reduceMotion: true));

    await _strikeByHold(tester, Weight.heavy);

    expect(sweep, findsNothing);
  });

  testWidgets('a struck row is dimmed to 0.35', (tester) async {
    await tester.pumpWidget(_host(Weight.heavy, isDone: true));

    final opacity = tester.widget<AnimatedOpacity>(
      find.byType(AnimatedOpacity),
    );

    expect(opacity.opacity, 0.35);
  });

  testWidgets('an open row is fully opaque', (tester) async {
    await tester.pumpWidget(_host(Weight.heavy));

    final opacity = tester.widget<AnimatedOpacity>(
      find.byType(AnimatedOpacity),
    );

    expect(opacity.opacity, 1);
  });
}
