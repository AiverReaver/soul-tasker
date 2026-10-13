import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/clock.dart';

void main() {
  test('03:59 belongs to the previous day', () {
    expect(dayOf(DateTime(2026, 10, 13, 3, 59)), '2026-10-12');
  });

  test('04:00 starts a new day', () {
    expect(dayOf(DateTime(2026, 10, 13, 4)), '2026-10-13');
  });

  test('rollover crosses month and year boundaries', () {
    expect(dayOf(DateTime(2026, 11, 1, 1)), '2026-10-31');
    expect(dayOf(DateTime(2027, 1, 1, 2)), '2026-12-31');
  });

  test('uses local calendar fields, so DST days still roll at 04:00', () {
    // Whatever the offset on this day, the hour field decides.
    expect(dayOf(DateTime(2026, 3, 8, 4, 30)), '2026-03-08');
    expect(dayOf(DateTime(2026, 3, 8, 3, 30)), '2026-03-07');
  });
}
