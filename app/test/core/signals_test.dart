import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/clock.dart';
import 'package:hearthrise/core/signals.dart';
import 'package:hearthrise/data/enums.dart';

// Install day 2026-10-01 is day 1; rollover 4 AM.
const _first = '2026-10-01';

SignalMark _fell(DateTime at) =>
    SignalMark(kind: SignalKind.fell, day: '', at: at);

SignalInput _input({
  List<String> visits = const [],
  List<SignalMark> marks = const [],
  List<AttemptMark> attempts = const [],
  int bonfireLessons = 0,
  bool tapMode = false,
  List<CommitMark> commits = const [],
}) => SignalInput(
  firstDay: _first,
  rolloverHour: 4,
  visitDays: visits,
  marks: marks,
  attempts: attempts,
  bonfireLessons: bonfireLessons,
  tapMode: tapMode,
  haptics: true,
  commits: commits,
);

DateTime _on(int day, [int hour = 21]) => DateTime(2026, 10, day, hour);
String _d(int day) => '2026-10-${day.toString().padLeft(2, '0')}';

void main() {
  group('return after a fall', () {
    test('a fall on day 1 and a visit on day 2: returned 1 of 1', () {
      final s = computeSignals(
        _input(visits: [_d(1), _d(2)], marks: [_fell(_on(1))]),
        _d(10),
      );
      expect(s.afterFalls.returned, 1);
      expect(s.afterFalls.judged, 1);
      expect(s.afterFalls.pending, 0);
    });

    test('no visit the next day, one the day after: returned 0 of 1', () {
      final s = computeSignals(
        _input(visits: [_d(3), _d(5)], marks: [_fell(_on(3))]),
        _d(10),
      );
      expect(s.afterFalls.returned, 0);
      expect(s.afterFalls.judged, 1);
    });

    test('a fall today or yesterday is pending, not judged', () {
      final s = computeSignals(
        _input(visits: [_d(9), _d(10)], marks: [_fell(_on(9)), _fell(_on(10))]),
        _d(10),
      );
      expect(s.afterFalls.judged, 0);
      expect(s.afterFalls.pending, 2);
    });

    test('three falls on one day count as one fallen day', () {
      final s = computeSignals(
        _input(
          visits: [_d(4)],
          marks: [_fell(_on(3, 9)), _fell(_on(3, 10)), _fell(_on(3, 11))],
        ),
        _d(10),
      );
      expect(s.fallenDays, 1);
      expect(s.afterFalls.returned, 1);
      expect(s.afterFalls.judged, 1);
    });

    test('a fall at 03:30 belongs to the day before', () {
      final s = computeSignals(
        _input(visits: [_d(4)], marks: [_fell(DateTime(2026, 10, 4, 3, 30))]),
        _d(10),
      );
      // Fallen day is the 3rd, so the visit on the 4th is a return.
      expect(s.afterFalls.returned, 1);
    });

    test('the fallen day comes from when it was felt, not the attempt day', () {
      // A missed 2nd judged when the app opened on the 3rd.
      final mark = SignalMark(
        kind: SignalKind.fell,
        day: _d(2),
        at: _on(3, 12),
      );
      final s = computeSignals(
        _input(visits: [_d(3), _d(4)], marks: [mark]),
        _d(10),
      );
      expect(s.afterFalls.returned, 1);
      expect(s.afterFalls.judged, 1);
    });
  });

  group('first week', () {
    test('falls on days 1 to 7 count; day 8 does not', () {
      final s = computeSignals(
        _input(
          visits: [_d(2), _d(9)],
          marks: [_fell(_on(1)), _fell(_on(7)), _fell(_on(8))],
        ),
        _d(20),
      );
      expect(s.firstWeekFalls, 2);
      expect(s.firstWeekReturns.returned, 1);
      expect(s.firstWeekReturns.judged, 2);
      expect(s.afterFalls.judged, 3);
      expect(s.afterFalls.returned, 2);
    });
  });

  group('attempts', () {
    test('strikes by weight, tried and Tried per Strike', () {
      final s = computeSignals(
        _input(
          attempts: const [
            AttemptMark(outcome: Outcome.strike, weight: Weight.light),
            AttemptMark(outcome: Outcome.strike, weight: Weight.light),
            AttemptMark(outcome: Outcome.strike, weight: Weight.bossTier),
            AttemptMark(outcome: Outcome.strike),
            AttemptMark(outcome: Outcome.tried, weight: Weight.heavy),
            AttemptMark(outcome: Outcome.tried, weight: Weight.light),
          ],
        ),
        _d(10),
      );
      expect(s.strikes, 4);
      expect(s.strikesBy[Weight.light], 2);
      expect(s.strikesBy[Weight.heavy], 0);
      expect(s.strikesBy[Weight.bossTier], 1);
      expect(s.strikesBy[null], 1);
      expect(s.tried, 2);
      expect(s.triedPerStrike, 0.5);
    });

    test('lessons on falls written vs skipped, plus bonfire lessons', () {
      final s = computeSignals(
        _input(
          attempts: const [
            AttemptMark(outcome: Outcome.fallen, hasLesson: true),
            AttemptMark(outcome: Outcome.fallen),
            AttemptMark(outcome: Outcome.fallen),
          ],
          bonfireLessons: 4,
        ),
        _d(10),
      );
      expect(s.fallLessonsWritten, 1);
      expect(s.fallLessonsSkipped, 2);
      expect(s.bonfireLessons, 4);
    });
  });

  group('tap mode', () {
    test('change count and the day of the first change', () {
      final s = computeSignals(
        _input(
          tapMode: true,
          marks: [
            SignalMark(
              kind: SignalKind.tapModeChanged,
              day: _d(5),
              at: _on(5),
              value: 1,
            ),
            SignalMark(
              kind: SignalKind.tapModeChanged,
              day: _d(6),
              at: _on(6),
              value: 0,
            ),
            SignalMark(
              kind: SignalKind.tapModeChanged,
              day: _d(9),
              at: _on(9),
              value: 1,
            ),
          ],
        ),
        _d(10),
      );
      expect(s.tapMode, isTrue);
      expect(s.tapChanges, 3);
      expect(s.firstTapChangeDay, 5);
    });

    test('no change gives null first day', () {
      final s = computeSignals(_input(), _d(10));
      expect(s.tapChanges, 0);
      expect(s.firstTapChangeDay, isNull);
    });
  });

  group('check-ins', () {
    test('latest answer and dismissals per window', () {
      SignalMark mark(SignalKind kind, int day, [int? value]) =>
          SignalMark(kind: kind, day: _d(day), at: _on(day), value: value);
      final s = computeSignals(
        _input(
          marks: [
            mark(SignalKind.checkInDismissed, 7),
            mark(SignalKind.checkIn, 8, CheckInAnswer.sometimes.index),
            mark(SignalKind.checkInDismissed, 14),
            mark(SignalKind.checkInDismissed, 15),
          ],
        ),
        _d(20),
      );
      expect(s.checkIns, hasLength(2));
      expect(s.checkIns[0].fromDay, 7);
      expect(s.checkIns[0].answer, CheckInAnswer.sometimes);
      expect(s.checkIns[0].dismissals, 1);
      expect(s.checkIns[1].fromDay, 14);
      expect(s.checkIns[1].answer, isNull);
      expect(s.checkIns[1].dismissals, 2);
    });
  });

  test('day numbers count the install day as day 1', () {
    expect(dayNumber(_first, _d(1)), 1);
    expect(dayNumber(_first, _d(7)), 7);
    expect(dayNumber(_first, '2026-11-01'), 32);
  });

  test('empty input gives zeros and no ratio', () {
    final s = computeSignals(_input(), _d(1));
    expect(s.fallenDays, 0);
    expect(s.afterFalls.judged, 0);
    expect(s.afterFalls.returned, 0);
    expect(s.firstWeekFalls, 0);
    expect(s.strikes, 0);
    expect(s.tried, 0);
    expect(s.triedPerStrike, isNull);
    expect(s.firstVisit, isNull);
    expect(s.dayNumber, 1);
  });

  group('promises', () {
    CommitMark c(int day, {int ext = 0, CommitmentOutcome? outcome}) =>
        CommitMark(day: _d(day), extensions: ext, outcome: outcome);

    test('free and flask extensions, late strikes', () {
      final s = computeSignals(
        _input(
          commits: [
            c(1, ext: 1),
            c(2, ext: 2),
            c(3, ext: 3),
            c(4, outcome: CommitmentOutcome.lateStrike),
            c(5, outcome: CommitmentOutcome.lateStrike),
            c(5),
          ],
        ),
        _d(10),
      );
      expect(s.freeExtensions, 3);
      expect(s.flaskExtensions, 3);
      expect(s.lateStrikes, 2);
    });

    test('week 1 counts days 1 to 7; cancelled are not made', () {
      final s = computeSignals(
        _input(
          commits: [
            c(1, outcome: CommitmentOutcome.kept),
            c(1, outcome: CommitmentOutcome.missed),
            c(7, outcome: CommitmentOutcome.kept),
            c(7, outcome: CommitmentOutcome.cancelled),
            c(8, outcome: CommitmentOutcome.kept),
          ],
        ),
        _d(10),
      );
      expect(s.week1!.made, 3);
      expect(s.week1!.kept, 2);
      expect(s.week1!.days, 7);
      expect(s.week4, isNull);
    });

    test('week 4 is days 22 to 28, partial while it runs', () {
      final s = computeSignals(
        _input(
          commits: [
            c(21, outcome: CommitmentOutcome.kept),
            c(22, outcome: CommitmentOutcome.kept),
            c(23, outcome: CommitmentOutcome.tried),
          ],
        ),
        _d(23),
      );
      expect(s.week4!.made, 2);
      expect(s.week4!.kept, 1);
      expect(s.week4!.days, 2);
    });

    test('week 1 is partial on day 3', () {
      final s = computeSignals(_input(), _d(3));
      expect(s.week1!.days, 3);
      expect(s.week1!.made, 0);
    });
  });
}
