import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/flask_pips.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: buildTheme(),
    home: Scaffold(body: child),
  ),
);

void main() {
  testWidgets('FlaskPips fills n of the cap and speaks it', (tester) async {
    await _pump(tester, const FlaskPips(count: 2, cap: 3));
    expect(find.byKey(const ValueKey('flask-full')), findsNWidgets(2));
    expect(find.byKey(const ValueKey('flask-empty')), findsOneWidget);
    expect(find.bySemanticsLabel('Flasks 2 of 3'), findsOneWidget);
  });

  testWidgets('FlaskPips with none left shows only empty pips', (tester) async {
    await _pump(tester, const FlaskPips(count: 0, cap: 3));
    expect(find.byKey(const ValueKey('flask-full')), findsNothing);
    expect(find.byKey(const ValueKey('flask-empty')), findsNWidgets(3));
  });
}
