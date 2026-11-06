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
    expect(find.text('To bank 7'), findsOneWidget);
    expect(find.text('Banked 42'), findsOneWidget);
  });

  testWidgets('before the first rest it shows one number and says what it is', (
    tester,
  ) async {
    await _pump(tester, const EmberTally(carried: 3, banked: 0));
    expect(find.text('Embers 3'), findsOneWidget);
    expect(find.text('Earned by striking. Rest to bank them.'), findsOneWidget);
    expect(find.textContaining('Carried'), findsNothing);
    expect(find.textContaining('Banked'), findsNothing);
  });

  testWidgets('EmberTally shows zeros without error', (tester) async {
    await _pump(tester, const EmberTally(carried: 0, banked: 0));
    expect(find.text('Embers 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
