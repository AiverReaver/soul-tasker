import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/onboarding_fields.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: buildTheme(),
    home: Scaffold(body: child),
  ),
);

void main() {
  testWidgets('LineField reports edits', (tester) async {
    String? seen;
    await _pump(
      tester,
      LineField(label: 'The boss', hint: 'Goal', onChanged: (t) => seen = t),
    );
    expect(find.text('The boss'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Garage');
    expect(seen, 'Garage');
  });
}
