import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import '../support/recording_haptics.dart';
import 'pump.dart';
import '../support/hold_finders.dart';

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

Future<void> _strikeAndConfirm(WidgetTester tester) async {
  await tester.tap(holdButton('Sit the exam'));
  await settle(tester);
  await tester.tap(find.text('Strike'));
  await settle(tester);
  await tester.tap(find.text('Defeated'));
  await settle(tester);
}

void main() {
  testWidgets('draining the last segment and confirming opens victory', (
    tester,
  ) async {
    final h = Harness();
    final id = await _oneTaskBoss(h);
    await h.settings.setTapMode(true);
    await pumpApp(tester, h, location: '/boss/$id');

    await _strikeAndConfirm(tester);

    expect(find.text('The Certification falls.'), findsOneWidget);
    expect(find.text('A relic remains.'), findsOneWidget);
    expect(await h.db.select(h.db.relics).get(), hasLength(1));
    await tearDownApp(tester, h);
  });

  testWidgets('Declare victory from the menu opens victory too', (
    tester,
  ) async {
    final h = Harness();
    final id = await _oneTaskBoss(h);
    await pumpApp(tester, h, location: '/boss/$id');

    await tester.tap(find.byTooltip('Boss actions'));
    await settle(tester);
    await tester.tap(find.text('Declare victory'));
    await settle(tester);
    await tester.tap(find.text('Defeated'));
    await settle(tester);

    expect(find.text('The Certification falls.'), findsOneWidget);
    expect(find.text('A relic remains.'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('Keep as a relic saves, goes home and opens the relic', (
    tester,
  ) async {
    final h = Harness();
    final id = await _oneTaskBoss(h);
    await h.settings.setTapMode(true);
    await pumpApp(tester, h, location: '/boss/$id');

    await _strikeAndConfirm(tester);
    await tester.ensureVisible(find.text('Keep as a relic'));
    await tester.tap(find.text('Keep as a relic'));
    await settle(tester);

    expect(find.text('Relic of The Certification'), findsWidgets);
    expect(find.text('The Certification falls.'), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('declining the confirm leaves the boss active, no relic', (
    tester,
  ) async {
    final h = Harness();
    final id = await _oneTaskBoss(h);
    await h.settings.setTapMode(true);
    await pumpApp(tester, h, location: '/boss/$id');

    await tester.tap(holdButton('Sit the exam'));
    await settle(tester);
    await tester.tap(find.text('Strike'));
    await settle(tester);
    await tester.tap(find.text('Not yet'));
    await settle(tester);

    expect(find.text('A relic remains.'), findsNothing);
    expect((await h.reload(id)).boss.status, BossStatus.active);
    expect(await h.db.select(h.db.relics).get(), isEmpty);
    await tearDownApp(tester, h);
  });

  testWidgets('shows the numbers, lessons in order, relic and its name', (
    tester,
  ) async {
    final h = Harness();
    final id = await _oneTaskBoss(h);
    await h.attempts.fall(id, 'Started too late.');
    await h.attempts.fall(id, 'Skipped the warm-up.');
    await h.settings.setTapMode(true);
    await pumpApp(tester, h, location: '/boss/$id');

    await _strikeAndConfirm(tester);

    expect(
      tester.widget<Text>(find.byKey(const ValueKey('victory-attempts'))).data,
      '3',
    );
    expect(find.text('attempts'), findsOneWidget);
    expect(find.text('1 day'), findsOneWidget);
    expect(find.text('3 embers of effort'), findsOneWidget);
    final first = find.textContaining('Attempt 1. Started too late.');
    final second = find.textContaining('Attempt 2. Skipped the warm-up.');
    expect(first, findsOneWidget);
    expect(tester.getTopLeft(first).dy, lessThan(tester.getTopLeft(second).dy));
    expect(find.bySemanticsLabel('A worn emblem'), findsOneWidget);
    expect(find.text('Relic of The Certification'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('Return to the hearth saves the inscription and returns home', (
    tester,
  ) async {
    final h = Harness();
    final id = await _oneTaskBoss(h);
    await h.settings.setTapMode(true);
    await pumpApp(tester, h, location: '/boss/$id');
    await _strikeAndConfirm(tester);

    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Patience.');
    await tester.ensureVisible(find.text('Return to the hearth'));
    await tester.tap(find.text('Return to the hearth'));
    await settle(tester);

    final relic = (await h.db.select(h.db.relics).get()).single;
    expect(relic.inscription, 'Patience.');
    expect(find.text('A relic remains.'), findsNothing);
    expect(find.text('HEARTHRISE'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('back saves the inscription too', (tester) async {
    final h = Harness();
    final id = await _oneTaskBoss(h);
    await h.settings.setTapMode(true);
    await pumpApp(tester, h, location: '/boss/$id');
    await _strikeAndConfirm(tester);

    await tester.enterText(find.byType(TextField), 'Still here.');
    await tester.binding.handlePopRoute();
    await settle(tester);

    expect(
      (await h.db.select(h.db.relics).get()).single.inscription,
      'Still here.',
    );
    expect(find.text('HEARTHRISE'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('the victory haptic fires once', (tester) async {
    final haptics = RecordingHaptics();
    final h = Harness();
    final id = await _oneTaskBoss(h);
    await h.settings.setTapMode(true);
    await pumpApp(
      tester,
      h,
      location: '/boss/$id',
      overrides: [haptics.asOverride],
    );
    await _strikeAndConfirm(tester);

    expect(haptics.events.where((e) => e == 'doubleHeavy'), hasLength(1));
    await tearDownApp(tester, h);
  });

  testWidgets('no victory haptic with haptics off', (tester) async {
    final sent = recordPlatformHaptics();
    final h = Harness();
    final id = await _oneTaskBoss(h);
    await h.settings.setTapMode(true);
    await h.settings.setHaptics(false);
    await pumpApp(tester, h, location: '/boss/$id');
    await _strikeAndConfirm(tester);

    expect(find.text('A relic remains.'), findsOneWidget);
    expect(sent, isEmpty);
    await tearDownApp(tester, h);
  });

  testWidgets('the defeated boss is gone from Home and Today', (tester) async {
    final h = Harness();
    final id = await _oneTaskBoss(h);
    await h.settings.setTapMode(true);
    await pumpApp(tester, h, location: '/boss/$id');
    await _strikeAndConfirm(tester);
    await tester.ensureVisible(find.text('Return to the hearth'));
    await tester.tap(find.text('Return to the hearth'));
    await settle(tester);

    expect(find.text('The Certification'), findsNothing);
    expect(find.text('VANQUISHED (1)'), findsNothing);
    expect(find.text('No boss stands before you.'), findsOneWidget);
    await tester.tap(find.text('Today'));
    await settle(tester);
    expect(find.text('Sit the exam'), findsNothing);
    await tearDownApp(tester, h);
  });
}
