import 'package:drift/drift.dart';

import '../core/clock.dart';
import '../core/ids.dart';
import 'boss_dao.dart';
import 'boss_view.dart';
import 'database.dart';
import 'ember_dao.dart';
import 'enums.dart';
import 'health_dao.dart';
import 'signal_dao.dart';

/// What the UI should show after a strike.
class StrikeResult {
  const StrikeResult({required this.isVanquished});

  /// The strike drained the last segment: show the defeat prompt (D3).
  final bool isVanquished;
}

const _maxLesson = 120;

/// A lesson as stored: trimmed, at most 120 characters, empty becomes null.
String? cleanLesson(String? raw) {
  final trimmed = raw?.trim() ?? '';
  return trimmed.isEmpty
      ? null
      : trimmed.substring(0, trimmed.length.clamp(0, _maxLesson));
}

/// Strikes, tries and falls. Attempt rows are only ever inserted.
class AttemptDao {
  AttemptDao(this._db, this._bosses, this._clock);

  final AppDatabase _db;
  final BossDao _bosses;
  final Clock _clock;
  late final _embers = EmberDao(_db, _clock);
  late final _health = HealthDao(_db, _clock, this);
  late final _signals = SignalDao(_db, _clock);

  Future<Task> _task(String taskId) =>
      (_db.select(_db.tasks)..where((t) => t.id.equals(taskId))).getSingle();

  Future<Boss> _boss(String bossId) =>
      (_db.select(_db.bosses)..where((b) => b.id.equals(bossId))).getSingle();

  /// Inserts the attempt and its ember earn. Returns the attempt id. [id]
  /// and [earnId] are given for records two phones make alike (D6).
  Future<String> _insert({
    required Boss boss,
    required Outcome outcome,
    required DateTime now,
    String? taskId,
    Weight? weight,
    String? phaseId,
    FallCause? cause,
    String? lesson,
    String? onDay,
    bool isLate = false,
    String? id,
    String? earnId,
  }) async {
    final day = onDay ?? dayOf(now, rolloverHour: await _db.rolloverHour());
    id ??= newId();
    await _db
        .into(_db.attempts)
        .insert(
          AttemptsCompanion.insert(
            id: id,
            bossId: boss.id,
            taskId: Value(taskId),
            bossAttempt: boss.attemptNumber,
            outcome: outcome,
            weight: Value(weight),
            cause: Value(cause),
            phaseId: Value(phaseId),
            lesson: Value(lesson),
            day: day,
            at: now,
          ),
        );
    await _embers.earn(
      outcome: outcome,
      weight: weight,
      bossId: boss.id,
      taskId: taskId,
      day: day,
      at: now,
      isLate: isLate,
      id: earnId,
    );
    await (_db.update(_db.bosses)..where((b) => b.id.equals(boss.id))).write(
      BossesCompanion(
        // A fall dated to a past deadline never moves this back.
        lastFoughtAt: Value(
          boss.lastFoughtAt != null && boss.lastFoughtAt!.isAfter(now)
              ? boss.lastFoughtAt
              : now,
        ),
        updatedAt: Value(now),
      ),
    );
    return id;
  }

  /// Completes a task. A struck task is left alone. [commitmentId] closes
  /// that promise instead of today's, for "Done late" on an earlier day.
  Future<StrikeResult> strike(String taskId, {String? commitmentId}) {
    return _db.transaction(() async {
      // A deadline that passed unnoticed is a miss before it is a strike.
      await _health.resolveDue();
      final task = await _task(taskId);
      final before = await _bosses.loadBoss(task.bossId);
      final view = before!.allTasks.firstWhere((t) => t.task.id == taskId);
      if (view.isStruck) return const StrikeResult(isVanquished: false);

      final now = _clock();
      final promise = commitmentId == null
          ? await _todaysCommitment(taskId, now)
          : await (_db.select(
              _db.commitments,
            )..where((c) => c.id.equals(commitmentId))).getSingleOrNull();
      final outcome = promise?.outcome;
      await _insert(
        boss: before.boss,
        outcome: Outcome.strike,
        now: now,
        taskId: taskId,
        weight: task.weight,
        isLate: promise != null && _paysLate.contains(outcome),
        earnId: systemId([taskId, await _strikePeriod(task, before, now)]),
      );
      if (promise != null && outcome == null) {
        await _close(promise, CommitmentOutcome.kept, now);
      } else if (promise != null &&
          (outcome == CommitmentOutcome.missed ||
              outcome == CommitmentOutcome.frozen)) {
        await _close(promise, CommitmentOutcome.lateStrike, now);
      }
      final after = await _bosses.loadBoss(task.bossId);
      return StrikeResult(
        isVanquished: !before.isVanquished && after!.isVanquished,
      );
    });
  }

