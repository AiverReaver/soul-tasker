// dart format width=80
import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/flask_dao.dart';

import 'generated/schema.dart';
import 'generated/schema_v6.dart' as v6;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  const made = '2026-10-01T09:00:00.000';

  Future<void> seedV6(v6.DatabaseAtV6 db, {int flasks = 1}) async {
    await db.customStatement(
      "INSERT INTO bosses (id, title, status, reset_on_fail, "
      "created_at, updated_at) "
      "VALUES ('b1', 'The Garage', 0, 1, '$made', '$made'), "
      "('b2', 'The Novel', 2, 0, '$made', '$made')",
    );
    await db.customStatement(
      "INSERT INTO tasks (id, boss_id, title, weight, recurrence, position, "
      "created_at, updated_at) VALUES "
      "('t1', 'b1', 'Sweep', 0, 0, 0, '$made', '$made'), "
      "('t2', 'b1', 'Shelves', 1, 0, 1, '$made', '$made'), "
      "('t3', 'b1', 'Bins', 0, 1, 2, '$made', '$made')",
    );
    await db.customStatement(
      "INSERT INTO attempts (id, boss_id, task_id, boss_attempt, outcome, "
      "cause, lesson, weight, day, at) VALUES "
      "('a1', 'b1', NULL, 1, 2, 0, 'Too much.', NULL, '2026-10-02', "
      "'2026-10-02T21:00:00.000'), "
      "('a2', 'b1', 't1', 2, 0, NULL, NULL, 0, '2026-10-03', "
      "'2026-10-03T10:00:00.000')",
    );
    await db.customStatement(
      "INSERT INTO commitments (id, task_id, boss_id, day, deadline, "
      "extensions, remind, outcome, resolved_at, created_at, updated_at) "
      "VALUES ('c1', 't2', 'b1', '2026-10-03', '2026-10-03T18:00:00.000', "
      "0, 0, 2, '2026-10-03T18:00:00.000', '$made', '$made')",
    );
    await db.customStatement(
      "INSERT INTO health_events (id, amount, reason, commitment_id, day, at) "
      "VALUES ('h1', -2, 0, 'c1', '2026-10-03', '2026-10-03T18:00:00.000')",
    );
    await db.customStatement(
      "INSERT INTO ember_events (id, kind, amount, boss_id, task_id, day, at) "
      "VALUES ('e1', 0, 1, 'b1', 't1', '2026-10-03', "
      "'2026-10-03T10:00:00.000')",
    );
    await db.customStatement(
      "INSERT INTO relics (id, boss_id, name, emblem, attempts, days, effort, "
      "story, inscription, defeated_day, created_at, updated_at) VALUES "
      "('r1', 'b2', 'The Novel', 0, 1, 3, 4, '{}', 'Done.', '2026-10-05', "
      "'$made', '$made')",
    );
    await db.customStatement(
      "INSERT INTO day_logs (day, kind, lesson, at) VALUES "
      "('2026-10-03', 0, 'Rest.', '2026-10-03T22:00:00.000'), "
      "('2026-10-04', 1, NULL, '2026-10-04T08:00:00.000')",
    );
    // Two days of picks, inserted out of position order.
    await db.customStatement(
      'INSERT INTO plan_picks (day, task_id, position) VALUES '
      "('2026-10-04', 't3', 2), ('2026-10-04', 't1', 0), "
      "('2026-10-04', 't2', 1), ('2026-10-05', 't2', 0)",
    );
    await db.customStatement(
      'INSERT INTO settings (id, tap_mode, default_reset_on_fail, haptics, '
      'rollover_hour, reminder_enabled, reminder_minutes, flasks, '
      "last_resolved_day, first_day, sound, onboarded) VALUES (1, 1, 2, 0, 3, "
      "1, 1200, $flasks, '2026-10-06', '2026-10-01', 1, 1)",
    );
  }

  Future<AppDatabase> upgraded({int flasks = 1}) async {
    final schema = await verifier.schemaAt(6);
    final oldDb = v6.DatabaseAtV6(schema.newConnection());
    await seedV6(oldDb, flasks: flasks);
    await oldDb.close();
    final db = AppDatabase(
      schema.newConnection(),
      clock: () => DateTime(2026, 10, 16, 12),
    );
    await verifier.migrateAndValidate(db, 8);
    return db;
  }

  Future<int> count(AppDatabase db, String table) async =>
      (await db.customSelect('SELECT * FROM $table').get()).length;

  test('v6 to v7 keeps every record', () async {
    final db = await upgraded();
    expect(await count(db, 'bosses'), 2);
    expect(await count(db, 'tasks'), 3);
    expect(await count(db, 'attempts'), 2);
    expect(await count(db, 'commitments'), 1);
    expect(await count(db, 'health_events'), 1);
    expect(await count(db, 'ember_events'), 1);
    final relic = (await db.select(db.relics).get()).single;
    expect(relic.inscription, 'Done.');
    await db.close();
  });

  test('derived flasks equal the old counter', () async {
    for (final n in [0, 1, 2, 3]) {
      final db = await upgraded(flasks: n);
      expect(await FlaskDao(db, () => DateTime(2026, 10, 16)).count(), n);
      // A full counter needs no event.
      expect(await count(db, 'flask_events'), n == 3 ? 0 : 1);
      await db.close();
    }
  });

  test('user settings are copied; per-device settings stay', () async {
    final db = await upgraded();
    final u = await db.select(db.userSettings).getSingle();
    expect(u.tapMode, isTrue);
    expect(u.defaultResetOnFail, ResetOnFail.wholeBoss);
    expect(u.haptics, isFalse);
    expect(u.rolloverHour, 3);
    expect(u.reminderEnabled, isTrue);
    expect(u.reminderMinutes, 1200);
    expect(u.sound, isTrue);
    expect(u.firstDay, '2026-10-01');
    final d = await db.select(db.settings).getSingle();
    expect(d.lastResolvedDay, '2026-10-06');
    expect(d.onboarded, isTrue);
    expect(await db.rolloverHour(), 3);
    await db.close();
  });

  test('attempts get updatedAt from at', () async {
    final db = await upgraded();
    final attempts = await db.select(db.attempts).get();
    expect(attempts, hasLength(2));
    for (final a in attempts) {
      expect(a.updatedAt, a.at);
    }
    await db.close();
  });

  test('day logs get updatedAt from at', () async {
    final db = await upgraded();
    final logs = await (db.select(
      db.dayLogs,
    )..orderBy([(l) => OrderingTerm(expression: l.day)])).get();
    expect(logs, hasLength(2));
    for (final l in logs) {
      expect(l.updatedAt, l.at);
    }
    expect(logs.first.lesson, 'Rest.');
    await db.close();
  });

  test('each day of picks becomes one day plan, in position order', () async {
    final db = await upgraded();
    final plans = await (db.select(
      db.dayPlans,
    )..orderBy([(p) => OrderingTerm(expression: p.day)])).get();
    expect(plans.map((p) => p.day), ['2026-10-04', '2026-10-05']);
    expect(jsonDecode(plans[0].taskIds), ['t1', 't2', 't3']);
    expect(jsonDecode(plans[1].taskIds), ['t2']);
    expect(
      await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE name = 'plan_picks'",
          )
          .get(),
      isEmpty,
    );
    await db.close();
  });

  test('sync state has a device id and cursor 0; outbox is empty', () async {
    final db = await upgraded();
    final s = await db.select(db.syncState).getSingle();
    expect(s.deviceId, isNotEmpty);
    expect(s.cursor, 0);
    expect(s.applying, isFalse);
    expect(s.accountEmail, isNull);
    expect(await count(db, 'sync_outbox'), 0);
    expect(await count(db, 'bloodstains'), 0);
    await db.close();
  });

  test('a fresh database has the v7 single rows', () async {
    final db = AppDatabase(
      NativeDatabase.memory(),
      clock: () => DateTime(2026, 10, 16, 12),
    );
    final u = await db.select(db.userSettings).getSingle();
    expect(u.firstDay, '2026-10-16');
    expect(u.rolloverHour, 4);
    expect((await db.select(db.settings).getSingle()).onboarded, isFalse);
    expect((await db.select(db.syncState).getSingle()).deviceId, isNotEmpty);
    expect(await FlaskDao(db, () => DateTime(2026, 10, 16)).count(), 3);
    expect(await count(db, 'sync_outbox'), 0);
    await db.close();
  });
}
