import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/deadlines.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/commitment_dao.dart';
import 'package:hearthrise/data/day_dao.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/health_dao.dart';
import 'package:hearthrise/data/signal_dao.dart';
import 'package:hearthrise/data/visit_dao.dart';

import 'harness.dart';

void main() {
  late Harness h;
  late SignalDao signals;
  setUp(() {
    h = Harness();
    signals = SignalDao(h.db, h.clock.call);
  });
  tearDown(() => h.db.close());

  Future<List<String>> fallIds() async => [
    for (final a in await h.db.select(h.db.attempts).get())
      if (a.outcome == Outcome.fallen) a.id,
  ];

  group('falls', () {
    test(
      'a declared fall writes one fell event with its day and time',
      () async {
        final view = await h.seed();
        await h.attempts.fall(view.boss.id, 'Too much at once.');

        final fall = (await h.bosses.loadAttempts(bossId: view.boss.id)).single;
        final event = (await signals.events()).single;
        expect(event.kind, SignalKind.fell);
        expect(event.day, fall.day);
        expect(event.at, fall.at);
        expect(event.value, isNull);
      },
    );

    test('strikes and tries write no signal', () async {
      final view = await h.seed();
      await h.attempts.strike(taskNamed(view, 'Flashcards').task.id);
      await h.attempts.tried(taskNamed(view, 'Read chapter 4').task.id);

      expect(await signals.events(), isEmpty);
    });

    test('a missed day writes one fell event per failed boss', () async {
      await h.seed();
      await h.seed();
      h.clock.now = DateTime(2026, 10, 15, 12);

      await DayDao(h.db, h.clock.call, h.attempts).resolve(lesson: 'Rest.');

      final events = await signals.events();
      expect(await fallIds(), hasLength(2));
      expect(events, hasLength(2));
      expect(events.map((e) => e.kind).toSet(), {SignalKind.fell});
      expect(events.map((e) => e.day).toSet(), {'2026-10-14'});
    });

    test(
      'a death at zero health writes a fell event at the deadline',
      () async {
        h.clock.now = DateTime(2026, 10, 13, 8);
        final commits = CommitmentDao(h.db, h.clock.call);
        final health = HealthDao(h.db, h.clock.call, h.attempts);
        final id = await h.bosses.saveBoss(
          BossDraft(
            title: 'A',
            resetOnFail: ResetOnFail.nothing,
            standalone: [
              for (var i = 0; i < 5; i++)
                TaskDraft(title: 'T$i', weight: Weight.heavy),
            ],
          ),
        );
        for (final t in (await h.reload(id)).allTasks) {
          await commits.commit(t.task.id, DeadlinePreset.oneHour);
        }
        h.clock.now = DateTime(2026, 10, 13, 18);

        final r = await health.resolveDue();

        final death = (await h.bosses.loadAttempts(bossId: id)).single;
        expect(r.deaths, hasLength(1));
        final event = (await signals.events()).single;
        expect(event.kind, SignalKind.fell);
        expect(event.at, death.at);
        expect(event.day, death.day);
      },
    );

    test('a fall rolled back leaves no event', () async {
      final view = await h.seed();
      await expectLater(
        h.db.transaction(() async {
          await h.attempts.fall(view.boss.id, null);
          throw StateError('boom');
        }),
        throwsStateError,
      );

      expect(await fallIds(), isEmpty);
      expect(await signals.events(), isEmpty);
    });

    test('deleting the boss keeps its fell events', () async {
      final view = await h.seed();
      await h.attempts.fall(view.boss.id, null);
      await h.bosses.deleteBoss(view.boss.id);

      expect(await fallIds(), isEmpty);
      expect(await signals.events(), hasLength(1));
    });
  });

  group('tap mode', () {
    test('turning it on writes a change with value 1', () async {
      await h.settings.setTapMode(true);

      final event = (await signals.events()).single;
      expect(event.kind, SignalKind.tapModeChanged);
      expect(event.value, 1);
      expect(event.day, '2026-10-13');
    });

    test('setting the same value again writes nothing', () async {
      await h.settings.setTapMode(false);
      await h.settings.setTapMode(true);
      await h.settings.setTapMode(true);

      expect(await signals.events(), hasLength(1));
    });

    test('back off writes value 0', () async {
      await h.settings.setTapMode(true);
      await h.settings.setTapMode(false);

      expect((await signals.events()).map((e) => e.value), [1, 0]);
      expect((await h.settings.read()).tapMode, isFalse);
    });
  });

  test('input gathers counts from a seeded database, no text', () async {
    final view = await h.seed();
    final visits = VisitDao(h.db, h.clock.call);
    await visits.record();
    await h.attempts.strike(taskNamed(view, 'Flashcards').task.id);
    await h.attempts.tried(taskNamed(view, 'Read chapter 4').task.id);
    await h.attempts.fall(view.boss.id, 'Too much at once.');
    await h.settings.setTapMode(true);
    await DayDao(h.db, h.clock.call, h.attempts).rest(lesson: 'Start early.');

    final input = await signals.input();

    expect(input.firstDay, '2026-10-13');
    expect(input.rolloverHour, 4);
    expect(input.visitDays, ['2026-10-13']);
    expect(input.marks.map((m) => m.kind), [
      SignalKind.fell,
      SignalKind.tapModeChanged,
    ]);
    expect(input.attempts.map((a) => a.outcome), [
      Outcome.strike,
      Outcome.tried,
      Outcome.fallen,
    ]);
    expect(input.attempts.last.hasLesson, isTrue);
    expect(input.attempts.first.weight, Weight.light);
    expect(input.bonfireLessons, 1);
    expect(input.tapMode, isTrue);
    expect(input.haptics, isTrue);
    expect(input.commits, isEmpty);
  });

  test('input carries each commitment day, extensions and outcome', () async {
    final view = await h.seed();
    final commits = CommitmentDao(h.db, h.clock.call);
    final taskId = taskNamed(view, 'Flashcards').task.id;
    await commits.commit(taskId, DeadlinePreset.oneHour);

    final input = await signals.input();

    expect(input.commits, hasLength(1));
    expect(input.commits.single.day, '2026-10-13');
    expect(input.commits.single.extensions, 0);
    expect(input.commits.single.outcome, isNull);
  });

  test('a rest with a note counts as one bonfire lesson', () async {
    await h.seed();
    final days = DayDao(h.db, h.clock.call, h.attempts);
    expect(await days.rest(lesson: 'Start the tempo run before work.'), isTrue);
    expect((await signals.input()).bonfireLessons, 1);
  });
}
