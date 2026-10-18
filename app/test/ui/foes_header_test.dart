import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/foes_header.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('serif title, quiet count, and a plus that adds a foe', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(
          body: FoesHeader(countLabel: '1 of 4 struck', onNewFoe: () => taps++),
        ),
      ),
    );
    final title = tester.widget<Text>(find.text('Today’s foes'));
    expect(title.style?.fontFamily, 'CormorantGaramond');
    expect(title.style?.fontSize, 22);
    expect(find.text('1 of 4 struck'), findsOneWidget);
    final count = tester.getRect(find.text('1 of 4 struck'));
    expect(
      count.left,
      greaterThanOrEqualTo(tester.getRect(find.text('Today’s foes')).right),
    );
    await tester.tap(find.bySemanticsLabel('New foe'));
    expect(taps, 1);
    expect(
      tester.getSize(find.bySemanticsLabel('New foe')).shortestSide,
      greaterThanOrEqualTo(48),
    );
  });
}
