import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show immutable;

import '../core/clock.dart';
import '../core/commitment_resolver.dart';
import '../core/deadlines.dart';
import '../core/ids.dart';
import 'attempt_dao.dart';
import 'database.dart';
import 'enums.dart';

/// A deadline that passed, as the away summary shows it.
@immutable
class SettledDeadline {
  const SettledDeadline({
    required this.commitmentId,
    required this.taskId,
    required this.taskTitle,
    required this.outcome,
    required this.loss,
    required this.day,
  });

  final String commitmentId;
  final String taskId;
  final String taskTitle;
  final CommitmentOutcome outcome;

  /// Half points lost; 0 when frozen.
  final int loss;
  final String day;
}

/// A health death, with the fall row the lesson will be added to.
@immutable
class HealthDeath {
  const HealthDeath({
    required this.attemptId,
    required this.bossId,
    required this.day,
  });

  final String attemptId;
  final String bossId;
  final String day;
}

@immutable
class DueResult {
  const DueResult({required this.settled, required this.deaths});

  final List<SettledDeadline> settled;
  final List<HealthDeath> deaths;
}

/// The player's health, derived from the ledger, and the settling of passed
/// deadlines (§5.12, Stage 4 plan D4 to D7).
class HealthDao {
  HealthDao(this._db, this._clock, this._attempts);

  final AppDatabase _db;
  final Clock _clock;
  final AttemptDao _attempts;

  static const _restores = {HealthReason.bonfireRestore, HealthReason.rise};
  static final _end = DateTime(9999);

  Future<String> _today() async =>
      dayOf(_clock(), rolloverHour: await _db.rolloverHour());

  Future<List<HealthMark>> _marks(String day) async => [
    for (final e in await (_db.select(
      _db.healthEvents,
    )..where((e) => e.day.equals(day))).get())
      HealthMark(
        at: e.at,
        amount: e.amount,
        isRestore: _restores.contains(e.reason),
      ),
  ];

  /// A day's health in half points, after every event recorded for it.
  Future<int> health(String day) async =>
      healthAt(kMaxHealthHalfPoints, await _marks(day), _end);

  Future<int> todayHealth() async => health(await _today());

  /// Health at 0 is the fallen state; a rise or rest ends it (plan D7).
  Future<bool> isDead(String day) async => await health(day) == 0;

  Future<bool> isDeadToday() async => isDead(await _today());

  /// Today's health, again after every health event or settings change.
  Stream<int> watchHealth() async* {
    yield await todayHealth();
    yield* _db
        .tableUpdates(
          TableUpdateQuery.onAllTables([_db.healthEvents, _db.userSettings]),
        )
        .asyncMap((_) => todayHealth());
  }

  /// Today's ritual day.
  Future<String> today() => _today();

  /// Health-death falls on [day] still waiting for their lesson.
  Future<List<String>> deathsWithoutLesson(String day) async => [
    for (final a
        in await (_db.select(_db.attempts)..where(
              (a) =>
                  a.day.equals(day) &
                  a.cause.equalsValue(FallCause.healthDeath) &
                  a.lesson.isNull(),
            ))
            .get())
      a.id,
  ];

  /// Writes one health event. [amount] is negative for a loss. An [id] that
  /// is already there writes nothing (Stage 7 plan D6).
  Future<void> record(
    int amount,
    HealthReason reason,
    String day,
    DateTime at, {
    String? commitmentId,
    String? id,
  }) => _db
      .into(_db.healthEvents)
      .insert(
        onConflict: DoNothing(),
        HealthEventsCompanion.insert(
          id: id ?? newId(),
          amount: amount,
          reason: reason,
          commitmentId: Value(commitmentId),
          day: day,
          at: at,
        ),
      );

  /// Restores [day] to full health. Writes nothing when already full.
  Future<bool> restore(HealthReason reason, String day, DateTime at) async {
    final missing = kMaxHealthHalfPoints - await health(day);
    if (missing == 0) return false;
    // One bonfire restore a day; rises counted within the day (D6).
    final rises = reason == HealthReason.rise
        ? (await (_db.select(_db.healthEvents)..where(
                    (e) => e.day.equals(day) & e.reason.equalsValue(reason),
                  ))
                  .get())
              .length
        : 0;
    await record(
      missing,
      reason,
      day,
      at,
      id: systemId([day, reason.name, rises]),
    );
    return true;
  }

