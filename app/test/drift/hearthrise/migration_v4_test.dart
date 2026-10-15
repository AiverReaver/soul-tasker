// dart format width=80
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v3.dart' as v3;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  Future<void> seedV3(v3.DatabaseAtV3 db, {required int rolloverHour}) async {
    const at = '2026-10-01T09:00:00.000';
    await db.customStatement(
      "INSERT INTO bosses (id, title, status, reset_on_fail, "
      "created_at, updated_at) "
      "VALUES ('b1', 'The Certification', 0, 1, '$at', '$at')",
    );
    await db.customStatement(
      "INSERT INTO tasks (id, boss_id, title, weight, recurrence, position, "
      "created_at, updated_at) "
      "VALUES ('t1', 'b1', 'Walk', 0, 1, 0, '$at', '$at')",
    );
    await db.customStatement(
      "INSERT INTO attempts (id, boss_id, task_id, boss_attempt, outcome, "
      "day, at) VALUES ('a1', 'b1', 't1', 1, 0, '2026-10-02', '$at')",
    );
    await db.customStatement(
      "INSERT INTO day_logs (day, kind, at) VALUES ('2026-10-02', 0, '$at')",
    );
    await db.customStatement(
      "INSERT INTO ember_events (id, kind, amount, day, at) "
      "VALUES ('e1', 0, 1, '2026-10-02', '$at')",
    );
    await db.customStatement(
      "INSERT INTO plan_picks (day, task_id, position) "
      "VALUES ('2026-10-03', 't1', 0)",
    );
    await db.customStatement(
      'INSERT INTO settings (id, tap_mode, default_reset_on_fail, haptics, '
      'rollover_hour, flasks, last_resolved_day) '
      "VALUES (1, 1, 0, 0, $rolloverHour, 2, '2026-10-12')",
    );
  }

  test('v3 to v4 keeps rows, adds empty tables, stamps firstDay', () async {
    final schema = await verifier.schemaAt(3);
    final oldDb = v3.DatabaseAtV3(schema.newConnection());
    await seedV3(oldDb, rolloverHour: 4);
    await oldDb.close();

    final db = AppDatabase(
      schema.newConnection(),
      clock: () => DateTime(2026, 10, 13, 12),
    );
    await verifier.migrateAndValidate(db, 4);

    for (final t in [
      'bosses',
      'tasks',
      'attempts',
      'day_logs',
      'ember_events',
      'plan_picks',
    ]) {
      expect(
        await db.customSelect('SELECT * FROM $t').get(),
        hasLength(1),
        reason: t,
      );
    }
    for (final t in ['commitments', 'health_events']) {
      expect(
        await db.customSelect('SELECT * FROM $t').get(),
        isEmpty,
        reason: t,
      );
    }
    final task =
        (await db.customSelect('SELECT * FROM tasks').getSingle()).data;
    expect(task['daily_deadline_minutes'], isNull);
    final s =
        (await db.customSelect('SELECT * FROM settings').getSingle()).data;
    expect(s['flasks'], 2);
    expect(s['last_resolved_day'], '2026-10-12');
    expect(s['first_day'], '2026-10-13');
    await db.close();
  });

  test('v4 upgrade stamps firstDay with the stored rollover hour', () async {
    final schema = await verifier.schemaAt(3);
    final oldDb = v3.DatabaseAtV3(schema.newConnection());
    await seedV3(oldDb, rolloverHour: 2);
    await oldDb.close();

    // 03:00: with the stored hour 2 this is already 2026-10-13; with the
    // default hour 4 it would still be 2026-10-12.
    final db = AppDatabase(
      schema.newConnection(),
      clock: () => DateTime(2026, 10, 13, 3),
    );
    await verifier.migrateAndValidate(db, 4);
    final s =
        (await db.customSelect('SELECT * FROM settings').getSingle()).data;
    expect(s['first_day'], '2026-10-13');
    await db.close();
  });

  test('a fresh database stamps firstDay with the default hour', () async {
    final db = AppDatabase(
      NativeDatabase.memory(),
      clock: () => DateTime(2026, 10, 13, 3),
    );
    final s = await db.select(db.settings).getSingle();
    expect(s.firstDay, '2026-10-12');
    await db.close();
  });
}
