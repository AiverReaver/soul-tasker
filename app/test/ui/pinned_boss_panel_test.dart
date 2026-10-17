import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/boss_art.dart';
import 'package:hearthrise/ui/needle_frame.dart';
import 'package:hearthrise/ui/pinned_boss_panel.dart';
import 'package:hearthrise/ui/shard_meter.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('a featured panel: deep edge, art, shard meter, enter button', (
    tester,
  ) async {
    var enters = 0, longs = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(
          body: PinnedBossPanel(
            title: 'The Certification',
            subtitle: 'Attempt 2 · Phase 1 of 3',
            health: 0.5,
            onEnter: () => enters++,
            onLongPress: () => longs++,
          ),
        ),
      ),
    );
    expect(find.text('The Certification'), findsOneWidget);
    expect(find.text('Attempt 2 · Phase 1 of 3'), findsOneWidget);
    expect(find.byType(BossArt), findsOneWidget);
    expect(find.byKey(const ValueKey('shard-on')), findsNWidgets(6));
    expect(
      tester.widget<NeedleFrame>(find.byType(NeedleFrame).first).edge,
      Biome.pharloom.palette.deep,
    );
    await tester.tap(find.text('Enter the fight'));
    expect(enters, 1);
    await tester.longPress(find.text('The Certification'));
    expect(longs, 1);
  });

  test('shards lit round health to twelfths', () {
    expect(shardsFor(1), ShardMeter.count);
    expect(shardsFor(0), 0);
    expect(shardsFor(0.04), 0);
    expect(shardsFor(0.5), 6);
  });
}
