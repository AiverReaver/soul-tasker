import 'package:drift/drift.dart';

import 'database.dart';
import 'enums.dart';

/// The single settings row (id 1), created with the database.
class SettingsDao {
  SettingsDao(this._db);

  final AppDatabase _db;

  Stream<AppSettings> watch() => _db.select(_db.settings).watchSingle();

  Future<void> setTapMode(bool isOn) =>
      _db.update(_db.settings).write(SettingsCompanion(tapMode: Value(isOn)));

  Future<void> setHaptics(bool isOn) =>
      _db.update(_db.settings).write(SettingsCompanion(haptics: Value(isOn)));

  Future<void> setDefaultReset(ResetOnFail reset) => _db
      .update(_db.settings)
      .write(SettingsCompanion(defaultResetOnFail: Value(reset)));
}
