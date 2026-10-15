import 'package:flutter/foundation.dart' show immutable;

import '../data/enums.dart';

/// Full health: 10 points, counted in half points (Stage 4 plan D4).
const kMaxHealthHalfPoints = 20;

/// One change to a day's health. A restore sets health back to max, whatever
/// came before, so a loss bigger than what was left cannot leave the player
/// short after a rise (plan D4).
@immutable
class HealthMark {
  const HealthMark({
    required this.at,
    required this.amount,
    this.isRestore = false,
  });

  final DateTime at;

  /// Negative for a loss. Ignored on a restore.
  final int amount;
  final bool isRestore;
}

/// A day's health at [time]: start at [max], apply [marks] up to and
/// including [time] in time order, clamping to 0..max after each one.
int healthAt(int max, List<HealthMark> marks, DateTime time) {
  final upTo = [
    for (final m in marks)
      if (!m.at.isAfter(time)) m,
  ]..sort((a, b) => a.at.compareTo(b.at));
  return upTo.fold(
    max,
    (health, m) => m.isRestore ? max : (health + m.amount).clamp(0, max),
  );
}

@immutable
class DueCommitment {
  const DueCommitment({
    required this.id,
    required this.bossId,
    required this.weight,
    required this.deadline,
  });

  final String id;
  final String bossId;
  final Weight weight;
  final DateTime deadline;
}

/// How a passed deadline ended: [CommitmentOutcome.missed] with its [loss],
/// or [CommitmentOutcome.frozen] with none.
@immutable
class Settled {
  const Settled({
    required this.id,
    required this.outcome,
    required this.loss,
    required this.at,
  });

  final String id;
  final CommitmentOutcome outcome;

  /// Half points lost, positive. The loss event is written at [at].
  final int loss;
  final DateTime at;
}

/// Health reached 0: the final blow and the boss that fails an attempt.
@immutable
class Death {
  const Death({
    required this.commitmentId,
    required this.bossId,
    required this.at,
  });

  final String commitmentId;
  final String bossId;
  final DateTime at;
}

@immutable
class ResolverResult {
  const ResolverResult({required this.settled, required this.deaths});

  final List<Settled> settled;
  final List<Death> deaths;
}

/// Settles one day's commitments whose deadline has passed by [now]
/// (§5.12, Stage 4 plan D6, D7). In deadline order: a deadline met at 0
/// health is frozen (the player is fallen, or committed while fallen and has
/// not risen); otherwise it costs the weight's loss, and the loss that
/// reaches 0 is a death. [marks] are the day's events already recorded.
ResolverResult resolveCommitments({
  required int max,
  required List<HealthMark> marks,
  required List<DueCommitment> due,
  required DateTime now,
}) {
  final passed = [
    for (final c in due)
      if (!c.deadline.isAfter(now)) c,
  ]..sort((a, b) => a.deadline.compareTo(b.deadline));
  final all = [...marks];
  final settled = <Settled>[];
  final deaths = <Death>[];
  for (final c in passed) {
    final before = healthAt(max, all, c.deadline);
    if (before == 0) {
      settled.add(
        Settled(
          id: c.id,
          outcome: CommitmentOutcome.frozen,
          loss: 0,
          at: c.deadline,
        ),
      );
      continue;
    }
    final loss = c.weight.healthLoss;
    all.add(HealthMark(at: c.deadline, amount: -loss));
    settled.add(
      Settled(
        id: c.id,
        outcome: CommitmentOutcome.missed,
        loss: loss,
        at: c.deadline,
      ),
    );
    if (before <= loss) {
      deaths.add(Death(commitmentId: c.id, bossId: c.bossId, at: c.deadline));
    }
  }
  return ResolverResult(settled: settled, deaths: deaths);
}
