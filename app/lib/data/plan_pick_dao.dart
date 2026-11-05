import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show immutable;

import '../core/clock.dart';
import '../core/missed_days.dart';
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

/// Replaces the plan for [day], saved whole as one row (Stage 7 plan D20).
/// At most [kMaxPicks], in the given order. Call inside a transaction to make
/// it part of a larger write.
Future<void> writePicks(
  AppDatabase db,
  String day,
  List<String> taskIds,
  DateTime at,
) async {
  if (taskIds.length > kMaxPicks) {
    throw ArgumentError('A day holds at most $kMaxPicks picks.');
  }
  await db
      .into(db.dayPlans)
      .insertOnConflictUpdate(
        DayPlansCompanion.insert(
          day: day,
          taskIds: jsonEncode(taskIds),
          updatedAt: at,
        ),
      );
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

  Future<void> setPicks(String day, List<String> taskIds) =>
      _db.transaction(() => writePicks(_db, day, taskIds, _clock()));

  /// Saves the picks for the day after the current one.
  Future<void> setTomorrow(List<String> taskIds) async => setPicks(
    shiftDay(dayOf(_clock(), rolloverHour: await _db.rolloverHour()), 1),
    taskIds,
  );

  Future<List<PlannedTask>> picksFor(String day) async {
    final plan = await (_db.select(
      _db.dayPlans,
    )..where((p) => p.day.equals(day))).getSingleOrNull();
    final ids = plan == null
        ? const <String>[]
        : (jsonDecode(plan.taskIds) as List).cast<String>();
    if (ids.isEmpty) return const [];
    final byTask = {
      for (final view in await _bosses.loadAll())
        if (view.boss.status == BossStatus.active)
          for (final t in view.allTasks) t.task.id: (t, view.boss.title),
    };
    final struckOnDay = {
      for (final a
          in await (_db.select(_db.attempts)..where(
                (a) =>
                    a.outcome.equalsValue(Outcome.strike) &
                    a.day.equals(day) &
                    a.taskId.isIn(ids),
              ))
              .get())
        a.taskId,
    };
    // Skipped: deleted tasks, bosses set aside or won, and one-time tasks
    // already struck before the day, which are no longer the day's work.
    return [
      for (final id in ids)
        if (byTask[id] case (final t, final bossTitle))
          if (struckOnDay.contains(id) || t.isDaily || !t.isStruck)
            PlannedTask(
              task: t.task,
              bossTitle: bossTitle,
              isStruck: struckOnDay.contains(id),
            ),
    ];
  }

  Future<List<PlannedTask>> _today() async =>
      picksFor(dayOf(_clock(), rolloverHour: await _db.rolloverHour()));

  /// The picks made for the day after the current one.
  Future<List<PlannedTask>> tomorrow() async => picksFor(
    shiftDay(dayOf(_clock(), rolloverHour: await _db.rolloverHour()), 1),
  );

  /// Today's picks, again after any change to plans, tasks or strikes.
  Stream<List<PlannedTask>> watchToday() async* {
    yield await _today();
    yield* _db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            _db.dayPlans,
            _db.bosses,
            _db.tasks,
            _db.attempts,
            _db.userSettings,
          ]),
        )
        .asyncMap((_) => _today());
  }
}
