import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/boss_card_tile.dart';
import 'package:hearthrise/ui/shard_meter.dart';
import 'package:hearthrise/ui/confirm_dialog.dart';
import 'package:hearthrise/ui/flash_line.dart';
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
        showHealth: true,
        onTap: () => taps++,
        onLongPress: () => longs++,
      ),
    );
    expect(find.text('Gwyn'), findsOneWidget);
    expect(find.text('Attempt 2 · Phase 1 of 2'), findsOneWidget);
    expect(find.text('Pinned'), findsOneWidget);
    expect(find.byType(ShardMeter), findsOneWidget);
    await tester.tap(find.text('Gwyn'));
    await tester.longPress(find.text('Gwyn'));
    expect([taps, longs], [1, 1]);
  });

  testWidgets('BossCardTile draws its frame; pin mark only when pinned', (
    tester,
  ) async {
    Future<void> pump(bool pinned) => _pump(
      tester,
      BossCardTile(
        title: 'Gwyn',
        attemptNumber: 1,
        progressLabel: 'Phase 1 of 2',
        health: 1,
        isPinned: pinned,
        onTap: () {},
        onLongPress: () {},
      ),
    );
    await pump(true);
    expect(find.byKey(const Key('boss-card-frame')), findsOneWidget);
    expect(find.byKey(const Key('pin-mark')), findsOneWidget);
    await pump(false);
    expect(find.byKey(const Key('boss-card-frame')), findsOneWidget);
    expect(find.byKey(const Key('pin-mark')), findsNothing);
  });

  testWidgets('BossCardTile survives 200% text and keeps a 48dp target', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: BossCardTile(
              title: 'A very long boss name that must wrap',
              attemptNumber: 12,
              progressLabel: 'Phase 3 of 4',
              health: 0.5,
              isPinned: true,
              showHealth: true,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(BossCardTile)).height,
      greaterThanOrEqualTo(kMinTarget),
    );
  });

  testWidgets('BossCardTile hides the meter unless asked', (tester) async {
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
    expect(find.byType(ShardMeter), findsNothing);
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
