import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/deadlines.dart';
import 'package:hearthrise/data/commitment_dao.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/ember_dao.dart';
import 'package:hearthrise/data/enums.dart';

import 'harness.dart';

void main() {
  late Harness h;
  late CommitmentDao commits;
  late EmberDao embers;
  setUp(() {
    h = Harness(null, StepClock(DateTime(2026, 10, 13, 8)));
    commits = CommitmentDao(h.db, h.clock.call);
    embers = EmberDao(h.db, h.clock.call);
  });
  tearDown(() => h.db.close());

  Future<String> task(String title) async =>
      taskNamed((await h.bosses.loadAll()).single, title).task.id;
  Future<Commitment> row() async =>
      (await commits.load('2026-10-13')).single.commitment;
  Future<List<HealthEvent>> health() => h.db.select(h.db.healthEvents).get();
  Future<int> carried() async => (await embers.tally()).carried;
  Future<void> setOutcome(CommitmentOutcome o) => h.db
      .update(h.db.commitments)
      .write(CommitmentsCompanion(outcome: Value(o)));

  test('strike before the deadline keeps it, full embers, no health', () async {
    await h.seed();
    final id = await task('Read chapter 4');
    await commits.commit(id, DeadlinePreset.tonight);
    await h.attempts.strike(id);
    expect((await row()).outcome, CommitmentOutcome.kept);
    expect((await row()).resolvedAt, isNotNull);
    expect(await health(), isEmpty);
    expect(await carried(), 3);
  });

  test('Tried before the deadline costs half and earns Tried embers', () async {
    await h.seed();
    for (final (title, half) in [
      ('Flashcards', 1),
      ('Read chapter 4', 2),
      ('Sit the exam', 3),
    ]) {
      final id = await task(title);
      await commits.commit(id, DeadlinePreset.tonight);
      await h.attempts.tried(id);
      final c = (await commits.load('2026-10-13'))
          .firstWhere((v) => v.taskTitle == title)
          .commitment;
      expect(c.outcome, CommitmentOutcome.tried, reason: title);
      final e = (await health()).firstWhere((e) => e.commitmentId == c.id);
      expect(e.amount, -half, reason: title);
      expect(e.reason, HealthReason.tried);
      expect(e.day, '2026-10-13');
    }
    expect(await carried(), 1 + 2 + 3);
  });

  test(
    'a strike after Tried earns Tried embers and changes nothing else',
    () async {
      await h.seed();
      final id = await task('Read chapter 4');
      await commits.commit(id, DeadlinePreset.tonight);
      await h.attempts.tried(id);
      final before = await carried();
      await h.attempts.strike(id);
      expect(await carried() - before, 2);
      expect((await row()).outcome, CommitmentOutcome.tried);
      expect(await health(), hasLength(1));
    },
  );

  for (final o in [CommitmentOutcome.missed, CommitmentOutcome.frozen]) {
    test('strike on a ${o.name} commitment is a late strike', () async {
      await h.seed();
      final id = await task('Read chapter 4');
      await commits.commit(id, DeadlinePreset.tonight);
      await setOutcome(o);
      await h.attempts.strike(id);
      expect((await row()).outcome, CommitmentOutcome.lateStrike);
      expect(await health(), isEmpty);
      expect(await carried(), 2);
    });
  }

  test('strike with no commitment is unchanged from Stage 3', () async {
    await h.seed();
    await h.attempts.strike(await task('Read chapter 4'));
    expect(await carried(), 3);
    expect(await h.db.select(h.db.commitments).get(), isEmpty);
    expect(await health(), isEmpty);
  });

  test('a daily task closes only today\'s commitment', () async {
    await h.seed();
    final walk = await task('Walk');
    await commits.commit(walk, DeadlinePreset.tonight);
    h.clock.now = DateTime(2026, 10, 14, 8);
    await commits.commit(walk, DeadlinePreset.tonight);
    await h.attempts.strike(walk);
    final yesterday = (await commits.load('2026-10-13')).single.commitment;
    final today = (await commits.load('2026-10-14')).single.commitment;
    expect(yesterday.outcome, isNull);
    expect(today.outcome, CommitmentOutcome.kept);
  });

  test('amountFor a late strike is the Tried amount', () {
    expect(EmberDao.amountFor(Outcome.strike, Weight.heavy, isLate: true), 2);
    expect(EmberDao.amountFor(Outcome.strike, Weight.heavy), 3);
  });
}
