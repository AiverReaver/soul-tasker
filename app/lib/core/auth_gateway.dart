import 'dart:io' show Platform;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Google sign-in and the session token's safe (Stage 7 plan D4). The app
/// talks to this seam, so tests need neither a device nor Google.
abstract interface class AuthGateway {
  /// False when this build cannot open Google sign-in (iOS without a client
  /// id): calling [googleIdToken] there would crash the app.
  bool get isGoogleConfigured;

  /// A Google ID token for the Web client id, or null when the user backs
  /// out of the Google sheet. Throws when sign-in fails.
  Future<String?> googleIdToken();

  Future<void> googleSignOut();

  Future<String?> readToken();

  Future<void> saveToken(String token);

  Future<void> clearToken();
}

/// The Web client id the server checks ID tokens against (plan D4). Set at
/// build time: `--dart-define=GOOGLE_WEB_CLIENT_ID=...`.
const kGoogleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

/// The iOS OAuth client id, set at build time:
/// `--dart-define=GOOGLE_IOS_CLIENT_ID=...`. The same value must be in
/// `ios/Runner/Info.plist` as GIDClientID, or the Google SDK aborts.
const kGoogleIosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

class DeviceAuthGateway implements AuthGateway {
  DeviceAuthGateway({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'hearthrise_session_token';

  final FlutterSecureStorage _storage;
  Future<void>? _initialized;

  @override
  bool get isGoogleConfigured =>
      !Platform.isIOS || kGoogleIosClientId.isNotEmpty;

  Future<void> _init() => _initialized ??= GoogleSignIn.instance.initialize(
    clientId: Platform.isIOS ? kGoogleIosClientId : null,
    serverClientId: kGoogleWebClientId.isEmpty ? null : kGoogleWebClientId,
  );

  @override
  Future<String?> googleIdToken() async {
    await _init();
    try {
      final account = await GoogleSignIn.instance.authenticate();
      return account.authentication.idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  @override
  Future<void> googleSignOut() async {
    await _init();
    await GoogleSignIn.instance.signOut();
  }

  @override
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  @override
  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  @override
  Future<void> clearToken() => _storage.delete(key: _tokenKey);
}
