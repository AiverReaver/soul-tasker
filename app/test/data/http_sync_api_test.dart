import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/http_sync_api.dart';
import 'package:hearthrise/data/sync_api.dart';
import 'package:hearthrise_api/hearthrise_api.dart'
    show ChangeDto, ChangeDtoOpEnum, HearthriseApi, PushResultStatusEnum;

/// Answers every request with [status] and [body], and keeps the requests.
class _Stub implements HttpClientAdapter {
  _Stub(this.status, this.body);

  final int status;
  final Object body;
  final seen = <RequestOptions>[];
  final bodies = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    seen.add(options);
    if (requestStream != null) {
      bodies.add(
        utf8.decode([for (final c in await requestStream.toList()) ...c]),
      );
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

HttpSyncApi _api(_Stub stub) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
    ..httpClientAdapter = stub;
  return HttpSyncApi(HearthriseApi(dio: dio).getSyncApi());
}

void main() {
  test('push posts the changes and returns the results', () async {
    final stub = _Stub(200, {
      'results': [
        {'table': 'bosses', 'id': 'b1', 'status': 'applied'},
      ],
    });
    final results = await _api(stub).push('dev-1', [
      ChangeDto(
        table: 'bosses',
        id: 'b1',
        op: ChangeDtoOpEnum.delete,
        deletedAt: '2026-10-16T09:00:00.000Z',
      ),
    ]);
    expect(results.single.status, PushResultStatusEnum.applied);
    expect(stub.seen.single.path, '/v1/sync/push');
    final sent = jsonDecode(stub.bodies.single) as Map<String, dynamic>;
    expect(sent['deviceId'], 'dev-1');
    expect((sent['changes'] as List).single['op'], 'delete');
  });

  test('pull asks since the cursor', () async {
    final stub = _Stub(200, {'changes': [], 'cursor': 7, 'hasMore': false});
    final page = await _api(stub).pull(7);
    expect(page.cursor, 7);
    expect(stub.seen.single.queryParameters, {'since': 7});
  });

  test('a 401 is SyncUnauthorized, in push and in pull', () async {
    final stub = _Stub(401, {'error': 'unauthorized'});
    await expectLater(_api(stub).pull(0), throwsA(isA<SyncUnauthorized>()));
    await expectLater(
      _api(stub).push('d', []),
      throwsA(isA<SyncUnauthorized>()),
    );
  });

  test('another error status is passed on to be retried', () async {
    final stub = _Stub(503, {'error': 'down'});
    await expectLater(_api(stub).pull(0), throwsA(isA<DioException>()));
  });
}
