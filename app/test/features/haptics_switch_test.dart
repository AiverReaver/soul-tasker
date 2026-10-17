import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import '../support/recording_haptics.dart';
import 'pump.dart';

Future<String> _seedBossTier(Harness h) => h.bosses.saveBoss(
  const BossDraft(
    title: 'The Climb',
    resetOnFail: ResetOnFail.nothing,
    phases: [
      PhaseDraft(
        name: 'Up',
        tasks: [
          TaskDraft(title: 'Summit push', weight: Weight.bossTier),
          TaskDraft(title: 'Pack', weight: Weight.light),
        ],
      ),
    ],
  ),
);

void main() {
  testWidgets('the switch shows on by default and stores the choice', (
    tester,
  ) async {
    final h = Harness();
    await pumpApp(tester, h);

    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
    final tile = find.widgetWithText(SwitchListTile, 'Haptics');
    expect(tester.widget<SwitchListTile>(tile).value, isTrue);

    await tester.tap(tile);
    await settle(tester);

    // getSingle, not watch().first: a stream never emits under fake async.
    final stored = await h.db.select(h.db.userSettings).getSingle();
    expect(stored.haptics, isFalse);
    expect(tester.widget<SwitchListTile>(tile).value, isFalse);
    await tearDownApp(tester, h);
  });

  testWidgets('a strike sends the landing haptic with haptics on', (
    tester,
  ) async {
    final sent = recordPlatformHaptics();
    final h = Harness();
    final view = await h.seed();
    await h.settings.setTapMode(true);
    await pumpApp(tester, h, location: '/boss/${view.boss.id}');

    await tester.tap(find.text('Read chapter 4'));
    await settle(tester);

    expect(sent, ['HapticFeedbackType.heavyImpact']);
    await tearDownApp(tester, h);
  });

  testWidgets('a strike with haptics off sends nothing', (tester) async {
    final sent = recordPlatformHaptics();
    final h = Harness();
    final view = await h.seed();
    await h.settings.setTapMode(true);
    await h.settings.setHaptics(false);
    await pumpApp(tester, h, location: '/boss/${view.boss.id}');

    await tester.tap(find.text('Read chapter 4'));
    await settle(tester);
    await tester.tap(find.text('Strike'));
    await settle(tester);

    expect(sent, isEmpty);
    expect(await h.db.select(h.db.attempts).get(), hasLength(1));
    await tearDownApp(tester, h);
  });

  testWidgets('switching off mid-hold silences the rest of the hold (D10)', (
    tester,
  ) async {
    final sent = recordPlatformHaptics();
    final h = Harness();
    final bossId = await _seedBossTier(h);
    await pumpApp(tester, h, location: '/boss/$bossId');

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Summit push')),
    );
    await tester.pump();
    await tester.pump(Weight.bossTier.holdDuration * 0.5);
    expect(sent, isNotEmpty, reason: 'the hold was ticking before the switch');

    await h.settings.setHaptics(false);
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    final sentBeforeFlip = sent.length;
    await tester.pump(Weight.bossTier.holdDuration);
    await gesture.up();
    await settle(tester);
    await tester.tap(find.text('Strike'));
    await settle(tester);

    expect(sent, hasLength(sentBeforeFlip));
    expect(await h.db.select(h.db.attempts).get(), hasLength(1));
    await tearDownApp(tester, h);
  });
}
