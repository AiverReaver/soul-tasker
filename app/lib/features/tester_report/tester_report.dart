import '../../core/signals.dart';
import '../../data/enums.dart';

/// Kept equal to `version:` in pubspec.yaml; a test checks it.
const kAppVersion = '1.0.0+1';

/// The text a tester pastes into the feedback form (§12, Stage 6 plan D1).
/// Counts and dates only: never a boss name, task title or lesson.
String buildTesterReport(Signals s, String appVersion) {
  String onOff(bool isOn) => isOn ? 'on' : 'off';
  String returns(ReturnCount r) => '${r.returned} of ${r.judged}';
  final by = s.strikesBy;
  final ratio = s.triedPerStrike;

  final tap = s.tapChanges == 0
      ? 'never changed'
      : 'changed ${s.tapChanges} ${s.tapChanges == 1 ? 'time' : 'times'}, '
            'first on day ${s.firstTapChangeDay}';

  String checkIn(CheckInWindow w) {
    final dismissed = w.dismissals == 0 ? '' : ' (dismissed ${w.dismissals})';
    if (w.answer case final answer?) return '${_answers[answer]}$dismissed';
    if (s.dayNumber < w.fromDay) return 'not asked yet';
    return 'no answer$dismissed';
  }

  return 'Hearthrise tester report\n'
      'Version: $appVersion\n'
      'Period: ${s.firstDay} to ${s.today} (day ${s.dayNumber})\n'
      'Visits recorded since: ${s.firstVisit ?? 'none yet'}\n'
      'Fallen days: ${s.fallenDays}\n'
      'Returned the next day after a fall: ${returns(s.afterFalls)} '
      '(${s.afterFalls.pending} pending)\n'
      'First-week fallen days: ${s.firstWeekFalls} '
      '(returned the next day ${returns(s.firstWeekReturns)})\n'
      'Strikes: ${s.strikes} '
      '(Light ${by[Weight.light]}, Heavy ${by[Weight.heavy]}, '
      'Boss-tier ${by[Weight.bossTier]}, weight unknown ${by[null]})\n'
      'Tried: ${s.tried}\n'
      'Tried per Strike: ${ratio == null ? 'n/a' : ratio.toStringAsFixed(2)}\n'
      'Lessons on falls: written ${s.fallLessonsWritten}, '
      'skipped ${s.fallLessonsSkipped}\n'
      'Bonfire lessons: ${s.bonfireLessons}\n'
      'Tap mode: ${onOff(s.tapMode)} ($tap)\n'
      'Haptics: ${onOff(s.haptics)}\n'
      '${[for (final w in s.checkIns) 'Check-in from day ${w.fromDay}: ${checkIn(w)}\n'].join()}';
}

const _answers = {
  CheckInAnswer.never: 'Never',
  CheckInAnswer.sometimes: 'Sometimes',
  CheckInAnswer.often: 'Often',
};
