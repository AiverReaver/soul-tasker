import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:hearthrise_api/hearthrise_api.dart'
    show
        ChangeDto,
        ChangeDtoOpEnum,
        PulledChangeDto,
        PulledChangeDtoOpEnum,
        PushResult,
        PushResultReasonEnum,
        PushResultStatusEnum;

import '../core/bloodstain_merge.dart';
import '../core/clock.dart';
import 'bloodstain_dao.dart';
import 'boss_dao.dart';
import 'database.dart';
import 'enums.dart';
import 'sync_api.dart';
import 'sync_dao.dart';
import 'sync_schema.dart';
import 'sync_sql.dart';
import 'tables.dart' show kUserSettingsId;

/// How a sync run ended.
enum SyncOutcome {
  /// Pushed and pulled everything.
  synced,

  /// A network or server error; everything stays queued for the next run.
  failed,

  /// The server refused this phone's session; `SyncState.sessionEnded` is set.
  signedOut,
}

/// Pushes the outbox and pulls what other phones wrote (Stage 7 plan D5,
/// D13, D14, D19). One run at a time; each run is push, then pull.
class SyncService {
  SyncService({
    required this._db,
    required this._api,
    required this._clock,
    required this._appVersion,
    this.batchSize = 1000,
  }) : _outbox = SyncDao(_db);

  final AppDatabase _db;
  final SyncApi _api;
  final Clock _clock;
  final String _appVersion;
  final SyncDao _outbox;

  /// The most changes the server takes in one push.
  final int batchSize;

  Future<SyncOutcome>? _running;

  /// Rows whose clock was already corrected once this run of the app; a
  /// second clock reject quarantines instead of looping (D14).
  final _clockFixed = <String>{};

  /// Runs a sync, or joins the one already running.
  Future<SyncOutcome> sync() => _running ??= _run().whenComplete(() {
    _running = null;
  });

  Future<SyncOutcome> _run() async {
    try {
      await _clearQuarantineOnNewVersion();
      await _push();
      await _pull();
      await _saveState(
        SyncStateCompanion(
          lastSyncAt: Value(_clock()),
          lastError: const Value(null),
        ),
      );
      return SyncOutcome.synced;
    } on SyncUnauthorized {
      await _saveState(
        const SyncStateCompanion(
          sessionEnded: Value(true),
          lastError: Value(null),
        ),
      );
      return SyncOutcome.signedOut;
    } on Object catch (e) {
      // Any other failure is a reason to try again later; the outbox and
      // the cursor are untouched, so the next run starts from the same place.
      await _saveState(SyncStateCompanion(lastError: Value('$e')));
      return SyncOutcome.failed;
    }
  }

  Future<SyncStateRow> _state() => _db.select(_db.syncState).getSingle();

  Future<void> _saveState(SyncStateCompanion values) =>
      _db.update(_db.syncState).write(values);

  /// Entries refused as malformed get one more try when the app is updated.
  Future<void> _clearQuarantineOnNewVersion() async {
    final state = await _state();
    if (state.lastAppVersion == _appVersion) return;
    await _db.transaction(() async {
      await _db
          .update(_db.syncOutbox)
          .write(const SyncOutboxCompanion(rejectedReason: Value(null)));
      await _saveState(SyncStateCompanion(lastAppVersion: Value(_appVersion)));
    });
  }

  // ---- Push ----

  Future<void> _push() async {
    final groups = await _collect();
    if (groups.isEmpty) return;
    final deviceId = (await _state()).deviceId;
    // Parents before children, so the server stores them in that order and
    // a pull on another phone meets a parent first.
    final order = kSyncColumns.keys.toList();
    groups.sort((a, b) {
      final byKind = (a.change.op == ChangeDtoOpEnum.delete ? 1 : 0).compareTo(
        b.change.op == ChangeDtoOpEnum.delete ? 1 : 0,
      );
      if (byKind != 0) return byKind;
      final byTable = order
          .indexOf(a.change.table)
          .compareTo(order.indexOf(b.change.table));
      return byTable != 0 ? byTable : a.firstSeq.compareTo(b.firstSeq);
    });
    for (var i = 0; i < groups.length; i += batchSize) {
      final batch = groups.skip(i).take(batchSize).toList();
      final results = await _api.push(deviceId, [
        for (final g in batch) g.change,
      ]);
      if (results.length != batch.length) {
        throw StateError(
          'push answered ${results.length} results for ${batch.length}',
        );
      }
      for (final (g, r) in [
        for (var j = 0; j < batch.length; j++) (batch[j], results[j]),
      ]) {
        await _settle(g, r);
      }
    }
  }

