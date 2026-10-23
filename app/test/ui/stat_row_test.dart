import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/stat_row.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('each stat is a value over its label, in equal columns', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: const Scaffold(
          body: StatRow(
            stats: [
              Stat('9', 'Attempts'),
              Stat('41', 'Days'),
              Stat('2,180', 'Effort'),
            ],
          ),
        ),
      ),
    );
    final value = tester.getRect(find.text('41'));
    final label = tester.getRect(find.text('Days'));
    expect(value.bottom, lessThanOrEqualTo(label.top));
    expect(
      tester.getCenter(find.text('9')).dx,
      lessThan(tester.getCenter(find.text('41')).dx),
    );
    expect(
      tester.getCenter(find.text('41')).dx,
      lessThan(tester.getCenter(find.text('2,180')).dx),
    );
    expect(tester.widget<Text>(find.text('41')).style?.fontSize, 17);
    expect(
      find.byWidgetPredicate((w) => w.key.toString().contains('stat-divider')),
      findsNWidgets(2),
    );
  });
}
