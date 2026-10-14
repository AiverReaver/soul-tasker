import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show immutable;

import '../core/clock.dart';
import 'database.dart';
import 'ember_dao.dart';
import 'enums.dart';

/// Flask charges never exceed this (Stage 3 plan D5).
const kFlaskCap = 3;

const _maxLesson = 120;

/// What covers today, and the flasks left.
@immutable
class DayStatus {
  const DayStatus({required this.kinds, required this.flasks});

  final Set<DayKind> kinds;
  final int flasks;

  /// Today's bonfire rest has happened (D9).
  bool get isRested => kinds.contains(DayKind.bonfire);

  /// A flask or a rest already covers today.
  bool get isCovered => isRested || kinds.contains(DayKind.flask);
}

/// The day's ritual state: bonfire rests, flasks and light days. Rows are only
/// ever inserted; the flask count is the one counter, kept in settings.
class DayDao {
  DayDao(this._db, this._clock) : _embers = EmberDao(_db, _clock);

  final AppDatabase _db;
  final Clock _clock;
  final EmberDao _embers;

  Future<String> _today() async =>
      dayOf(_clock(), rolloverHour: await _db.rolloverHour());

  Future<Set<DayKind>> _kindsOn(String day) async => {
    for (final l in await (_db.select(
      _db.dayLogs,
    )..where((l) => l.day.equals(day))).get())
      l.kind,
  };

  Future<int> _flasks() async =>
      (await _db.select(_db.settings).getSingle()).flasks;

  Future<void> _setFlasks(int count) => _db
      .update(_db.settings)
      .write(SettingsCompanion(flasks: Value(count.clamp(0, kFlaskCap))));

  Future<void> _log(String day, DayKind kind, DateTime at, [String? lesson]) =>
      _db
          .into(_db.dayLogs)
          .insert(
            DayLogsCompanion.insert(
              day: day,
              kind: kind,
              lesson: Value(lesson),
              at: at,
            ),
          );

  Future<DayStatus> today() async =>
      DayStatus(kinds: await _kindsOn(await _today()), flasks: await _flasks());

  Stream<DayStatus> watchToday() async* {
    yield await today();
    yield* _db
        .tableUpdates(TableUpdateQuery.onAllTables([_db.dayLogs, _db.settings]))
        .asyncMap((_) => today());
  }

  /// Rests at the bonfire: banks the carried embers, restores one flask, keeps
  /// the lesson. Returns false, changing nothing, if today was already rested.
  Future<bool> rest({String? lesson}) => _db.transaction(() async {
    final day = await _today();
    if ((await _kindsOn(day)).contains(DayKind.bonfire)) return false;
    final trimmed = lesson?.trim() ?? '';
    await _log(
      day,
      DayKind.bonfire,
      _clock(),
      trimmed.isEmpty
          ? null
          : trimmed.substring(0, trimmed.length.clamp(0, _maxLesson)),
    );
    await _embers.bank();
    await _setFlasks(await _flasks() + 1);
    return true;
  });

  /// Spends a flask to cover today. False if none is left or today is
  /// already covered.
  Future<bool> skipToday() => _db.transaction(() async {
    final day = await _today();
    final flasks = await _flasks();
    if (flasks == 0 || (await _kindsOn(day)).any(_isCover)) return false;
    await _log(day, DayKind.flask, _clock());
    await _setFlasks(flasks - 1);
    return true;
  });

  /// Marks today a light day. It counts only if a task is struck (D8).
  Future<bool> markLight() => _db.transaction(() async {
    final day = await _today();
    if ((await _kindsOn(day)).contains(DayKind.light)) return false;
    await _log(day, DayKind.light, _clock());
    return true;
  });

  static bool _isCover(DayKind kind) =>
      kind == DayKind.bonfire || kind == DayKind.flask;
}
