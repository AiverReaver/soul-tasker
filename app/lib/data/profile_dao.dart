import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show immutable;

import '../core/clock.dart';
import '../core/level.dart';
import 'commitment_dao.dart';
import 'database.dart';
import 'enums.dart';

/// What the profile shows: lifetime banked embers, the level they give,
/// flasks, and planning accuracy (Stage 5 plan D9, D10).
@immutable
class ProfileData {
  const ProfileData({
    required this.banked,
    required this.level,
    required this.flasks,
    required this.today,
    required this.week,
  });

  final int banked;
  final LevelInfo level;
  final int flasks;
  final DayRecord today;
  final DayRecord week;
}

class ProfileDao {
  ProfileDao(this._db, this._clock) : _commitments = CommitmentDao(_db, _clock);

  final AppDatabase _db;
  final Clock _clock;
  final CommitmentDao _commitments;

  Future<ProfileData> read() async {
    final banked =
        await (_db.selectOnly(_db.emberEvents)
              ..addColumns([_db.emberEvents.amount.sum()])
              ..where(_db.emberEvents.kind.equals(EmberKind.bank.index)))
            .map((r) => r.read(_db.emberEvents.amount.sum()) ?? 0)
            .getSingle();
    final settings = await _db.select(_db.settings).getSingle();
    final today = dayOf(_clock(), rolloverHour: settings.rolloverHour);
    return ProfileData(
      banked: banked,
      level: levelFor(banked),
      flasks: settings.flasks,
      today: await _commitments.record(today),
      week: await _commitments.week(today),
    );
  }

  /// Again after every change to embers, settings or commitments.
  Stream<ProfileData> watch() async* {
    yield await read();
    yield* _db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            _db.emberEvents,
            _db.settings,
            _db.commitments,
            _db.healthEvents,
          ]),
        )
        .asyncMap((_) => read());
  }
}