  /// What one paid strike of [task] covers (D6): the day for a daily task,
  /// the attempt it is open from for a one-time task, so a reset task pays
  /// again but two phones striking it once pay once.
  Future<String> _strikePeriod(Task task, BossView view, DateTime now) async {
    if (task.recurrence == Recurrence.daily) {
      return dayOf(now, rolloverHour: await _db.rolloverHour());
    }
    final phase = view.phases
        .where((p) => p.phase.id == task.phaseId)
        .firstOrNull
        ?.phase;
    return 'attempt ${phase?.openFromAttempt ?? view.boss.openFromAttempt}';
  }

  /// Records a try that fell short. Returns true when the rule of three
  /// should prompt for this task (D11).
  Future<bool> tried(String taskId) {
    return _db.transaction(() async {
      await _health.resolveDue();
      final task = await _task(taskId);
      final now = _clock();
      await _insert(
        boss: await _boss(task.bossId),
        outcome: Outcome.tried,
        now: now,
        taskId: taskId,
        weight: task.weight,
      );
      final promise = await _todaysCommitment(taskId, now);
      if (promise != null && promise.outcome == null) {
        await _close(promise, CommitmentOutcome.tried, now);
        final before = await _health.health(promise.day);
        await _health.record(
          -task.weight.healthLoss ~/ 2,
          HealthReason.tried,
          promise.day,
          now,
          commitmentId: promise.id,
        );
        // A broken promise can deal the final blow too (plan D7).
        if (before > 0 && await _health.isDead(promise.day)) {
          await failBoss(
            task.bossId,
            FallCause.healthDeath,
            null,
            onDay: promise.day,
            at: now,
          );
        }
      }
      final history = await _bosses.loadAttempts(bossId: task.bossId);
      return isRuleOfThree(triesSinceStrike(taskId, history));
    });
  }

  /// Commitments whose strike pays the Tried rate (plan D8, D9).
  static const _paysLate = {
    CommitmentOutcome.tried,
    CommitmentOutcome.missed,
    CommitmentOutcome.frozen,
  };

  Future<Commitment?> _todaysCommitment(String taskId, DateTime now) async {
    final day = dayOf(now, rolloverHour: await _db.rolloverHour());
    return (_db.select(_db.commitments)
          ..where((c) => c.taskId.equals(taskId) & c.day.equals(day)))
        .getSingleOrNull();
  }

  Future<void> _close(
    Commitment promise,
    CommitmentOutcome outcome,
    DateTime now,
  ) => (_db.update(_db.commitments)..where((c) => c.id.equals(promise.id)))
      .write(
        CommitmentsCompanion(
          outcome: Value(outcome),
          resolvedAt: Value(now),
          updatedAt: Value(now),
        ),
      );

  /// A declared failed attempt (§5.4, plan §6.3). Raises the counter, keeps
  /// the lesson, applies the boss's reset. Returns true when the phase rule
  /// of three should prompt (D6, D11).
  Future<bool> fall(String bossId, String? lesson) {
    return _db.transaction(() async {
      await failBoss(bossId, FallCause.declared, cleanLesson(lesson));
      final history = await _bosses.loadAttempts(bossId: bossId);
      return isRuleOfThree(samePhaseFallRun(bossId, history));
    });
  }

