import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/features/strike/hold_to_strike.dart';
import 'package:hearthrise/ui/hold_button.dart';
import 'package:hearthrise/ui/needle_frame.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/hold_finders.dart';
import '../../support/recording_haptics.dart';

Widget _host({bool isDone = false, String? bossName}) => ProviderScope(
  overrides: [RecordingHaptics().asOverride],
  child: MaterialApp(
    theme: buildTheme(),
    home: Scaffold(
      body: HoldToStrike(
        title: 'The task',
        weight: Weight.heavy,
        isDone: isDone,
        bossName: bossName,
        onStrike: () {},
      ),
    ),
  ),
);

void main() {
  final p = Biome.pharloom.palette;

  testWidgets('an open row offers a labelled hold button', (tester) async {
    await tester.pumpWidget(_host(bossName: 'Thesis Warden'));
    expect(find.bySemanticsLabel('Hold to strike: The task'), findsOneWidget);
    expect(find.text('Thesis Warden · +3 embers'), findsOneWidget);
    expect(find.text('Heavy'), findsNothing);
  });

  testWidgets('without a boss name the meta line is the embers alone', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    expect(find.text('+3 embers'), findsOneWidget);
  });

  testWidgets('a struck row reads "Struck" in its meta line', (tester) async {
    await tester.pumpWidget(_host(isDone: true, bossName: 'Thesis Warden'));
    expect(find.text('Struck · +3 embers'), findsOneWidget);
    expect(find.byType(HoldButton), findsNothing);
  });

  testWidgets('the hold is ready from 80%, and the row edge turns silk', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    bool ready() => tester.widget<HoldButton>(holdButton('The task')).isReady;
    final g = await tester.startGesture(
      tester.getCenter(holdButton('The task')),
    );
    await tester.pump(); // the ticker's first frame starts the clock
    await tester.pump(const Duration(milliseconds: 400)); // 67% of 600 ms
    expect(ready(), isFalse);
    expect(tester.widget<NeedleFrame>(find.byType(NeedleFrame)).edge, p.silk);
    await tester.pump(const Duration(milliseconds: 100)); // 83%
    expect(ready(), isTrue);
    await g.up();
    await tester.pumpAndSettle();
  });

  testWidgets('tapping the row away from the button starts no hold', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    final g = await tester.startGesture(
      tester.getCenter(find.text('The task')),
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.widget<HoldButton>(holdButton('The task')).progress, 0);
    await g.up();
  });
}
