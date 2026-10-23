import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/features/strike/hold_to_strike.dart';
import 'package:material_ui/material_ui.dart';

import 'support/recording_haptics.dart';
import 'support/hold_finders.dart';

Widget _host({
  required VoidCallback onStrike,
  required RecordingHaptics haptics,
  bool tapMode = false,
}) => ProviderScope(
  overrides: [haptics.asOverride],
  child: MaterialApp(
    theme: buildTheme(),
    home: Scaffold(
      body: HoldToStrike(
        title: 'Read chapter 4',
        weight: Weight.heavy,
        isDone: false,
        tapMode: tapMode,
        onStrike: onStrike,
      ),
    ),
  ),
);

void main() {
  testWidgets('full hold strikes, early release does not', (tester) async {
    var strikes = 0;
    final haptics = RecordingHaptics();
    await tester.pumpWidget(_host(onStrike: () => strikes++, haptics: haptics));
    final row = holdButton('Read chapter 4'); // Heavy: 600 ms hold

    var gesture = await tester.startGesture(tester.getCenter(row));
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(strikes, 0);
    expect(haptics.events, isNot(contains('heavy')));

    gesture = await tester.startGesture(tester.getCenter(row));
    await tester.pump(); // first frame sets the animation start time
    await tester.pump(Weight.heavy.holdDuration);
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(strikes, 1);
    expect(haptics.events.last, 'heavy');
  });

  testWidgets('tap mode strikes on a single tap', (tester) async {
    var strikes = 0;
    final haptics = RecordingHaptics();
    await tester.pumpWidget(
      _host(onStrike: () => strikes++, haptics: haptics, tapMode: true),
    );
    await tester.tap(holdButton('Read chapter 4'));
    expect(strikes, 1);
    expect(haptics.events, ['heavy']);
  });
}
