import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/commitment_resolver.dart';
import 'package:hearthrise/data/enums.dart';

DateTime t(int hour, [int minute = 0]) => DateTime(2026, 10, 14, hour, minute);

DueCommitment due(
  String id,
  Weight weight,
  DateTime deadline, [
  String boss = 'A',
]) => DueCommitment(id: id, bossId: boss, weight: weight, deadline: deadline);

HealthMark loss(int amount, DateTime at) => HealthMark(at: at, amount: -amount);
HealthMark restore(DateTime at) =>
    HealthMark(at: at, amount: 0, isRestore: true);

ResolverResult run(
  List<DueCommitment> list, {
  List<HealthMark> marks = const [],
  DateTime? now,
}) => resolveCommitments(
  max: kMaxHealthHalfPoints,
  marks: marks,
  due: list,
  now: now ?? t(23, 59),
);

void main() {
  group('healthAt', () {
    test('starts full and clamps at 0 after each event', () {
      final marks = [loss(18, t(9)), loss(6, t(10))];
      expect(healthAt(20, const [], t(9)), 20);
      expect(healthAt(20, marks, t(9)), 2);
      expect(healthAt(20, marks, t(10)), 0);
    });

    test('a restore sets health to max whatever came before', () {
      final marks = [
        loss(18, t(9)),
        loss(6, t(10)),
        restore(t(11)),
        loss(2, t(12)),
      ];
      expect(healthAt(20, marks, t(11)), 20);
      expect(healthAt(20, marks, t(12)), 18);
    });

    test('ignores events after the given time and sorts by time', () {
      final marks = [loss(2, t(12)), loss(4, t(9))];
      expect(healthAt(20, marks, t(10)), 16);
    });
  });

  test('nothing due: nothing settled', () {
    final r = run(const []);
    expect(r.settled, isEmpty);
    expect(r.deaths, isEmpty);
  });

  test('a Light miss costs 2 half points', () {
    final r = run([due('c1', Weight.light, t(9))]);
    expect(r.settled.single.outcome, CommitmentOutcome.missed);
    expect(r.settled.single.loss, 2);
    expect(r.settled.single.at, t(9));
  });

  test('Heavy and Boss-tier misses cost 4 and 6', () {
    final r = run([
      due('h', Weight.heavy, t(9)),
      due('b', Weight.bossTier, t(10)),
    ]);
    expect(r.settled.map((s) => s.loss), [4, 6]);
  });

  test('a deadline after now is left alone', () {
    final r = run([due('c1', Weight.light, t(15))], now: t(14));
    expect(r.settled, isEmpty);
  });

  test('misses are processed in deadline order', () {
    final r = run([
      due('late', Weight.light, t(12)),
      due('early', Weight.light, t(9)),
    ]);
    expect(r.settled.map((s) => s.id), ['early', 'late']);
  });

  test('an earlier Tried event counts toward the total', () {
    final r = run(
      [for (var i = 0; i < 5; i++) due('h$i', Weight.heavy, t(10 + i))],
      marks: [loss(1, t(8))],
    );
    // 19 left: four Heavy misses bring it to 3, the fifth kills.
    expect(r.deaths.single.commitmentId, 'h4');
  });

  test('exactly 0 is a death on the final-blow boss, at its deadline', () {
    final r = run([
      due('a', Weight.bossTier, t(9), 'A'),
      due('b', Weight.bossTier, t(10), 'A'),
      due('c', Weight.heavy, t(11), 'B'),
      due('d', Weight.heavy, t(12), 'A'),
    ]);
    expect(r.deaths, hasLength(1));
    expect(r.deaths.single.commitmentId, 'd');
    expect(r.deaths.single.bossId, 'A');
    expect(r.deaths.single.at, t(12));
  });

  test('overkill still dies once and clamps at 0', () {
    final r = run([due('b', Weight.bossTier, t(10))], marks: [loss(18, t(9))]);
    expect(r.deaths.single.commitmentId, 'b');
    expect(r.settled.single.loss, 6);
  });

  test('after a death later deadlines are frozen with no loss', () {
    final r = run(
      [due('b', Weight.bossTier, t(10)), due('l', Weight.light, t(11))],
      marks: [loss(18, t(9))],
    );
    expect(r.settled.last.outcome, CommitmentOutcome.frozen);
    expect(r.settled.last.loss, 0);
    expect(r.deaths, hasLength(1));
  });

  test('already dead before the batch: the deadline is frozen', () {
    final r = run([due('l', Weight.light, t(11))], marks: [loss(20, t(9))]);
    expect(r.settled.single.outcome, CommitmentOutcome.frozen);
    expect(r.deaths, isEmpty);
  });

  test('a rise unfreezes later deadlines; earlier ones stay frozen', () {
    final r = run(
      [due('frozen', Weight.light, t(10)), due('after', Weight.light, t(13))],
      marks: [loss(20, t(9)), restore(t(12))],
    );
    expect(r.settled.first.outcome, CommitmentOutcome.frozen);
    expect(r.settled.last.outcome, CommitmentOutcome.missed);
    expect(r.settled.last.loss, 2);
  });

  test('a second death after a rise is reported', () {
    final r = run(
      [for (var i = 0; i < 5; i++) due('h$i', Weight.heavy, t(13, i))],
      marks: [loss(20, t(9)), restore(t(12))],
    );
    expect(r.deaths.single.commitmentId, 'h4');
  });

  test('overkill, rise, then a later loss ends at max minus that loss', () {
    final r = run(
      [due('b', Weight.bossTier, t(10)), due('l', Weight.light, t(13))],
      marks: [loss(18, t(9)), restore(t(12))],
    );
    expect(r.settled.map((s) => s.outcome), [
      CommitmentOutcome.missed,
      CommitmentOutcome.missed,
    ]);
    final after = [
      loss(18, t(9)),
      loss(6, t(10)),
      restore(t(12)),
      loss(2, t(13)),
    ];
    expect(healthAt(20, after, t(13)), 18);
  });

  test('made while fallen, deadline before any rise: frozen', () {
    final r = run([due('new', Weight.heavy, t(15))], marks: [loss(20, t(9))]);
    expect(r.settled.single.outcome, CommitmentOutcome.frozen);
  });

  test('made while fallen, then a rise before its deadline: a miss costs', () {
    final r = run(
      [due('new', Weight.heavy, t(15))],
      marks: [loss(20, t(9)), restore(t(14))],
    );
    expect(r.settled.single.outcome, CommitmentOutcome.missed);
    expect(r.settled.single.loss, 4);
  });

  test('the §5.12 beginner day: five Heavy misses fall, the ninth freezes', () {
    final r = run([
      for (var i = 0; i < 5; i++) due('h$i', Weight.heavy, t(12 + i)),
      due('h5', Weight.heavy, t(20)),
    ]);
    var health = 20;
    final seen = <int>[];
    for (final s in r.settled.take(5)) {
      health -= s.loss;
      seen.add(health);
    }
    expect(seen, [16, 12, 8, 4, 0]);
    expect(r.deaths.single.commitmentId, 'h4');
    expect(r.settled.last.outcome, CommitmentOutcome.frozen);
  });
}
