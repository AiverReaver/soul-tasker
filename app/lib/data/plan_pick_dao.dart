import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show immutable;

import '../core/clock.dart';
import 'boss_dao.dart';
import 'database.dart';
import 'enums.dart';

/// Most tasks a day's plan holds (§5.6, rule of three).
const kMaxPicks = 3;

/// An open task that could be picked for tomorrow.
@immutable
class PickCandidate {
  const PickCandidate({
    required this.taskId,
    required this.title,
    required this.bossTitle,
    required this.weight,
  });

  final String taskId;
  final String title;
  final String bossTitle;
  final Weight weight;
}

/// A task picked for a day, with whether it is struck now.
@immutable
class PlannedTask {
  const PlannedTask({
    required this.task,
    required this.bossTitle,
    required this.isStruck,
  });

  final Task task;
  final String bossTitle;
  final bool isStruck;
}

/// Tomorrow's three (Stage 3 plan D11).
class PlanPickDao {
  PlanPickDao(this._db, this._bosses, this._clock);

  final AppDatabase _db;
  final BossDao _bosses;
  final Clock _clock;

  /// Open tasks of active bosses, for the bonfire's picker.
  Future<List<PickCandidate>> candidates() async => [
    for (final view in await _bosses.loadAll())
      if (view.boss.status == BossStatus.active)
        for (final t in view.allTasks)
          if (!t.isStruck)
            PickCandidate(
              taskId: t.task.id,
              title: t.task.title,
              bossTitle: view.boss.title,
              weight: t.task.weight,
            ),
  ];

  /// Replaces the picks for [day]. At most [kMaxPicks], in the given order.
  Future<void> setPicks(String day, List<String> taskIds) {
    if (taskIds.length > kMaxPicks) {
      throw ArgumentError('A day holds at most $kMaxPicks picks.');
    }
    return _db.transaction(() async {
      await (_db.delete(_db.planPicks)..where((p) => p.day.equals(day))).go();
      for (final (i, id) in taskIds.indexed) {
        await _db
            .into(_db.planPicks)
            .insert(
              PlanPicksCompanion.insert(day: day, taskId: id, position: i),
            );
      }
    });
  }

  Future<List<PlannedTask>> picksFor(String day) async {
    final rows =
        await (_db.select(_db.planPicks)
              ..where((p) => p.day.equals(day))
              ..orderBy([(p) => OrderingTerm.asc(p.position)]))
            .get();
    if (rows.isEmpty) return const [];
    final byTask = {
      for (final view in await _bosses.loadAll())
        for (final t in view.allTasks) t.task.id: (t, view.boss.title),
    };
    return [
      for (final row in rows)
        if (byTask[row.taskId] case (final t, final bossTitle))
          PlannedTask(task: t.task, bossTitle: bossTitle, isStruck: t.isStruck),
    ];
  }

  Future<List<PlannedTask>> _today() async =>
      picksFor(dayOf(_clock(), rolloverHour: await _db.rolloverHour()));

  /// Today's picks, again after any change to plans, tasks or strikes.
  Stream<List<PlannedTask>> watchToday() async* {
    yield await _today();
    yield* _db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            _db.planPicks,
            _db.bosses,
            _db.tasks,
            _db.attempts,
            _db.settings,
          ]),
        )
        .asyncMap((_) => _today());
  }
}
