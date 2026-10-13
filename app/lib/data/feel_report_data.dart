import 'database.dart';
import 'enums.dart';

/// One attempt reduced to what the feel report counts. Never carries a
/// title or lesson text (plan D3, D13).
class FeelAttempt {
  const FeelAttempt({
    required this.outcome,
    required this.weight,
    required this.hasLesson,
  });

  final Outcome outcome;

  /// Null for falls and for rows written before schema v2.
  final Weight? weight;
  final bool hasLesson;
}

/// Everything the feel report prints, and nothing more.
class FeelReportData {
  const FeelReportData({
    required this.attempts,
    required this.since,
    required this.settings,
  });

  final List<FeelAttempt> attempts;

  /// Creation time of the earliest surviving boss; null with no bosses.
  final DateTime? since;
  final AppSettings settings;
}
