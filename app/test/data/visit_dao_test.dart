import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/visit_dao.dart';

import 'harness.dart';

void main() {
  late Harness h;
  late VisitDao visits;
  setUp(() {
    h = Harness();
    visits = VisitDao(h.db, h.clock.call);
  });
  tearDown(() => h.db.close());

  test(
    'record writes the ritual day with the time of the first open',
    () async {
      await visits.record();

      final row = (await h.db.select(h.db.visits).get()).single;
      expect(row.day, '2026-10-13');
      expect(row.firstAt, DateTime(2026, 10, 13, 12, 0, 1));
    },
  );

  test('a second open the same day keeps the first time', () async {
    await visits.record();
    h.clock.now = DateTime(2026, 10, 13, 20);
    await visits.record();

    final rows = await h.db.select(h.db.visits).get();
    expect(rows, hasLength(1));
    expect(rows.single.firstAt, DateTime(2026, 10, 13, 12, 0, 1));
  });

  test('03:59 and 04:00 with rollover 4 are different days', () async {
    h.clock.now = DateTime(2026, 10, 14, 3, 58, 59);
    await visits.record();
    h.clock.now = DateTime(2026, 10, 14, 3, 59, 59);
    await visits.record();

    expect(await visits.days(), ['2026-10-13', '2026-10-14']);
  });

  test('the user rollover hour decides the day', () async {
    await h.settings.setRolloverHour(0);
    h.clock.now = DateTime(2026, 10, 14, 1);
    await visits.record();

    expect(await visits.days(), ['2026-10-14']);
  });

  test('days come back sorted, oldest first', () async {
    h.clock.now = DateTime(2026, 10, 16, 12);
    await visits.record();
    h.clock.now = DateTime(2026, 10, 14, 12);
    await visits.record();

    expect(await visits.days(), ['2026-10-14', '2026-10-16']);
  });
}
