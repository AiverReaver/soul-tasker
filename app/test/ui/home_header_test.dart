import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/home_header.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'date line, serif greeting, embers and a level badge and the profile and settings circles',
    (tester) async {
      final taps = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(),
          home: Scaffold(
            body: HomeHeader(
              dateLine: 'Sat, 17 Oct',
              greeting: 'Evening.',
              embers: 42,
              level: 4,
              levelBars: 3,
              percentToNext: 30,
              onProfile: () => taps.add('profile'),
              onSettings: () => taps.add('settings'),
            ),
          ),
        ),
      );
      expect(find.text('Sat, 17 Oct'), findsOneWidget);
      final greeting = tester.widget<Text>(find.text('Evening.'));
      expect(greeting.style?.fontFamily, 'CormorantGaramond');
      expect(greeting.style?.fontSize, 34);
      expect(find.text('42'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Level 4, 30 percent to level 5'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('level-bar-on')), findsNWidgets(3));
      await tester.tap(find.bySemanticsLabel('Your profile'));
      await tester.tap(find.bySemanticsLabel('Settings'));
      expect(taps, ['profile', 'settings']);
    },
  );

  test('greetingFor picks the part of the day', () {
    expect(greetingFor(8), 'Morning.');
    expect(greetingFor(14), 'Afternoon.');
    expect(greetingFor(19), 'Evening.');
    expect(greetingFor(2), 'Evening.');
  });
}
