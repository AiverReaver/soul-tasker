import 'package:dio/dio.dart';

import 'data/http_account_api.dart';
import 'data/http_sync_api.dart';
import 'data/sync_api.dart';

import 'package:hearthrise_api/hearthrise_api.dart' show HearthriseApi;

/// The release server, set at build time:
/// `--dart-define=API_BASE_URL=https://...`. Empty means no backend: sign-in
/// is refused and the app stays as it was before Stage 7.
const kApiBaseUrl = String.fromEnvironment('API_BASE_URL');

bool get hasServer => kApiBaseUrl.isNotEmpty;

Dio _dio(String? token) => Dio(
  BaseOptions(
    baseUrl: kApiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: token == null ? null : {'Authorization': 'Bearer $token'},
  ),
);

HttpAccountApi buildAccountApi() => HttpAccountApi(_dio);

SyncApi buildSyncApi(String token) =>
    HttpSyncApi(HearthriseApi(dio: _dio(token)).getSyncApi());
