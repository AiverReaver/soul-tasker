import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/profile_level.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('a framed diamond, "Level N", bars and the way to the next', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: const Scaffold(
          body: ProfileLevel(level: 7, toNext: 160, bars: 3, percentToNext: 56),
        ),
      ),
    );
    final title = tester.widget<Text>(find.text('Level 7'));
    expect(title.style?.fontFamily, 'CormorantGaramond');
    expect(title.style?.fontSize, 30);
    expect(find.text('160 embers to the next'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.byKey(const ValueKey('level-bar-on')), findsNWidgets(3));
    expect(find.byKey(const ValueKey('level-bar-off')), findsNWidgets(2));
    expect(
      find.bySemanticsLabel('Level 7, 56 percent to level 8'),
      findsOneWidget,
    );
    final diamond = tester.getRect(find.byKey(const ValueKey('level-diamond')));
    expect(diamond.size, const Size.square(64));
    expect(diamond.right, lessThan(tester.getRect(find.text('Level 7')).left));
  });
}
