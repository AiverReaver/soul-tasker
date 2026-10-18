import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/glass_action_row.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('a labelled button row, at least 48 px tall, that taps', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(
          body: GlassActionRow(label: 'Edit', onTap: () => taps++),
        ),
      ),
    );
    expect(find.bySemanticsLabel('Edit'), findsOneWidget);
    expect(tester.getSize(find.byType(GlassActionRow)).height, 52);
    await tester.tap(find.text('Edit'));
    expect(taps, 1);
  });
}
