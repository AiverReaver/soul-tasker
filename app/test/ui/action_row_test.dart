import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/action_row.dart';
import 'package:hearthrise/ui/glass_surface.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('a plain labelled row, 52 px tall, that taps and is not glass', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(
          body: ActionRow(label: 'Edit', onTap: () => taps++),
        ),
      ),
    );
    expect(find.bySemanticsLabel('Edit'), findsOneWidget);
    expect(tester.getSize(find.byType(ActionRow)).height, 52);
    expect(
      find.descendant(
        of: find.byType(ActionRow),
        matching: find.byType(GlassSurface),
      ),
      findsNothing,
    );
    await tester.tap(find.text('Edit'));
    expect(taps, 1);
  });
}
