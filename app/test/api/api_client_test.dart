import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/sync_sql.dart';
import 'package:hearthrise_api/hearthrise_api.dart';
import 'package:hearthrise_api/spec_hash.dart';

void main() {
  test('the generated client matches server/openapi.json (D3)', () {
    // Tests run from app/. If this fails, run tool/gen_api_client.sh.
    final spec = File('../server/openapi.json').readAsBytesSync();
    expect(kOpenApiSha256, sha256.convert(spec).toString());
  });

  group('ChangeDto round-trips for every synced table', () {
    for (final table in kSyncedTables.keys) {
      test(table, () {
        final json = {
          'table': table,
          'id': '$table-1',
          'op': 'upsert',
          'updatedAt': '2026-10-16T09:00:00.123456Z',
          'row': {
            'title': 'The Garage',
            'position': 2,
            'is_pinned': true,
            'lesson': null,
            'task_ids': ['t1', 't2'],
          },
        };
        final dto = ChangeDto.fromJson(json);
        expect(dto.table, table);
        expect(jsonDecode(jsonEncode(dto.toJson())), json);
      });
    }

    test('a delete has no row', () {
      final json = {
        'table': 'bosses',
        'id': 'b1',
        'op': 'delete',
        'deletedAt': '2026-10-16T10:00:00Z',
      };
      expect(jsonDecode(jsonEncode(ChangeDto.fromJson(json).toJson())), json);
    });
  });
}
