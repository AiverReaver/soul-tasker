import '../../core/clock.dart';
import '../../data/enums.dart';
import '../../data/feel_report_data.dart';

/// Kept equal to `version:` in pubspec.yaml; a test checks it.
const kAppVersion = '1.0.0+1';

/// The text a tester pastes into a message (§12, plan D3). Counts only:
/// never a boss name, task title or lesson.
String buildFeelReport(FeelReportData data, DateTime now, String appVersion) {
  final strikes = data.attempts.where((a) => a.outcome == Outcome.strike);
  int strikesOf(Weight? weight) =>
      strikes.where((a) => a.weight == weight).length;
  final falls = data.attempts.where((a) => a.outcome == Outcome.fallen);
  final written = falls.where((a) => a.hasLesson).length;
  final tried = data.attempts.where((a) => a.outcome == Outcome.tried).length;
  final hour = data.settings.rolloverHour;
  final end = dayOf(now, rolloverHour: hour);
  final since = data.since;
  final period = since == null
      ? 'no bosses yet (to $end)'
      : '${dayOf(since, rolloverHour: hour)} to $end (since the earliest surviving boss)';
  String onOff(bool isOn) => isOn ? 'on' : 'off';

  return 'Hearthrise feel report\n'
      'Version: $appVersion\n'
      'Period: $period\n'
      'Strikes: ${strikes.length} '
      '(Light ${strikesOf(Weight.light)}, Heavy ${strikesOf(Weight.heavy)}, '
      'Boss-tier ${strikesOf(Weight.bossTier)}, '
      'weight unknown ${strikesOf(null)})\n'
      'Tried: $tried\n'
      'Falls: ${falls.length} '
      '(lessons written $written, skipped ${falls.length - written})\n'
      'Tap mode: ${onOff(data.settings.tapMode)}\n'
      'Haptics: ${onOff(data.settings.haptics)}\n';
}
