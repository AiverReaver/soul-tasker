// dart format width=80
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/settings_dao.dart';

import 'generated/schema.dart';
import 'generated/schema_v8.dart' as v8;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v8 to v9 keeps the device row and turns motion effects on', () async {
    final schema = await verifier.schemaAt(8);
    final oldDb = v8.DatabaseAtV8(schema.newConnection());
    await oldDb.customStatement(
      "INSERT INTO settings (id, last_resolved_day, onboarded) "
      "VALUES (1, '2026-10-03', 1)",
    );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 9);
    final row = await SettingsDao(db).device();
    expect(row.onboarded, isTrue);
    expect(row.lastResolvedDay, '2026-10-03');
    expect(row.motionEffects, isTrue);
    await db.close();
  });
}
