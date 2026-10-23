import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/boss_view.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/ui/glass_sheet.dart';
import 'package:hearthrise/ui/glass_tab_bar.dart';
import 'package:hearthrise/ui/hold_button.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import 'pump.dart';

void main() {
  testWidgets('Home opens on a greeting, the level and today’s tasks', (
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
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            w.properties.label == 'Level 1, 0 percent to level 2',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Your profile'), findsOneWidget);
    expect(find.bySemanticsLabel('Settings'), findsOneWidget);
    expect(find.text('Today’s tasks'), findsOneWidget);
    expect(find.text('0 of 4 struck'), findsOneWidget);
    expect(find.byKey(const ValueKey('new-foe')), findsOneWidget);
    expect(find.byType(HoldButton), findsWidgets);

    await h.attempts.strike(taskNamed(view, 'Read chapter 4').task.id);
    await settle(tester);
    expect(find.text('1 of 4 struck'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('with every task struck, Home points to the bonfire', (
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
    await h.attempts.strike(taskNamed(view, 'Walk').task.id);
    await settle(tester);
    expect(find.text('All tasks struck. Rest at the bonfire'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('the bottom bar stays on every tab: Bosses, Today, Bonfire and '
      'Relics', (tester) async {
    final h = Harness();
    await h.seed();
    await pumpApp(tester, h, tall: true);
    expect(find.byType(GlassTabBar), findsOneWidget);

    await tester.tap(find.text('Today'));
    await settle(tester);
    expect(find.text('0 of 4 struck · hold to strike'), findsOneWidget);
    expect(find.byType(GlassTabBar), findsOneWidget);
    await tester.tap(find.text('Home'));
    await settle(tester);
    expect(find.text('0 of 4 struck'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await settle(tester);
    expect(find.text('Hall of relics'), findsOneWidget);
    expect(find.byType(GlassTabBar), findsOneWidget);

    await tester.tap(find.text('Bonfire'));
    await settle(tester);
    expect(find.text('BONFIRE'), findsOneWidget);
    expect(find.byType(GlassTabBar), findsOneWidget);

    await tester.tap(find.text('Home'));
    await settle(tester);
    expect(find.bySemanticsLabel('Your profile'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('the bar marks the tab you are on, also when opened by URL', (
    tester,
  ) async {
    final h = Harness();
    await pumpApp(tester, h, location: '/bonfire', tall: true);
    final bar = tester.widget<GlassTabBar>(find.byType(GlassTabBar));
    expect(bar.selected, 2);
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
    expect(find.text('Chapter I of II · Attempt 1'), findsOneWidget);
    expect(find.text('Boss health'), findsOneWidget);
    await tester.tap(find.text('Enter the fight'));
    await settle(tester);
    expect(find.text('Chapter I of II'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('All bosses leads to the full list', (tester) async {
    final h = Harness();
    await h.seed();
    await pumpApp(tester, h, tall: true);
    expect(find.text('All bosses · 1 active'), findsOneWidget);
    await tester.tap(find.text('All bosses · 1 active'));
    await settle(tester);
    expect(find.text('Name a new boss'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('the struck count skips bosses set aside and follows the chip', (
    tester,
  ) async {
    final h = Harness();
    final view = await h.seed();
    final habit = await h.bosses.saveBoss(
      const BossDraft(
        title: 'The Habit',
        resetOnFail: ResetOnFail.nothing,
        phases: [],
        standalone: [TaskDraft(title: 'Walk', recurrence: Recurrence.daily)],
      ),
    );
    await h.attempts.strike(taskNamed(await h.reload(habit), 'Walk').task.id);
    await pumpApp(tester, h, tall: true);
    expect(find.text('1 of 5 struck'), findsOneWidget);

    await tester.tap(find.text(view.boss.title).first);
    await settle(tester);
    expect(find.text('0 of 4 struck'), findsOneWidget);

    await tester.tap(find.text('All'));
    await settle(tester);
    await h.bosses.setStatus(habit, BossStatus.waiting);
    await settle(tester);
    expect(find.text('0 of 4 struck'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('a struck one-time task stays in its group count on Home and '
      'Today alike', (tester) async {
    final h = Harness();
    final view = await h.seed();
    await h.attempts.strike(taskNamed(view, 'Read chapter 4').task.id);
    await pumpApp(tester, h, tall: true);
    expect(find.text('1 of 4 struck'), findsOneWidget);
    await tester.tap(find.text('Today'));
    await settle(tester);
    expect(find.text('1 of 4 struck · hold to strike'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('long-press a boss: a glass sheet over the tab bar; The Day '
      'offers no status change', (tester) async {
    final h = Harness();
    final view = await h.seed();
    await h.bosses.ensureDayBoss();
    await pumpApp(tester, h, location: '/bosses', tall: true);

    await tester.longPress(find.text('The Day'));
    await settle(tester);
    expect(find.byType(GlassSheet), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byType(GlassSheet),
        matching: find.byType(Navigator),
      ),
      findsOneWidget,
    );
    expect(find.text('Pin'), findsOneWidget);
    expect(find.text('Set waiting'), findsNothing);
    await tester.tap(find.text('Cancel'));
    await settle(tester);

    await tester.longPress(find.text(view.boss.title));
    await settle(tester);
    await tester.tap(find.text('Set waiting'));
    await settle(tester);
    expect((await h.reload(view.boss.id)).boss.status, BossStatus.waiting);
    await tearDownApp(tester, h);
  });
}
