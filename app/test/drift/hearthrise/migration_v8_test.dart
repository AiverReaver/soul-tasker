// dart format width=80
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/palette.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/settings_dao.dart';

import 'generated/schema.dart';
import 'generated/schema_v7.dart' as v7;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v7 to v8 keeps the device row and starts on Pharloom', () async {
    final schema = await verifier.schemaAt(7);
    final oldDb = v7.DatabaseAtV7(schema.newConnection());
    await oldDb.customStatement(
      "INSERT INTO settings (id, last_resolved_day, onboarded) "
      "VALUES (1, '2026-10-03', 1)",
    );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 8);
    final row = await SettingsDao(db).device();
    expect(row.onboarded, isTrue);
    expect(row.lastResolvedDay, '2026-10-03');
    expect(row.biome, Biome.pharloom);
    await db.close();
  });
}