  /// Fails one boss attempt: writes the fallen row, raises the counter and
  /// applies the boss's reset. Shared by a declared fall, a missed day and a
  /// health death. [onDay] is the day the attempt belongs to when it is not
  /// today; [at] its time when it is not now (a deadline settled late,
  /// Stage 4 plan D6). Returns the fallen row's id.
  Future<String> failBoss(
    String bossId,
    FallCause cause,
    String? lesson, {
    String? onDay,
    DateTime? at,
  }) {
    return _db.transaction(() async {
      final now = at ?? _clock();
      final view = (await _bosses.loadBoss(bossId))!;
      final boss = view.boss;
      final current = view.currentPhase?.phase;
      final day = onDay ?? dayOf(now, rolloverHour: await _db.rolloverHour());
      final systemMade = await _fallId(bossId, cause, day);
      if (systemMade != null &&
          await (_db.select(
                _db.attempts,
              )..where((a) => a.id.equals(systemMade))).getSingleOrNull() !=
              null) {
        // Another phone's fall for the same reason is already here.
        return systemMade;
      }
      final id = await _insert(
        id: systemMade,
        boss: boss,
        outcome: Outcome.fallen,
        now: now,
        phaseId: current?.id,
        cause: cause,
        lesson: lesson,
        onDay: day,
      );
      final fall = await (_db.select(
        _db.attempts,
      )..where((a) => a.id.equals(id))).getSingle();
      await _signals.add(SignalKind.fell, day: fall.day, at: fall.at);

      final next = boss.attemptNumber + 1;
      await (_db.update(_db.bosses)..where((b) => b.id.equals(bossId))).write(
        BossesCompanion(attemptNumber: Value(next), updatedAt: Value(now)),
      );
      await _reset(view, current, next, now);
      return id;
    });
  }

  /// The id of a fall the app makes, alike on every phone (D6): one per
  /// boss per missed day; one per health death, counted within the day.
  /// Null for a declared fall, which the user makes.
  Future<String?> _fallId(String bossId, FallCause cause, String day) async {
    switch (cause) {
      case FallCause.declared:
        return null;
      case FallCause.missedDay:
        return systemId([bossId, day, cause.name]);
      case FallCause.healthDeath:
        final before =
            await (_db.select(_db.attempts)..where(
                  (a) =>
                      a.bossId.equals(bossId) &
                      a.day.equals(day) &
                      a.cause.equalsValue(FallCause.healthDeath),
                ))
                .get();
        return systemId([bossId, day, cause.name, before.length]);
    }
  }

  /// Adds the lesson to a fall written before it was asked (a health death,
  /// plan D7). Never replaces a lesson already there.
  Future<void> addLesson(List<String> attemptIds, String? lesson) async {
    final clean = cleanLesson(lesson);
    if (clean == null) return;
    await (_db.update(_db.attempts)
          ..where((a) => a.id.isIn(attemptIds) & a.lesson.isNull()))
        .write(AttemptsCompanion(lesson: Value(clean)));
  }

  Future<void> _reset(
    BossView view,
    Phase? current,
    int next,
    DateTime now,
  ) async {
    final reopen = PhasesCompanion(
      openFromAttempt: Value(next),
      updatedAt: Value(now),
    );
    switch (view.boss.resetOnFail) {
      case ResetOnFail.nothing:
        return;
      case ResetOnFail.currentPhase:
        if (current == null) return;
        await (_db.update(
          _db.phases,
        )..where((p) => p.id.equals(current.id))).write(reopen);
      case ResetOnFail.wholeBoss:
        await (_db.update(
          _db.phases,
        )..where((p) => p.bossId.equals(view.boss.id))).write(reopen);
        await (_db.update(_db.bosses)..where((b) => b.id.equals(view.boss.id)))
            .write(BossesCompanion(openFromAttempt: Value(next)));
    }
  }
}