  /// One send per row: the outbox entries are folded, then read as the row
  /// is now, so an edit between two runs is sent once (D14).
  Future<List<_Send>> _collect() async {
    final queued = await _outbox.pending();
    if (queued.isEmpty) return [];
    final parked = await _outbox.quarantined();
    final byRow = <String, List<OutboxEntry>>{};
    for (final e in queued) {
      (byRow['${e.tbl}/${e.rowId}'] ??= []).add(e);
    }
    final sends = <_Send>[];
    for (final MapEntry(key: key, value: entries) in byRow.entries) {
      final seqs = [
        ...entries.map((e) => e.seq),
        // An older refusal of this row is replaced by this fresh entry.
        ...parked.where((p) => '${p.tbl}/${p.rowId}' == key).map((p) => p.seq),
      ];
      final first = entries.first;
      final row = await _readRow(first.tbl, first.rowId);
      if (row != null) {
        sends.add(_Send(_upsert(first.tbl, first.rowId, row), seqs));
        continue;
      }
      final deletes = entries.where((e) => e.op == SyncOp.delete);
      if (deletes.isEmpty || kNaturalKeyTables.contains(first.tbl)) {
        // Nothing left to say about it.
        await _outbox.ack(seqs);
        continue;
      }
      sends.add(
        _Send(
          ChangeDto(
            table: first.tbl,
            id: first.rowId,
            op: ChangeDtoOpEnum.delete,
            deletedAt: _iso(deletes.last.at),
          ),
          seqs,
        ),
      );
    }
    return sends;
  }

  String _idSql(String table) => kSyncedTables[table]!.replaceAll('{r}', table);

  Future<Map<String, Object?>?> _readRow(String table, String id) async {
    final rows = await _db
        .customSelect(
          'SELECT * FROM $table WHERE ${_idSql(table)} = ?',
          variables: [Variable(id)],
        )
        .get();
    return rows.isEmpty ? null : rows.single.data;
  }

  String _iso(DateTime t) => t.toUtc().toIso8601String();

  ChangeDto _upsert(String table, String id, Map<String, Object?> row) {
    final json = <String, Object?>{};
    for (final MapEntry(key: col, value: type)
        in kSyncColumns[table]!.entries) {
      final v = row[col];
      json[col] = v == null
          ? null
          : switch (type) {
              'boolean' => v != 0 && v != false,
              'timestamptz' => _iso(DateTime.parse(v as String)),
              'jsonb' => (jsonDecode(v as String) as List).cast<String>(),
              _ => v,
            };
    }
    return ChangeDto(
      table: table,
      id: id,
      op: ChangeDtoOpEnum.upsert,
      updatedAt: kEventTables.contains(table)
          ? null
          : _iso(DateTime.parse(row['updated_at']! as String)),
      row: json,
    );
  }

  Future<void> _settle(_Send send, PushResult result) async {
    if (result.status != PushResultStatusEnum.rejected) {
      _clockFixed.remove(send.key);
      await _outbox.ack(send.seqs);
      return;
    }
    final isClock = result.reason == PushResultReasonEnum.clock;
    if (isClock &&
        _clockFixed.add(send.key) &&
        send.change.op == ChangeDtoOpEnum.upsert &&
        !kEventTables.contains(send.change.table)) {
      // Re-stamp with this phone's now; the write queues a fresh entry.
      await _db.transaction(() async {
        await _db.customStatement(
          'UPDATE ${send.change.table} SET updated_at = ? '
          'WHERE ${_idSql(send.change.table)} = ?',
          [sqlTime(_clock()), send.change.id],
        );
        await _outbox.ack(send.seqs);
      });
      return;
    }
    final why = result.message ?? result.reason?.name ?? 'rejected';
    for (final seq in send.seqs) {
      await _outbox.quarantine(seq, why);
    }
  }

  // ---- Pull ----

  Future<void> _pull() async {
    var since = (await _state()).cursor;
    while (true) {
      final page = await _api.pull(since);
      await _apply(page.changes, page.cursor);
      since = page.cursor;
      if (!page.hasMore) return;
    }
  }