  /// Makes today's standing daily commitments, then settles every open
  /// commitment whose deadline has passed, oldest day first. All or nothing.
  Future<DueResult> resolveDue() => _db.transaction(() async {
    final now = _clock();
    final hour = await _db.rolloverHour();
    await _makeStanding(now, hour);
    final due = await _due(now);
    final settled = <SettledDeadline>[];
    final deaths = <HealthDeath>[];
    final days = {for (final row in due) row.commitment.day}.toList()..sort();
    for (final day in days) {
      final rows = [
        for (final row in due)
          if (row.commitment.day == day) row,
      ];
      final result = resolveCommitments(
        max: kMaxHealthHalfPoints,
        marks: await _marks(day),
        due: [
          for (final r in rows)
            DueCommitment(
              id: r.commitment.id,
              bossId: r.commitment.bossId,
              weight: r.task.weight,
              deadline: r.commitment.deadline,
            ),
        ],
        now: now,
      );
      for (final s in result.settled) {
        final row = rows.firstWhere((r) => r.commitment.id == s.id);
        await _settle(row.commitment, s, now);
        settled.add(
          SettledDeadline(
            commitmentId: s.id,
            taskId: row.task.id,
            taskTitle: row.task.title,
            outcome: s.outcome,
            loss: s.loss,
            day: day,
          ),
        );
      }
      for (final d in result.deaths) {
        final attemptId = await _attempts.failBoss(
          d.bossId,
          FallCause.healthDeath,
          null,
          onDay: day,
          at: d.at,
        );
        deaths.add(
          HealthDeath(attemptId: attemptId, bossId: d.bossId, day: day),
        );
      }
    }
    return DueResult(settled: settled, deaths: deaths);
  });

  Future<void> _settle(Commitment c, Settled s, DateTime now) async {
    await (_db.update(_db.commitments)..where((r) => r.id.equals(c.id))).write(
      CommitmentsCompanion(
        outcome: Value(s.outcome),
        resolvedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    if (s.loss > 0) {
      await record(
        -s.loss,
        HealthReason.miss,
        c.day,
        s.at,
        commitmentId: c.id,
        id: systemId([c.id, HealthReason.miss.name]),
      );
    }
  }

  /// Open commitments of active bosses whose deadline has passed.
  Future<List<({Commitment commitment, Task task})>> _due(DateTime now) async {
    final query =
        _db.select(_db.commitments).join([
          innerJoin(_db.tasks, _db.tasks.id.equalsExp(_db.commitments.taskId)),
          innerJoin(
            _db.bosses,
            _db.bosses.id.equalsExp(_db.commitments.bossId),
          ),
        ])..where(
          _db.commitments.outcome.isNull() &
              _db.commitments.deadline.isSmallerOrEqualValue(now) &
              _db.bosses.status.equalsValue(BossStatus.active),
        );
    return [
      for (final row in await query.get())
        (
          commitment: row.readTable(_db.commitments),
          task: row.readTable(_db.tasks),
        ),
    ];
  }

  /// Today's commitment for each daily task with a standing deadline on an
  /// active boss (plan D12). shortcut: made only on days the app runs; a day
  /// the app never opens is judged by the missed-day rule instead.
  Future<void> _makeStanding(DateTime now, int hour) async {
    final today = dayOf(now, rolloverHour: hour);
    final query =
        _db.select(_db.tasks).join([
          innerJoin(_db.bosses, _db.bosses.id.equalsExp(_db.tasks.bossId)),
        ])..where(
          _db.tasks.dailyDeadlineMinutes.isNotNull() &
              _db.tasks.recurrence.equalsValue(Recurrence.daily) &
              _db.bosses.status.equalsValue(BossStatus.active),
        );
    final [y, m, d] = today.split('-').map(int.parse).toList();
    final end = dayEnd(now, rolloverHour: hour);
    for (final row in await query.get()) {
      final task = row.readTable(_db.tasks);
      final minutes = task.dailyDeadlineMinutes!;
      // Minutes up to the rollover hour belong to the end of the day.
      final wanted = DateTime(
        y,
        m,
        minutes <= hour * 60 ? d + 1 : d,
        minutes ~/ 60,
        minutes % 60,
      );
      final deadline = wanted.isAfter(end) ? end : wanted;
      // Opened after the time already passed: no promise to break today.
      if (!deadline.isAfter(now)) continue;
      await _db
          .into(_db.commitments)
          .insert(
            CommitmentsCompanion.insert(
              id: systemId([task.id, today]),
              taskId: task.id,
              bossId: task.bossId,
              day: today,
              deadline: deadline,
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }
}
