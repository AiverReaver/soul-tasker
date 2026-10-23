import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/ui/filter_chips.dart';
import 'package:hearthrise/ui/needle_frame.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import 'pump.dart';

void main() {
  testWidgets('a struck task stays on Home for its animation, then goes', (
    tester,
  ) async {
    final h = Harness();
    final view = await h.seed();
    await pumpApp(tester, h, tall: true);
    expect(find.text('Read chapter 4'), findsOneWidget);
    await h.attempts.strike(taskNamed(view, 'Read chapter 4').task.id);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Read chapter 4'), findsOneWidget);
    expect(find.byKey(const ValueKey('row-check')), findsWidgets);
    await tester.pump(const Duration(seconds: 2));
    await settle(tester);
    expect(find.text('Read chapter 4'), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('Home filter chips line up with the 20 px page margin', (
    tester,
  ) async {
    final h = Harness();
    await h.seed();
    await h.bosses.saveBoss(
      const BossDraft(
        title: 'The Habit',
        resetOnFail: ResetOnFail.nothing,
        phases: [],
        standalone: [TaskDraft(title: 'Stretch', recurrence: Recurrence.daily)],
      ),
    );
    await pumpApp(tester, h, tall: true);
    final all = find.descendant(
      of: find.byType(FilterChips<String>),
      matching: find.byType(NeedleFrame),
    );
    expect(tester.getTopLeft(all.first).dx, 20);
    await tearDownApp(tester, h);
  });
}