  /// One page, in one transaction: the rows, then the cursor. Triggers are
  /// off while the rows go in, so nothing pulled is sent back.
  Future<void> _apply(List<PulledChangeDto> changes, int cursor) =>
      _db.transaction(() async {
        final deviceId = (await _state()).deviceId;
        final bosses = <String>{};
        // Rows whose merge result differs from what the server holds.
        final resend = <(String, String)>{};
        await _outbox.setApplying(true);
        for (final c in changes) {
          if (!kSyncColumns.containsKey(c.table)) continue;
          if (c.op == PulledChangeDtoOpEnum.delete) {
            await _applyDelete(c);
          } else if (c.row != null) {
            final result = await _applyUpsert(c, deviceId);
            if (result.bossId != null) bosses.add(result.bossId!);
            if (result.resend case final key?) resend.add(key);
          }
        }
        await BossDao(_db, _clock).recomputeAttemptNumbers();
        await _outbox.setApplying(false);
        await _saveState(SyncStateCompanion(cursor: Value(cursor)));

        // These are our own merge results: they are written with triggers
        // on, so the next push carries them.
        for (final (table, id) in resend) {
          // Later than the row it corrects, or last write wins would drop it.
          final current = _parse((await _readRow(table, id))!['updated_at']);
          final now = _clock();
          final bump = now.isAfter(current)
              ? now
              : current.add(const Duration(milliseconds: 1));
          await _db.customStatement(
            'UPDATE $table SET updated_at = ? WHERE ${_idSql(table)} = ?',
            [sqlTime(bump), id],
          );
        }
        final stains = BloodstainDao(_db, _clock);
        for (final bossId in bosses) {
          await stains.settleBloodstains(bossId);
        }
      });

  Future<void> _forgetQueued(String table, String id) => (_db.delete(
    _db.syncOutbox,
  )..where((e) => e.tbl.equals(table) & e.rowId.equals(id))).go();

  Future<void> _applyDelete(PulledChangeDto c) async {
    if (kNaturalKeyTables.contains(c.table)) return;
    // Foreign keys carry the delete to the children, as on the server.
    await _db.customStatement(
      'DELETE FROM ${c.table} WHERE ${_idSql(c.table)} = ?',
      [c.id],
    );
    await _forgetQueued(c.table, c.id);
  }

  DateTime _parse(Object? v) => DateTime.parse(v! as String);

  Object? _toSql(String type, Object? v) {
    if (v == null) return null;
    return switch (type) {
      'boolean' => (v as bool) ? 1 : 0,
      'integer' => (v as num).toInt(),
      'timestamptz' => sqlTime(_parse(v).toLocal()),
      'jsonb' => jsonEncode(v),
      _ => v,
    };
  }

  Future<bool> _exists(String table, String id) async =>
      (await _readRow(table, id)) != null;

  Future<bool> _hasQueuedDelete(String table, String id) async =>
      (await (_db.select(_db.syncOutbox)..where(
                (e) =>
                    e.tbl.equals(table) &
                    e.rowId.equals(id) &
                    e.op.equals(SyncOp.delete.index),
              ))
              .get())
          .isNotEmpty;

  Future<_Applied> _applyUpsert(PulledChangeDto c, String deviceId) async {
    final table = c.table;
    final row = {...c.row!};
    for (final ref in kSyncReferences) {
      if (ref.table != table || row[ref.column] == null) continue;
      if (!await _exists(ref.parent, row[ref.column]! as String)) {
        // Parent unknown here: a child is dropped, a link is cleared.
        if (ref.cascade) return const _Applied();
        row[ref.column] = null;
      }
    }
    final local = await _readRow(table, c.id);
    if (local == null && await _hasQueuedDelete(table, c.id)) {
      // We deleted it; the tombstone we send wins on the server.
      return const _Applied();
    }
    final isEvent = kEventTables.contains(table);
    if (isEvent) {
      if (local != null) return const _Applied();
      await _write(table, c.id, row, null);
      return const _Applied();
    }
    final remoteAt = _parse(c.updatedAt);
    if (table == 'bloodstains') {
      return _applyBloodstain(c.id, row, remoteAt, local);
    }
    if (local != null && !_remoteWins(c, remoteAt, deviceId, local)) {
      if (table == 'user_settings') return _firstDayOnly(row, local);
      if (table == 'bosses') await _takeDefeat(row, local);
      return const _Applied();
    }
    var resend = false;
    if (table == 'user_settings' && local != null) {
      final merged = _earliest(
        local['first_day'] as String?,
        row['first_day'] as String?,
      );
      resend = merged != row['first_day'];
      row['first_day'] = merged;
    }
    if (table == 'bosses' && local != null) {
      resend = _keepDefeat(row, local);
    }
    await _write(table, c.id, row, remoteAt);
    await _forgetQueued(table, c.id);
    return resend ? _Applied(resend: (table, c.id)) : const _Applied();
  }

  static final _defeated = BossStatus.defeated.index;

