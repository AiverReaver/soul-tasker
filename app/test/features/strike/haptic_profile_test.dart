import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/features/strike/hold_to_strike.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/recording_haptics.dart';

const _frame = Duration(milliseconds: 16);

Widget _host(
  RecordingHaptics haptics,
  Weight weight, {
  bool tapMode = false,
  VoidCallback? onStrike,
}) => ProviderScope(
  overrides: [haptics.asOverride],
  child: MaterialApp(
    theme: buildTheme(),
    home: Scaffold(
      body: HoldToStrike(
        title: 'The task',
        weight: weight,
        isDone: false,
        tapMode: tapMode,
        onStrike: onStrike ?? () {},
      ),
    ),
  ),
);

/// Holds frame by frame, so every beat of the build-up gets its own frame
/// the way it does on a phone.
Future<void> _holdFor(WidgetTester tester, Duration duration) async {
  var elapsed = Duration.zero;
  while (elapsed < duration) {
    await tester.pump(_frame);
    elapsed += _frame;
  }
}

Future<TestGesture> _press(WidgetTester tester) async {
  final gesture = await tester.startGesture(
    tester.getCenter(find.text('The task')),
  );
  await tester.pump(); // first frame sets the animation start time
  return gesture;
}

void main() {
  const fullProfiles = {
    Weight.light: ['tick', 'light'],
    Weight.heavy: ['tick', 'tick', 'tick', 'medium', 'heavy'],
    Weight.bossTier: [
      'tick',
      'tick',
      'tick',
      'tick',
      'tick',
      'medium',
      'doubleHeavy',
    ],
  };

  for (final MapEntry(key: weight, value: expected) in fullProfiles.entries) {
    testWidgets('${weight.label}: a full hold plays the profile', (
      tester,
    ) async {
      final haptics = RecordingHaptics();
      var strikes = 0;
      await tester.pumpWidget(
        _host(haptics, weight, onStrike: () => strikes++),
      );

      final gesture = await _press(tester);
      await _holdFor(tester, weight.holdDuration + _frame * 2);
      await gesture.up();
      await tester.pumpAndSettle();

      expect(haptics.events, expected);
      expect(strikes, 1);
    });

    testWidgets('${weight.label}: releasing early sends no landing and stops '
        'the ticks', (tester) async {
      final haptics = RecordingHaptics();
      var strikes = 0;
      await tester.pumpWidget(
        _host(haptics, weight, onStrike: () => strikes++),
      );

      final gesture = await _press(tester);
      await _holdFor(tester, weight.holdDuration * 0.6);
      await gesture.up();
      final sentAtRelease = haptics.events.length;
      await tester.pumpAndSettle();

      expect(haptics.events, hasLength(sentAtRelease));
      expect(
        haptics.events,
        everyElement(isIn(['tick', 'medium'])),
        reason: 'no landing haptic',
      );
      expect(strikes, 0);
    });
  }

  const tapLandings = {
    Weight.light: ['light'],
    Weight.heavy: ['heavy'],
    Weight.bossTier: ['doubleHeavy'],
  };

  for (final MapEntry(key: weight, value: expected) in tapLandings.entries) {
    testWidgets('${weight.label}: tap mode sends the landing haptic only', (
      tester,
    ) async {
      final haptics = RecordingHaptics();
      await tester.pumpWidget(_host(haptics, weight, tapMode: true));

      await tester.tap(find.text('The task'));
      await tester.pumpAndSettle();

      expect(haptics.events, expected);
    });
  }
}
