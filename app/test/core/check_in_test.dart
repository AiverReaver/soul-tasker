import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/check_in.dart';
import 'package:hearthrise/core/signals.dart';
import 'package:hearthrise/data/enums.dart';

const _first = '2026-10-01';
String _d(int day) => '2026-10-${day.toString().padLeft(2, '0')}';

SignalMark _m(SignalKind kind, int day, [int? value]) => SignalMark(
  kind: kind,
  day: _d(day),
  at: DateTime(2026, 10, day, 21),
  value: value,
);

void main() {
  test('nothing before day 7', () {
    expect(dueCheckIn(_first, _d(6), const []), isNull);
  });

  test('window 7 opens on day 7', () {
    expect(dueCheckIn(_first, _d(7), const []), 7);
  });

  test('a dismiss hides it for the rest of that day only', () {
    final marks = [_m(SignalKind.checkInDismissed, 7)];
    expect(dueCheckIn(_first, _d(7), marks), isNull);
    expect(dueCheckIn(_first, _d(9), marks), 7);
  });

  test('three dismissals close the window', () {
    final marks = [
      _m(SignalKind.checkInDismissed, 7),
      _m(SignalKind.checkInDismissed, 8),
      _m(SignalKind.checkInDismissed, 9),
    ];
    expect(dueCheckIn(_first, _d(10), marks), isNull);
  });

  test('an answer closes the window', () {
    final marks = [_m(SignalKind.checkIn, 7, CheckInAnswer.never.index)];
    expect(dueCheckIn(_first, _d(8), marks), isNull);
  });

  test('window 14 opens on day 14 even if 7 was never answered', () {
    expect(dueCheckIn(_first, _d(14), const []), 14);
    final answered7 = [_m(SignalKind.checkIn, 8, 0)];
    expect(dueCheckIn(_first, _d(14), answered7), 14);
  });
}
