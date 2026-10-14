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
  light(Duration(milliseconds: 300), 'Light', buildUpTicks: 1, embers: 1),
  heavy(
    Duration(milliseconds: 600),
    'Heavy',
    buildUpTicks: 3,
    embers: 3,
    hasBuildUpPulse: true,
  ),
  bossTier(
    Duration(milliseconds: 1200),
    'Boss-tier',
    buildUpTicks: 5,
    embers: 6,
    hasBuildUpPulse: true,
  );

  const Weight(
    this.holdDuration,
    this.label, {
    required this.buildUpTicks,
    required this.embers,
    this.hasBuildUpPulse = false,
  });
  final Duration holdDuration;
  final String label;

  /// Embers a strike earns (Stage 3 plan D7); a try earns half, rounded up.
  final int embers;

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

/// How a day was covered or kept (Stage 3 plan D3, D8).
enum DayKind { bonfire, flask, light }

enum EmberKind { earn, bank }
