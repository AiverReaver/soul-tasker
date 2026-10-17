import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/boss_view.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/ui/hearth_nav_bar.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import 'pump.dart';

void main() {
  testWidgets('Home opens on a greeting, the level and today’s foes', (
    tester,
  ) async {
    final h = Harness();
    final BossView view = await h.seed();
    await pumpApp(tester, h, tall: true);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Text &&
            const {'Morning.', 'Afternoon.', 'Evening.'}.contains(w.data),
      ),
      findsOneWidget,
    );
    expect(find.text('Level 1'), findsOneWidget);

    await tester.tap(find.text('Today'));
    await settle(tester);
    expect(find.text('Today’s foes'), findsOneWidget);
    expect(find.text('0 of 4 struck · hold to strike'), findsOneWidget);

    await h.attempts.strike(taskNamed(view, 'Read chapter 4').task.id);
    await settle(tester);
    expect(find.text('1 of 4 struck · hold to strike'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('with every foe struck, Home points to the bonfire', (
    tester,
  ) async {
    final h = Harness();
    final id = await h.bosses.saveBoss(
      const BossDraft(
        title: 'The Habit',
        resetOnFail: ResetOnFail.nothing,
        phases: [],
        standalone: [TaskDraft(title: 'Walk', recurrence: Recurrence.daily)],
      ),
    );
    final view = await h.reload(id);
    await pumpApp(tester, h, tall: true);
    await tester.tap(find.text('Today'));
    await settle(tester);
    await h.attempts.strike(taskNamed(view, 'Walk').task.id);
    await settle(tester);
    expect(find.text('All foes struck. Rest at the bonfire'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('the bottom bar switches Bosses and Today, and opens Bonfire '
      'and Relics', (tester) async {
    final h = Harness();
    await h.seed();
    await pumpApp(tester, h, tall: true);
    expect(find.byType(HearthNavBar), findsOneWidget);

    await tester.tap(find.text('Today'));
    await settle(tester);
    expect(find.text('Today’s foes'), findsOneWidget);
    await tester.tap(find.text('Bosses'));
    await settle(tester);
    expect(find.text('Today’s foes'), findsNothing);

    await tester.tap(find.text('Relics'));
    await settle(tester);
    expect(find.text('HALL OF RELICS'), findsOneWidget);
    await tester.pageBack();
    await settle(tester);

    await tester.tap(find.text('Bonfire'));
    await settle(tester);
    expect(find.text('BONFIRE'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('a pinned boss is a featured panel that opens its fight', (
    tester,
  ) async {
    final h = Harness();
    final view = await h.seed();
    await h.bosses.setPinned(view.boss.id, isPinned: true);
    await pumpApp(tester, h, tall: true);

    expect(find.byKey(const Key('pinned-boss-panel')), findsOneWidget);
    await tester.tap(find.text('Enter the fight'));
    await settle(tester);
    expect(find.text('Phase I of II'), findsOneWidget);
    await tearDownApp(tester, h);
  });
}
