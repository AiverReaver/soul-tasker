// dart format width=80
import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v4.dart' as v4;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  Future<void> seedV4(v4.DatabaseAtV4 db) async {
    const made = '2026-10-01T09:00:00.000';
    const won = '2026-10-05T10:00:00.000';
    // b1 is defeated on its third attempt; b2 is still active.
    await db.customStatement(
      "INSERT INTO bosses (id, title, defeat_meaning, status, "
      "attempt_number, reset_on_fail, created_at, updated_at, defeated_at) "
      "VALUES ('b1', 'The Certification', 'I am certified', 2, 3, 1, "
      "'$made', '$won', '$won')",
    );
    await db.customStatement(
      "INSERT INTO bosses (id, title, status, reset_on_fail, "
      "created_at, updated_at) "
      "VALUES ('b2', 'The Garage', 0, 1, '$made', '$made')",
    );
    await db.customStatement(
      "INSERT INTO phases (id, boss_id, name, position, created_at, "
      "updated_at) VALUES ('p2', 'b1', 'Fight', 1, '$made', '$made'), "
      "('p1', 'b1', 'Learn', 0, '$made', '$made')",
    );
    await db.customStatement(
      "INSERT INTO tasks (id, boss_id, phase_id, title, weight, recurrence, "
      "position, created_at, updated_at) "
      "VALUES ('t1', 'b1', 'p1', 'Read', 0, 0, 0, '$made', '$made')",
    );
    await db.customStatement(
      "INSERT INTO attempts (id, boss_id, boss_attempt, outcome, cause, "
      "lesson, day, at) VALUES "
      "('a1', 'b1', 1, 2, 0, 'Started too late.', '2026-10-02', "
      "'2026-10-02T21:00:00.000'), "
      "('a2', 'b1', 2, 2, 2, NULL, '2026-10-03', '2026-10-03T21:00:00.000'), "
      "('a3', 'b1', 2, 2, 0, 'Skipped the warm-up.', '2026-10-04', "
      "'2026-10-04T21:00:00.000')",
    );
    await db.customStatement(
      "INSERT INTO ember_events (id, kind, amount, boss_id, day, at) VALUES "
      "('e1', 0, 3, 'b1', '2026-10-02', '$made'), "
      "('e2', 0, 1, 'b1', '2026-10-03', '$made'), "
      "('e3', 0, 5, 'b2', '2026-10-03', '$made'), "
      "('e4', 1, 9, NULL, '2026-10-03', '$made')",
    );
    await db.customStatement(
      'INSERT INTO settings (id, tap_mode, default_reset_on_fail, haptics, '
      'rollover_hour, flasks, last_resolved_day, first_day) '
      "VALUES (1, 0, 0, 1, 4, 3, '2026-10-05', '2026-10-01')",
    );
  }

  test(
    'v4 to v5 keeps rows, adds sound and onboarded, backfills relics',
    () async {
      final schema = await verifier.schemaAt(4);
      final oldDb = v4.DatabaseAtV4(schema.newConnection());
      await seedV4(oldDb);
      await oldDb.close();

      final db = AppDatabase(
        schema.newConnection(),
        clock: () => DateTime(2026, 10, 13, 12),
      );
      await verifier.migrateAndValidate(db, 5);

      expect(await db.customSelect('SELECT * FROM bosses').get(), hasLength(2));
      expect(
        await db.customSelect('SELECT * FROM attempts').get(),
        hasLength(3),
      );
      expect(
        await db.customSelect('SELECT * FROM ember_events').get(),
        hasLength(4),
      );
      final s =
          (await db.customSelect('SELECT * FROM settings').getSingle()).data;
      expect(s['sound'], 0);
      expect(s['onboarded'], 1);
      expect(s['flasks'], 3);

      final relics = await db.select(db.relics).get();
      expect(relics, hasLength(1));
      final relic = relics.single;
      expect(relic.bossId, 'b1');
      expect(relic.name, 'Relic of The Certification');
      expect(relic.attempts, 3);
      expect(relic.days, 5);
      expect(relic.effort, 4);
      expect(relic.defeatedDay, '2026-10-05');
      expect(relic.inscription, isNull);
      final story = jsonDecode(relic.story) as Map<String, dynamic>;
      expect(story['phases'], ['Learn', 'Fight']);
      expect((story['lessons'] as List).map((l) => (l as Map)['text']), [
        'Started too late.',
        'Skipped the warm-up.',
      ]);
      await db.close();
    },
  );

  test('a fresh database has no relics and is not onboarded', () async {
    final db = AppDatabase(
      NativeDatabase.memory(),
      clock: () => DateTime(2026, 10, 13, 12),
    );
    final s = await db.select(db.settings).getSingle();
    expect(s.onboarded, isFalse);
    expect((await db.select(db.userSettings).getSingle()).sound, isFalse);
    expect(await db.select(db.relics).get(), isEmpty);
    await db.close();
  });
}
