import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/database.dart' show Task;
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/ui/glass_action_row.dart';
import 'package:hearthrise/ui/ember_button.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/harness.dart';
import '../pump.dart';

void main() {
  late Harness h;
  late String id;
  setUp(() async {
    h = Harness();
    id = (await h.seed()).boss.id;
  });

  Future<void> open(WidgetTester tester) async {
    await pumpApp(tester, h, tall: true);
    await tester.tap(find.byKey(const ValueKey('new-foe')));
    await settle(tester);
  }

  Future<List<Task>> standalone() async =>
      (await h.reload(id)).standalone.map((t) => t.task).toList();

  testWidgets('the sheet: title, name field, real strengths, the boss', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('A new task'), findsOneWidget);
    expect(find.text('Name the task'), findsOneWidget);
    for (final w in Weight.values) {
      expect(find.text(w.label), findsOneWidget);
      expect(find.text('+${w.embers} embers'), findsOneWidget);
    }
    expect(find.text('Strikes at'), findsOneWidget);
    expect(find.text('The Certification'), findsWidgets);
    await tearDownApp(tester, h);
  });

  testWidgets('reference layout: eyebrow, stacked Strikes at, coral Add', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Today’s tasks'), findsWidgets);
    expect(find.widgetWithText(EmberButton, 'Add to today'), findsOneWidget);
    final label = tester.getRect(find.text('Strikes at'));
    final row = tester.getRect(find.text('The Certification').last);
    expect(row.top, greaterThan(label.bottom));
    await tearDownApp(tester, h);
  });

  testWidgets('Add to today saves the task to the boss and closes', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(find.byType(TextField), 'Call the bank');
    await tester.tap(find.text('Heavy'));
    await tester.tap(find.text('Add to today'));
    await settle(tester);

    final added = (await standalone()).firstWhere(
      (t) => t.title == 'Call the bank',
    );
    expect(added.weight, Weight.heavy);
    expect(find.text('A new task'), findsNothing);
    expect(find.text('Call the bank'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('with no name Add to today does nothing', (tester) async {
    await open(tester);
    final before = (await standalone()).length;
    await tester.tap(find.text('Add to today'));
    await settle(tester);
    expect(find.text('A new task'), findsOneWidget);
    expect((await standalone()).length, before);
    await tearDownApp(tester, h);
  });

  testWidgets('Cancel saves nothing', (tester) async {
    await open(tester);
    final before = (await standalone()).length;
    await tester.enterText(find.byType(TextField), 'Never saved');
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.text('A new task'), findsNothing);
    expect((await standalone()).length, before);
    await tearDownApp(tester, h);
  });

  testWidgets('Strikes at opens the boss picker and the pick is used', (
    tester,
  ) async {
    final other = await h.bosses.saveBoss(
      const BossDraft(
        title: 'The Habit',
        resetOnFail: ResetOnFail.nothing,
        phases: [],
        standalone: [TaskDraft(title: 'Walk', recurrence: Recurrence.daily)],
      ),
    );
    await open(tester);
    await tester.tap(find.text('Strikes at'));
    await settle(tester);
    final pick = find.widgetWithText(GlassActionRow, 'The Habit').last;
    expect(pick, findsOneWidget);
    await tester.tap(pick);
    await settle(tester);

    await tester.enterText(find.byType(TextField), 'Stretch');
    await tester.tap(find.text('Add to today'));
    await settle(tester);
    final titles = (await h.reload(other)).standalone.map((t) => t.task.title);
    expect(titles, contains('Stretch'));
    await tearDownApp(tester, h);
  });
}
