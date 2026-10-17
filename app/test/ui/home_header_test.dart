import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/home_header.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('date line, serif greeting, embers and a 5-bar level meter', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: const Scaffold(
          body: HomeHeader(
            dateLine: 'Sat, 17 Oct',
            greeting: 'Evening.',
            embers: 42,
            level: 4,
            levelBars: 3,
          ),
        ),
      ),
    );
    expect(find.text('Sat, 17 Oct'), findsOneWidget);
    final greeting = tester.widget<Text>(find.text('Evening.'));
    expect(greeting.style?.fontFamily, 'CormorantGaramond');
    expect(greeting.style?.fontSize, 34);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('Level 4'), findsOneWidget);
    expect(find.byKey(const ValueKey('level-bar-on')), findsNWidgets(3));
    expect(find.byKey(const ValueKey('level-bar-off')), findsNWidgets(2));
  });

  test('greetingFor picks the part of the day', () {
    expect(greetingFor(8), 'Morning.');
    expect(greetingFor(14), 'Afternoon.');
    expect(greetingFor(19), 'Evening.');
    expect(greetingFor(2), 'Evening.');
  });
}
