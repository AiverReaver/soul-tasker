import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/account_api.dart';
import 'package:hearthrise/data/http_account_api.dart';

class _Stub implements HttpClientAdapter {
  _Stub(this.status, [this.body = const {}]);

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
      status == 204 ? '' : jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

HttpAccountApi _api(_Stub stub) => HttpAccountApi(
  (token) => Dio(
    BaseOptions(
      baseUrl: 'https://example.test',
      headers: token == null ? null : {'Authorization': 'Bearer $token'},
    ),
  )..httpClientAdapter = stub,
);

void main() {
  test('signIn posts the Google token and returns the session', () async {
    final stub = _Stub(200, {
      'token': 'tok',
      'expiresAt': '2026-12-15T00:00:00.000Z',
      'user': {'id': 'u1', 'email': 'ash@example.com'},
    });
    final s = await _api(stub).signIn('google-id-token');
    expect((s.token, s.userId, s.email), ('tok', 'u1', 'ash@example.com'));
    expect(stub.seen.single.path, '/v1/auth/google');
    expect(jsonDecode(stub.bodies.single), {'idToken': 'google-id-token'});
    expect(stub.seen.single.headers['Authorization'], isNull);
  });

  test('signOut and deleteAccount carry the session token', () async {
    final out = _Stub(204);
    await _api(out).signOut('tok');
    expect(out.seen.single.path, '/v1/auth/logout');
    expect(out.seen.single.method, 'POST');
    expect(out.seen.single.headers['Authorization'], 'Bearer tok');

    final del = _Stub(204);
    await _api(del).deleteAccount('tok');
    expect(del.seen.single.path, '/v1/account');
    expect(del.seen.single.method, 'DELETE');
    expect(del.seen.single.headers['Authorization'], 'Bearer tok');
  });

  test('a refusal or a network error is an AccountException', () async {
    await expectLater(
      _api(_Stub(401, {'error': 'invalid id token'})).signIn('x'),
      throwsA(isA<AccountException>()),
    );
    await expectLater(
      _api(_Stub(503)).deleteAccount('tok'),
      throwsA(isA<AccountException>()),
    );
  });
}
