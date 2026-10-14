import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/flask_choice.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: buildTheme(),
    home: Scaffold(body: child),
  ),
);

void main() {
  testWidgets('FlaskChoice says what was missed and fires its two actions', (
    tester,
  ) async {
    var used = 0;
    var fell = 0;
    await _pump(
      tester,
      FlaskChoice(
        daysMissed: 2,
        flasks: 3,
        onUseFlask: () => used++,
        onLetFall: () => fell++,
      ),
    );

    expect(find.text('2 days passed without rest.'), findsOneWidget);
    expect(find.text('You hold 3 flasks.'), findsOneWidget);
    await tester.tap(find.text('Use a flask'));
    await tester.tap(find.text('Let it fall'));
    expect((used, fell), (1, 1));
  });

  testWidgets('FlaskChoice speaks one day and one flask in the singular', (
    tester,
  ) async {
    await _pump(
      tester,
      FlaskChoice(
        daysMissed: 1,
        flasks: 1,
        onUseFlask: () {},
        onLetFall: () {},
      ),
    );
    expect(find.text('A day passed without rest.'), findsOneWidget);
    expect(find.text('You hold 1 flask.'), findsOneWidget);
  });
}
