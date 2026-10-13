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

/// Hold length and haptic build-up per weight (plan section 5). First-guess
/// numbers, expected to move in tuning.
enum Weight {
  light(Duration(milliseconds: 300), 'Light', buildUpTicks: 1),
  heavy(
    Duration(milliseconds: 600),
    'Heavy',
    buildUpTicks: 3,
    hasBuildUpPulse: true,
  ),
  bossTier(
    Duration(milliseconds: 1200),
    'Boss-tier',
    buildUpTicks: 5,
    hasBuildUpPulse: true,
  );

  const Weight(
    this.holdDuration,
    this.label, {
    required this.buildUpTicks,
    this.hasBuildUpPulse = false,
  });
  final Duration holdDuration;
  final String label;

  /// Selection ticks during the hold, spread evenly.
  final int buildUpTicks;

  /// One medium pulse after the ticks, just before the strike lands.
  final bool hasBuildUpPulse;

  /// One step lighter, used when splitting a task (minimum Light).
  Weight get lighter => values[index == 0 ? 0 : index - 1];
}

enum Recurrence { none, daily }

enum Outcome { strike, tried, fallen }

/// Why a boss attempt failed (§5.4). Stage 1 writes [declared] only.
enum FallCause { declared, healthDeath, missedDay }
