import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/boss_art.dart';
import 'package:hearthrise/ui/needle_frame.dart';
import 'package:hearthrise/ui/pinned_boss_panel.dart';
import 'package:hearthrise/ui/shard_meter.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    VoidCallback? onEnter,
    VoidCallback? onLongPress,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: buildTheme(),
      home: Scaffold(
        body: PinnedBossPanel(
          label: 'Boss · Chapter I of III',
          title: 'The Certification',
          subtitle: 'Attempt 2 · 9 days left',
          health: 0.5,
          design: BossDesign.matron,
          onEnter: onEnter ?? () {},
          onLongPress: onLongPress ?? () {},
        ),
      ),
    ),
  );

  testWidgets('a featured card: label, name, line, art and shards', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('BOSS · CHAPTER I OF III'), findsOneWidget);
    expect(find.text('The Certification'), findsOneWidget);
    expect(find.text('Attempt 2 · 9 days left'), findsOneWidget);
    final art = tester.widget<BossArt>(find.byType(BossArt));
    expect(art.design, BossDesign.matron);
    expect(art.width, 92);
    expect(find.byKey(const ValueKey('shard-on')), findsNWidgets(6));
    expect(
      tester.widget<NeedleFrame>(find.byType(NeedleFrame).first).edge,
      Biome.pharloom.palette.deep,
    );
  });

  testWidgets('the art sits beside the name, never over it', (tester) async {
    await pump(tester);
    expect(
      tester.getTopRight(find.text('The Certification')).dx,
      lessThanOrEqualTo(tester.getTopLeft(find.byType(BossArt)).dx),
    );
  });

  testWidgets('the whole card opens the fight; there is no extra button', (
    tester,
  ) async {
    var enters = 0, longs = 0;
    await pump(tester, onEnter: () => enters++, onLongPress: () => longs++);
    expect(find.text('Enter the fight'), findsNothing);
    expect(find.text('Boss health'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('shard-on')).first);
    expect(enters, 1);
    await tester.tap(find.text('The Certification'));
    expect(enters, 2);
    await tester.longPress(find.text('The Certification'));
    expect(longs, 1);
  });

  testWidgets('it speaks as a button that names the boss', (tester) async {
    await pump(tester);
    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp('Enter the fight'))),
      matchesSemantics(
        label:
            'Enter the fight: The Certification. Attempt 2 · 9 days left. '
            'Boss health 6 of 12',
        isButton: true,
        hasTapAction: true,
        hasLongPressAction: true,
      ),
    );
  });

  test('shards lit round health to twelfths', () {
    expect(shardsFor(1), ShardMeter.count);
    expect(shardsFor(0), 0);
    expect(shardsFor(0.04), 0);
    expect(shardsFor(0.5), 6);
  });
}
