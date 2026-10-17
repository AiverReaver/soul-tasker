import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/features/boss/boss_stage.dart';
import 'package:hearthrise/ui/pharloom_backdrop.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import 'pump.dart';

void main() {
  testWidgets('home shows the empty state', (tester) async {
    final h = Harness();
    await pumpApp(tester, h);

    expect(find.text('No boss stands before you.'), findsOneWidget);
    expect(find.text('Name a new boss'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('home lists active bosses and a waiting section', (tester) async {
    final h = Harness();
    final waiting = await h.seed();
    await h.bosses.setStatus(waiting.boss.id, BossStatus.waiting);
    await h.seed();
    await pumpApp(tester, h);

    expect(find.text('The Certification'), findsOneWidget);
    expect(find.text('WAITING (1)'), findsOneWidget);
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

  testWidgets('mark as tried shows the quiet line', (tester) async {
    final h = Harness();
    final view = await h.seed();
    await pumpApp(tester, h, location: '/boss/${view.boss.id}');

    await tester.tap(find.byTooltip('Actions for Read chapter 4'));
    await settle(tester);
    await tester.tap(find.text('Mark as tried'));
    await settle(tester);

    expect(find.text('You tried. That counts.'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('fallen round trip shows the new attempt line', (tester) async {
    final h = Harness();
    final view = await h.seed();
    await pumpApp(tester, h, location: '/boss/${view.boss.id}');
    expect(find.text('Attempt 1.'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('This attempt failed'), 200);
    await tester.tap(find.text('This attempt failed'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'Rushed the second phase.');
    await tester.tap(find.text('Rise'));
    await settle(tester);
    // The attempt line sits at the top; scroll back to it.
    await tester.scrollUntilVisible(find.textContaining('Attempt 2.'), -200);

    expect(
      find.text('Attempt 2. Last time: Rushed the second phase.'),
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
    await pumpApp(tester, h2);
    await tester.tap(find.text('Today'));
    await settle(tester);
    expect(find.text('Book the room'), findsOneWidget);
    expect(find.text('Walk · daily'), findsOneWidget);
    await tearDownApp(tester, h2);
  });
}
