import '../data/enums.dart';
import 'check_in.dart';
import 'clock.dart';
import 'missed_days.dart';

/// One signal event, as the tester report needs it (Stage 6 plan D3).
class SignalMark {
  const SignalMark({
    required this.kind,
    required this.day,
    required this.at,
    this.value,
  });

  final SignalKind kind;
  final String day;
  final DateTime at;
  final int? value;
}

/// One attempt reduced to what is counted: never a title or lesson text.
class AttemptMark {
  const AttemptMark({
    required this.outcome,
    this.weight,
    this.hasLesson = false,
  });

  final Outcome outcome;

  /// Null for falls and for rows written before schema v2.
  final Weight? weight;
  final bool hasLesson;
}

/// One commitment reduced to what is counted (Stage 6 step 7).
class CommitMark {
  const CommitMark({required this.day, required this.extensions, this.outcome});

  final String day;
  final int extensions;

  /// Null while still open.
  final CommitmentOutcome? outcome;
}

/// Promises in one week of the test (§12 "week one versus week four").
class WeekPromises {
  const WeekPromises({
    required this.made,
    required this.kept,
    required this.days,
  });

  /// Not counting those cancelled, as in `CommitmentDao.record`.
  final int made;
  final int kept;

  /// Days of the week elapsed so far, 1 to 7.
  final int days;

  double get perDay => made / days;
}

/// Everything the signals are computed from.
class SignalInput {
  const SignalInput({
    required this.firstDay,
    required this.rolloverHour,
    required this.visitDays,
    required this.marks,
    required this.attempts,
    required this.bonfireLessons,
    required this.tapMode,
    required this.haptics,
    this.commits = const [],
  });

  /// The install day (day 1).
  final String firstDay;
  final int rolloverHour;
  final List<String> visitDays;
  final List<SignalMark> marks;
  final List<AttemptMark> attempts;
  final int bonfireLessons;
  final bool tapMode;
  final bool haptics;
  final List<CommitMark> commits;
}

/// Fallen days followed by a visit the next day (Stage 6 plan D5).
class ReturnCount {
  const ReturnCount({
    required this.returned,
    required this.judged,
    required this.pending,
  });

  final int returned;

  /// Fallen days whose next day has ended.
  final int judged;

  /// Fallen days whose next day is today or later.
  final int pending;
}

/// What one check-in window collected.
class CheckInWindow {
  const CheckInWindow({
    required this.fromDay,
    required this.answer,
    required this.dismissals,
  });

  final int fromDay;

  /// The latest answer in the window; null when never answered.
  final CheckInAnswer? answer;
  final int dismissals;
}

/// The §12 signals, counts only.
class Signals {
  const Signals({
    required this.firstDay,
    required this.today,
    required this.dayNumber,
    required this.firstVisit,
    required this.fallenDays,
    required this.afterFalls,
    required this.firstWeekFalls,
    required this.firstWeekReturns,
    required this.strikesBy,
    required this.tried,
    required this.fallLessonsWritten,
    required this.fallLessonsSkipped,
    required this.bonfireLessons,
    required this.tapMode,
    required this.tapChanges,
    required this.firstTapChangeDay,
    required this.haptics,
    required this.checkIns,
    required this.freeExtensions,
    required this.flaskExtensions,
    required this.lateStrikes,
    required this.week1,
    required this.week4,
  });

  final String firstDay;
  final String today;

  /// Today's day number; the install day is 1.
  final int dayNumber;

  /// The earliest recorded visit; null with none.
  final String? firstVisit;
  final int fallenDays;
  final ReturnCount afterFalls;

  /// Fallen days in days 1 to 7.
  final int firstWeekFalls;
  final ReturnCount firstWeekReturns;

  /// Strikes per weight; the null key is "weight unknown".
  final Map<Weight?, int> strikesBy;
  final int tried;
  final int fallLessonsWritten;
  final int fallLessonsSkipped;
  final int bonfireLessons;
  final bool tapMode;
  final int tapChanges;

  /// Day number of the first hold-to-tap change; null with none.
  final int? firstTapChangeDay;
  final bool haptics;
  final List<CheckInWindow> checkIns;

  /// Commitments extended at least once (the first extension is free).
  final int freeExtensions;

  /// Extensions after the first, each paid with a flask.
  final int flaskExtensions;
  final int lateStrikes;

  /// Days 1 to 7, so far. Null only if today is before the install day.
  final WeekPromises? week1;

