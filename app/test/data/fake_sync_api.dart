import 'dart:async';

import 'package:hearthrise/core/bloodstain_merge.dart';
import 'package:hearthrise/data/sync_api.dart';
import 'package:hearthrise/data/sync_schema.dart';
import 'package:hearthrise_api/hearthrise_api.dart' hide SyncApi;

class _Rec {
  _Rec({
    required this.row,
    required this.updatedAt,
    required this.deviceId,
    required this.seq,
    this.deletedAt,
  });

  Map<String, Object?>? row;
  DateTime? updatedAt;
  String deviceId;
  int seq;
  DateTime? deletedAt;
}

final _iso = RegExp(
  r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,6})?(Z|[+-]\d{2}:\d{2})$',
);

/// The server's merge rules (`server/src/sync.ts`, plan D5, D13, D19) for one
/// user, in memory. Its bloodstain cases run against the shared fixture, so
/// it cannot drift from the real server.
class FakeSyncApi implements SyncApi {
  FakeSyncApi({this.pageSize = 500, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final int pageSize;
  final DateTime Function() _now;
  final _tables = <String, Map<String, _Rec>>{};
  int _seq = 0;

  /// Every push received, as (deviceId, changes).
  final pushes = <(String, List<ChangeDto>)>[];
  int pullCalls = 0;

  /// Throws on the next call (a network error); one entry per call.
  int failCalls = 0;

  /// Throws [SyncUnauthorized] on every call.
  bool unauthorized = false;

  /// Runs inside the next push, before it answers: an edit "in flight".
  Future<void> Function()? duringPush;

  /// Reject these ("table/id") with a reason; the entry is used up by
  /// [rejectOnce], kept by [reject].
  final reject = <String, PushResultReasonEnum>{};
  final rejectOnce = <String, PushResultReasonEnum>{};

  Map<String, _Rec> _t(String table) => _tables.putIfAbsent(table, () => {});

  /// The stored payload of a live row, or null.
  Map<String, Object?>? rowOf(String table, String id) {
    final r = _t(table)[id];
    return r?.deletedAt == null ? r?.row : null;
  }

  bool isDeleted(String table, String id) => _t(table)[id]?.deletedAt != null;

  List<String> liveIds(String table) => [
    for (final e in _t(table).entries)
      if (e.value.deletedAt == null) e.key,
  ];

  void _gate() {
    if (unauthorized) throw const SyncUnauthorized();
    if (failCalls > 0) {
      failCalls--;
      throw StateError('network down');
    }
  }

  @override
  Future<List<PushResult>> push(
    String deviceId,
    List<ChangeDto> changes,
  ) async {
    _gate();
    pushes.add((deviceId, changes));
    final hook = duringPush;
    duringPush = null;
    await hook?.call();
    return [for (final c in changes) _applyOne(deviceId, c)];
  }

  PushResult _result(
    ChangeDto c,
    PushResultStatusEnum status, [
    PushResultReasonEnum? reason,
    String? message,
  ]) => PushResult(
    table: c.table,
    id: c.id,
    status: status,
    reason: reason,
    message: message,
  );

  PushResult _applyOne(String deviceId, ChangeDto c) {
    final key = '${c.table}/${c.id}';
    final forced = rejectOnce.remove(key) ?? reject[key];
    if (forced != null) {
      return _result(c, PushResultStatusEnum.rejected, forced, 'forced');
    }
    final columns = kSyncColumns[c.table];
    if (columns == null) {
      return _result(
        c,
        PushResultStatusEnum.rejected,
        PushResultReasonEnum.malformed,
        'unknown table',
      );
    }
    if (c.op == ChangeDtoOpEnum.delete) {
      if (kNaturalKeyTables.contains(c.table)) {
        return _result(
          c,
          PushResultStatusEnum.rejected,
          PushResultReasonEnum.malformed,
          'never deleted',
        );
      }
      final at = c.deletedAt == null ? _now() : DateTime.parse(c.deletedAt!);
      return _status(c, _deleteRow(c.table, c.id, at, deviceId));
    }
    final problem = _check(c, columns);
    if (problem != null) {
      return _result(
        c,
        PushResultStatusEnum.rejected,
        problem.startsWith('clock')
            ? PushResultReasonEnum.clock
            : PushResultReasonEnum.malformed,
        problem,
      );
    }
    return _status(c, _upsert(c, deviceId));
  }

  PushResult _status(ChangeDto c, bool applied) => _result(
    c,
    applied ? PushResultStatusEnum.applied : PushResultStatusEnum.ignored,
  );

  String? _check(ChangeDto c, Map<String, String> columns) {
    final row = c.row;
    if (row == null) return 'upsert without row';
    if (row.length != columns.length || !columns.keys.every(row.containsKey)) {
      return 'columns must be exactly ${columns.keys.join(', ')}';
    }
    for (final MapEntry(key: col, value: type) in columns.entries) {
      final v = row[col];
      if (v == null) continue;
      final ok = switch (type) {
        'text' => v is String,
        'integer' => v is int,
        'boolean' => v is bool,
        'timestamptz' => v is String && _iso.hasMatch(v),
        _ => v is List && v.every((x) => x is String),
      };
      if (!ok) return 'bad $col';
    }
    if (!kEventTables.contains(c.table)) {
      final u = c.updatedAt;
      if (u == null || !_iso.hasMatch(u)) return 'bad updatedAt';
      if (DateTime.parse(u).difference(_now()) > const Duration(hours: 24)) {
        return 'clock: updatedAt is more than 24 h ahead';
      }
    }
    return null;
  }

  int _next() => ++_seq;

  bool _upsert(ChangeDto c, String deviceId) {
    final table = c.table;
    final existing = _t(table)[c.id];
    if (existing?.deletedAt != null) return false;
    final row = {...c.row!};
    for (final ref in kSyncReferences) {
      if (ref.table != table || row[ref.column] == null) continue;
      if (isDeleted(ref.parent, row[ref.column]! as String)) {
        if (ref.cascade) return false;
        row[ref.column] = null;
      }
    }
    final updatedAt = c.updatedAt == null ? null : DateTime.parse(c.updatedAt!);
    if (table == 'bloodstains') {
      return _bloodstain(c.id, row, updatedAt!, deviceId, existing);
    }
    if (kEventTables.contains(table)) {
      if (existing != null) return false;
      _t(table)[c.id] = _Rec(
        row: row,
        updatedAt: null,
        deviceId: deviceId,
        seq: _next(),
      );
      return true;
    }
    if (existing != null) {
      final newer = _newer(
        updatedAt!,
        deviceId,
        existing.updatedAt!,
        existing.deviceId,
      );
      if (!newer) return false;
    }
    _t(table)[c.id] = _Rec(
      row: row,
      updatedAt: updatedAt,
      deviceId: deviceId,
      seq: _next(),
    );
    return true;
  }

  bool _newer(DateTime at, String device, DateTime thenAt, String thenDevice) =>
      at.isAfter(thenAt) || (at == thenAt && device.compareTo(thenDevice) > 0);

  bool _deleteRow(String table, String id, DateTime at, String deviceId) {
    final existing = _t(table)[id];
    if (existing?.deletedAt != null) return false;
    _t(table)[id] = _Rec(
      row: null,
      updatedAt: null,
      deviceId: deviceId,
      seq: _next(),
      deletedAt: at,
    );
    for (final ref in kSyncReferences) {
      if (ref.parent != table) continue;
      for (final child in _t(ref.table).entries.toList()) {
        if (child.value.deletedAt != null) continue;
        if (child.value.row![ref.column] != id) continue;
        if (ref.cascade) {
          _deleteRow(ref.table, child.key, at, deviceId);
        } else {
          child.value.row![ref.column] = null;
          child.value.seq = _next();
        }
      }
    }
    return true;
  }

  DateTime? _time(Object? v) => v == null ? null : DateTime.parse(v as String);

  bool _bloodstain(
    String id,
    Map<String, Object?> row,
    DateTime updatedAt,
    String deviceId,
    _Rec? existing,
  ) {
    final incoming = (
      recoveredAt: _time(row['recovered_at']),
      lostAt: _time(row['lost_at']),
    );
    final String bossId = row['boss_id']! as String;
    bool changed;
    if (existing == null) {
      final merged = mergeStainTimes(incoming, (
        recoveredAt: null,
        lostAt: null,
      ));
      row['recovered_at'] = merged.recoveredAt?.toUtc().toIso8601String();
      row['lost_at'] = merged.lostAt?.toUtc().toIso8601String();
      _t('bloodstains')[id] = _Rec(
        row: row,
        updatedAt: updatedAt,
        deviceId: deviceId,
        seq: _next(),
      );
      changed = true;
    } else {
      final stored = existing.row!;
      final merged = mergeStainTimes((
        recoveredAt: _time(stored['recovered_at']),
        lostAt: _time(stored['lost_at']),
      ), incoming);
      final newRec = merged.recoveredAt?.toUtc().toIso8601String();
      final newLost = merged.lostAt?.toUtc().toIso8601String();
      changed =
          newRec != stored['recovered_at'] || newLost != stored['lost_at'];
      if (changed) {
        stored['recovered_at'] = newRec;
        stored['lost_at'] = newLost;
        existing.deviceId = deviceId;
        existing.seq = _next();
        if (updatedAt.isAfter(existing.updatedAt!)) {
          existing.updatedAt = updatedAt;
        }
      }
    }
    return _settle(bossId) || changed;
  }

  /// The newest active bloodstain stays; the rest are lost at its time (D11).
  bool _settle(String bossId) {
    final live =
        [
          for (final e in _t('bloodstains').entries)
            if (e.value.deletedAt == null &&
                e.value.row!['boss_id'] == bossId &&
                e.value.row!['recovered_at'] == null &&
                e.value.row!['lost_at'] == null)
              e,
        ]..sort((a, b) {
          final byTime = DateTime.parse(b.value.row!['created_at']! as String)
              .compareTo(DateTime.parse(a.value.row!['created_at']! as String));
          return byTime != 0 ? byTime : b.key.compareTo(a.key);
        });
    if (live.length < 2) return false;
    final at = DateTime.parse(live.first.value.row!['created_at']! as String);
    for (final loser in live.skip(1)) {
      loser.value.row!['lost_at'] = at.toUtc().toIso8601String();
      loser.value.seq = _next();
    }
    return true;
  }

  @override
  Future<PullResponse> pull(int since) async {
    _gate();
    pullCalls++;
    final all = <(String, String, _Rec)>[
      for (final t in _tables.entries)
        for (final r in t.value.entries)
          if (r.value.seq > since) (t.key, r.key, r.value),
    ]..sort((a, b) => a.$3.seq.compareTo(b.$3.seq));
    final page = all.take(pageSize).toList();
    return PullResponse(
      changes: [
        for (final (table, id, r) in page)
          PulledChangeDto(
            table: table,
            id: id,
            op: r.deletedAt == null
                ? PulledChangeDtoOpEnum.upsert
                : PulledChangeDtoOpEnum.delete,
            seq: r.seq,
            deviceId: r.deviceId,
            updatedAt: r.updatedAt?.toUtc().toIso8601String(),
            deletedAt: r.deletedAt?.toUtc().toIso8601String(),
            row: r.deletedAt == null ? {...r.row!} : null,
          ),
      ],
      cursor: page.isEmpty ? since : page.last.$3.seq,
      hasMore: all.length > pageSize,
    );
  }
}
