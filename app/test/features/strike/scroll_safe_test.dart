import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/features/strike/hold_to_strike.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/harness.dart';
import '../../support/recording_haptics.dart';
import '../pump.dart';

const _frame = Duration(milliseconds: 16);
const _dragPastSlop = Offset(0, -40);

Future<void> _holdFor(WidgetTester tester, Duration duration) async {
  var elapsed = Duration.zero;
  while (elapsed < duration) {
    await tester.pump(_frame);
    elapsed += _frame;
  }
}

double _scrolled(WidgetTester tester) => tester
    .state<ScrollableState>(find.byType(Scrollable).first)
    .position
    .pixels;

/// The ember fill of the row titled [title]: 0 empty, 1 full.
double _fill(WidgetTester tester, String title) {
  final row = find.ancestor(
    of: find.text(title),
    matching: find.byType(HoldToStrike),
  );
  final fill = find.descendant(
    of: row,
    matching: find.byType(FractionallySizedBox),
  );
  return tester.widget<FractionallySizedBox>(fill).widthFactor!;
}

void main() {
  testWidgets('a lone list: dragging while holding scrolls and never strikes', (
    tester,
  ) async {
    final strikes = <int>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [RecordingHaptics().asOverride],
        child: MaterialApp(
          theme: buildTheme(),
          home: Scaffold(
            body: ListView(
              children: [
                for (var i = 0; i < 20; i++)
                  HoldToStrike(
                    title: 'Task $i',
                    weight: Weight.heavy,
                    isDone: false,
                    onStrike: () => strikes.add(i),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Task 2')),
    );
    await tester.pump();
    await gesture.moveBy(_dragPastSlop);
    await _holdFor(tester, Weight.heavy.holdDuration * 2);
    await gesture.up();
    await tester.pumpAndSettle();

    expect(strikes, isEmpty);
    expect(_scrolled(tester), greaterThan(0));
    expect(_fill(tester, 'Task 2'), 0);
  });

  testWidgets('a lone list: pressing without moving still strikes', (
    tester,
  ) async {
    final strikes = <int>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [RecordingHaptics().asOverride],
        child: MaterialApp(
          theme: buildTheme(),
          home: Scaffold(
            body: ListView(
              children: [
                for (var i = 0; i < 20; i++)
                  HoldToStrike(
                    title: 'Task $i',
                    weight: Weight.heavy,
                    isDone: false,
                    onStrike: () => strikes.add(i),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Task 2')),
    );
    await tester.pump();
    await _holdFor(tester, Weight.heavy.holdDuration + _frame * 2);
    await gesture.up();
    await tester.pumpAndSettle();

    expect(strikes, [2]);
  });

  testWidgets('through Today: dragging while holding scrolls and never '
      'strikes', (tester) async {
    final h = Harness();
    await h.bosses.saveBoss(
      BossDraft(
        title: 'The Long List',
        resetOnFail: ResetOnFail.nothing,
        phases: [
          PhaseDraft(
            name: 'All of it',
            tasks: [for (var i = 0; i < 20; i++) TaskDraft(title: 'Chore $i')],
          ),
        ],
      ),
    );
    await pumpApp(tester, h);
    await tester.tap(find.text('Today'));
    await settle(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Chore 2')),
    );
    await tester.pump();
    await gesture.moveBy(_dragPastSlop);
    await _holdFor(tester, Weight.heavy.holdDuration * 2);
    await gesture.up();
    await settle(tester);

    expect(await h.db.select(h.db.attempts).get(), isEmpty);
    expect(_scrolled(tester), greaterThan(0));
    await tearDownApp(tester, h);
  });
}
