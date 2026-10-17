import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/diamond_pip.dart';
import 'package:hearthrise/ui/hearth_nav_bar.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(
  WidgetTester tester, {
  int selected = 1,
  ValueChanged<int>? onTap,
}) => tester.pumpWidget(
  MaterialApp(
    theme: buildTheme(),
    home: Scaffold(
      bottomNavigationBar: HearthNavBar(
        selected: selected,
        onTap: onTap ?? (_) {},
      ),
    ),
  ),
);

void main() {
  final p = Biome.pharloom.palette;

  testWidgets('four labelled items; taps report the index', (tester) async {
    int? tapped;
    await _pump(tester, onTap: (i) => tapped = i);
    for (final (i, l) in HearthNavBar.labels.indexed) {
      expect(find.text(l), findsOneWidget, reason: l);
      await tester.tap(find.text(l));
      expect(tapped, i);
    }
    expect(
      tester.getSize(find.byKey(const ValueKey('nav-item-0'))).height,
      greaterThanOrEqualTo(kMinTarget),
    );
  });

  testWidgets('selected label is bone, the rest ash, all 12 px', (
    tester,
  ) async {
    await _pump(tester);
    final today = tester.widget<Text>(find.text('Today')).style!;
    final bosses = tester.widget<Text>(find.text('Bosses')).style!;
    expect(today.color, p.bone);
    expect(bosses.color, p.ash);
    expect(today.fontSize, 12);
    expect(bosses.fontSize, 12);
  });

  testWidgets('every item has an icon, tinted like its label', (tester) async {
    await _pump(tester);
    for (var i = 0; i < 4; i++) {
      expect(find.byKey(ValueKey('nav-icon-$i')), findsOneWidget);
    }
  });

  testWidgets('one silk 7 px diamond marks the selected item only', (
    tester,
  ) async {
    await _pump(tester);
    final pip = tester.widget<DiamondPip>(find.byType(DiamondPip));
    expect(pip.color, p.silk);
    expect(pip.size, 7);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('nav-item-1')),
        matching: find.byType(DiamondPip),
      ),
      findsOneWidget,
    );
  });

  testWidgets('bar sits on the void colour with a seam edge', (tester) async {
    await _pump(tester);
    final box = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('nav-bar')),
    );
    final d = box.decoration as BoxDecoration;
    expect(d.color, p.void_);
    expect((d.border as Border).top.color, p.seam);
  });
}
