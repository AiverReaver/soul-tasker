// Stored as integers by index. Only append new values; never reorder.

enum BossStatus { active, waiting, defeated }

/// What a failed attempt undoes (§5.1).
enum ResetOnFail {
  nothing('Nothing'),
  currentPhase('Current phase'),
  wholeBoss('Whole boss');

  const ResetOnFail(this.label);
  final String label;
}

enum Weight {
  light(Duration(milliseconds: 300), 'Light'),
  heavy(Duration(milliseconds: 600), 'Heavy'),
  bossTier(Duration(milliseconds: 1200), 'Boss-tier');

  const Weight(this.holdDuration, this.label);
  final Duration holdDuration;
  final String label;

  /// One step lighter, used when splitting a task (minimum Light).
  Weight get lighter => values[index == 0 ? 0 : index - 1];
}

enum Recurrence { none, daily }

enum Outcome { strike, tried, fallen }

/// Why a boss attempt failed (§5.4). Stage 1 writes [declared] only.
enum FallCause { declared, healthDeath, missedDay }
