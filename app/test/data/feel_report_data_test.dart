import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/features/feel_report/feel_report.dart';

import 'harness.dart';

void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() => h.db.close());

  test(
    'returns outcome, weight and lesson presence for each attempt',
    () async {
      final view = await h.seed();
      await h.attempts.strike(taskNamed(view, 'Flashcards').task.id);
      await h.attempts.tried(taskNamed(view, 'Read chapter 4').task.id);
      await h.attempts.fall(view.boss.id, 'Start earlier.');
      await h.attempts.fall(view.boss.id, null);

      final data = await h.attempts.feelReportData();

      expect(data.attempts.map((a) => (a.outcome, a.weight, a.hasLesson)), [
        (Outcome.strike, Weight.light, false),
        (Outcome.tried, Weight.heavy, false),
        (Outcome.fallen, null, true),
        (Outcome.fallen, null, false),
      ]);
    },
  );

  test('returns the earliest surviving boss and the settings', () async {
    final first = await h.seed();
    final firstCreated = first.boss.createdAt;
    h.clock.now = h.clock.now.add(const Duration(days: 2));
    await h.seed();
    await h.settings.setTapMode(true);
    await h.settings.setHaptics(false);

    final data = await h.attempts.feelReportData();

    expect(data.since, firstCreated);
    expect(data.settings.tapMode, isTrue);
    expect(data.settings.haptics, isFalse);
  });

  test('has no boss date when there are no bosses', () async {
    expect((await h.attempts.feelReportData()).since, isNull);
  });

  test('a report built from real data carries no boss, task or lesson '
      'text', () async {
    final id = await h.bosses.saveBoss(
      const BossDraft(
        title: 'Zorblax the Unnamed',
        resetOnFail: ResetOnFail.nothing,
        phases: [
          PhaseDraft(
            name: 'Quuxphase',
            tasks: [TaskDraft(title: 'Frobnicate widgets')],
          ),
        ],
      ),
    );
    final view = await h.reload(id);
    await h.attempts.strike(view.segments.single.task.id);
    await h.attempts.fall(id, 'Grumblesnort lesson');

    final report = buildFeelReport(
      await h.attempts.feelReportData(),
      h.clock.now,
      '1.0.0+1',
    );

    for (final secret in [
      'Zorblax',
      'Quuxphase',
      'Frobnicate',
      'Grumblesnort',
    ]) {
      expect(report, isNot(contains(secret)));
    }
  });
}
