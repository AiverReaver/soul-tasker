import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/plan_pick_dao.dart';
import 'package:hearthrise/ui/plan_banner.dart';

import '../data/harness.dart';
import 'pump.dart';

void main() {
  testWidgets('Today shows the planned three first on the picked day', (
    tester,
  ) async {
    final h = Harness();
    final view = await h.seed();
    await PlanPickDao(
      h.db,
      h.bosses,
      h.clock.call,
    ).setPicks('2026-10-13', [taskNamed(view, 'Read chapter 4').task.id]);
    await pumpApp(tester, h);
    await tester.tap(find.text('Today'));
    await settle(tester);

    expect(find.byType(PlanBanner), findsOneWidget);
    expect(find.text("TODAY'S THREE"), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('Today hides the block when nothing is planned', (tester) async {
    final h = Harness();
    await h.seed();
    await pumpApp(tester, h);
    await tester.tap(find.text('Today'));
    await settle(tester);

    expect(find.byType(PlanBanner), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('picks for another day do not show', (tester) async {
    final h = Harness();
    final view = await h.seed();
    await PlanPickDao(
      h.db,
      h.bosses,
      h.clock.call,
    ).setPicks('2026-10-14', [taskNamed(view, 'Walk').task.id]);
    await pumpApp(tester, h);
    await tester.tap(find.text('Today'));
    await settle(tester);

    expect(find.byType(PlanBanner), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('rows are grouped by boss and chapter with "n of m"', (
    tester,
  ) async {
    final h = Harness();
    final view = await h.seed();
    await h.attempts.strike(taskNamed(view, 'Walk').task.id);
    await pumpApp(tester, h);
    await tester.tap(find.text('Today'));
    await settle(tester);

    // One label per run: dailies, the current chapter, the rest.
    expect(find.text('THE CERTIFICATION · DAILY'), findsOneWidget);
    expect(find.text('1 of 1'), findsOneWidget);
    expect(find.text('THE CERTIFICATION · CHAPTER I · LEARN'), findsOneWidget);
    expect(find.text('0 of 2'), findsOneWidget);
    await tearDownApp(tester, h);
  });
}
