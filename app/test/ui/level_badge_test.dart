import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/level_badge.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('a serif numeral, the embers, five bars and a spoken label', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: const Scaffold(
          body: LevelBadge(level: 7, embers: 42, percentToNext: 56, bars: 3),
        ),
      ),
    );
    final numeral = tester.widget<Text>(find.text('7'));
    expect(numeral.style?.fontFamily, 'CormorantGaramond');
    expect(find.text('42'), findsOneWidget);
    expect(find.byKey(const ValueKey('level-bar-on')), findsNWidgets(3));
    expect(find.byKey(const ValueKey('level-bar-off')), findsNWidgets(2));
    expect(
      find.bySemanticsLabel('Level 7, 56 percent to level 8'),
      findsOneWidget,
    );
  });
}
