import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/deadlines.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/commitment_dao.dart';
import 'package:hearthrise/data/ember_dao.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import 'pump.dart';

/// A boss with one task, struck and defeated; returns the relic id.
Future<String> _relic(Harness h, String title, {int falls = 0}) async {
  final id = await h.bosses.saveBoss(
    BossDraft(
      title: title,
      resetOnFail: ResetOnFail.nothing,
      phases: const [
        PhaseDraft(
          name: 'Fight',
          tasks: [TaskDraft(title: 'The deed')],
        ),
      ],
    ),
  );
  for (var i = 0; i < falls; i++) {
    await h.attempts.fall(id, 'Lesson ${i + 1}.');
  }
  await h.attempts.strike((await h.reload(id)).allTasks.first.task.id);
  await h.bosses.setStatus(id, BossStatus.defeated);
  return (await h.relics.idForBoss(id))!;
}

void main() {
  testWidgets('the Home app bar opens the profile', (tester) async {
    final h = Harness();
    await pumpApp(tester, h);
    await tester.tap(find.byTooltip('Profile'));
    await settle(tester);
    expect(find.text('PROFILE'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('shows level, banked embers, flasks and accuracy', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final h = Harness();
    final view = await h.seed();
    final task = taskNamed(view, 'Read chapter 4').task;
    await CommitmentDao(
      h.db,
      h.clock.call,
    ).commit(task.id, DeadlinePreset.tonight);
    await h.attempts.strike(task.id); // heavy: 3 embers, promise kept
    await EmberDao(h.db, h.clock.call).bank();
    await pumpApp(tester, h, location: '/profile');

    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('7 embers to the next'), findsOneWidget);
    expect(find.text('3 embers banked'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Flasks 3 of 3')), findsOneWidget);
    expect(find.text('Today: 1 of 1 kept. This week: 1 of 1.'), findsOneWidget);
    semantics.dispose();
    await tearDownApp(tester, h);
  });

  testWidgets('no relics: the hall shows the empty line', (tester) async {
    final h = Harness();
    await pumpApp(tester, h, location: '/profile');
    expect(
      find.text('No foes vanquished yet. The first relic awaits.'),
      findsOneWidget,
    );
    await tearDownApp(tester, h);
  });

  testWidgets('two relics: the newer is first', (tester) async {
    final h = Harness();
    await _relic(h, 'Older');
    await _relic(h, 'Newer');
    await pumpApp(tester, h, location: '/profile');

    expect(
      tester.getTopLeft(find.text('Relic of Newer')).dy,
      lessThan(tester.getTopLeft(find.text('Relic of Older')).dy),
    );
    await tearDownApp(tester, h);
  });

  testWidgets('a relic opens with its numbers, lessons and its line', (
    tester,
  ) async {
    final h = Harness();
    await _relic(h, 'The Certification', falls: 2);
    await pumpApp(tester, h, location: '/profile');

    await tester.tap(find.text('Relic of The Certification'));
    await settle(tester);

    expect(find.text('3 attempts'), findsOneWidget);
    expect(find.text('3 attempts. Every one of them counted.'), findsOneWidget);
    expect(find.textContaining('Attempt 1. Lesson 1.'), findsOneWidget);
    expect(find.textContaining('Attempt 2. Lesson 2.'), findsOneWidget);
    expect(find.text('Relic of The Certification'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('one attempt reads "One attempt. It counted."', (tester) async {
    final h = Harness();
    final id = await _relic(h, 'Quick');
    await pumpApp(tester, h, location: '/relic/$id');
    expect(find.text('One attempt. It counted.'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('editing the inscription saves it; the detail updates', (
    tester,
  ) async {
    final h = Harness();
    final id = await _relic(h, 'The Certification');
    await pumpApp(tester, h, location: '/relic/$id');

    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Patience.');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await settle(tester);

    final stored = (await h.db.select(h.db.relics).get()).single;
    expect(stored.inscription, 'Patience.');
    expect(find.text('Patience.'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('a relic whose boss was deleted still opens in full', (
    tester,
  ) async {
    final h = Harness();
    final id = await _relic(h, 'The Certification', falls: 1);
    await h.bosses.deleteBoss((await h.bosses.loadAll()).single.boss.id);
    await pumpApp(tester, h, location: '/relic/$id');

    expect(find.text('Relic of The Certification'), findsOneWidget);
    expect(find.text('2 attempts. Every one of them counted.'), findsOneWidget);
    expect(find.textContaining('Attempt 1. Lesson 1.'), findsOneWidget);
    await tearDownApp(tester, h);
  });
}
