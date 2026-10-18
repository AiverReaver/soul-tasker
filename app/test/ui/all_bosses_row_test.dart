import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/all_bosses_row.dart';
import 'package:hearthrise/ui/needle_frame.dart';
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

  testWidgets('sits in a needle frame with a drawn chevron', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(body: AllBossesRow(active: 1, waiting: 0, onTap: () {})),
      ),
    );
    expect(find.byType(NeedleFrame), findsOneWidget);
    final left = tester.getTopLeft(find.text('All bosses · 1 active')).dx;
    expect(left, greaterThanOrEqualTo(32));
  });

  testWidgets('"All bosses" leads in bold, the counts follow quietly', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(body: AllBossesRow(active: 2, waiting: 1, onTap: () {})),
      ),
    );
    final span = tester
        .widget<Text>(find.text('All bosses · 2 active · 1 waiting'))
        .textSpan!;
    final parts = (span as TextSpan).children!.cast<TextSpan>();
    expect(parts.first.text, 'All bosses');
    expect(parts.first.style?.fontWeight, FontWeight.w600);
    expect(parts.last.style?.color, Biome.pharloom.palette.ash);
  });
}
