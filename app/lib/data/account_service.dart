import 'package:drift/drift.dart';

import '../core/auth_gateway.dart';
import 'account_api.dart';
import 'database.dart';
import 'sync_service.dart';
import 'sync_sql.dart';

enum SignInOutcome {
  /// Signed in and the first sync ran (or will retry).
  signedIn,

  /// The user closed the Google sheet.
  cancelled,

  /// The user declined to back this phone up to the account (D18).
  declined,

  /// Google or the server refused; nothing changed.
  failed,

  /// This build has no server or no Google client id; Google never opened.
  unavailable,
}

class SignInResult {
  const SignInResult(this.outcome, {this.showMergeNotice = false});

  final SignInOutcome outcome;

  /// The account already had bosses from another phone (D16); say once that
  /// both are kept.
  final bool showMergeNotice;
}

/// Sign-in, sign-out and account deletion (Stage 7 plan D16 to D18).
/// Signing in queues everything in the outbox, so the first sync is a
/// normal one and a crash resumes from the durable queue.
class AccountService {
  AccountService({
    required this._db,
    required this._gateway,
    required this._api,
    required this._runSync,
    required this._currentSession,
    required this._setSession,
    this._hasServer = _always,
  });

  static bool _always() => true;

  final AppDatabase _db;
  final AuthGateway _gateway;
  final AccountApi _api;
  final Future<SyncOutcome> Function() _runSync;
  final AccountSession? Function() _currentSession;
  final void Function(AccountSession?) _setSession;
  final bool Function() _hasServer;

  /// [confirmBackup] is asked with the account's email when this phone last
  /// belonged to another account, or its session ended (D18).
  Future<SignInResult> signIn({
    required Future<bool> Function(String email) confirmBackup,
  }) async {
    if (!_hasServer() || !_gateway.isGoogleConfigured) {
      return const SignInResult(SignInOutcome.unavailable);
    }
    final String? idToken;
    final AccountSession session;
    try {
      idToken = await _gateway.googleIdToken();
      if (idToken == null) return const SignInResult(SignInOutcome.cancelled);
      session = await _api.signIn(idToken);
    } on Object {
      return const SignInResult(SignInOutcome.failed);
    }

    final state = await _db.select(_db.syncState).getSingle();
    final isStranger =
        state.sessionEnded ||
        (state.lastAccountId != null && state.lastAccountId != session.userId);
    if (isStranger && !await confirmBackup(session.email)) {
      await _revoke(session.token);
      return const SignInResult(SignInOutcome.declined);
    }

    final before = await _bossIds();
    await _gateway.saveToken(session.token);
    await _db.transaction(() async {
      await _queueEverything();
      await _db
          .update(_db.syncState)
          .write(
            SyncStateCompanion(
              accountEmail: Value(session.email),
              lastAccountId: Value(session.userId),
              sessionEnded: const Value(false),
              cursor: const Value(0),
              lastError: const Value(null),
            ),
          );
    });
    _setSession(session);

    final outcome = await _runSync();
    var notice = false;
    if (outcome == SyncOutcome.synced) {
      final arrived = (await _bossIds()).difference(before);
      final shown =
          (await _db.select(_db.syncState).getSingle()).mergeNoticeShown;
      if (arrived.isNotEmpty && !shown) {
        notice = true;
        await _db
            .update(_db.syncState)
            .write(const SyncStateCompanion(mergeNoticeShown: Value(true)));
      }
    }
    return SignInResult(SignInOutcome.signedIn, showMergeNotice: notice);
  }

  Future<Set<String>> _bossIds() async => {
    for (final r in await _db.customSelect('SELECT id FROM bosses').get())
      r.read<String>('id'),
  };

  /// Every synced row, as an upsert. Inserting into the outbox fires no
  /// trigger, so nothing is queued twice (D16).
  Future<void> _queueEverything() async {
    for (final table in kSyncedTables.keys) {
      final id = kSyncedTables[table]!.replaceAll('{r}', table);
      await _db.customStatement(
        'INSERT INTO sync_outbox (tbl, row_id, op, at) '
        "SELECT '$table', $id, 0, hearthrise_now() FROM $table",
      );
    }
  }

  Future<void> _revoke(String token) async {
    try {
      await _api.signOut(token);
    } on Object {
      // The token is unused and expires on its own.
    }
    await _gateway.googleSignOut();
  }

  /// Forgets the token, empties the outbox and resets the cursor (D18).
  /// Local data stays.
  Future<void> signOut() async {
    final session = _currentSession();
    if (session != null) await _revoke(session.token);
    await endSession();
  }

  /// Removes the account on the server, then ends the session (D17). Throws
  /// [AccountException] and changes nothing when the server cannot.
  Future<void> deleteAccount() async {
    final session = _currentSession();
    if (session == null) return;
    await _api.deleteAccount(session.token);
    await _gateway.googleSignOut();
    await endSession();
  }

  /// The session is over, here or on the server: forget it. Used for
  /// sign-out, deletion and a 401, after which the phone is in no-account
  /// mode with its data intact.
  Future<void> endSession() async {
    await _gateway.clearToken();
    await _db.transaction(() async {
      await _db.delete(_db.syncOutbox).go();
      await _db
          .update(_db.syncState)
          .write(
            const SyncStateCompanion(
              cursor: Value(0),
              accountEmail: Value(null),
              lastError: Value(null),
            ),
          );
    });
    _setSession(null);
  }
}
