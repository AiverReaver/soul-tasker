import 'package:dio/dio.dart';
import 'package:hearthrise_api/hearthrise_api.dart' as api show SyncApi;
import 'package:hearthrise_api/hearthrise_api.dart'
    show ChangeDto, PullResponse, PushRequest, PushResult;

import 'sync_api.dart';

/// [SyncApi] over the generated client. The client's `Dio` carries the
/// session token (Stage 7 plan step 9); a 401 becomes [SyncUnauthorized] and
/// every other failure is left as thrown, to be retried.
class HttpSyncApi implements SyncApi {
  HttpSyncApi(this._client);

  final api.SyncApi _client;

  @override
  Future<List<PushResult>> push(String deviceId, List<ChangeDto> changes) =>
      _guard(() async {
        final response = await _client.syncPush(
          pushRequest: PushRequest(deviceId: deviceId, changes: changes),
        );
        return response.data!.results;
      });

  @override
  Future<PullResponse> pull(int since) => _guard(() async {
    final response = await _client.syncPull(since: since);
    return response.data!;
  });

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const SyncUnauthorized();
      rethrow;
    }
  }
}
