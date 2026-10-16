import 'package:drift/drift.dart';

import '../core/clock.dart';
import '../core/ids.dart';
import 'boss_draft.dart';
import 'boss_view.dart';
import 'database.dart';
import 'enums.dart';
import 'relic_dao.dart';

/// Bosses, phases and tasks: reads as derived views, writes as transactions.
class BossDao {
  BossDao(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;
  late final _relics = RelicDao(_db, _clock);

  /// Emits now and after every change to the fight tables.
  Stream<void> _changes() async* {
    yield null;
    yield* _db.tableUpdates(
      TableUpdateQuery.onAllTables([
        _db.bosses,
        _db.phases,
        _db.tasks,
        _db.attempts,
        _db.userSettings,
      ]),
    );
  }

  Stream<List<BossView>> watchAll() => _changes().asyncMap((_) => loadAll());

  Stream<BossView?> watchBoss(String id) =>
      _changes().asyncMap((_) => loadBoss(id));

  /// All bosses in home order. One query per table, grouped in memory.
  Future<List<BossView>> loadAll() async {
    final bosses = await _db.select(_db.bosses).get();
    return _views(
      await _db.rolloverHour(),
      bosses,
      await _db.select(_db.phases).get(),
      await _db.select(_db.tasks).get(),
      await loadAttempts(),
    );
  }

  Future<BossView?> loadBoss(String id) async {
    final boss = await (_db.select(
      _db.bosses,
    )..where((b) => b.id.equals(id))).getSingleOrNull();
    if (boss == null) return null;
    final phases = await (_db.select(
      _db.phases,
    )..where((p) => p.bossId.equals(id))).get();
    final tasks = await (_db.select(
      _db.tasks,
    )..where((t) => t.bossId.equals(id))).get();
    return _views(
      await _db.rolloverHour(),
      [boss],
      phases,
      tasks,
      await loadAttempts(bossId: id),
    ).single;
  }

  /// Attempts in time order, optionally for one boss.
  Future<List<Attempt>> loadAttempts({String? bossId}) {
    final query = _db.select(_db.attempts)
      ..orderBy([(a) => OrderingTerm.asc(a.at)]);
    if (bossId != null) query.where((a) => a.bossId.equals(bossId));
    return query.get();
  }

  List<BossView> _views(
    int rolloverHour,
    List<Boss> bosses,
    List<Phase> phases,
    List<Task> tasks,
    List<Attempt> attempts,
  ) {
    final today = dayOf(_clock(), rolloverHour: rolloverHour);
    return [
      for (final b in [...bosses]..sort(compareBosses))
        buildBossView(
          boss: b,
          phases: phases,
          tasks: tasks,
          attempts: attempts,
          today: today,
        ),
    ];
  }

  /// Creates or updates a boss with its phases and tasks. Returns the id.
  /// A boss needs a task unless [allowEmpty]: onboarding asks only for a
  /// title and adds the first tasks later (Stage 5 plan D11).
  Future<String> saveBoss(BossDraft draft, {bool allowEmpty = false}) {
    if (allowEmpty ? !draft.isNamed : !draft.canSave) {
      throw ArgumentError('A boss needs a title and at least one task.');
    }
    return _db.transaction(() async {
      final now = _clock();
      final bossId = draft.id ?? newId();
      final meaning = draft.defeatMeaning.trim();
      await _db
          .into(_db.bosses)
          .insert(
            BossesCompanion.insert(
              id: bossId,
              title: draft.title.trim(),
              defeatMeaning: Value(meaning.isEmpty ? null : meaning),
              status: BossStatus.active,
              resetOnFail: draft.resetOnFail,
              targetDate: Value(draft.targetDate),
              createdAt: now,
              updatedAt: now,
            ),
            onConflict: DoUpdate(
              (_) => BossesCompanion(
                title: Value(draft.title.trim()),
                defeatMeaning: Value(meaning.isEmpty ? null : meaning),
                resetOnFail: Value(draft.resetOnFail),
                targetDate: Value(draft.targetDate),
                updatedAt: Value(now),
              ),
            ),
          );

      final phaseIds = <String>[];
      final taskIds = <String>[];
      for (final (i, phase) in draft.phases.indexed) {
        final phaseId = phase.id ?? newId();
        phaseIds.add(phaseId);
        await _upsertPhase(bossId, phaseId, phase.name.trim(), i, now);
        for (final (j, task) in phase.tasks.indexed) {
          taskIds.add(await _upsertTask(bossId, phaseId, task, j, now));
        }
      }
      for (final (j, task) in draft.standalone.indexed) {
        taskIds.add(await _upsertTask(bossId, null, task, j, now));
      }

      // Removed rows. Split tasks are hidden from the draft, so keep them.
      await (_db.delete(_db.tasks)..where(
            (t) =>
                t.bossId.equals(bossId) &
                t.id.isNotIn(taskIds) &
                t.isSplit.equals(false),
          ))
          .go();
      await (_db.delete(
        _db.phases,
      )..where((p) => p.bossId.equals(bossId) & p.id.isNotIn(phaseIds))).go();
      return bossId;
    });
  }

  Future<void> _upsertPhase(
    String bossId,
    String id,
    String name,
    int position,
    DateTime now,
  ) {
    return _db
        .into(_db.phases)
        .insert(
          PhasesCompanion.insert(
            id: id,
            bossId: bossId,
            name: name,
            position: position,
            createdAt: now,
            updatedAt: now,
          ),
          onConflict: DoUpdate(
            (_) => PhasesCompanion(
              name: Value(name),
              position: Value(position),
              updatedAt: Value(now),
            ),
          ),
        );
  }

  Future<String> _upsertTask(
    String bossId,
    String? phaseId,
    TaskDraft task,
    int position,
    DateTime now,
  ) async {
    final id = task.id ?? newId();
    final title = task.title.trim();
    await _db
        .into(_db.tasks)
        .insert(
          TasksCompanion.insert(
            id: id,
            bossId: bossId,
            phaseId: Value(phaseId),
            title: title,
            weight: task.weight,
            recurrence: task.recurrence,
            position: position,
            createdAt: now,
            updatedAt: now,
          ),
          onConflict: DoUpdate(
            (_) => TasksCompanion(
              phaseId: Value(phaseId),
              title: Value(title),
              weight: Value(task.weight),
              recurrence: Value(task.recurrence),
              position: Value(position),
              updatedAt: Value(now),
            ),
          ),
        );
    return id;
  }

  /// Waiting or defeated cancels the boss's open commitments, so they never
  /// expire while it rests (Stage 4 plan D11). Defeat is final: it writes the
  /// relic in the same transaction, and a defeated boss cannot move again
  /// (Stage 5 plan D2).
  Future<void> setStatus(String bossId, BossStatus status) =>
      _db.transaction(() async {
        final current = await (_db.select(
          _db.bosses,
        )..where((b) => b.id.equals(bossId))).getSingle();
        if (current.status == BossStatus.defeated) {
          if (status == BossStatus.defeated) return;
          throw StateError('A defeated boss stays defeated.');
        }
        final now = _clock();
        await _updateBoss(
          bossId,
          BossesCompanion(
            status: Value(status),
            defeatedAt: Value(status == BossStatus.defeated ? now : null),
            updatedAt: Value(now),
          ),
        );
        if (status == BossStatus.active) return;
        if (status == BossStatus.defeated) await _relics.createFor(bossId);
        await (_db.update(
          _db.commitments,
        )..where((c) => c.bossId.equals(bossId) & c.outcome.isNull())).write(
          CommitmentsCompanion(
            outcome: const Value(CommitmentOutcome.cancelled),
            resolvedAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      });

  Future<void> setPinned(String bossId, {required bool isPinned}) =>
      _updateBoss(
        bossId,
        BossesCompanion(isPinned: Value(isPinned), updatedAt: Value(_clock())),
      );

  Future<void> _updateBoss(String bossId, BossesCompanion values) =>
      (_db.update(_db.bosses)..where((b) => b.id.equals(bossId))).write(values);

  /// Deletes the boss with its phases, tasks and attempts.
  Future<void> deleteBoss(String bossId) =>
      (_db.delete(_db.bosses)..where((b) => b.id.equals(bossId))).go();

  /// Deletes a task. Its attempts stay, with the task reference cleared (D10).
  Future<void> deleteTask(String taskId) =>
      (_db.delete(_db.tasks)..where((t) => t.id.equals(taskId))).go();

  /// Replaces a task with 2 to 5 smaller ones right after it (§6.4).
  Future<void> splitTask(String taskId, List<String> titles) {
    final clean = titles
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (clean.length < 2 || clean.length > 5) {
      throw ArgumentError('Split into 2 to 5 smaller foes.');
    }
    return _db.transaction(() async {
      final now = _clock();
      final original = await (_db.select(
        _db.tasks,
      )..where((t) => t.id.equals(taskId))).getSingle();
      final siblings = (_db.select(_db.tasks)
        ..where(
          (t) =>
              t.bossId.equals(original.bossId) &
              t.position.isBiggerThanValue(original.position) &
              (original.phaseId == null
                  ? t.phaseId.isNull()
                  : t.phaseId.equals(original.phaseId!)),
        ));
      for (final s in await siblings.get()) {
        await (_db.update(_db.tasks)..where((t) => t.id.equals(s.id))).write(
          TasksCompanion(position: Value(s.position + clean.length)),
        );
      }
      for (final (i, title) in clean.indexed) {
        await _db
            .into(_db.tasks)
            .insert(
              TasksCompanion.insert(
                id: newId(),
                bossId: original.bossId,
                phaseId: Value(original.phaseId),
                title: title,
                weight: original.weight.lighter,
                recurrence: original.recurrence,
                position: original.position + 1 + i,
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
      await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId))).write(
        TasksCompanion(isSplit: const Value(true), updatedAt: Value(now)),
      );
    });
  }
}
