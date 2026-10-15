// Stored as an integer by index on a relic. Only append new values.

/// How worn a relic's emblem is, set once from the attempts taken (Stage 5
/// plan D5). Never a ranking: a first-try win is not "better".
enum Weathering {
  unmarked,
  worn,
  scarred,
  weathered;

  /// Attempts up to each bound: 1, 3 and 8.
  static const thresholds = [1, 3, 8];

  static Weathering forAttempts(int attempts) {
    for (final (i, limit) in thresholds.indexed) {
      if (attempts <= limit) return values[i];
    }
    return weathered;
  }
}

/// Longest relic inscription, in characters (Stage 5 plan D7).
const kInscriptionMax = 120;
