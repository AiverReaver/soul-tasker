import 'package:dio/dio.dart';
import 'package:hearthrise_api/hearthrise_api.dart'
    show AuthGoogleRequest, HearthriseApi;

import 'account_api.dart';

/// [AccountApi] over the generated client. [dio] builds a client for the
/// release server, with the session token as a bearer header when given.
class HttpAccountApi implements AccountApi {
  HttpAccountApi(this._dio);

  final Dio Function(String? token) _dio;

  HearthriseApi _client([String? token]) => HearthriseApi(dio: _dio(token));

  @override
  Future<AccountSession> signIn(String idToken) => _guard(() async {
    final response = await _client().getAuthApi().authGoogle(
      authGoogleRequest: AuthGoogleRequest(idToken: idToken),
    );
    final s = response.data!;
    return AccountSession(
      token: s.token,
      userId: s.user.id,
      email: s.user.email,
    );
  });

  @override
  Future<void> signOut(String token) =>
      _guard(() => _client(token).getAuthApi().logout());

  @override
  Future<void> deleteAccount(String token) =>
      _guard(() => _client(token).getAccountApi().deleteAccount());

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw AccountException('HTTP ${e.response?.statusCode ?? 'no response'}');
    }
  }
}
