import 'package:hearthrise_api/hearthrise_api.dart'
    show ChangeDto, PullResponse, PushResult;

/// What the sync service needs from the server. The real one wraps the
/// generated client; tests use a fake that follows the same merge rules
/// (Stage 7 plan step 8). Any exception means "try again later", except
/// [SyncUnauthorized].
abstract interface class SyncApi {
  /// Sends [changes] and returns one result per change, in order.
  Future<List<PushResult>> push(String deviceId, List<ChangeDto> changes);

  /// Changes after [since], oldest first, one page at a time.
  Future<PullResponse> pull(int since);
}

/// The server no longer accepts this phone's session (HTTP 401).
class SyncUnauthorized implements Exception {
  const SyncUnauthorized();

  @override
  String toString() => 'SyncUnauthorized';
}
