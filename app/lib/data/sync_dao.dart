import 'package:drift/drift.dart';

import 'database.dart';

/// The outbox the triggers fill, and this phone's sync bookkeeping
/// (Stage 7 plan D14).
class SyncDao {
  SyncDao(this._db);

  final AppDatabase _db;

  /// Entries waiting to be sent, oldest first. Quarantined ones are left out.
  Future<List<OutboxEntry>> pending() =>
      (_db.select(_db.syncOutbox)
            ..where((e) => e.rejectedReason.isNull())
            ..orderBy([(e) => OrderingTerm.asc(e.seq)]))
          .get();

  /// Entries the server refused as malformed, kept until retried.
  Future<List<OutboxEntry>> quarantined() =>
      (_db.select(_db.syncOutbox)
            ..where((e) => e.rejectedReason.isNotNull())
            ..orderBy([(e) => OrderingTerm.asc(e.seq)]))
          .get();

  /// Removes exactly the entries a push sent. An edit made while it was in
  /// flight has a later seq and stays queued.
  Future<void> ack(Iterable<int> seqs) =>
      (_db.delete(_db.syncOutbox)..where((e) => e.seq.isIn(seqs))).go();

  Future<void> quarantine(int seq, String reason) =>
      (_db.update(_db.syncOutbox)..where((e) => e.seq.equals(seq))).write(
        SyncOutboxCompanion(rejectedReason: Value(reason)),
      );

  /// While true, writes queue nothing: they came from the server.
  Future<void> setApplying(bool isApplying) => _db
      .update(_db.syncState)
      .write(SyncStateCompanion(applying: Value(isApplying)));
}
