import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/boss_view.dart';
import 'package:hearthrise/data/day_boss.dart';
import 'package:hearthrise/data/day_dao.dart';
import 'package:hearthrise/data/ember_dao.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/ui/filter_chips.dart';
import 'package:hearthrise/ui/flash_line.dart';
import 'package:hearthrise/ui/glass_sheet.dart';
import 'package:hearthrise/ui/day_panel.dart';
import 'package:hearthrise/ui/glass_tab_bar.dart';
import 'package:hearthrise/ui/task_group_header.dart';
import 'package:hearthrise/ui/hold_button.dart';
import 'package:hearthrise/ui/week_streak_card.dart';
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
    expect(find.bySemanticsLabel('Your profile'), findsNothing);
    // Its own node, not merged into the eyebrow beside it.
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

  testWidgets('after the rest, the empty list says so', (tester) async {
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
    await h.attempts.strike(taskNamed(view, 'Walk').task.id);
    await DayDao(h.db, h.clock.call, h.attempts).rest();
    await pumpApp(tester, h, tall: true);
    expect(find.text('You’ve rested. See you tomorrow.'), findsOneWidget);
    expect(find.text('All tasks struck. Rest at the bonfire'), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('the bottom bar stays on every tab: Today, Bosses, Profile', (
    tester,
  ) async {
    final h = Harness();
    await h.seed();
    await pumpApp(tester, h, tall: true);
    expect(find.byType(GlassTabBar), findsOneWidget);
    expect(find.text('0 of 4 struck'), findsOneWidget);

    await tester.tap(find.text('Bosses'));
    await settle(tester);
    expect(find.text('All bosses'), findsOneWidget);
    expect(find.byType(GlassTabBar), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await settle(tester);
    expect(find.text('Hall of relics'), findsOneWidget);
    expect(find.byType(GlassTabBar), findsOneWidget);

    await tester.tap(find.text('Today'));
    await settle(tester);
    expect(find.text('0 of 4 struck'), findsOneWidget);
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
    expect(find.text('BOSS · CHAPTER I OF II'), findsOneWidget);
    expect(find.text('Attempt 1'), findsOneWidget);
    await tester.tap(find.byKey(const Key('pinned-boss-panel')));
    await settle(tester);
    expect(find.text('Chapter I of II'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('Home shows the week streak, and a rest adds to it', (
    tester,
  ) async {
    final h = Harness();
    await h.seed();
    await pumpApp(tester, h, tall: true);
    await tester.scrollUntilVisible(
      find.byType(WeekStreakCard),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView).first,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Begins today'), findsOneWidget);
    await DayDao(h.db, h.clock.call, h.attempts).rest();
    await settle(tester);
    expect(find.text('1 day unbroken'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('Today shows boss filter chips once there are two bosses', (
    tester,
  ) async {
    final h = Harness();
    await h.seed();
    await h.bosses.ensureDayBoss();
    await pumpApp(tester, h, tall: true);
    expect(find.byType(FilterChips<String>), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('the Bosses tab leads to the full list', (tester) async {
    final h = Harness();
    await h.seed();
    await pumpApp(tester, h, tall: true);
    await tester.tap(find.text('Bosses'));
    await settle(tester);
    expect(find.text('The Certification'), findsOneWidget);
    expect(find.text('Name a new boss'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('the struck count skips bosses set aside and follows the Today '
      'chip', (tester) async {
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

  testWidgets('a struck one-time task stays in its group count', (
    tester,
  ) async {
    final h = Harness();
    final view = await h.seed();
    await h.attempts.strike(taskNamed(view, 'Read chapter 4').task.id);
    await pumpApp(tester, h, tall: true);
    expect(find.text('1 of 4 struck'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('long-press a boss: a glass sheet over the tab bar; The Day '
      'offers no status change', (tester) async {
    final h = Harness();
    final view = await h.seed();
    await h.bosses.ensureDayBoss();
    await h.bosses.setPinned(dayBossId, isPinned: true);
    await pumpApp(tester, h, tall: true);

    // The Day is reached on Home only: its pinned panel.
    await tester.longPress(
      find.descendant(
        of: find.byKey(const Key('pinned-boss-panel')),
        matching: find.text('The Day'),
      ),
    );
    await settle(tester);
    expect(find.byType(GlassSheet), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byType(GlassSheet),
        matching: find.byType(Navigator),
      ),
      findsOneWidget,
    );
    expect(find.text('Unpin'), findsOneWidget);
    expect(find.text('Set waiting'), findsNothing);
    await tester.tap(find.text('Cancel'));
    await settle(tester);

    await tester.tap(find.text('Bosses'));
    await settle(tester);
    await tester.longPress(find.text(view.boss.title));
    await settle(tester);
    await tester.tap(find.text('Set waiting'));
    await settle(tester);
    expect((await h.reload(view.boss.id)).boss.status, BossStatus.waiting);
    await tearDownApp(tester, h);
  });

  testWidgets('the flash line is inset 20 px like the rest of Home', (
    tester,
  ) async {
    final h = Harness();
    await h.seed();
    await pumpApp(tester, h, tall: true);
    expect(tester.getTopLeft(find.byType(FlashLine)).dx, 20);
    await tearDownApp(tester, h);
  });

  testWidgets('The Day is left out of the Bosses tab', (tester) async {
    final h = Harness();
    await h.seed();
    await h.bosses.ensureDayBoss();
    await pumpApp(tester, h, tall: true);
    await tester.tap(find.text('Bosses'));
    await settle(tester);
    expect(find.text('The Certification'), findsOneWidget);
    expect(find.text('The Day'), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('a strike shows its embers on Home at once, before any rest', (
    tester,
  ) async {
    final h = Harness();
    final view = await h.seed();
    await h.attempts.strike(view.phases.first.tasks.first.task.id);
    final earned = (await EmberDao(h.db, h.clock.call).tally()).carried;
    expect(earned, greaterThan(0));
    await pumpApp(tester, h, tall: true);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('home-header')),
        matching: find.text('$earned'),
      ),
      findsOneWidget,
    );
    await tearDownApp(tester, h);
  });

  testWidgets('The Day leads Home: first group, and its label opens its '
      'screen', (tester) async {
    final h = Harness();
    await h.seed();
    await h.bosses.ensureDayBoss();
    await h.bosses.addQuickTask('Call the bank');
    await pumpApp(tester, h, tall: true);

    final headers = tester.widgetList<TaskGroupHeader>(
      find.byType(TaskGroupHeader),
    );
    expect(headers.first.label, 'The Day');

    await tester.tap(find.text('THE DAY'));
    await settle(tester);
    expect(find.byType(DayPanel), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('The Day leads the chips: first chip', (tester) async {
    final h = Harness();
    await h.seed();
    await h.bosses.ensureDayBoss();
    await pumpApp(tester, h, tall: true);
    expect(
      tester.getTopLeft(find.text('The Day').first).dx,
      lessThan(tester.getTopLeft(find.text('The Certification').first).dx),
    );
    await tearDownApp(tester, h);
  });

  testWidgets('the bonfire card waits for evening or a cleared day', (
    tester,
  ) async {
    final h = Harness();
    await h.seed();
    h.clock.now = DateTime(2026, 10, 13, 10);
    await pumpApp(tester, h, tall: true);
    expect(find.text('Rest at the bonfire'), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('in the evening the bonfire card opens the bonfire, with back', (
    tester,
  ) async {
    final h = Harness();
    await h.seed();
    h.clock.now = DateTime(2026, 10, 13, 19);
    await pumpApp(tester, h, tall: true);
    await tester.tap(find.text('Rest at the bonfire'));
    await settle(tester);
    expect(find.text('BONFIRE'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Back'));
    await settle(tester);
    expect(find.text('Today’s tasks'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('tasks come before the week streak, so they sit high', (
    tester,
  ) async {
    final h = Harness();
    await h.seed();
    await pumpApp(tester, h, tall: true);
    await tester.scrollUntilVisible(
      find.byType(WeekStreakCard),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView).first,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(
      tester.getTopLeft(find.byType(WeekStreakCard)).dy,
      greaterThan(tester.getTopLeft(find.text('Walk')).dy),
    );
    await tearDownApp(tester, h);
  });
}
