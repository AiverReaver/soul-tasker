import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/ui/glass_tab_bar.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/harness.dart';
import '../pump.dart';

void main() {
  testWidgets('the glass bar floats 19 px above the bottom, over the body', (
    tester,
  ) async {
    final h = Harness();
    await pumpApp(tester, h, tall: true);
    expect(find.byType(GlassTabBar), findsOneWidget);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold).first).extendBody,
      isTrue,
    );
    final bar = tester.getRect(find.byKey(const ValueKey('nav-bar')));
    expect(bar.bottom, 1800 / 2 - 19);
    await tearDownApp(tester, h);
  });

  testWidgets('the bar marks the tab you are on, also when opened by URL', (
    tester,
  ) async {
    final h = Harness();
    await pumpApp(tester, h, location: '/bonfire', tall: true);
    expect(tester.widget<GlassTabBar>(find.byType(GlassTabBar)).selected, 2);
    await tearDownApp(tester, h);
  });

  testWidgets('tabs go to their routes', (tester) async {
    final h = Harness();
    await h.seed();
    await pumpApp(tester, h, tall: true);
    await tester.tap(find.text('Profile'));
    await settle(tester);
    expect(find.text('HALL OF RELICS'), findsOneWidget);
    await tester.tap(find.text('Bonfire'));
    await settle(tester);
    expect(find.text('BONFIRE'), findsOneWidget);
    await tester.tap(find.text('Home'));
    await settle(tester);
    expect(find.text('BONFIRE'), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('Today with no pinned boss opens the foes list', (tester) async {
    final h = Harness();
    await h.seed();
    await pumpApp(tester, h, tall: true);
    await tester.tap(find.text('Today'));
    await settle(tester);
    expect(find.text('Today’s foes'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('Today with a pinned boss opens that boss’s fight (Q1)', (
    tester,
  ) async {
    final h = Harness();
    final view = await h.seed();
    await h.bosses.setPinned(view.boss.id, isPinned: true);
    await pumpApp(tester, h, tall: true);
    await tester.tap(find.text('Today'));
    await settle(tester);
    expect(find.text('Phase I of II'), findsOneWidget);
    await tearDownApp(tester, h);
  });
}
