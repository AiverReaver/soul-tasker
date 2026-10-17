import 'package:hearthrise/core/auth_gateway.dart';
import 'package:hearthrise/data/account_api.dart';

/// Google sign-in and secure storage, in memory.
class FakeAuthGateway implements AuthGateway {
  /// What the Google sheet returns; null is the user backing out.
  String? idToken = 'google-token-ash';

  /// Make the sheet fail.
  bool fails = false;

  /// Whether Google sign-in can run on this build (an iOS client id).
  @override
  bool isGoogleConfigured = true;

  /// How often the Google sheet was opened.
  int googleCalls = 0;

  String? token;
  int googleSignOuts = 0;

  @override
  Future<String?> googleIdToken() async {
    googleCalls++;
    if (fails) throw StateError('google failed');
    return idToken;
  }

  @override
  Future<void> googleSignOut() async => googleSignOuts++;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> saveToken(String value) async => token = value;

  @override
  Future<void> clearToken() async => token = null;
}

/// The account endpoints: Google ID tokens map to accounts.
class FakeAccountApi implements AccountApi {
  FakeAccountApi();

  final accounts = <String, ({String id, String email})>{
    'google-token-ash': (id: 'user-ash', email: 'ash@example.com'),
    'google-token-bo': (id: 'user-bo', email: 'bo@example.com'),
  };

  bool failSignIn = false;
  final calls = <String>[];
  int _n = 0;

  @override
  Future<AccountSession> signIn(String idToken) async {
    calls.add('signIn');
    final a = accounts[idToken];
    if (failSignIn || a == null) throw const AccountException('refused');
    return AccountSession(
      token: 'session-${++_n}',
      userId: a.id,
      email: a.email,
    );
  }

  @override
  Future<void> signOut(String token) async => calls.add('signOut:$token');

  @override
  Future<void> deleteAccount(String token) async => calls.add('delete:$token');
}
