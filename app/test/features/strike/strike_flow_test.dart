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
  VoidCallback? onHint,
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
        onHint: onHint,
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
  late int strikes, hints;
  setUp(() => strikes = hints = 0);

  Widget host({bool tapMode = false}) =>
      _host(tapMode: tapMode, onStrike: () => strikes++, onHint: () => hints++);

  testWidgets('a short tap on the needle nudges it and asks for a hold', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.tap(holdButton('The task'));
    await tester.pump(_frame);
    await tester.pump(_frame * 3);
    expect(hints, 1);
    final shake = tester.widget<Transform>(find.byKey(kStrikeShakeKey));
    expect(shake.transform.getTranslation().x, isNot(0), reason: 'it shakes');
    await tester.pumpAndSettle();
    expect(strikes, 0);
  });

  testWidgets('a scroll that starts on the needle is not a tap', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.drag(holdButton('The task'), const Offset(0, 80));
    await tester.pumpAndSettle();
    expect(hints, 0);
  });

  testWidgets('a full hold strikes at once, with no question after', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await _hold(tester);
    expect(strikes, 1);
    expect(find.byKey(kStrikeSweepKey), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('HOW DID THE STRIKE LAND?'), findsNothing);
    expect(strikes, 1);
  });

  testWidgets('a hold let go early writes nothing', (tester) async {
    await tester.pumpWidget(host());
    final g = await tester.startGesture(
      tester.getCenter(holdButton('The task')),
    );
    await tester.pump(Weight.light.holdDuration ~/ 2);
    await g.up();
    await tester.pumpAndSettle();
    expect(strikes, 0);
  });

  testWidgets('tap mode strikes on one tap', (tester) async {
    await tester.pumpWidget(host(tapMode: true));
    await tester.tap(holdButton('The task'));
    await tester.pump(_frame);
    expect(find.byKey(kStrikeSweepKey), findsOneWidget);
    await tester.pumpAndSettle();
    expect((strikes, hints), (1, 0));
    expect(find.text('HOW DID THE STRIKE LAND?'), findsNothing);
  });
}
