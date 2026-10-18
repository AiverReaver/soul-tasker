import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/all_bosses_row.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('counts active and waiting bosses, and taps through', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(
          body: AllBossesRow(active: 2, waiting: 1, onTap: () => taps++),
        ),
      ),
    );
    expect(find.text('All bosses · 2 active · 1 waiting'), findsOneWidget);
    await tester.tap(find.text('All bosses · 2 active · 1 waiting'));
    expect(taps, 1);
  });

  testWidgets('leaves out waiting when there are none', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(body: AllBossesRow(active: 1, waiting: 0, onTap: () {})),
      ),
    );
    expect(find.text('All bosses · 1 active'), findsOneWidget);
  });
}
