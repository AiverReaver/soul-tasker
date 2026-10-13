import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/boss_card_tile.dart';
import 'package:hearthrise/ui/boss_health_bar.dart';
import 'package:hearthrise/ui/confirm_dialog.dart';
import 'package:hearthrise/ui/flash_line.dart';
import 'package:hearthrise/ui/strike_sweep_view.dart';
import 'package:hearthrise/ui/task_row_tile.dart';
import 'package:material_ui/material_ui.dart';

// Pumped without a ProviderScope or router: ui widgets need neither.
Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: buildTheme(),
    home: Scaffold(body: child),
  ),
);

void main() {
  testWidgets('FlashLine shows its message', (tester) async {
    await _pump(tester, const FlashLine('It is done.'));
    expect(find.text('It is done.'), findsOneWidget);
  });

  testWidgets('BossHealthBar speaks health and draws one segment each', (
    tester,
  ) async {
    await _pump(
      tester,
      const BossHealthBar(
        groups: [
          [true, false],
          [true],
        ],
        health: 2 / 3,
      ),
    );
    expect(find.bySemanticsLabel('Boss health 67 percent'), findsOneWidget);
    expect(find.byType(FractionallySizedBox), findsNWidgets(3));
  });

  testWidgets('TaskRowTile shows title, weight, sweep and trailing', (
    tester,
  ) async {
    await _pump(
      tester,
      const TaskRowTile(
        title: 'Slay',
        weightLabel: 'Heavy',
        isDone: false,
        progress: 0.5,
        sweep: SizedBox(key: ValueKey('sw')),
        trailing: Text('menu'),
      ),
    );
    expect(find.text('Slay'), findsOneWidget);
    expect(find.text('Heavy'), findsOneWidget);
    expect(find.text('menu'), findsOneWidget);
    expect(find.byKey(const ValueKey('sw')), findsOneWidget);
  });

  testWidgets('TaskRowTile dims a done row to 0.35', (tester) async {
    await _pump(
      tester,
      const TaskRowTile(
        title: 'Done',
        weightLabel: 'Light',
        isDone: true,
        progress: 0,
      ),
    );
    await tester.pumpAndSettle();
    final opacity = tester.widget<AnimatedOpacity>(
      find.byType(AnimatedOpacity),
    );
    expect(opacity.opacity, 0.35);
  });

  testWidgets('StrikeSweepView is wider for boss tier', (tester) async {
    Future<double> width(bool isBoss) async {
      await _pump(tester, StrikeSweepView(progress: 0.5, isBossTier: isBoss));
      return tester.getSize(find.byType(SizedBox).last).width;
    }

    expect(await width(true), greaterThan(await width(false)));
  });

  testWidgets('BossCardTile shows values and fires callbacks', (tester) async {
    var taps = 0, longs = 0;
    await _pump(
      tester,
      BossCardTile(
        title: 'Gwyn',
        attemptNumber: 2,
        progressLabel: 'Phase 1 of 2',
        health: 1,
        isPinned: true,
        healthGroups: const [
          [true],
        ],
        onTap: () => taps++,
        onLongPress: () => longs++,
      ),
    );
    expect(find.text('Gwyn'), findsOneWidget);
    expect(find.text('Attempt 2 · Phase 1 of 2'), findsOneWidget);
    expect(find.text('Pinned'), findsOneWidget);
    expect(find.byType(BossHealthBar), findsOneWidget);
    await tester.tap(find.text('Gwyn'));
    await tester.longPress(find.text('Gwyn'));
    expect([taps, longs], [1, 1]);
  });

  testWidgets('BossCardTile hides the bar without groups', (tester) async {
    await _pump(
      tester,
      BossCardTile(
        title: 'Daily',
        attemptNumber: 1,
        progressLabel: 'Daily foes',
        health: 0,
        isPinned: false,
        onTap: () {},
        onLongPress: () {},
      ),
    );
    expect(find.byType(BossHealthBar), findsNothing);
  });

  testWidgets('ConfirmDialog pops true on action, false on Not yet', (
    tester,
  ) async {
    bool? result;
    await _pump(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await showDialog<bool>(
            context: context,
            builder: (_) =>
                const ConfirmDialog(question: 'Sure?', action: 'Yes'),
          ),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Sure?'), findsOneWidget);
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  test('lib/ui imports no data, providers or router', () {
    final banned = RegExp(
      r"^import '.*(/data/|flutter_riverpod|go_router|core/haptics|features/)",
      multiLine: true,
    );
    for (final f in Directory('lib/ui').listSync().whereType<File>()) {
      expect(
        banned.hasMatch(f.readAsStringSync()),
        isFalse,
        reason: '${f.path} breaks the stateless-ui rule',
      );
    }
  });
}
