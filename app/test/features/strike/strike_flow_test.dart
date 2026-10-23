import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/features/strike/hold_to_strike.dart';
import 'package:hearthrise/features/strike/strike_sweep.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/hold_finders.dart';
import '../../support/recording_haptics.dart';

const _frame = Duration(milliseconds: 16);

Widget _host({
  bool tapMode = false,
  required VoidCallback onStrike,
  required VoidCallback onTried,
}) => ProviderScope(
  overrides: [RecordingHaptics().asOverride],
  child: MaterialApp(
    theme: buildTheme(),
    home: Scaffold(
      body: HoldToStrike(
        title: 'The task',
        weight: Weight.light,
        isDone: false,
        tapMode: tapMode,
        onStrike: onStrike,
        onTried: onTried,
      ),
    ),
  ),
);

Future<void> _hold(WidgetTester tester) async {
  final g = await tester.startGesture(tester.getCenter(holdButton('The task')));
  await tester.pump();
  var elapsed = Duration.zero;
  while (elapsed < Weight.light.holdDuration + _frame * 2) {
    await tester.pump(_frame);
    elapsed += _frame;
  }
  await g.up();
  await tester.pump(_frame);
}

void main() {
  late int strikes, tries;
  setUp(() => strikes = tries = 0);

  Widget host({bool tapMode = false}) => _host(
    tapMode: tapMode,
    onStrike: () => strikes++,
    onTried: () => tries++,
  );

  testWidgets('the beats play first; the sheet opens when they end', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await _hold(tester);
    expect(find.text('HOW DID THE STRIKE LAND?'), findsNothing);
    expect(find.byKey(kStrikeSweepKey), findsOneWidget);

    await tester.pump(sweepDuration(Weight.light) + _frame);
    await tester.pumpAndSettle();
    expect(find.text('HOW DID THE STRIKE LAND?'), findsOneWidget);
    expect(strikes + tries, 0, reason: 'nothing is written before a choice');
  });

  testWidgets('"Clean strike" writes the strike', (tester) async {
    await tester.pumpWidget(host());
    await _hold(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clean strike'));
    await tester.pumpAndSettle();
    expect((strikes, tries), (1, 0));
  });

  testWidgets('"A real try" writes the try and never the strike', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await _hold(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('A real try'));
    await tester.pumpAndSettle();
    expect((strikes, tries), (0, 1));
  });

  testWidgets('Cancel writes nothing and the row is open again', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await _hold(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(strikes + tries, 0);
    expect(find.bySemanticsLabel('Hold to strike: The task'), findsOneWidget);
  });

  testWidgets('tap mode skips the hold, then plays and asks the same way', (
    tester,
  ) async {
    await tester.pumpWidget(host(tapMode: true));
    await tester.tap(holdButton('The task'));
    await tester.pump(_frame);
    expect(find.byKey(kStrikeSweepKey), findsOneWidget);
    expect(find.text('HOW DID THE STRIKE LAND?'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('HOW DID THE STRIKE LAND?'), findsOneWidget);
    await tester.tap(find.text('Clean strike'));
    await tester.pumpAndSettle();
    expect(strikes, 1);
  });
}
