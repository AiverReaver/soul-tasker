// dart format width=80
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;

const _tables = ['bosses', 'phases', 'tasks', 'attempts', 'settings'];

Future<Map<String, List<Map<String, Object?>>>> _dump(
  GeneratedDatabase db,
) async => {
  for (final t in _tables)
    t: [
      for (final r in await db.customSelect('SELECT * FROM $t').get()) r.data,
    ],
};

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // Every schema update with no data: written migrations must produce the
    // schema the generated snapshot describes.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test('v1 to v2 keeps every row; haptics on, attempt weight null', () async {
    final schema = await verifier.schemaAt(1);
    final oldDb = v1.DatabaseAtV1(schema.newConnection());
    const at = '2026-10-01T09:00:00.000';
    await oldDb.customStatement(
      "INSERT INTO bosses (id, title, status, reset_on_fail, "
      "created_at, updated_at) "
      "VALUES ('b1', 'The Certification', 0, 1, '$at', '$at')",
    );
    await oldDb.customStatement(
      "INSERT INTO phases (id, boss_id, name, position, created_at, "
      "updated_at) VALUES ('p1', 'b1', 'Learn', 0, '$at', '$at')",
    );
    await oldDb.customStatement(
      "INSERT INTO tasks (id, boss_id, phase_id, title, weight, recurrence, "
      "position, created_at, updated_at) "
      "VALUES ('t1', 'b1', 'p1', 'Read chapter 4', 1, 0, 0, '$at', '$at')",
    );
    await oldDb.customStatement(
      "INSERT INTO attempts (id, boss_id, task_id, boss_attempt, outcome, "
      "lesson, day, at) VALUES "
      "('a1', 'b1', 't1', 1, 0, NULL, '2026-10-01', '$at'), "
      "('a2', 'b1', NULL, 1, 2, 'Start earlier.', '2026-10-02', '$at')",
    );
    await oldDb.customStatement(
      'INSERT INTO settings (id, tap_mode, default_reset_on_fail) '
      'VALUES (1, 1, 0)',
    );
    final before = await _dump(oldDb);
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 2);
    final after = await _dump(db);

    const added = {'attempts': 'weight', 'settings': 'haptics'};
    for (final t in _tables) {
      final kept = [
        for (final row in after[t]!)
          {
            for (final e in row.entries)
              if (e.key != added[t]) e.key: e.value,
          },
      ];
      expect(kept, before[t], reason: 'table $t');
    }
    expect(after['settings']!.single['tap_mode'], 1);
    expect(after['settings']!.single['haptics'], 1);
    expect(after['attempts']!.map((r) => r['weight']), [null, null]);
    await db.close();
  });
}
