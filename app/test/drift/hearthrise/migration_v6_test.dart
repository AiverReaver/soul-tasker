// dart format width=80
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/enums.dart';

import 'generated/schema.dart';
import 'generated/schema_v5.dart' as v5;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  Future<void> seedV5(v5.DatabaseAtV5 db) async {
    const made = '2026-10-01T09:00:00.000';
    await db.customStatement(
      "INSERT INTO bosses (id, title, status, reset_on_fail, "
      "created_at, updated_at) "
      "VALUES ('b1', 'The Garage', 0, 1, '$made', '$made')",
    );
    // Two falls (declared, missed day), one strike, one tried.
    await db.customStatement(
      "INSERT INTO attempts (id, boss_id, boss_attempt, outcome, cause, "
      "lesson, weight, day, at) VALUES "
      "('a1', 'b1', 1, 2, 0, 'Too much at once.', NULL, '2026-10-02', "
      "'2026-10-02T21:00:00.000'), "
      "('a2', 'b1', 2, 0, NULL, NULL, 1, '2026-10-03', "
      "'2026-10-03T10:00:00.000'), "
      "('a3', 'b1', 2, 1, NULL, NULL, 0, '2026-10-03', "
      "'2026-10-03T11:00:00.000'), "
      "('a4', 'b1', 2, 2, 2, NULL, NULL, '2026-10-04', "
      "'2026-10-06T08:00:00.000')",
    );
    await db.customStatement(
      "INSERT INTO ember_events (id, kind, amount, boss_id, day, at) VALUES "
      "('e1', 0, 3, 'b1', '2026-10-03', '$made')",
    );
    await db.customStatement(
      'INSERT INTO settings (id, tap_mode, default_reset_on_fail, haptics, '
      'rollover_hour, flasks, last_resolved_day, first_day, sound, '
      "onboarded) VALUES (1, 0, 0, 1, 4, 3, '2026-10-06', '2026-10-01', "
      '0, 1)',
    );
  }

  test('v5 to v6 keeps rows, adds visits, backfills fell events', () async {
    final schema = await verifier.schemaAt(5);
    final oldDb = v5.DatabaseAtV5(schema.newConnection());
    await seedV5(oldDb);
    await oldDb.close();

    final db = AppDatabase(
      schema.newConnection(),
      clock: () => DateTime(2026, 10, 16, 12),
    );
    await verifier.migrateAndValidate(db, 6);

    expect(await db.customSelect('SELECT * FROM bosses').get(), hasLength(1));
    expect(await db.customSelect('SELECT * FROM attempts').get(), hasLength(4));
    expect(
      await db.customSelect('SELECT * FROM ember_events').get(),
      hasLength(1),
    );
    final s = await db.select(db.settings).getSingle();
    expect(s.onboarded, isTrue);
    expect(s.firstDay, '2026-10-01');

    expect(await db.select(db.visits).get(), isEmpty);

    final events = await (db.select(
      db.signalEvents,
    )..orderBy([(e) => OrderingTerm(expression: e.at)])).get();
    expect(events, hasLength(2));
    expect(events.map((e) => e.kind), everyElement(SignalKind.fell));
    expect(events.map((e) => e.day), ['2026-10-02', '2026-10-04']);
    // Same instant as the fallen attempt it came from.
    final falls =
        await (db.select(db.attempts)
              ..where((a) => a.outcome.equalsValue(Outcome.fallen))
              ..orderBy([(a) => OrderingTerm(expression: a.at)]))
            .get();
    expect(events.map((e) => e.at), falls.map((a) => a.at));
    expect(events.map((e) => e.value), everyElement(isNull));
    expect(events.map((e) => e.id).toSet(), hasLength(2));
    await db.close();
  });

  test(
    'fell events have no foreign key: deleting the boss keeps them',
    () async {
      final schema = await verifier.schemaAt(5);
      final oldDb = v5.DatabaseAtV5(schema.newConnection());
      await seedV5(oldDb);
      await oldDb.close();

      final db = AppDatabase(
        schema.newConnection(),
        clock: () => DateTime(2026, 10, 16, 12),
      );
      await db.customStatement("DELETE FROM bosses WHERE id = 'b1'");
      expect(await db.customSelect('SELECT * FROM attempts').get(), isEmpty);
      expect(await db.select(db.signalEvents).get(), hasLength(2));
      await db.close();
    },
  );

  test('a fresh database has no visits and no signal events', () async {
    final db = AppDatabase(
      NativeDatabase.memory(),
      clock: () => DateTime(2026, 10, 16, 12),
    );
    expect(await db.select(db.visits).get(), isEmpty);
    expect(await db.select(db.signalEvents).get(), isEmpty);
    await db.close();
  });
}
