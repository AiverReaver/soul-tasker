import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/days_left.dart';

void main() {
  final now = DateTime(2026, 10, 18, 12);

  test('no target date, or one already past, gives nothing', () {
    expect(daysLeftLabel(null, now), isNull);
    expect(daysLeftLabel(DateTime(2026, 10, 18, 11), now), isNull);
  });

  test('counts whole days up, so the last day reads "1 day left"', () {
    expect(daysLeftLabel(DateTime(2026, 10, 18, 20), now), '1 day left');
    expect(daysLeftLabel(DateTime(2026, 10, 19, 12), now), '1 day left');
    expect(daysLeftLabel(DateTime(2026, 10, 27, 12), now), '9 days left');
  });
}
