import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import 'pump.dart';

HearthPalette _palette(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Scaffold).first))
        .extension<HearthPalette>()!;

void main() {
  late Harness h;
  setUp(() => h = Harness());

  testWidgets('picking Moss Grotto repaints Home and survives a restart', (
    tester,
  ) async {
    await pumpApp(tester, h);
    expect(_palette(tester), Biome.pharloom.palette);

    await tester.tap(find.bySemanticsLabel('Settings'));
    await settle(tester);
    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Moss Grotto'));
    await settle(tester);
    await tester.pageBack();
    await settle(tester);
    expect(_palette(tester), Biome.moss.palette);

    // A restart: the app is torn down and rebuilt on the same database.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
    await pumpApp(tester, h);
    expect(_palette(tester), Biome.moss.palette);
    await tearDownApp(tester, h);
  });
}