  /// A defeat is final across phones (Stage 5 D2, extended): when [local] is
  /// defeated, [row] (the remote version about to be written) keeps the
  /// defeat, with the earlier of the two times. True when that leaves the row
  /// different from the remote one, so it must be sent again.
  bool _keepDefeat(Map<String, Object?> row, Map<String, Object?> local) {
    if (local['status'] != _defeated) return false;
    final localAt = _parse(local['defeated_at']);
    final remoteAt = row['status'] == _defeated && row['defeated_at'] != null
        ? _parse(row['defeated_at'])
        : null;
    final earliest = remoteAt != null && remoteAt.isBefore(localAt)
        ? remoteAt
        : localAt;
    final changed =
        row['status'] != _defeated ||
        remoteAt == null ||
        !remoteAt.isAtSameMomentAs(earliest);
    row['status'] = _defeated;
    row['defeated_at'] = earliest.toUtc().toIso8601String();
    return changed;
  }

  /// The remote copy lost on time, but a defeat in it still counts: take the
  /// defeat (or its earlier time) and nothing else. The server holds it
  /// already, so nothing is sent.
  Future<void> _takeDefeat(
    Map<String, Object?> remote,
    Map<String, Object?> local,
  ) async {
    if (remote['status'] != _defeated || remote['defeated_at'] == null) return;
    final remoteAt = _parse(remote['defeated_at']);
    final localAt = local['status'] == _defeated
        ? _parse(local['defeated_at'])
        : null;
    if (localAt != null && !remoteAt.isBefore(localAt)) return;
    await _db.customStatement(
      'UPDATE bosses SET status = ?, defeated_at = ? WHERE id = ?',
      [_defeated, sqlTime(remoteAt.toLocal()), local['id']],
    );
  }

  bool _remoteWins(
    PulledChangeDto c,
    DateTime remoteAt,
    String deviceId,
    Map<String, Object?> local,
  ) {
    final localAt = _parse(local['updated_at']);
    return remoteAt.isAfter(localAt) ||
        (remoteAt.isAtSameMomentAs(localAt) &&
            c.deviceId.compareTo(deviceId) > 0);
  }

  String? _earliest(String? a, String? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.compareTo(b) <= 0 ? a : b;
  }

  /// The remote settings lost on time, but their `firstDay` may be earlier
  /// (D9); keep ours and send the corrected row.
  Future<_Applied> _firstDayOnly(
    Map<String, Object?> remote,
    Map<String, Object?> local,
  ) async {
    final merged = _earliest(
      local['first_day'] as String?,
      remote['first_day'] as String?,
    );
    if (merged == local['first_day']) return const _Applied();
    await _db.customStatement('UPDATE user_settings SET first_day = ?', [
      merged,
    ]);
    return const _Applied(resend: ('user_settings', kUserSettingsId));
  }

  /// Field-by-field merge (D19): the earliest recovery and loss, a recovery
  /// clears the loss. Never replaces the whole row.
  Future<_Applied> _applyBloodstain(
    String id,
    Map<String, Object?> row,
    DateTime remoteAt,
    Map<String, Object?>? local,
  ) async {
    final bossId = (local?['boss_id'] ?? row['boss_id'])! as String;
    DateTime? time(Object? v) => v == null ? null : _parse(v);
    final remoteTimes = (
      recoveredAt: time(row['recovered_at']),
      lostAt: time(row['lost_at']),
    );
    if (local == null) {
      final merged = mergeStainTimes(remoteTimes, (
        recoveredAt: null,
        lostAt: null,
      ));
      row['recovered_at'] = merged.recoveredAt?.toIso8601String();
      row['lost_at'] = merged.lostAt?.toIso8601String();
      await _write(
        'bloodstains',
        id,
        row,
        stainUpdatedAt(_parse(row['created_at']), merged),
      );
      return _Applied(bossId: bossId);
    }
    final localTimes = (
      recoveredAt: time(local['recovered_at']),
      lostAt: time(local['lost_at']),
    );
    final merged = mergeStainTimes(localTimes, remoteTimes);
    final updatedAt = stainUpdatedAt(_parse(local['created_at']), merged);
    if (merged.recoveredAt != localTimes.recoveredAt ||
        merged.lostAt != localTimes.lostAt ||
        updatedAt != _parse(local['updated_at'])) {
      await _db.customStatement(
        'UPDATE bloodstains SET recovered_at = ?, lost_at = ?, updated_at = ? '
        'WHERE id = ?',
        [
          _toSql('timestamptz', merged.recoveredAt?.toIso8601String()),
          _toSql('timestamptz', merged.lostAt?.toIso8601String()),
          sqlTime(updatedAt.toLocal()),
          id,
        ],
      );
      await _forgetQueued('bloodstains', id);
    }
    return _Applied(bossId: bossId);
  }

