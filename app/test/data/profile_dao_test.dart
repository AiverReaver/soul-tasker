import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/deadlines.dart';
import 'package:hearthrise/data/commitment_dao.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/day_dao.dart';
import 'package:hearthrise/data/ember_dao.dart';
import 'package:hearthrise/data/profile_dao.dart';

import 'harness.dart';

void main() {
  late Harness h;
  late ProfileDao profile;
  late EmberDao embers;
  setUp(() {
    h = Harness();
    profile = ProfileDao(h.db, h.clock.call);
    embers = EmberDao(h.db, h.clock.call);
  });
  tearDown(() => h.db.close());

  Future<void> earn(String taskTitle) async {
    final view = await h.seed();
    await h.attempts.strike(taskNamed(view, taskTitle).task.id);
  }

  test('lifetime banked sums bank events only', () async {
    expect((await profile.read()).banked, 0);
    await earn('Read chapter 4'); // heavy: 3 carried
    expect((await profile.read()).banked, 0);
    await embers.bank();
    expect((await profile.read()).banked, 3);
    expect((await profile.read()).level.level, 1);
  });

  test('spending a flask or resting never lowers it', () async {
    await earn('Read chapter 4');
    await embers.bank();
    await h.db
        .update(h.db.settings)
        .write(const SettingsCompanion(flasks: Value(0)));
    final days = DayDao(h.db, h.clock.call, h.attempts);
    await days.rest();
    final p = await profile.read();
    expect(p.banked, 3);
    expect(p.flasks, 1);
  });

  test(
    'watchProfile updates after a bank and after a flask is spent',
    () async {
      final seen = <ProfileData>[];
      final sub = profile.watch().listen(seen.add);
      await pumpEventQueue();
      expect(seen.last.banked, 0);
      expect(seen.last.flasks, 3);
      expect(seen.last.today.made, 0);

      await earn('Read chapter 4');
      await embers.bank();
      await pumpEventQueue();
      expect(seen.last.banked, 3);

      await h.db
          .update(h.db.settings)
          .write(const SettingsCompanion(flasks: Value(2)));
      await pumpEventQueue();
      expect(seen.last.flasks, 2);
      expect(seen.last.banked, 3);
      await sub.cancel();
    },
  );

  test("carries today's record and the week's from the commitments", () async {
    final view = await h.seed();
    final task = taskNamed(view, 'Read chapter 4').task;
    await CommitmentDao(
      h.db,
      h.clock.call,
    ).commit(task.id, DeadlinePreset.tonight);
    await h.attempts.strike(task.id);
    final p = await profile.read();
    expect(p.today.made, 1);
    expect(p.today.kept, 1);
    expect(p.week.made, 1);
  });
}
