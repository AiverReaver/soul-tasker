import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:flutter/widgets.dart';

import '../data/harness.dart';
import '../support/fake_sounds.dart';
import 'pump.dart';

Future<String> _oneTaskBoss(Harness h) => h.bosses.saveBoss(
  const BossDraft(
    title: 'The Certification',
    resetOnFail: ResetOnFail.nothing,
    phases: [
      PhaseDraft(
        name: 'Fight',
        tasks: [TaskDraft(title: 'Sit the exam')],
      ),
    ],
  ),
);

void main() {
  for (final isOn in [true, false]) {
    final label = isOn ? 'on' : 'off';

    testWidgets('victory plays its tone only with sound $label', (
      tester,
    ) async {
      final player = FakeSoundPlayer();
      final h = Harness();
      final id = await _oneTaskBoss(h);
      await h.settings.setTapMode(true);
      await h.settings.setSound(isOn);
      await pumpApp(
        tester,
        h,
        location: '/boss/$id',
        overrides: [player.asOverride],
      );

      await tester.tap(find.text('Sit the exam'));
      await settle(tester);
      await tester.tap(find.text('Strike'));
      await settle(tester);
      await tester.tap(find.text('Defeated'));
      await settle(tester);

      expect(player.calls, isOn ? ['play:victory'] : isEmpty);
      await tearDownApp(tester, h);
    });

    testWidgets('the fallen screen plays the thud only with sound $label', (
      tester,
    ) async {
      final player = FakeSoundPlayer();
      final h = Harness();
      final id = await _oneTaskBoss(h);
      await h.settings.setSound(isOn);
      await pumpApp(
        tester,
        h,
        location: '/boss/$id',
        overrides: [player.asOverride],
      );

      await tester.scrollUntilVisible(find.text('This attempt failed'), 200);
      await tester.tap(find.text('This attempt failed'));
      await settle(tester);

      expect(player.calls, isOn ? ['play:fallen'] : isEmpty);
      await tearDownApp(tester, h);
    });
  }

  testWidgets('the bonfire hums while visible, and stops on leave', (
    tester,
  ) async {
    final player = FakeSoundPlayer();
    final h = Harness();
    await h.settings.setSound(true);
    await pumpApp(tester, h, overrides: [player.asOverride]);

    await tester.tap(find.text('Rest at the bonfire'));
    await settle(tester);
    expect(player.calls, ['hum:start']);

    await tester.pageBack();
    await settle(tester);
    expect(player.calls, ['hum:start', 'hum:stop']);
    await tearDownApp(tester, h);
  });

  testWidgets('the hum stops in the background and resumes', (tester) async {
    final player = FakeSoundPlayer();
    final h = Harness();
    await h.settings.setSound(true);
    await pumpApp(tester, h, overrides: [player.asOverride]);
    await tester.tap(find.text('Rest at the bonfire'));
    await settle(tester);
    expect(player.calls, ['hum:start']);

    // The real order the platform walks through when the screen goes off.
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pump();
    expect(player.calls.first, 'hum:start');
    expect(player.calls.last, 'hum:stop');

    player.calls.clear();
    for (final state in [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pump();
    expect(player.calls.last, 'hum:start');
    await tearDownApp(tester, h);
  });

  testWidgets('with sound off the bonfire is silent', (tester) async {
    final player = FakeSoundPlayer();
    final h = Harness();
    await pumpApp(
      tester,
      h,
      location: '/bonfire',
      overrides: [player.asOverride],
    );
    expect(player.calls, isEmpty);
    await tearDownApp(tester, h);
  });
}
