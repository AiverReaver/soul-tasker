import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/clock.dart';

void main() {
  test('formatClock shows minutes from midnight as a 12-hour time', () {
    expect(formatClock(0), '12:00 AM');
    expect(formatClock(4 * 60), '4:00 AM');
    expect(formatClock(12 * 60), '12:00 PM');
    expect(formatClock(21 * 60), '9:00 PM');
    expect(formatClock(18 * 60 + 5), '6:05 PM');
    expect(formatClock(23 * 60 + 59), '11:59 PM');
  });
}
