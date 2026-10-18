import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../core/clock.dart';
import '../core/ids.dart';
import '../core/palette.dart';
import 'database.steps.dart';
import 'day_dao.dart' show kFlaskCap;
import 'enums.dart';
import 'relic_dao.dart';
import 'sync_sql.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Bosses,
    Phases,
    Tasks,
    Attempts,
    Settings,
    DayLogs,
    EmberEvents,
    Commitments,
    HealthEvents,
    Relics,
    Visits,
    SignalEvents,
    UserSettings,
    FlaskEvents,
    Bloodstains,
    SyncOutbox,
    DayPlans,
    SyncState,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// [clock] only stamps `lastResolvedDay` and `firstDay` on create and
  /// upgrade (Stage 3 plan D12, Stage 4 plan D13).
  AppDatabase(super.e, {this._clock = DateTime.now});

  /// The on-device database.
  AppDatabase.open()
    : this(
        driftDatabase(
          name: 'hearthrise',
          native: const DriftNativeOptions(setup: registerSyncFunctions),
        ),
      );

  final Clock _clock;

  @override
  int get schemaVersion => 9;

  /// The hour a day ends. Every `dayOf` call reads this, so what is written
  /// and what is shown agree (plan step 1).
  Future<int> rolloverHour() async =>
      (await select(userSettings).getSingle()).rolloverHour;

  /// v7 moves the synced columns of [old], a v6 `settings` row, into
  /// `user_settings` (Stage 7 plan D9).
  Future<void> _copyUserSettings(QueryRow old, DateTime now) => customInsert(
    'INSERT INTO user_settings (id, tap_mode, default_reset_on_fail, '
    'haptics, rollover_hour, reminder_enabled, reminder_minutes, '
    'first_day, sound, updated_at) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    variables: [
      const Variable(kUserSettingsId),
      for (final c in const [
        'tap_mode',
        'default_reset_on_fail',
        'haptics',
        'rollover_hour',
        'reminder_enabled',
        'reminder_minutes',
      ])
        Variable<int>(old.read<int>(c)),
      Variable<String>(old.readNullable<String>('first_day')),
      Variable<int>(old.read<int>('sound')),
      Variable<DateTime>(now),
    ],
  );

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      final today = dayOf(_clock());
      await into(settings)
          .insert(SettingsCompanion(lastResolvedDay: Value(today)));
      // Defaults are as old as time, so any real choice synced from another
      // phone wins over them (Stage 7 plan D5).
      await into(userSettings).insert(
        UserSettingsCompanion.insert(
          firstDay: Value(today),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );
      await into(syncState)
          .insert(SyncStateCompanion.insert(deviceId: newId()));
    },
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await m.addColumn(schema.attempts, schema.attempts.weight);
        await m.addColumn(schema.settings, schema.settings.haptics);
      },
      from2To3: (m, schema) async {
        await m.createTable(schema.dayLogs);
        await m.createTable(schema.emberEvents);
        await m.createTable(schema.planPicks);
        await m.addColumn(schema.settings, schema.settings.rolloverHour);
        await m.addColumn(schema.settings, schema.settings.reminderEnabled);
        await m.addColumn(schema.settings, schema.settings.reminderMinutes);
        await m.addColumn(schema.settings, schema.settings.flasks);
        await m.addColumn(schema.settings, schema.settings.lastResolvedDay);
        await customStatement('UPDATE settings SET last_resolved_day = ?', [
          dayOf(_clock()),
        ]);
      },
      from3To4: (m, schema) async {
        await m.createTable(schema.commitments);
        await m.createTable(schema.healthEvents);
        await m.addColumn(schema.tasks, schema.tasks.dailyDeadlineMinutes);
        await m.addColumn(schema.settings, schema.settings.firstDay);
        // The user may have moved the rollover hour; stamp with theirs.
        final row = await customSelect('SELECT rollover_hour FROM settings')
            .getSingleOrNull();
        final hour = row?.read<int>('rollover_hour') ?? kRolloverHour;
        await customStatement('UPDATE settings SET first_day = ?', [
          dayOf(_clock(), rolloverHour: hour),
        ]);
      },
      from4To5: (m, schema) async {
        await m.createTable(schema.relics);
        await m.addColumn(schema.settings, schema.settings.sound);
        await m.addColumn(schema.settings, schema.settings.onboarded);
        // Existing installs have no use for the welcome.
        await customStatement('UPDATE settings SET onboarded = 1');
      },
      from5To6: (m, schema) async {
        await m.createTable(schema.visits);
        await m.createTable(schema.signalEvents);
        // Falls so far become signals; visits before v6 are unknown.
        final falls = await customSelect(
          'SELECT day, at FROM attempts WHERE outcome = ?',
          variables: [Variable.withInt(Outcome.fallen.index)],
        ).get();
        for (final fall in falls) {
          await customStatement(
            'INSERT INTO signal_events (id, kind, day, at) VALUES (?, ?, ?, ?)',
            [
              newId(),
              SignalKind.fell.index,
              fall.read<String>('day'),
              fall.data['at'],
            ],
          );
        }
      },
      from6To7: (m, schema) async {
        final now = _clock();
        // Read what moves before the settings table loses it.
        final old = await customSelect('SELECT * FROM settings')
            .getSingleOrNull();
        await m.createTable(schema.userSettings);
        await m.createTable(schema.flaskEvents);
        await m.createTable(schema.bloodstains);
        await m.createTable(schema.syncOutbox);
        await m.createTable(schema.dayPlans);
        await m.createTable(schema.syncState);

        final hour = old?.read<int>('rollover_hour') ?? kRolloverHour;
        final today = dayOf(now, rolloverHour: hour);
        if (old != null) {
          await _copyUserSettings(old, now);
        }
        // One event so the derived count equals the old counter (D8).
        final flasks = old?.read<int>('flasks') ?? kFlaskCap;
        if (flasks < kFlaskCap) {
          await customInsert(
            'INSERT INTO flask_events (id, kind, amount, reason, day, at) '
            'VALUES (?, ?, ?, ?, ?, ?)',
            variables: [
              Variable(newId()),
              Variable(FlaskKind.spend.index),
              Variable(kFlaskCap - flasks),
              Variable(FlaskReason.backfill.index),
              Variable(today),
              Variable<DateTime>(now),
            ],
          );
        }
        await m.alterTable(TableMigration(schema.settings));
        await m.alterTable(
          TableMigration(
            schema.attempts,
            columnTransformer: {schema.attempts.updatedAt: schema.attempts.at},
            newColumns: [schema.attempts.updatedAt],
          ),
        );
        await m.alterTable(
          TableMigration(
            schema.dayLogs,
            columnTransformer: {schema.dayLogs.updatedAt: schema.dayLogs.at},
            newColumns: [schema.dayLogs.updatedAt],
          ),
        );

        // Each day's picks become one plan, in position order (D20).
        final picks = await customSelect(
          'SELECT day, task_id FROM plan_picks ORDER BY day, position',
        ).get();
        final byDay = <String, List<String>>{};
        for (final p in picks) {
          (byDay[p.read<String>('day')] ??= []).add(p.read<String>('task_id'));
        }
        for (final MapEntry(key: day, value: ids) in byDay.entries) {
          await customInsert(
            'INSERT INTO day_plans (day, task_ids, updated_at) VALUES (?, ?, ?)',
            variables: [
              Variable(day),
              Variable(jsonEncode(ids)),
              Variable<DateTime>(now),
            ],
          );
        }
        await m.deleteTable('plan_picks');

        // No outbox rows: the first sign-in uploads everything (D16).
        await customInsert(
          'INSERT INTO sync_state (id, device_id) VALUES (1, ?)',
          variables: [Variable(newId())],
        );
      },
      from7To8: (m, schema) async {
        await m.addColumn(schema.settings, schema.settings.biome);
      },
      from8To9: (m, schema) async {
        await m.addColumn(schema.settings, schema.settings.motionEffects);
      },
    ),
    beforeOpen: (details) async {
      // SQLite leaves foreign keys off unless asked; cascades need them.
      await customStatement('PRAGMA foreign_keys = ON');
      // Bosses defeated before relics existed get one from what is left of
      // them. After the steps, so the same builder as a live defeat runs.
      if (details.hadUpgrade && (details.versionBefore ?? 5) < 5) {
        // Before v3 there is no hour; before v7 it is still in `settings`.
        final hour = switch (details.versionNow) {
          < 3 => kRolloverHour,
          < 7 =>
            (await customSelect(
                  'SELECT rollover_hour FROM settings',
                ).getSingleOrNull())?.read<int>('rollover_hour') ??
                kRolloverHour,
          _ => null,
        };
        await RelicDao(this, _clock).backfill(rolloverHour: hour);
      }
      // Change capture for sync (Stage 7 plan D14). Last, so rows written
      // by the upgrade are not queued: the first sign-in sends everything.
      if (details.versionNow >= 7) {
        for (final sql in syncTriggerSql()) {
          await customStatement(sql);
        }
      }
    },
  );
}
