import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/boss_view.dart';

import 'harness.dart';

// The write side (attempt `day`) and the read side (`isStruck`, "today")
// must use the same rollover hour (plan step 1, D10).
void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() => h.db.close());

  Future<String> dayOfOnlyAttempt() async =>
      (await h.db.select(h.db.attempts).getSingle()).day;

  group('write side', () {
    test('rollover 4: a 03:00 strike belongs to the previous day', () async {
      final view = await h.seed();
      h.clock.now = DateTime(2026, 10, 14, 3);
      await h.attempts.strike(taskNamed(view, 'Walk').task.id);
      expect(await dayOfOnlyAttempt(), '2026-10-13');
    });

    test('rollover 2: a 03:00 strike belongs to the same day', () async {
      final view = await h.seed();
      await h.settings.setRolloverHour(2);
      h.clock.now = DateTime(2026, 10, 14, 3);
      await h.attempts.strike(taskNamed(view, 'Walk').task.id);
      expect(await dayOfOnlyAttempt(), '2026-10-14');
    });

    test('changing the hour never rewrites old rows (D10)', () async {
      final view = await h.seed();
      h.clock.now = DateTime(2026, 10, 14, 3);
      await h.attempts.strike(taskNamed(view, 'Walk').task.id);
      await h.settings.setRolloverHour(2);
      expect(await dayOfOnlyAttempt(), '2026-10-13');
    });
  });

  group('read side', () {
    test('rollover 2: a 03:00 daily strike shows struck, and a second '
        'strike writes nothing', () async {
      final view = await h.seed();
      await h.settings.setRolloverHour(2);
      h.clock.now = DateTime(2026, 10, 14, 3);
      final id = taskNamed(view, 'Walk').task.id;
      await h.attempts.strike(id);

      final one = await h.reload(view.boss.id);
      expect(taskNamed(one, 'Walk').isStruck, isTrue);
      final all = await h.bosses.loadAll();
      expect(taskNamed(all.single, 'Walk').isStruck, isTrue);

      await h.attempts.strike(id);
      expect(await h.db.select(h.db.attempts).get(), hasLength(1));
    });

    test('rollover 4: a 03:00 strike stays struck until 04:00', () async {
      final view = await h.seed();
      h.clock.now = DateTime(2026, 10, 14, 3);
      await h.attempts.strike(taskNamed(view, 'Walk').task.id);

      expect(taskNamed(await h.reload(view.boss.id), 'Walk').isStruck, isTrue);
      h.clock.now = DateTime(2026, 10, 14, 4);
      expect(taskNamed(await h.reload(view.boss.id), 'Walk').isStruck, isFalse);
    });

    test('an open boss stream re-emits when the hour changes', () async {
      final view = await h.seed();
      h.clock.now = DateTime(2026, 10, 14, 3);
      await h.attempts.strike(taskNamed(view, 'Walk').task.id);

      final seen = <bool>[];
      final sub = h.bosses.watchAll().listen(
        (List<BossView> v) => seen.add(taskNamed(v.single, 'Walk').isStruck),
      );
      addTearDown(sub.cancel);
      await pumpEventQueue(times: 50);
      expect(seen.last, isTrue);

      // Hour 2 makes 03:00 the next day, so the day-13 strike is yesterday's.
      await h.settings.setRolloverHour(2);
      await pumpEventQueue(times: 50);
      expect(seen.last, isFalse);
    });
  });
}
