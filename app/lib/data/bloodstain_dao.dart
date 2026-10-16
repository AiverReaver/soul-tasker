import 'package:drift/drift.dart';

import '../core/bloodstain_merge.dart';
import '../core/clock.dart';
import '../core/ids.dart';
import 'database.dart';

/// [local] and [remote] copies of one bloodstain, merged (Stage 7 plan
/// D19): what never changes after the drop keeps the local value, the times
/// merge by `mergeStainTimes`, and `updatedAt` is the later one.
Bloodstain mergeBloodstain(Bloodstain local, Bloodstain remote) {
  final times = mergeStainTimes(
    (recoveredAt: local.recoveredAt, lostAt: local.lostAt),
    (recoveredAt: remote.recoveredAt, lostAt: remote.lostAt),
  );
  return local.copyWith(
    recoveredAt: Value(times.recoveredAt),
    lostAt: Value(times.lostAt),
    updatedAt: remote.updatedAt.isAfter(local.updatedAt)
        ? remote.updatedAt
        : local.updatedAt,
  );
}

/// Embers left where a boss was fallen (§5.8, §9.2). At most one is active
/// per boss. Nothing drops one until Stage 8; gentle mode removes no embers.
class BloodstainDao {
  BloodstainDao(this._db, [this._clock = DateTime.now]);

  final AppDatabase _db;
  final Clock _clock;

  Expression<bool> _isActive($BloodstainsTable b) =>
      b.recoveredAt.isNull() & b.lostAt.isNull();

  Future<Bloodstain?> active(String bossId) =>
      (_db.select(_db.bloodstains)
            ..where((b) => b.bossId.equals(bossId) & _isActive(b))
            ..limit(1))
          .getSingleOrNull();

  /// Leaves a new active bloodstain on [bossId]; the one active before is
  /// lost at the new one's time, in the same transaction (§9.2).
  Future<String> drop({
    required String bossId,
    String? taskId,
    String? attemptId,
    required int amount,
  }) => _db.transaction(() async {
    final now = _clock();
    await (_db.update(_db.bloodstains)
          ..where((b) => b.bossId.equals(bossId) & _isActive(b)))
        .write(BloodstainsCompanion(lostAt: Value(now), updatedAt: Value(now)));
    final id = newId();
    await _db
        .into(_db.bloodstains)
        .insert(
          BloodstainsCompanion.insert(
            id: id,
            bossId: bossId,
            taskId: Value(taskId),
            attemptId: Value(attemptId),
            amount: amount,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  });

  /// Recovers an active bloodstain. False, changing nothing, when it is
  /// already recovered or lost.
  Future<bool> recover(String id) async {
    final now = _clock();
    final changed =
        await (_db.update(
          _db.bloodstains,
        )..where((b) => b.id.equals(id) & _isActive(b))).write(
          BloodstainsCompanion(recoveredAt: Value(now), updatedAt: Value(now)),
        );
    return changed == 1;
  }

  /// Keeps only the newest active bloodstain on [bossId] (by `createdAt`,
  /// ties by the larger id) and marks the rest lost at its time (D11). Run
  /// after a merge; a second run changes nothing.
  Future<void> settleBloodstains(String bossId) => _db.transaction(() async {
    final live =
        await (_db.select(_db.bloodstains)
              ..where((b) => b.bossId.equals(bossId) & _isActive(b))
              ..orderBy([
                (b) => OrderingTerm.desc(b.createdAt),
                (b) => OrderingTerm.desc(b.id),
              ]))
            .get();
    if (live.length < 2) return;
    final winner = live.first;
    await (_db.update(
      _db.bloodstains,
    )..where((b) => b.id.isIn([for (final s in live.skip(1)) s.id]))).write(
      BloodstainsCompanion(
        lostAt: Value(winner.createdAt),
        updatedAt: Value(_clock()),
      ),
    );
  });
}
