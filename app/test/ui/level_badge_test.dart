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

  testWidgets('large: a bigger numeral, same bars', (tester) async {
    Future<double> numeralSize({required bool isLarge}) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(),
          home: Scaffold(
            body: LevelBadge(
              level: 7,
              embers: 42,
              percentToNext: 56,
              bars: 3,
              isLarge: isLarge,
            ),
          ),
        ),
      );
      return tester.widget<Text>(find.text('7')).style!.fontSize!;
    }

    final small = await numeralSize(isLarge: false);
    final large = await numeralSize(isLarge: true);
    expect(large, greaterThan(small));
    expect(find.byKey(const ValueKey('level-bar-on')), findsNWidgets(3));
  });

  testWidgets('the rotated diamond keeps its corners inside the badge', (
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
    final slot = tester.getSize(
      find.ancestor(of: find.text('7'), matching: find.byType(Stack)).first,
    );
    expect(slot.width, greaterThanOrEqualTo(26 * 1.4142));
  });
}
