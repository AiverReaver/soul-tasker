import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'enums.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Bosses, Phases, Tasks, Attempts, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// The on-device database.
  AppDatabase.open() : super(driftDatabase(name: 'hearthrise'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await into(settings).insert(const SettingsCompanion());
    },
    beforeOpen: (details) async {
      // SQLite leaves foreign keys off unless asked; cascades need them.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
