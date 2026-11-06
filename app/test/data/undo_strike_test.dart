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
  Future<Commitment> promise() async =>
      (await commits.load('2026-10-13')).single.commitment;

  test('undo reopens the task and takes back its embers', () async {
    final view = await h.seed();
    final id = await task('Read chapter 4');
    final result = await h.attempts.strike(id);
    await h.attempts.undoStrike(result);

    final after = await h.reload(view.boss.id);
    expect(taskNamed(after, 'Read chapter 4').isStruck, isFalse);
    expect(await h.db.select(h.db.attempts).get(), isEmpty);
    expect((await embers.tally()).carried, 0);
  });

  test('a struck task can be struck again after undo', () async {
    await h.seed();
    final id = await task('Walk');
    await h.attempts.undoStrike(await h.attempts.strike(id));
    await h.attempts.strike(id);
    expect(await h.db.select(h.db.attempts).get(), hasLength(1));
    expect((await embers.tally()).carried, greaterThan(0));
  });

  test('undo of a strike on a struck task changes nothing', () async {
    await h.seed();
    final id = await task('Walk');
    await h.attempts.strike(id);
    final again = await h.attempts.strike(id);
    await h.attempts.undoStrike(again);
    expect(await h.db.select(h.db.attempts).get(), hasLength(1));
  });

  test('undo reopens a promise the strike kept', () async {
    await h.seed();
    final id = await task('Read chapter 4');
    await commits.commit(id, DeadlinePreset.tonight);
    await h.attempts.undoStrike(await h.attempts.strike(id));
    expect((await promise()).outcome, isNull);
    expect((await promise()).resolvedAt, isNull);
  });

  test('undo of a late strike puts the promise back as missed', () async {
    await h.seed();
    final id = await task('Read chapter 4');
    await commits.commit(id, DeadlinePreset.tonight);
    await h.db
        .update(h.db.commitments)
        .write(
          const CommitmentsCompanion(outcome: Value(CommitmentOutcome.missed)),
        );
    await h.attempts.undoStrike(await h.attempts.strike(id));
    expect((await promise()).outcome, CommitmentOutcome.missed);
  });
}
