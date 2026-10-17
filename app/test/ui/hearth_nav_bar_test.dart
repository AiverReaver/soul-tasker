import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/hearth_nav_bar.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('four labelled items, the selected one in silk, taps report '
      'the index', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(
          bottomNavigationBar: HearthNavBar(
            selected: 1,
            onTap: (i) => tapped = i,
          ),
        ),
      ),
    );
    final p = Biome.pharloom.palette;
    for (final l in ['Bosses', 'Today', 'Bonfire', 'Relics']) {
      expect(find.text(l), findsOneWidget, reason: l);
    }
    expect(tester.widget<Text>(find.text('Today')).style?.color, p.silk);
    expect(tester.widget<Text>(find.text('Bosses')).style?.color, p.ash);
    for (final (i, l) in ['Bosses', 'Today', 'Bonfire', 'Relics'].indexed) {
      await tester.tap(find.text(l));
      expect(tapped, i);
    }
    expect(
      tester.getSize(find.byKey(const ValueKey('nav-item-0'))).height,
      greaterThanOrEqualTo(kMinTarget),
    );
  });
}
