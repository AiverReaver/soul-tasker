import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/ui/glass_tab_bar.dart';
import 'package:hearthrise/ui/nav_icon.dart';
import 'package:material_ui/material_ui.dart';

import 'glass_host.dart';

void main() {
  Widget bar({int selected = 1, ValueChanged<int>? onTap}) => glassHost(
    Align(
      alignment: Alignment.bottomCenter,
      child: GlassTabBar(selected: selected, onTap: onTap ?? (_) {}),
    ),
  );

  testWidgets('three labelled tabs with the shell keys', (tester) async {
    await tester.pumpWidget(bar());
    for (final label in ['Today', 'Bosses', 'Profile']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Home'), findsNothing);
    expect(find.text('Bonfire'), findsNothing);
    // Today a blade, Bosses a mask, Profile a gem.
    for (final (i, glyph) in [1, 0, 3].indexed) {
      expect(find.byKey(ValueKey('nav-item-$i')), findsOneWidget);
      expect(
        tester.widget<NavIcon>(find.byKey(ValueKey('nav-icon-$i'))).index,
        glyph,
      );
    }
    expect(find.byKey(const ValueKey('nav-bar')), findsOneWidget);
  });

  testWidgets('the selected tab is marked and wears the silk diamond', (
    tester,
  ) async {
    await tester.pumpWidget(bar(selected: 2));
    expect(find.byKey(const ValueKey('nav-diamond')), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Profile')),
      matchesSemantics(
        label: 'Profile',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Today')),
      matchesSemantics(
        label: 'Today',
        isButton: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
  });

  testWidgets('a tap fires onTap with the index', (tester) async {
    int? got;
    await tester.pumpWidget(bar(onTap: (i) => got = i));
    await tester.tap(find.byKey(const ValueKey('nav-item-2')));
    expect(got, 2);
  });

  testWidgets('a 62 px pill floating 21 px in', (tester) async {
    await tester.pumpWidget(bar());
    final pill = find.byKey(const ValueKey('nav-bar'));
    expect(tester.getSize(pill).height, 62);
    expect(tester.getTopLeft(pill).dx, 21);
    expect(GlassTabBar.clearance, 100);
  });
}
