import 'package:drift/drift.dart';

import '../core/clock.dart';
import '../core/palette.dart';
import 'database.dart';
import 'enums.dart';
import 'signal_dao.dart';

/// The synced settings row and this phone's own row (Stage 7 plan D9).
/// Every synced write stamps `updatedAt`, the last-write-wins key.
class SettingsDao {
  SettingsDao(this._db, [this._clock = DateTime.now]);

  final AppDatabase _db;
  final Clock _clock;

  Future<AppSettings> read() => _db.select(_db.userSettings).getSingle();

  Stream<AppSettings> watch() => _db.select(_db.userSettings).watchSingle();

  /// What only this phone keeps: onboarding and missed-day bookkeeping.
  Stream<DeviceSettings> watchDevice() =>
      _db.select(_db.settings).watchSingle();

  Future<DeviceSettings> device() => _db.select(_db.settings).getSingle();

  Future<void> _write(UserSettingsCompanion change) => _db
      .update(_db.userSettings)
      .write(change.copyWith(updatedAt: Value(_clock())));

  /// Logs each real change for the tester report (Stage 6 plan D4).
  Future<void> setTapMode(bool isOn) => _db.transaction(() async {
    if ((await read()).tapMode == isOn) return;
    await _write(UserSettingsCompanion(tapMode: Value(isOn)));
    await SignalDao(
      _db,
      _clock,
    ).add(SignalKind.tapModeChanged, value: isOn ? 1 : 0);
  });

  Future<void> setHaptics(bool isOn) =>
      _write(UserSettingsCompanion(haptics: Value(isOn)));

  Future<void> setOnboarded(bool isDone) => _db
      .update(_db.settings)
      .write(SettingsCompanion(onboarded: Value(isDone)));

  Future<void> setBiome(Biome biome) =>
      _db.update(_db.settings).write(SettingsCompanion(biome: Value(biome)));

  Future<void> setSound(bool isOn) =>
      _write(UserSettingsCompanion(sound: Value(isOn)));

  /// A day ends at this local hour (0 to 6, plan D10).
  Future<void> setRolloverHour(int hour) {
    RangeError.checkValueInInterval(hour, 0, 6, 'hour');
    return _write(UserSettingsCompanion(rolloverHour: Value(hour)));
  }

  /// [minutes] is from midnight, 0 to 1439.
  Future<void> setReminder({required bool enabled, required int minutes}) {
    RangeError.checkValueInInterval(minutes, 0, 1439, 'minutes');
    return _write(
      UserSettingsCompanion(
        reminderEnabled: Value(enabled),
        reminderMinutes: Value(minutes),
      ),
    );
  }

  Future<void> setDefaultReset(ResetOnFail reset) =>
      _write(UserSettingsCompanion(defaultResetOnFail: Value(reset)));
}
