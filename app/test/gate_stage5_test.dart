import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/day_dao.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/profile_dao.dart';
import 'package:material_ui/material_ui.dart';

import 'data/harness.dart';
import 'features/pump.dart';
import 'support/fake_reminders.dart';
import 'support/hold_finders.dart';

// The Stage 5 gate, scripted (STAGE5_PLAN.md step 11): a new install goes
// through onboarding to a saved boss, falls twice with lessons, drains the
// last segment, and the relic outlives the boss.
void main() {
  testWidgets('install, fight, fall twice, win, and keep the relic', (
    tester,
  ) async {
    final h = Harness();
    final reminders = FakeReminders();
    void at(int day, [int hour = 9]) =>
        h.clock.now = DateTime(2026, 10, 13 + day, hour);

    // 1. Install, day 1: onboarding to a saved boss with two phases and two
    // daily foes, reminder on.
    at(1);
    await pumpApp(tester, h, onboarded: false, reminders: reminders);
    expect(find.text("Failing is fine. Quitting isn't."), findsOneWidget);
    await tester.tap(find.text('Next'));
    await settle(tester);
    await tester.enterText(
      find.byKey(const ValueKey('boss-title')),
      'The Certification',
    );
    await tester.pump();
    await tester.tap(find.text('Next'));
    await settle(tester);
    await tester.tap(find.text('Next')); // keep both suggested phases
    await settle(tester);
    final dailies = find.byWidgetPredicate(
      (w) => w is TextFormField && w.key.toString().contains('daily-'),
    );
    await tester.enterText(dailies, 'Walk');
    await tester.tap(find.text('Add a daily foe'));
    await settle(tester);
    await tester.enterText(dailies.last, 'Flashcards');
    await tester.tap(find.text('Next'));
    await settle(tester);
    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.tap(find.text('Begin'));
    await settle(tester);
    expect(find.text('The Certification'), findsOneWidget);
    await tester.tap(find.text('Today'));
    await settle(tester);
    expect(find.text('Walk · daily'), findsOneWidget);
    expect(find.text('Flashcards · daily'), findsOneWidget);
    expect(reminders.calls, contains('schedule:1260'));
    // Leave the app view; keep the database for the rest of the script.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));

    // One task in each phase, Heavy (the editor's job, done by the DAO).
    final bossId = (await h.bosses.loadAll()).single.boss.id;
    final draft = BossDraft.fromView(await h.reload(bossId));
    await h.bosses.saveBoss(
      draft.copyWith(
        phases: [
          for (final (i, p) in draft.phases.indexed)
            p.copyWith(tasks: [TaskDraft(title: 'Phase task ${i + 1}')]),
        ],
      ),
    );
    final view = await h.reload(bossId);
    final walk = view.standalone.firstWhere((t) => t.task.title == 'Walk');

    // 2. Day 1: strike a daily foe, then fall with a lesson. Attempt 2.
    await h.attempts.strike(walk.task.id);
    await h.attempts.fall(bossId, 'Started too late.');
    expect((await h.reload(bossId)).boss.attemptNumber, 2);

    // 3. Day 2: rest at the bonfire; the profile shows the bank.
    at(2, 20);
    final days = DayDao(h.db, h.clock.call, h.attempts);
    expect(await days.rest(), isTrue);
    final profile = await ProfileDao(h.db, h.clock.call).read();
    expect(profile.banked, 1);
    expect(profile.level.level, 1);

    // 4. Day 3: fall again. Attempt 3.
    at(3);
    await h.attempts.fall(bossId, 'Skipped the warm-up.');
    expect((await h.reload(bossId)).boss.attemptNumber, 3);

    // 5 and 6. Day 3: strike both phase tasks; the last segment drains and
    // the victory screen tells the story.
    await h.settings.setTapMode(true);
    await pumpApp(
      tester,
      h,
      location: '/boss/$bossId',
      onboarded: null,
      reminders: reminders,
    );
    await tester.tap(holdButton('Phase task 1'));
    await settle(tester);
    await tester.tap(find.text('Clean strike'));
    await settle(tester);
    await tester.tap(holdButton('Phase task 2'));
    await settle(tester);
    await tester.tap(find.text('Clean strike'));
    await settle(tester);
    await tester.tap(find.text('Defeated'));
    await settle(tester);

    final earned = (await h.db.select(h.db.emberEvents).get())
        .where((e) => e.kind == EmberKind.earn && e.bossId == bossId)
        .fold<int>(0, (sum, e) => sum + e.amount);
    expect(earned, 7); // Walk 1 + two Heavy strikes of 3
    expect(find.textContaining(' falls.'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('victory-attempts'))).data,
      '3',
    );
    expect(find.text('attempts'), findsOneWidget);
    expect(find.text('3 days'), findsOneWidget);
    expect(find.text('$earned embers of effort'), findsOneWidget);
    final first = find.textContaining('Attempt 1. Started too late.');
    final second = find.textContaining('Attempt 2. Skipped the warm-up.');
    expect(first, findsOneWidget);
    expect(tester.getTopLeft(first).dy, lessThan(tester.getTopLeft(second).dy));
    expect(find.bySemanticsLabel('A worn emblem'), findsOneWidget);
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Patience.');
    await tester.ensureVisible(find.text('Return to the hearth'));
    await tester.tap(find.text('Return to the hearth'));
    await settle(tester);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));

    final stored = (await h.db.select(h.db.relics).get()).single;
    expect(stored.emblem, Weathering.worn);
    expect(stored.inscription, 'Patience.');
    final before = (await h.relics.load(stored.id))!;

    // 7. Rename the boss, edit a phase, delete it: the relic is unchanged.
    final edit = BossDraft.fromView(await h.reload(bossId));
    await h.bosses.saveBoss(
      edit.copyWith(
        title: 'Renamed',
        phases: [
          edit.phases.first.copyWith(name: 'Edited'),
          edit.phases.last,
        ],
      ),
    );
    await h.bosses.deleteBoss(bossId);
    final after = (await h.relics.load(stored.id))!;
    expect(after.relic.bossId, isNull);
    expect(after.relic.name, 'Relic of The Certification');
    expect(after.relic.attempts, 3);
    expect(after.relic.days, 3);
    expect(after.relic.effort, 7);
    expect(after.relic.inscription, 'Patience.');
    expect(after.story.encode(), before.story.encode());
    expect(after.story.phases, ['Learn the pattern', 'The fight']);
    expect(after.story.lessons.map((l) => l.text), [
      'Started too late.',
      'Skipped the warm-up.',
    ]);

    // 8. The profile's hall lists it; its detail shows the timeline; only
    // the inscription and updatedAt change when it is edited.
    await pumpApp(
      tester,
      h,
      location: '/profile',
      onboarded: null,
      reminders: reminders,
    );
    expect(find.text('Relic of The Certification'), findsOneWidget);
    await tester.tap(find.text('Relic of The Certification'));
    await settle(tester);
    expect(find.textContaining('Attempt 1. Started too late.'), findsOneWidget);
    expect(find.text('3 attempts. Every one of them counted.'), findsOneWidget);
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Patience, earned.');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await settle(tester);

    final edited = (await h.db.select(h.db.relics).get()).single;
    expect(edited.inscription, 'Patience, earned.');
    expect(edited.updatedAt.isAfter(stored.updatedAt), isTrue);
    expect(
      edited.copyWith(
        inscription: const Value('Patience.'),
        updatedAt: stored.updatedAt,
        bossId: Value(stored.bossId),
      ),
      stored,
    );
    await tearDownApp(tester, h);
  });
}
