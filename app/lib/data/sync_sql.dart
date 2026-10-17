import 'package:sqlite3/common.dart';

import '../core/clock.dart';
import 'enums.dart';

/// Synced tables and the SQL for one row's id, as the server stores it
/// (Stage 7 plan D14); `{r}` is the row. Day logs have a natural key, sent
/// as "$day:$kind".
const kSyncedTables = {
  'bosses': '{r}.id',
  'phases': '{r}.id',
  'tasks': '{r}.id',
  'attempts': '{r}.id',
  'commitments': '{r}.id',
  'health_events': '{r}.id',
  'ember_events': '{r}.id',
  'flask_events': '{r}.id',
  'relics': '{r}.id',
  'bloodstains': '{r}.id',
  'day_logs': "{r}.day || ':' || {r}.kind",
  'day_plans': '{r}.day',
  'user_settings': '{r}.id',
};

/// Registers `hearthrise_now()`, the time the outbox triggers stamp, on a
/// raw connection. Pass it as the `setup` of every connection that writes;
/// tests pass a fixed [clock]. A top-level function, so it can be sent to
/// the database isolate.
void registerSyncFunctions(CommonDatabase db, [Clock clock = DateTime.now]) {
  db.createFunction(
    functionName: 'hearthrise_now',
    argumentCount: const AllowedArgumentCount(0),
    deterministic: false,
    directOnly: false,
    function: (_) => sqlTime(clock()),
  );
}

/// [t] as drift stores it with `store_date_time_values_as_text`: ISO 8601,
/// with the UTC offset for a local time, so it reads back as the same time.
String sqlTime(DateTime t) {
  if (t.isUtc) return t.toIso8601String();
  final offset = t.timeZoneOffset;
  final hours = offset.inHours.abs();
  final minutes = offset.inMinutes.abs() - 60 * hours;
  return '${t.toIso8601String()} ${offset.isNegative ? '-' : '+'}'
      '${'$hours'.padLeft(2, '0')}:${'$minutes'.padLeft(2, '0')}';
}

/// One insert, update and delete trigger per synced table, each writing an
/// outbox row in the same transaction as the change, except while pulled
/// rows are applied. TEMP, so they are made on every open and never part of
/// the stored schema.
List<String> syncTriggerSql() => [
  for (final MapEntry(key: table, value: id) in kSyncedTables.entries)
    for (final (event, row, op) in [
      ('INSERT', 'NEW', SyncOp.upsert),
      ('UPDATE', 'NEW', SyncOp.upsert),
      ('DELETE', 'OLD', SyncOp.delete),
    ])
      'CREATE TEMP TRIGGER IF NOT EXISTS sync_${table}_${event.toLowerCase()} '
          'AFTER $event ON $table '
          'WHEN (SELECT applying FROM sync_state WHERE id = 1) = 0 '
          'BEGIN INSERT INTO sync_outbox (tbl, row_id, op, at) VALUES '
          "('$table', ${id.replaceAll('{r}', row)}, ${op.index}, "
          'hearthrise_now()); END',
];
