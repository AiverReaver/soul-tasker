import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/sync_schema.dart';
import 'package:hearthrise/data/sync_sql.dart';

void main() {
  // Tests run from app/. The server checks its own tables against this file.
  final fixture = jsonDecode(
    File('../server/test/fixtures/sync_schema.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  test('the synced columns equal the server fixture, in order', () {
    final columns = (fixture['columns'] as Map<String, dynamic>).map(
      (t, cols) => MapEntry(
        t,
        (cols as Map<String, dynamic>).entries
            .map((e) => '${e.key}:${e.value}')
            .toList(),
      ),
    );
    final ours = kSyncColumns.map(
      (t, cols) =>
          MapEntry(t, [for (final e in cols.entries) '${e.key}:${e.value}']),
    );
    expect(ours, columns);
  });

  test('event and natural-key tables equal the server fixture', () {
    expect(kEventTables, unorderedEquals(fixture['events'] as List));
    expect(kNaturalKeyTables, unorderedEquals(fixture['naturalKey'] as List));
  });

  test('the references equal the server fixture', () {
    final refs = [
      for (final r in fixture['references'] as List)
        '${r['table']}.${r['column']}>${r['parent']}:${r['onDelete']}',
    ];
    expect([
      for (final r in kSyncReferences)
        '${r.table}.${r.column}>${r.parent}:${r.cascade ? 'cascade' : 'setNull'}',
    ], refs);
  });

  test('every synced table is one the outbox triggers watch', () {
    expect(kSyncColumns.keys, unorderedEquals(kSyncedTables.keys));
  });
}
