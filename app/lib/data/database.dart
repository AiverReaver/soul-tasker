import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'database.steps.dart';
import 'enums.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Bosses, Phases, Tasks, Attempts, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// The on-device database.
  AppDatabase.open() : super(driftDatabase(name: 'hearthrise'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await into(settings).insert(const SettingsCompanion());
    },
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await m.addColumn(schema.attempts, schema.attempts.weight);
        await m.addColumn(schema.settings, schema.settings.haptics);
      },
    ),
    beforeOpen: (details) async {
      // SQLite leaves foreign keys off unless asked; cascades need them.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