  /// Inserts or replaces one row in place. `ON CONFLICT DO UPDATE`, not
  /// `REPLACE`, so children of the row are not cascaded away.
  Future<void> _write(
    String table,
    String id,
    Map<String, Object?> row,
    DateTime? updatedAt,
  ) async {
    final columns = kSyncColumns[table]!;
    final key = switch (table) {
      'day_logs' => ['day', 'kind'],
      'day_plans' => ['day'],
      _ => ['id'],
    };
    final names = [
      ...columns.keys,
      if (key.first == 'id') 'id',
      if (updatedAt != null) 'updated_at',
    ];
    final values = [
      for (final MapEntry(key: col, value: type) in columns.entries)
        _toSql(type, row[col]),
      if (key.first == 'id') id,
      if (updatedAt != null) sqlTime(updatedAt.toLocal()),
    ];
    final update = [
      for (final n in names)
        if (!key.contains(n)) '$n = excluded.$n',
    ];
    try {
      await _db.customStatement(
        'INSERT INTO $table (${names.join(', ')}) '
        'VALUES (${List.filled(names.length, '?').join(', ')}) '
        'ON CONFLICT(${key.join(', ')}) '
        '${update.isEmpty ? 'DO NOTHING' : 'DO UPDATE SET ${update.join(', ')}'}',
        values,
      );
    } on Object catch (e) {
      // Two phones made different ids for one natural key before ids were
      // deterministic. Keep ours; there is nothing safe to merge.
      if (!'$e'.contains('UNIQUE constraint')) rethrow;
    }
  }
}

/// One change to send and the outbox entries it stands for.
class _Send {
  _Send(this.change, this.seqs);

  final ChangeDto change;
  final List<int> seqs;

  String get key => '${change.table}/${change.id}';
  int get firstSeq => seqs.reduce((a, b) => a < b ? a : b);
}

/// What applying one pulled row asks of the page: a boss whose bloodstains
/// need settling, or a row to re-send.
class _Applied {
  const _Applied({this.bossId, this.resend});

  final String? bossId;

  /// A (table, id) whose merged row differs from the server's, so it is sent
  /// again with a later time.
  final (String, String)? resend;
}

/// When to sync (Stage 7 plan D15): on start and resume, 5 s after the last
/// local write, and after a failure at 30 s, 2 min and 10 min, then not
/// until the next start or resume. No background job.
class SyncScheduler {
  SyncScheduler({required this._run, this._timer = Timer.new});

  static const debounce = Duration(seconds: 5);
  static const backoff = [
    Duration(seconds: 30),
    Duration(minutes: 2),
    Duration(minutes: 10),
  ];

  final Future<SyncOutcome> Function() _run;
  final Timer Function(Duration, void Function()) _timer;

  Timer? _waiting;
  int _failures = 0;
  bool _running = false;
  bool _again = false;
  bool _disposed = false;

  /// App start, or a fresh sign-in. Completes with how the run ended.
  Future<SyncOutcome> start() => _now();

  /// App back in the foreground.
  Future<SyncOutcome> resumed() => _now();

  Future<SyncOutcome> _now() {
    _waiting?.cancel();
    _failures = 0;
    return _go();
  }

  /// A local write happened. Ignored while waiting out a failure or after
  /// giving up: the wait, or the next resume, covers it.
  void localWrite() {
    if (_disposed || _failures > 0) return;
    _waiting?.cancel();
    _waiting = _timer(debounce, () => unawaited(_go()));
  }

  /// Runs now. Completes `failed` when it could not run: one is already
  /// in flight (it will go again) or the scheduler is gone.
  Future<SyncOutcome> _go() async {
    if (_disposed) return SyncOutcome.failed;
    if (_running) {
      _again = true;
      return SyncOutcome.failed;
    }
    _running = true;
    SyncOutcome outcome;
    try {
      outcome = await _run();
    } finally {
      _running = false;
    }
    if (_disposed) return outcome;
    switch (outcome) {
      case SyncOutcome.synced:
        _failures = 0;
      case SyncOutcome.signedOut:
        _failures = 0;
        return outcome;
      case SyncOutcome.failed:
        _failures++;
        if (_failures <= backoff.length) {
          _waiting?.cancel();
          _waiting = _timer(backoff[_failures - 1], () => unawaited(_go()));
        }
        return outcome;
    }
    if (_again) {
      _again = false;
      localWrite();
    }
    return outcome;
  }

  void dispose() {
    _disposed = true;
    _waiting?.cancel();
  }
}
