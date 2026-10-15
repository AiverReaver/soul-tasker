import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show immutable;

import '../core/clock.dart';
import '../core/deadlines.dart';
import '../core/ids.dart';
import '../core/missed_days.dart';
import 'database.dart';
import 'enums.dart';

/// A commitment with what the screens show next to it.
@immutable
class CommitmentView {
  const CommitmentView({
    required this.commitment,
    required this.taskTitle,
    required this.bossTitle,
    required this.weight,
  });

  final Commitment commitment;
  final String taskTitle;
  final String bossTitle;
  final Weight weight;
}

/// The calm note for a heavy day (Stage 4 plan D17).
@immutable
class LoadNote {
  const LoadNote({required this.count, required this.heavy});

  final int count;

  /// Heavy and Boss-tier promises.
  final int heavy;

  @override
  bool operator ==(Object other) =>
      other is LoadNote && other.count == count && other.heavy == heavy;

  @override
  int get hashCode => Object.hash(count, heavy);

  @override
  String toString() => 'LoadNote($count, heavy: $heavy)';
}

/// One day's or one week's promises (§5.12, plan D16).
@immutable
class DayRecord {
  const DayRecord({
    required this.made,
    required this.kept,
    this.healthLost = 0,
    this.fell = false,
  });

  /// Promises made, not counting those set aside with a waiting boss.
  final int made;

  /// Struck before the deadline, extended or not.
  final int kept;

  /// Half points lost.
  final int healthLost;
  final bool fell;
}

/// The note shows from this many promises in a day.
const kLoadNoteCount = 6;

