import 'package:drift/drift.dart';

import '../core/clock.dart';
import 'database.dart';
import 'enums.dart';
import 'signal_dao.dart';

/// The single settings row (id 1), created with the database.
class SettingsDao {
  SettingsDao(this._db, [this._clock = DateTime.now]);

  final AppDatabase _db;
  final Clock _clock;

  Future<AppSettings> read() => _db.select(_db.settings).getSingle();

  Stream<AppSettings> watch() => _db.select(_db.settings).watchSingle();

  /// Logs each real change for the tester report (Stage 6 plan D4).
  Future<void> setTapMode(bool isOn) => _db.transaction(() async {
    if ((await read()).tapMode == isOn) return;
    await _db
        .update(_db.settings)
        .write(SettingsCompanion(tapMode: Value(isOn)));
    await SignalDao(
      _db,
      _clock,
    ).add(SignalKind.tapModeChanged, value: isOn ? 1 : 0);
  });

  Future<void> setHaptics(bool isOn) =>
      _db.update(_db.settings).write(SettingsCompanion(haptics: Value(isOn)));

  Future<void> setOnboarded(bool isDone) => _db
      .update(_db.settings)
      .write(SettingsCompanion(onboarded: Value(isDone)));

  Future<void> setSound(bool isOn) =>
      _db.update(_db.settings).write(SettingsCompanion(sound: Value(isOn)));

  /// A day ends at this local hour (0 to 6, plan D10).
  Future<void> setRolloverHour(int hour) {
    RangeError.checkValueInInterval(hour, 0, 6, 'hour');
    return _db
        .update(_db.settings)
        .write(SettingsCompanion(rolloverHour: Value(hour)));
  }

  /// [minutes] is from midnight, 0 to 1439.
  Future<void> setReminder({required bool enabled, required int minutes}) {
    RangeError.checkValueInInterval(minutes, 0, 1439, 'minutes');
    return _db
        .update(_db.settings)
        .write(
          SettingsCompanion(
            reminderEnabled: Value(enabled),
            reminderMinutes: Value(minutes),
          ),
        );
  }

  Future<void> setDefaultReset(ResetOnFail reset) => _db
      .update(_db.settings)
      .write(SettingsCompanion(defaultResetOnFail: Value(reset)));
}
