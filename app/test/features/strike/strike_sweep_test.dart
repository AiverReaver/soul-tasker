import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/features/strike/hold_to_strike.dart';
import 'package:hearthrise/features/strike/strike_sweep.dart';
import 'package:hearthrise/ui/dust_vanish.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/recording_haptics.dart';
import '../../support/hold_finders.dart';

const _frame = Duration(milliseconds: 16);

Widget _host(
  Weight weight, {
  bool tapMode = false,
  bool isDone = false,
  bool reduceMotion = false,
  VoidCallback? onStrike,
  VoidCallback? onTried,
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
        onStrike: onStrike ?? () {},
        onTried: onTried,
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
    tester.getCenter(holdButton('The task')),
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

  testWidgets('a landed strike shakes the row, then lets it rest', (
    tester,
  ) async {
    Offset shake() {
      final t = tester.widget<Transform>(find.byKey(kStrikeShakeKey)).transform;
      return Offset(t.getTranslation().x, t.getTranslation().y);
    }

    await tester.pumpWidget(_host(Weight.heavy));
    await _strikeByHold(tester, Weight.heavy);
    expect(shake(), Offset.zero, reason: 'the cut is drawn before the shake');

    await tester.pump(const Duration(milliseconds: 200));
    expect(shake(), isNot(Offset.zero));

    await tester.pump(sweepDuration(Weight.heavy));
    expect(shake(), Offset.zero);
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

    await tester.tap(holdButton('The task'));
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

  testWidgets('a struck task bursts into dust', (tester) async {
    await tester.pumpWidget(_host(Weight.light, onTried: () {}));
    await _strikeByHold(tester, Weight.light);
    await tester.pump(_frame * 3);
    expect(find.byKey(kDustPainterKey), findsOneWidget);
  });
}
