// dart format width=80
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test(
    'v2 to v3 keeps rows, adds empty tables and settings defaults',
    () async {
      final schema = await verifier.schemaAt(2);
      final oldDb = v2.DatabaseAtV2(schema.newConnection());
      const at = '2026-10-01T09:00:00.000';
      await oldDb.customStatement(
        "INSERT INTO bosses (id, title, status, reset_on_fail, "
        "created_at, updated_at) "
        "VALUES ('b1', 'The Certification', 0, 1, '$at', '$at')",
      );
      await oldDb.customStatement(
        "INSERT INTO attempts (id, boss_id, task_id, boss_attempt, outcome, "
        "lesson, day, at) VALUES "
        "('a1', 'b1', NULL, 1, 2, 'Start earlier.', '2026-10-02', '$at')",
      );
      await oldDb.customStatement(
        'INSERT INTO settings (id, tap_mode, default_reset_on_fail, haptics) '
        'VALUES (1, 1, 0, 0)',
      );
      await oldDb.close();

      // 2026-10-13 12:00: the upgrade day (D12).
      final db = AppDatabase(
        schema.newConnection(),
        clock: () => DateTime(2026, 10, 13, 12),
      );
      await verifier.migrateAndValidate(db, 3);

      expect(await db.customSelect('SELECT * FROM bosses').get(), hasLength(1));
      expect(
        await db.customSelect('SELECT * FROM attempts').get(),
        hasLength(1),
      );
      for (final t in ['day_logs', 'ember_events', 'plan_picks']) {
        expect(
          await db.customSelect('SELECT * FROM $t').get(),
          isEmpty,
          reason: t,
        );
      }
      final s =
          (await db.customSelect('SELECT * FROM settings').getSingle()).data;
      expect(s['tap_mode'], 1);
      expect(s['haptics'], 0);
      expect(s['rollover_hour'], 4);
      expect(s['reminder_enabled'], 0);
      expect(s['reminder_minutes'], 1260);
      expect(s['flasks'], 3);
      expect(s['last_resolved_day'], '2026-10-13');
      await db.close();
    },
  );
}
