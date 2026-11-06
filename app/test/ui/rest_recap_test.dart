import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/rest_recap.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: buildTheme(),
    home: Scaffold(body: child),
  ),
);

void main() {
  testWidgets('names the night, the day, tomorrow and the way out', (
    tester,
  ) async {
    var done = 0;
    await _pump(
      tester,
      RestRecap(
        night: 1,
        strikes: 2,
        kept: 1,
        tomorrow: 'Write before noon',
        onDone: () => done++,
      ),
    );
    expect(find.text('Night 1.'), findsOneWidget);
    expect(find.text('2 tasks struck. 1 ember kept.'), findsOneWidget);
    expect(find.text('Tomorrow: Write before noon'), findsOneWidget);
    expect(find.text('You’ve rested. See you tomorrow.'), findsOneWidget);
    await tester.tap(find.text('Back to today'));
    expect(done, 1);
  });

  testWidgets('one task, no embers and no line for tomorrow', (tester) async {
    await _pump(
      tester,
      RestRecap(night: 3, strikes: 1, kept: 0, onDone: () {}),
    );
    expect(find.text('Night 3.'), findsOneWidget);
    expect(find.text('1 task struck. 0 embers kept.'), findsOneWidget);
    expect(find.textContaining('Tomorrow:'), findsNothing);
  });
}
