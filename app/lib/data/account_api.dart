/// A signed-in account: the opaque session token and who it is for.
class AccountSession {
  const AccountSession({
    required this.token,
    required this.userId,
    required this.email,
  });

  final String token;
  final String userId;
  final String email;
}

/// The server refused or could not do what an account call asked.
class AccountException implements Exception {
  const AccountException(this.message);

  final String message;

  @override
  String toString() => 'AccountException: $message';
}

/// The account endpoints (Stage 7 plan D4, D17). Throws [AccountException].
abstract interface class AccountApi {
  /// Verifies a Google ID token and opens a session.
  Future<AccountSession> signIn(String idToken);

  /// Ends [token]'s session on the server.
  Future<void> signOut(String token);

  /// Removes every row of the account (D17).
  Future<void> deleteAccount(String token);
}
