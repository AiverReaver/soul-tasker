import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/features/strike/hold_to_strike.dart';
import 'package:hearthrise/features/strike/strike_sweep.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/hold_finders.dart';
import '../../support/recording_haptics.dart';

void main() {
  testWidgets('a held row tenses: it trembles 1 px left and right', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [RecordingHaptics().asOverride],
        child: MaterialApp(
          theme: buildTheme(),
          home: Scaffold(
            body: HoldToStrike(
              title: 'The task',
              weight: Weight.heavy,
              isDone: false,
              tapMode: false,
              onStrike: () {},
              onTried: () {},
            ),
          ),
        ),
      ),
    );
    final g = await tester.startGesture(
      tester.getCenter(holdButton('The task')),
    );
    final seen = <double>{};
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      final shake = tester.widget<Transform>(find.byKey(kStrikeShakeKey));
      seen.add(shake.transform.getTranslation().x);
    }
    expect(seen, containsAll([-1.0, 1.0]));
    await g.up();
    await tester.pumpAndSettle();
    final rest = tester.widget<Transform>(find.byKey(kStrikeShakeKey));
    expect(rest.transform.getTranslation().x, 0);
  });
}
