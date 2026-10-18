import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/profile_dao.dart';
import 'package:hearthrise/features/boss_edit/boss_edit_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/harness.dart';
import '../../support/boss_actions.dart';
import '../pump.dart';

void main() {
  late Harness h;
  late String id;
  setUp(() async {
    h = Harness();
    id = (await h.seed()).boss.id;
  });

  testWidgets('the header has back, the phase and the ⋯ actions', (
    tester,
  ) async {
    await pumpApp(tester, h, location: '/boss/$id', tall: true);
    expect(find.bySemanticsLabel('Back'), findsOneWidget);
    expect(find.text('Phase I of II'), findsOneWidget);
    expect(find.bySemanticsLabel('Boss actions'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('the panel: name, attempt, health as N / 12', (tester) async {
    await pumpApp(tester, h, location: '/boss/$id', tall: true);
    expect(find.text('The Certification'), findsOneWidget);
    expect(
      find.textContaining('Attempt 1', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Boss health'), findsOneWidget);
    expect(find.text('12 / 12'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('the attempt line shows days left and the last lesson in '
      'italic serif', (tester) async {
    final view = await h.reload(id);
    await h.bosses.saveBoss(
      BossDraft.fromView(view)
          .copyWith(targetDate: h.clock().add(const Duration(days: 9))),
    );
    await h.attempts.fall(id, 'Started too late.');
    await pumpApp(tester, h, location: '/boss/$id', tall: true);
    expect(
      find.textContaining(
        'Attempt 2 · 9 days left · Last lesson: Started too late.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    await tearDownApp(tester, h);
  });

  testWidgets('the current phase is a heading with its struck count', (
    tester,
  ) async {
    await pumpApp(tester, h, location: '/boss/$id', tall: true);
    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('0 of 3 struck · hold to strike'), findsOneWidget);
    await h.attempts.strike(
      (await h.reload(id)).phases.first.tasks.first.task.id,
    );
    await settle(tester);
    expect(find.text('1 of 3 struck · hold to strike'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('the hint, then the boss kneels when the phase is done', (
    tester,
  ) async {
    await pumpApp(tester, h, location: '/boss/$id', tall: true);
    expect(
      find.text('Each strike takes shards from the Certification.'),
      findsOneWidget,
    );
    final view = await h.reload(id);
    for (final t in view.phases.first.tasks.where((t) => !t.isDaily)) {
      await h.attempts.strike(t.task.id);
    }
    await settle(tester);
    expect(
      find.text('The Certification kneels. Phase II awaits.'),
      findsOneWidget,
    );
    await tearDownApp(tester, h);
  });

  testWidgets('⋯ opens the actions sheet with every row', (tester) async {
    await pumpApp(tester, h, location: '/boss/$id', tall: true);
    await tester.tap(find.bySemanticsLabel('Boss actions'));
    await settle(tester);
    for (final label in [
      'Leave for now',
      'Edit',
      'Pin',
      'Declare victory',
      'This attempt failed',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    await tearDownApp(tester, h);
  });

  testWidgets('Edit opens the editor', (tester) async {
    await pumpApp(tester, h, location: '/boss/$id', tall: true);
    await tapBossAction(tester, 'Edit');
    expect(find.byType(BossEditScreen), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('Pin toggles the pin, and the row then reads Unpin', (
    tester,
  ) async {
    await pumpApp(tester, h, location: '/boss/$id', tall: true);
    await tapBossAction(tester, 'Pin');
    expect((await h.reload(id)).boss.isPinned, isTrue);
    await tester.tap(find.bySemanticsLabel('Boss actions'));
    await settle(tester);
    expect(find.text('Unpin'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('Leave for now asks first, with the boss and the embers kept', (
    tester,
  ) async {
    await h.attempts.strike(
      (await h.reload(id)).phases.first.tasks.first.task.id,
    );
    await pumpApp(tester, h, location: '/boss/$id', tall: true);
    await tapBossAction(tester, 'Leave for now');
    final kept = (await ProfileDao(h.db, h.clock.call).read()).banked;
    expect(find.text('Leave the fight?'), findsOneWidget);
    expect(find.text('THE CERTIFICATION'), findsOneWidget);
    expect(
      find.textContaining('Struck foes stay struck and you keep $kept embers.'),
      findsOneWidget,
    );
    expect((await h.reload(id)).boss.status, BossStatus.active);
    await tearDownApp(tester, h);
  });

  testWidgets('Keep fighting closes the alert and changes nothing', (
    tester,
  ) async {
    await pumpApp(tester, h, location: '/boss/$id', tall: true);
    await tapBossAction(tester, 'Leave for now');
    await tester.tap(find.text('Keep fighting'));
    await settle(tester);
    expect(find.text('Leave the fight?'), findsNothing);
    expect((await h.reload(id)).boss.status, BossStatus.active);
    expect(find.text('Phase I of II'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('confirming Leave for now sets waiting and returns Home', (
    tester,
  ) async {
    await pumpApp(tester, h, tall: true);
    await tester.tap(find.text('All bosses · 1 active'));
    await settle(tester);
    await tester.tap(find.text('The Certification'));
    await settle(tester);
    await tapBossAction(tester, 'Leave for now');
    await tester.tap(find.text('Leave for now').last);
    await settle(tester);
    expect((await h.reload(id)).boss.status, BossStatus.waiting);
    expect(find.byKey(const ValueKey('home-header')), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('the back circle goes back, or Home with nothing behind', (
    tester,
  ) async {
    await pumpApp(tester, h, location: '/boss/$id', tall: true);
    await tester.tap(find.bySemanticsLabel('Back'));
    await settle(tester);
    expect(find.byKey(const ValueKey('home-header')), findsOneWidget);
    await tearDownApp(tester, h);
  });
}
