import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/ember_tally.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: buildTheme(),
    home: Scaffold(body: child),
  ),
);

void main() {
  testWidgets('EmberTally shows carried and banked from its values', (
    tester,
  ) async {
    await _pump(tester, const EmberTally(carried: 7, banked: 42));
    expect(find.text('Carried 7'), findsOneWidget);
    expect(find.text('Banked 42'), findsOneWidget);
  });

  testWidgets('EmberTally shows zeros without error', (tester) async {
    await _pump(tester, const EmberTally(carried: 0, banked: 0));
    expect(find.text('Carried 0'), findsOneWidget);
    expect(find.text('Banked 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
