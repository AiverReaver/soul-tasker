import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import 'pump.dart';

// Stage 5 plan D13: the new screens must not overflow on a small and a large
// phone, nor at 200% text on the small one. A RenderFlex overflow is thrown
// as a framework exception, which `takeException` returns.

typedef _Setup = ({Size size, double text, String name});

const _setups = <_Setup>[
  (size: Size(320, 568), text: 1.0, name: '320 x 568'),
  (size: Size(412, 915), text: 1.0, name: '412 x 915'),
  (size: Size(320, 568), text: 2.0, name: '320 x 568 at 200% text'),
];

Future<String> _defeatedBoss(Harness h, {int falls = 3}) async {
  final id = await h.bosses.saveBoss(
    const BossDraft(
      title: 'The Very Long Certification Of Considerable Patience',
      defeatMeaning: 'I am the kind of person who finishes what they start',
      resetOnFail: ResetOnFail.nothing,
      phases: [
        PhaseDraft(
          name: 'Learn the pattern',
          tasks: [TaskDraft(title: 'Sit the exam')],
        ),
        PhaseDraft(name: 'The fight'),
      ],
    ),
  );
  for (var i = 0; i < falls; i++) {
    await h.attempts.fall(
      id,
      'A fairly long lesson number ${i + 1} that wraps over a few lines.',
    );
  }
  await h.attempts.strike((await h.reload(id)).allTasks.first.task.id);
  await h.bosses.setStatus(id, BossStatus.defeated);
  return (await h.relics.idForBoss(id))!;
}

Future<void> _check(
  WidgetTester tester,
  _Setup setup,
  String Function(Harness h, String relicId) location, {
  bool withRelic = true,
  bool onboarded = true,
  Future<void> Function(WidgetTester tester)? after,
}) async {
  tester.view.physicalSize = setup.size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = setup.text;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  final h = Harness();
  final relicId = withRelic ? await _defeatedBoss(h) : '';
  await pumpApp(
    tester,
    h,
    location: location(h, relicId),
    onboarded: onboarded,
  );
  expect(tester.takeException(), isNull, reason: setup.name);
  if (after != null) await after(tester);
  expect(tester.takeException(), isNull, reason: setup.name);
  await tearDownApp(tester, h);
}

void main() {
  for (final setup in _setups) {
    group(setup.name, () {
      testWidgets('victory', (tester) async {
        await _check(tester, setup, (_, id) => '/victory/$id');
      });

      testWidgets('relic detail', (tester) async {
        await _check(tester, setup, (_, id) => '/relic/$id');
      });

      testWidgets('profile with relics', (tester) async {
        await _check(tester, setup, (_, _) => '/profile');
      });

      testWidgets('profile with none', (tester) async {
        await _check(tester, setup, (_, _) => '/profile', withRelic: false);
      });

      testWidgets('every onboarding page', (tester) async {
        await _check(
          tester,
          setup,
          (_, _) => '/',
          withRelic: false,
          onboarded: false,
          after: (tester) async {
            for (var page = 1; page <= 4; page++) {
              if (page == 2) {
                await tester.enterText(
                  find.byKey(const ValueKey('boss-title')),
                  'A boss with a rather long name indeed',
                );
                await tester.pump();
              }
              if (page == 3) {
                await tester.ensureVisible(find.text('Add a phase'));
                await tester.tap(find.text('Add a phase'));
                await settle(tester);
              }
              if (page == 4) {
                await tester.ensureVisible(find.text('Add a daily foe'));
                await tester.tap(find.text('Add a daily foe'));
                await settle(tester);
                await tester.ensureVisible(find.text('Add a daily foe'));
                await tester.tap(find.text('Add a daily foe'));
                await settle(tester);
              }
              await tester.tap(find.text('Next'));
              await settle(tester);
              expect(tester.takeException(), isNull, reason: 'page $page');
            }
          },
        );
      });

      testWidgets('bonfire', (tester) async {
        await _check(tester, setup, (_, _) => '/bonfire', withRelic: false);
      });
    });
  }
}
