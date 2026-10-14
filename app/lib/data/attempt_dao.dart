import 'package:drift/drift.dart';

import '../core/clock.dart';
import '../core/ids.dart';
import 'boss_dao.dart';
import 'boss_view.dart';
import 'database.dart';
import 'enums.dart';
import 'feel_report_data.dart';

/// What the UI should show after a strike.
class StrikeResult {
  const StrikeResult({required this.isVanquished});

  /// The strike drained the last segment: show the defeat prompt (D3).
  final bool isVanquished;
}

/// Strikes, tries and falls. Attempt rows are only ever inserted.
class AttemptDao {
  AttemptDao(this._db, this._bosses, this._clock);

  final AppDatabase _db;
  final BossDao _bosses;
  final Clock _clock;

  static const _maxLesson = 120;

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
  }) async {
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
            day: dayOf(now, rolloverHour: await _db.rolloverHour()),
            at: now,
          ),
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

      await _insert(
        boss: before.boss,
        outcome: Outcome.strike,
        now: _clock(),
        taskId: taskId,
        weight: task.weight,
      );
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
      await _insert(
        boss: await _boss(task.bossId),
        outcome: Outcome.tried,
        now: _clock(),
        taskId: taskId,
        weight: task.weight,
      );
      final history = await _bosses.loadAttempts(bossId: task.bossId);
      return isRuleOfThree(triesSinceStrike(taskId, history));
    });
  }

  /// A declared failed attempt (§5.4, plan §6.3). Raises the counter, keeps
  /// the lesson, applies the boss's reset. Returns true when the phase rule
  /// of three should prompt (D6, D11).
  Future<bool> fall(String bossId, String? lesson) {
    final trimmed = lesson?.trim() ?? '';
    final kept = trimmed.isEmpty
        ? null
        : trimmed.substring(0, trimmed.length.clamp(0, _maxLesson));
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
        cause: FallCause.declared,
        lesson: kept,
      );

      final next = boss.attemptNumber + 1;
      await (_db.update(_db.bosses)..where((b) => b.id.equals(bossId))).write(
        BossesCompanion(attemptNumber: Value(next), updatedAt: Value(now)),
      );
      await _reset(view, current, next, now);

      final history = await _bosses.loadAttempts(bossId: bossId);
      return isRuleOfThree(samePhaseFallRun(bossId, history));
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
