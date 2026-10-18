import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/features/boss_edit/boss_edit_screen.dart';
import 'package:hearthrise/features/boss/boss_stage.dart';
import 'package:hearthrise/ui/pharloom_backdrop.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import '../support/boss_actions.dart';
import '../support/foe_actions.dart';
import 'pump.dart';

void main() {
  testWidgets('the bosses list shows the empty state', (tester) async {
    final h = Harness();
    await pumpApp(tester, h, location: '/bosses', tall: true);

    expect(find.text('No boss stands before you.'), findsOneWidget);
    expect(find.text('Name a new boss'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('the pinned boss comes first, then the other active ones', (
    tester,
  ) async {
    final h = Harness();
    final other = await h.seed();
    final pinned = await h.seed();
    await h.bosses.setPinned(pinned.boss.id, isPinned: true);
    await h.bosses.saveBoss(
      const BossDraft(
        title: 'The Habit',
        resetOnFail: ResetOnFail.nothing,
        phases: [],
        standalone: [TaskDraft(title: 'Walk', recurrence: Recurrence.daily)],
      ),
    );
    await pumpApp(tester, h, location: '/bosses', tall: true);

    final pinnedY = tester.getTopLeft(
      find.byKey(const Key('pinned-boss-panel')),
    );
    expect(
      tester.getTopLeft(find.text('The Habit')).dy,
      greaterThan(pinnedY.dy),
    );
    expect(other.boss.id, isNot(pinned.boss.id));
    await tearDownApp(tester, h);
  });

  testWidgets('Name a new boss opens the editor', (tester) async {
    final h = Harness();
    await h.seed();
    await pumpApp(tester, h, location: '/bosses', tall: true);
    await tester.tap(find.text('Name a new boss'));
    await settle(tester);
    expect(find.byType(BossEditScreen), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('Waiting (n) is collapsed until you open it', (tester) async {
    final h = Harness();
    final waiting = await h.seed();
    await h.bosses.setStatus(waiting.boss.id, BossStatus.waiting);
    await h.bosses.saveBoss(
      const BossDraft(
        title: 'The Habit',
        resetOnFail: ResetOnFail.nothing,
        phases: [],
        standalone: [TaskDraft(title: 'Walk', recurrence: Recurrence.daily)],
      ),
    );
    await pumpApp(tester, h, location: '/bosses', tall: true);

    expect(find.text('Waiting (1)'), findsOneWidget);
    expect(find.text('The Certification'), findsNothing);
    await tester.tap(find.text('Waiting (1)'));
    await settle(tester);
    expect(find.text('The Certification'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('the back circle leaves the list', (tester) async {
    final h = Harness();
    await h.seed();
    await pumpApp(tester, h, tall: true);
    await tester.tap(find.text('All bosses · 1 active'));
    await settle(tester);
    await tester.tap(find.bySemanticsLabel('Back'));
    await settle(tester);
    expect(find.text('All bosses · 1 active'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('screens sit on the Pharloom night; a boss stands on its page', (
    tester,
  ) async {
    final h = Harness();
    final view = await h.seed();
    await pumpApp(tester, h, location: '/boss/${view.boss.id}');

    expect(find.byType(PharloomBackdrop), findsOneWidget);
    expect(find.byType(BossStage), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('a boss page names its phase in roman numerals', (tester) async {
    final h = Harness();
    final view = await h.seed();
    await pumpApp(tester, h, location: '/boss/${view.boss.id}');

    expect(find.text('Phase I of II'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('mark as tried shows the quiet line', (tester) async {
    final h = Harness();
    final view = await h.seed();
    await pumpApp(tester, h, location: '/boss/${view.boss.id}', tall: true);

    await tapFoeAction(tester, 'Read chapter 4', 'Mark as tried');

    expect(find.text('You tried. That counts.'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('fallen round trip shows the new attempt line', (tester) async {
    final h = Harness();
    final view = await h.seed();
    await pumpApp(tester, h, location: '/boss/${view.boss.id}');
    expect(find.textContaining('Attempt 1'), findsOneWidget);

    await tapBossAction(tester, 'This attempt failed');
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'Rushed the second phase.');
    await tester.tap(find.text('Rise'));
    await settle(tester);

    expect(
      find.textContaining(
        'Attempt 2 · Last lesson: Rushed the second phase.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    await tearDownApp(tester, h);
  });

  testWidgets('a standalone task added in the editor is saved, and standalone '
      'tasks show in Today', (tester) async {
    final h = Harness();
    final view = await h.seed();
    await pumpApp(tester, h, location: '/boss/${view.boss.id}/edit');

    final addStandalone = find.byKey(const ValueKey('add-standalone-task'));
    await tester.scrollUntilVisible(
      addStandalone,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(addStandalone);
    await settle(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'What will you do?'),
      'Pack the bag',
    );
    await tester.pump();
    await tester.tap(find.text('Done'));
    await settle(tester);
    await tester.tap(find.text('Save'));
    await settle(tester);

    final saved = await h.reload(view.boss.id);
    expect(saved.standalone.map((t) => t.task.title), [
      'Book the room',
      'Pack the bag',
    ]);

    await tearDownApp(tester, h);
    final h2 = Harness();
    await h2.seed();
    await pumpApp(tester, h2, tall: true);
    await tester.tap(find.text('Today'));
    await settle(tester);
    expect(find.text('Book the room'), findsOneWidget);
    expect(find.text('Walk · daily'), findsOneWidget);
    await tearDownApp(tester, h2);
  });
}