  /// Days 22 to 28; null before day 22.
  final WeekPromises? week4;

  int get strikes => strikesBy.values.fold(0, (a, b) => a + b);

  /// Null with no strikes.
  double? get triedPerStrike => strikes == 0 ? null : tried / strikes;
}

/// The §12 signals as of [today] (Stage 6 plan D5 to D7).
Signals computeSignals(SignalInput input, String today) {
  final visits = input.visitDays.toSet();
  final fallen = {
    for (final m in input.marks)
      if (m.kind == SignalKind.fell)
        dayOf(m.at, rolloverHour: input.rolloverHour),
  };

  ReturnCount count(Iterable<String> days) {
    var returned = 0;
    var judged = 0;
    var pending = 0;
    for (final day in days) {
      final next = shiftDay(day, 1);
      if (next.compareTo(today) >= 0) {
        pending++;
      } else {
        judged++;
        if (visits.contains(next)) returned++;
      }
    }
    return ReturnCount(returned: returned, judged: judged, pending: pending);
  }

  final firstWeek = fallen
      .where((d) => dayNumber(input.firstDay, d) <= 7)
      .toList();

  final strikesBy = <Weight?, int>{
    for (final w in [...Weight.values, null]) w: 0,
  };
  var tried = 0;
  var written = 0;
  var skipped = 0;
  for (final a in input.attempts) {
    switch (a.outcome) {
      case Outcome.strike:
        strikesBy[a.weight] = strikesBy[a.weight]! + 1;
      case Outcome.tried:
        tried++;
      case Outcome.fallen:
        a.hasLesson ? written++ : skipped++;
    }
  }

  final taps = [
    for (final m in input.marks)
      if (m.kind == SignalKind.tapModeChanged) m,
  ]..sort((a, b) => a.at.compareTo(b.at));

  final checkIns = [for (final from in kCheckInDays) _window(input, from)];

  final sortedVisits = [...visits]..sort();
  return Signals(
    firstDay: input.firstDay,
    today: today,
    dayNumber: dayNumber(input.firstDay, today),
    firstVisit: sortedVisits.isEmpty ? null : sortedVisits.first,
    fallenDays: fallen.length,
    afterFalls: count(fallen),
    firstWeekFalls: firstWeek.length,
    firstWeekReturns: count(firstWeek),
    strikesBy: strikesBy,
    tried: tried,
    fallLessonsWritten: written,
    fallLessonsSkipped: skipped,
    bonfireLessons: input.bonfireLessons,
    tapMode: input.tapMode,
    tapChanges: taps.length,
    firstTapChangeDay: taps.isEmpty
        ? null
        : dayNumber(input.firstDay, taps.first.day),
    haptics: input.haptics,
    checkIns: checkIns,
    freeExtensions: input.commits.where((c) => c.extensions > 0).length,
    flaskExtensions: input.commits.fold(
      0,
      (sum, c) => sum + (c.extensions > 1 ? c.extensions - 1 : 0),
    ),
    lateStrikes: input.commits
        .where((c) => c.outcome == CommitmentOutcome.lateStrike)
        .length,
    week1: _week(input, today, 1),
    week4: _week(input, today, 22),
  );
}

WeekPromises? _week(SignalInput input, String today, int from) {
  final now = dayNumber(input.firstDay, today);
  if (now < from) return null;
  final inWeek = [
    for (final c in input.commits)
      if (dayNumber(input.firstDay, c.day) case final n
          when n >= from && n < from + 7 && n <= now)
        c,
  ];
  return WeekPromises(
    made: inWeek.where((c) => c.outcome != CommitmentOutcome.cancelled).length,
    kept: inWeek.where((c) => c.outcome == CommitmentOutcome.kept).length,
    days: (now - from + 1).clamp(1, 7),
  );
}

CheckInWindow _window(SignalInput input, int from) {
  final inWindow = [
    for (final m in input.marks)
      if ((m.kind == SignalKind.checkIn ||
              m.kind == SignalKind.checkInDismissed) &&
          checkInWindowOn(input.firstDay, m.day) == from)
        m,
  ]..sort((a, b) => a.at.compareTo(b.at));
  final answers = inWindow.where((m) => m.kind == SignalKind.checkIn);
  return CheckInWindow(
    fromDay: from,
    answer: answers.isEmpty ? null : CheckInAnswer.values[answers.last.value!],
    dismissals: inWindow
        .where((m) => m.kind == SignalKind.checkInDismissed)
        .length,
  );
}
