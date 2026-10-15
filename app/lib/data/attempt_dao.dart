import 'package:drift/drift.dart';

import '../core/clock.dart';
import '../core/ids.dart';
import 'boss_dao.dart';
import 'boss_view.dart';
import 'database.dart';
import 'ember_dao.dart';
import 'enums.dart';
import 'feel_report_data.dart';

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

  Future<Task> _task(String taskId) =>
      (_db.select(_db.tasks)..where((t) => t.id.equals(taskId))).getSingle();

  Future<Boss> _boss(String bossId) =>
      (_db.select(_db.bosses)..where((b) => b.id.equals(bossId))).getSingle();

  Future<void> _insert({
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
  }) async {
    final day = onDay ?? dayOf(now, rolloverHour: await _db.rolloverHour());
    await _db
        .into(_db.attempts)
        .insert(
          AttemptsCompanion.insert(
            id: newId(),
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
    );
    await (_db.update(_db.bosses)..where((b) => b.id.equals(boss.id))).write(
      BossesCompanion(lastFoughtAt: Value(now), updatedAt: Value(now)),
    );
  }

  /// Completes a task. A struck task is left alone.
  Future<StrikeResult> strike(String taskId) {
    return _db.transaction(() async {
      final task = await _task(taskId);
      final before = await _bosses.loadBoss(task.bossId);
      final view = before!.allTasks.firstWhere((t) => t.task.id == taskId);
      if (view.isStruck) return const StrikeResult(isVanquished: false);

      final now = _clock();
      final promise = await _todaysCommitment(taskId, now);
      final outcome = promise?.outcome;
      await _insert(
        boss: before.boss,
        outcome: Outcome.strike,
        now: now,
        taskId: taskId,
        weight: task.weight,
        isLate: promise != null && _paysLate.contains(outcome),
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

  /// Records a try that fell short. Returns true when the rule of three
  /// should prompt for this task (D11).
  Future<bool> tried(String taskId) {
    return _db.transaction(() async {
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
        await _db
            .into(_db.healthEvents)
            .insert(
              HealthEventsCompanion.insert(
                id: newId(),
                amount: -task.weight.healthLoss ~/ 2,
                reason: HealthReason.tried,
                commitmentId: Value(promise.id),
                day: promise.day,
                at: now,
              ),
            );
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
  /// applies the boss's reset. Shared by a declared fall and a missed day.
  /// [onDay] is the day the attempt belongs to when it is not today.
  Future<void> failBoss(
    String bossId,
    FallCause cause,
    String? lesson, {
    String? onDay,
  }) {
    return _db.transaction(() async {
      final now = _clock();
      final view = (await _bosses.loadBoss(bossId))!;
      final boss = view.boss;
      final current = view.currentPhase?.phase;
      await _insert(
        boss: boss,
        outcome: Outcome.fallen,
        now: now,
        phaseId: current?.id,
        cause: cause,
        lesson: lesson,
        onDay: onDay,
      );

      final next = boss.attemptNumber + 1;
      await (_db.update(_db.bosses)..where((b) => b.id.equals(bossId))).write(
        BossesCompanion(attemptNumber: Value(next), updatedAt: Value(now)),
      );
      await _reset(view, current, next, now);
    });
  }

  /// What the feel report counts (plan D13): outcome, weight and lesson
  /// presence per attempt, never titles or lesson text.
  Future<FeelReportData> feelReportData() async {
    final attempts = await _db.select(_db.attempts).get();
    final bosses = await _db.select(_db.bosses).get();
    final created = bosses.map((b) => b.createdAt);
    return FeelReportData(
      attempts: [
        for (final a in attempts)
          FeelAttempt(
            outcome: a.outcome,
            weight: a.weight,
            hasLesson: a.lesson != null,
          ),
      ],
      since: created.isEmpty
          ? null
          : created.reduce((a, b) => a.isBefore(b) ? a : b),
      settings: await _db.select(_db.settings).getSingle(),
    );
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
