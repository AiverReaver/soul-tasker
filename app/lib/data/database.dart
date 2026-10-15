import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../core/clock.dart';
import 'database.steps.dart';
import 'enums.dart';
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
    PlanPicks,
    Commitments,
    HealthEvents,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// [clock] only stamps `lastResolvedDay` and `firstDay` on create and
  /// upgrade (Stage 3 plan D12, Stage 4 plan D13).
  AppDatabase(super.e, {this._clock = DateTime.now});

  /// The on-device database.
  AppDatabase.open() : this(driftDatabase(name: 'hearthrise'));

  final Clock _clock;

  @override
  int get schemaVersion => 4;

  /// The hour a day ends. Every `dayOf` call reads this, so what is written
  /// and what is shown agree (plan step 1).
  Future<int> rolloverHour() async =>
      (await select(settings).getSingle()).rolloverHour;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      final today = dayOf(_clock());
      await into(settings).insert(
        SettingsCompanion(
          lastResolvedDay: Value(today),
          firstDay: Value(today),
        ),
      );
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
    ),
    beforeOpen: (details) async {
      // SQLite leaves foreign keys off unless asked; cascades need them.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
