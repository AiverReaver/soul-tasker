import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/day_boss.dart';
import 'package:hearthrise/features/boss/boss_stage.dart';
import 'package:hearthrise/ui/day_panel.dart';
import 'package:hearthrise/ui/glass_sheet.dart';

import '../../data/harness.dart';
import '../pump.dart';

void main() {
  testWidgets('The Day: its panel, today’s tasks and a quick add', (
    tester,
  ) async {
    final h = Harness();
    await h.bosses.ensureDayBoss();
    final bank = await h.bosses.addQuickTask('Call the bank');
    await h.bosses.addQuickTask('Water plants');
    await h.attempts.strike(bank);
    await pumpApp(tester, h, location: '/boss/$dayBossId', tall: true);

    expect(find.text('The default boss'), findsOneWidget);
    expect(find.byType(DayPanel), findsOneWidget);
    expect(find.text('1 / 2 open'), findsOneWidget);
    expect(find.byType(BossStage), findsNothing);
    expect(find.text('Today’s tasks'), findsOneWidget);
    expect(find.text('1 of 2 struck'), findsOneWidget);
    expect(find.textContaining('Call the bank'), findsOneWidget);
    expect(find.textContaining('Water plants'), findsOneWidget);
    expect(find.text('BEYOND THE CHAPTERS'), findsNothing);

    await tester.tap(find.text('Add a quick task'));
    await settle(tester);
    expect(find.byType(GlassSheet), findsOneWidget);
    expect(find.text('A new task'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('an empty Day says how to start and still offers the add', (
    tester,
  ) async {
    final h = Harness();
    await h.bosses.ensureDayBoss();
    await pumpApp(tester, h, location: '/boss/$dayBossId', tall: true);
    expect(
      find.text('Nothing here yet. Add a quick task and it fights here today.'),
      findsOneWidget,
    );
    expect(find.text('Today’s tasks'), findsNothing);
    expect(find.text('Add a quick task'), findsOneWidget);
    await tearDownApp(tester, h);
  });
}
