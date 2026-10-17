import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/day_dao.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/flask_dao.dart';

import 'harness.dart';

void main() {
  group('foldFlasks (D8)', () {
    FlaskStep spend(int n) => (kind: FlaskKind.spend, amount: n);
    const restore = (kind: FlaskKind.restore, amount: 1);

    test('starts full', () => expect(foldFlasks(const []), kFlaskCap));

    test('spends and restores add up', () {
      expect(foldFlasks([spend(1)]), 2);
      expect(foldFlasks([spend(2), restore]), 2);
    });

    test('clamps at the cap per step, in order', () {
      // Restore at full is lost; the later spend still counts.
      expect(foldFlasks([restore, spend(1)]), 2);
      expect(foldFlasks([spend(1), restore]), 3);
    });

    test('clamps at 0 per step, in order', () {
      expect(foldFlasks([spend(3), spend(1), restore]), 1);
      expect(foldFlasks([spend(5)]), 0);
    });
  });

  group('FlaskDao', () {
    late Harness h;
    late FlaskDao flasks;
    setUp(() {
      h = Harness();
      flasks = FlaskDao(h.db, h.clock.call);
    });
    tearDown(() => h.db.close());

    test('spend and restore write events and change the count', () async {
      expect(await flasks.count(), 3);
      await flasks.spend(1, FlaskReason.skipDay, '2026-10-13');
      expect(await flasks.count(), 2);
      await flasks.restore(FlaskReason.bonfire, '2026-10-13');
      expect(await flasks.count(), 3);
      final events = await h.db.select(h.db.flaskEvents).get();
      expect(events.map((e) => e.kind), [FlaskKind.spend, FlaskKind.restore]);
      expect(events.first.reason, FlaskReason.skipDay);
      expect(events.first.day, '2026-10-13');
    });

    test('order is by time, not by insert', () async {
      final at = h.clock.now;
      await flasks.restore(
        FlaskReason.bonfire,
        '2026-10-13',
        at: at.add(const Duration(hours: 1)),
      );
      await flasks.spend(1, FlaskReason.skipDay, '2026-10-13', at: at);
      // Spend first (2), then restore (3).
      expect(await flasks.count(), 3);
    });

    test('adjustTo writes one event that reaches the target', () async {
      await flasks.adjustTo(1, '2026-10-13');
      expect(await flasks.count(), 1);
      await flasks.adjustTo(1, '2026-10-13');
      expect(await h.db.select(h.db.flaskEvents).get(), hasLength(1));
      await flasks.adjustTo(3, '2026-10-13');
      expect(await flasks.count(), 3);
    });
  });

  test('DayDao answers match the event count', () async {
    final h = Harness();
    final flasks = FlaskDao(h.db, h.clock.call);
    final days = DayDao(h.db, h.clock.call, h.attempts);
    expect((await days.today()).flasks, 3);
    expect(await days.skipToday(), isTrue);
    expect((await days.today()).flasks, 2);
    expect(await flasks.count(), 2);
    await h.db.close();
  });
}