/// Promises: commit, extend, read (§5.12).
class CommitmentDao {
  CommitmentDao(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  /// Commits [taskId] for today. Returns the new id, or null, writing
  /// nothing, when the task is already committed today or its boss is not
  /// active.
  Future<String?> commit(
    String taskId,
    DeadlinePreset preset, {
    bool remind = false,
  }) => _db.transaction(() async {
    final now = _clock();
    final hour = await _db.rolloverHour();
    final day = dayOf(now, rolloverHour: hour);
    final task = await (_db.select(
      _db.tasks,
    )..where((t) => t.id.equals(taskId))).getSingle();
    final boss = await (_db.select(
      _db.bosses,
    )..where((b) => b.id.equals(task.bossId))).getSingle();
    if (boss.status != BossStatus.active) return null;
    final existing = await (_db.select(
      _db.commitments,
    )..where((c) => c.taskId.equals(taskId) & c.day.equals(day))).get();
    if (existing.isNotEmpty) return null;
    final id = newId();
    await _db
        .into(_db.commitments)
        .insert(
          CommitmentsCompanion.insert(
            id: id,
            taskId: taskId,
            bossId: boss.id,
            day: day,
            deadline: deadlineFor(preset, now, rolloverHour: hour),
            remind: Value(remind),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  });

  /// Moves an open commitment's deadline later (plan D10). The first move is
  /// free, each later one spends a flask. False, changing nothing, after the
  /// deadline, without a flask when one is due, or when [preset] is not
  /// later than the current deadline.
  Future<bool> extend(String id, DeadlinePreset preset) => _db.transaction(
    () async {
      final now = _clock();
      final c = await (_db.select(
        _db.commitments,
      )..where((c) => c.id.equals(id))).getSingle();
      if (c.outcome != null || !now.isBefore(c.deadline)) return false;
      final next = deadlineFor(
        preset,
        now,
        rolloverHour: await _db.rolloverHour(),
      );
      if (!next.isAfter(c.deadline)) return false;
      final settings = await _db.select(_db.settings).getSingle();
      final costsFlask = c.extensions >= 1;
      if (costsFlask && settings.flasks == 0) return false;
      if (costsFlask) {
        await _db
            .update(_db.settings)
            .write(SettingsCompanion(flasks: Value(settings.flasks - 1)));
      }
      await (_db.update(_db.commitments)..where((r) => r.id.equals(id))).write(
        CommitmentsCompanion(
          deadline: Value(next),
          extensions: Value(c.extensions + 1),
          updatedAt: Value(now),
        ),
      );
      return true;
    },
  );

  /// Today's commitments by task id, again whenever a commitment or the
  /// settings change.
  Stream<Map<String, CommitmentView>> watchToday() async* {
    Future<Map<String, CommitmentView>> read() async {
      final day = dayOf(_clock(), rolloverHour: await _db.rolloverHour());
      return {for (final v in await load(day)) v.commitment.taskId: v};
    }

    yield await read();
    yield* _db
        .tableUpdates(
          TableUpdateQuery.onAllTables([_db.commitments, _db.settings]),
        )
        .asyncMap((_) => read());
  }

  /// A day's commitments in deadline order.
  Future<List<CommitmentView>> load(String day) async {
    final query =
        _db.select(_db.commitments).join([
            innerJoin(
              _db.tasks,
              _db.tasks.id.equalsExp(_db.commitments.taskId),
            ),
            innerJoin(
              _db.bosses,
              _db.bosses.id.equalsExp(_db.commitments.bossId),
            ),
          ])
          ..where(_db.commitments.day.equals(day))
          ..orderBy([OrderingTerm.asc(_db.commitments.deadline)]);
    return [
      for (final row in await query.get())
        CommitmentView(
          commitment: row.readTable(_db.commitments),
          taskTitle: row.readTable(_db.tasks).title,
          bossTitle: row.readTable(_db.bosses).title,
          weight: row.readTable(_db.tasks).weight,
        ),
    ];
  }

  /// [day]'s promises made and kept, health lost, and whether a health
  /// death happened.
  Future<DayRecord> record(String day) async {
    final rows = await (_db.select(
      _db.commitments,
    )..where((c) => c.day.equals(day))).get();
    final lost = await (_db.select(
      _db.healthEvents,
    )..where((e) => e.day.equals(day) & e.amount.isSmallerThanValue(0))).get();
    final deaths =
        await (_db.select(_db.attempts)..where(
              (a) =>
                  a.day.equals(day) &
                  a.cause.equalsValue(FallCause.healthDeath),
            ))
            .get();
    return DayRecord(
      made: rows.where((c) => c.outcome != CommitmentOutcome.cancelled).length,
      kept: rows.where((c) => c.outcome == CommitmentOutcome.kept).length,
      healthLost: lost.fold(0, (sum, e) => sum - e.amount),
      fell: deaths.isNotEmpty,
    );
  }

  /// Made and kept over the seven days ending with [today].
  Future<DayRecord> week(String today) async {
    var made = 0;
    var kept = 0;
    for (var i = 6; i >= 0; i--) {
      final r = await record(shiftDay(today, -i));
      made += r.made;
      kept += r.kept;
    }
    return DayRecord(made: made, kept: kept);
  }

  /// The calm note once a day holds [kLoadNoteCount] promises, else null.
  Future<LoadNote?> loadNote(String day) async {
    final made = [
      for (final v in await load(day))
        if (v.commitment.outcome != CommitmentOutcome.cancelled) v,
    ];
    if (made.length < kLoadNoteCount) return null;
    return LoadNote(
      count: made.length,
      heavy: made.where((v) => v.weight != Weight.light).length,
    );
  }

  /// Sets or clears the standing daily deadline of a daily task (plan D12).
  Future<void> setStanding(String taskId, int? minutes) async {
    if (minutes != null) RangeError.checkValueInInterval(minutes, 0, 1439);
    final task = await (_db.select(
      _db.tasks,
    )..where((t) => t.id.equals(taskId))).getSingle();
    if (task.recurrence != Recurrence.daily) {
      throw ArgumentError('Only a daily task has a standing deadline.');
    }
    await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId))).write(
      TasksCompanion(
        dailyDeadlineMinutes: Value(minutes),
        updatedAt: Value(_clock()),
      ),
    );
  }
}
