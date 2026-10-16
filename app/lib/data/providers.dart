import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth_gateway.dart';
import '../core/clock.dart';
import '../core/haptics.dart';
import '../core/sounds.dart';
import '../server_config.dart';
import 'attempt_dao.dart';
import 'boss_dao.dart';
import 'boss_view.dart';
import 'commitment_dao.dart';
import 'database.dart';
import 'day_dao.dart';
import 'health_dao.dart';
import 'plan_pick_dao.dart';
import 'profile_dao.dart';
import 'relic_dao.dart';
import 'ember_dao.dart';
import 'flask_dao.dart';
import 'settings_dao.dart';
import 'signal_dao.dart';
import 'account_api.dart';
import 'account_service.dart';
import '../features/tester_report/tester_report.dart' show kAppVersion;
import 'sync_api.dart';
import 'sync_service.dart';
import 'sync_sql.dart' show kSyncedTables;
import 'visit_dao.dart';

/// Overridden in tests with an in-memory database.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

final bossDaoProvider = Provider(
  (ref) => BossDao(ref.watch(databaseProvider), ref.watch(clockProvider)),
);

final attemptDaoProvider = Provider(
  (ref) => AttemptDao(
    ref.watch(databaseProvider),
    ref.watch(bossDaoProvider),
    ref.watch(clockProvider),
  ),
);

final settingsDaoProvider = Provider(
  (ref) => SettingsDao(ref.watch(databaseProvider), ref.watch(clockProvider)),
);

final flaskDaoProvider = Provider(
  (ref) => FlaskDao(ref.watch(databaseProvider), ref.watch(clockProvider)),
);

final bossListProvider = StreamProvider<List<BossView>>(
  (ref) => ref.watch(bossDaoProvider).watchAll(),
);

final bossDetailProvider = StreamProvider.family<BossView?, String>(
  (ref, id) => ref.watch(bossDaoProvider).watchBoss(id),
);

final settingsProvider = StreamProvider(
  (ref) => ref.watch(settingsDaoProvider).watch(),
);

/// Reads the setting on every haptic rather than watching it, so one object
/// stays valid for the life of the app (D10). On while settings load.
final hapticsProvider = Provider(
  (ref) => Haptics(() => ref.read(settingsProvider).value?.haptics ?? true),
);

final emberDaoProvider = Provider(
  (ref) => EmberDao(ref.watch(databaseProvider), ref.watch(clockProvider)),
);

final emberTallyProvider = StreamProvider(
  (ref) => ref.watch(emberDaoProvider).watchTally(),
);

final dayDaoProvider = Provider(
  (ref) => DayDao(
    ref.watch(databaseProvider),
    ref.watch(clockProvider),
    ref.watch(attemptDaoProvider),
  ),
);

final dayStatusProvider = StreamProvider(
  (ref) => ref.watch(dayDaoProvider).watchToday(),
);

final planPickDaoProvider = Provider(
  (ref) => PlanPickDao(
    ref.watch(databaseProvider),
    ref.watch(bossDaoProvider),
    ref.watch(clockProvider),
  ),
);

final todayPicksProvider = StreamProvider(
  (ref) => ref.watch(planPickDaoProvider).watchToday(),
);

final daySummaryProvider = StreamProvider(
  (ref) => ref.watch(dayDaoProvider).watchSummary(),
);

/// Open tasks to pick from, read once when the bonfire opens.
final commitmentDaoProvider = Provider(
  (ref) => CommitmentDao(ref.watch(databaseProvider), ref.watch(clockProvider)),
);

/// Today's commitments by task id.
final todayCommitmentsProvider = StreamProvider(
  (ref) => ref.watch(commitmentDaoProvider).watchToday(),
);

final healthDaoProvider = Provider(
  (ref) => HealthDao(
    ref.watch(databaseProvider),
    ref.watch(clockProvider),
    ref.watch(attemptDaoProvider),
  ),
);

/// Today's health in half points.
final healthProvider = StreamProvider(
  (ref) => ref.watch(healthDaoProvider).watchHealth(),
);

/// Today's and this week's promises, again whenever today's change.
final accuracyProvider = FutureProvider.autoDispose((ref) async {
  ref.watch(todayCommitmentsProvider);
  ref.watch(healthProvider);
  final health = ref.watch(healthDaoProvider);
  final commits = ref.watch(commitmentDaoProvider);
  final today = await health.today();
  return (today: await commits.record(today), week: await commits.week(today));
});

final pickCandidatesProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(planPickDaoProvider).candidates(),
);

/// Tomorrow's picks, read again whenever today's rest status changes.
final tomorrowPicksProvider = FutureProvider.autoDispose((ref) {
  ref.watch(dayStatusProvider);
  return ref.watch(planPickDaoProvider).tomorrow();
});

final relicDaoProvider = Provider(
  (ref) => RelicDao(ref.watch(databaseProvider), ref.watch(clockProvider)),
);

final relicListProvider = StreamProvider(
  (ref) => ref.watch(relicDaoProvider).watchAll(),
);

final relicProvider = StreamProvider.family<RelicView?, String>(
  (ref, id) => ref.watch(relicDaoProvider).watch(id),
);

final profileProvider = StreamProvider(
  (ref) =>
      ProfileDao(ref.watch(databaseProvider), ref.watch(clockProvider)).watch(),
);

/// Overridden in `main` with the real audio player and in tests with a fake.
final soundPlayerProvider = Provider<SoundPlayer>(
  (ref) => const SilentSoundPlayer(),
);

/// Reads the setting on every cue, like [hapticsProvider]. Off while
/// settings load.
final soundsProvider = Provider(
  (ref) => Sounds(
    ref.watch(soundPlayerProvider),
    () => ref.read(settingsProvider).value?.sound ?? false,
  ),
);

final visitDaoProvider = Provider(
  (ref) => VisitDao(ref.watch(databaseProvider), ref.watch(clockProvider)),
);

final signalDaoProvider = Provider(
  (ref) => SignalDao(ref.watch(databaseProvider), ref.watch(clockProvider)),
);

/// The check-in window due at the bonfire, read once when it opens.
final checkInDueProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(signalDaoProvider).checkInDue(),
);

final authGatewayProvider = Provider<AuthGateway>((ref) => DeviceAuthGateway());

/// The account endpoints. `main` sets the release server; a build without
/// one refuses sign-in quietly.
final accountApiProvider = Provider<AccountApi>((ref) => const _NoServer());

class _NoServer implements AccountApi {
  const _NoServer();

  @override
  Future<AccountSession> signIn(String idToken) =>
      throw const AccountException('no server in this build');

  @override
  Future<void> signOut(String token) =>
      throw const AccountException('no server in this build');

  @override
  Future<void> deleteAccount(String token) =>
      throw const AccountException('no server in this build');
}

/// The session loaded from secure storage before the app starts.
final initialSessionProvider = Provider<AccountSession?>((ref) => null);

/// Who this phone is signed in as, or null (Stage 7 plan D1).
final sessionProvider = NotifierProvider<SessionNotifier, AccountSession?>(
  SessionNotifier.new,
);

class SessionNotifier extends Notifier<AccountSession?> {
  @override
  AccountSession? build() => ref.watch(initialSessionProvider);

  // A setter named for what it does; Notifier state is protected.
  void set(AccountSession? session) => state = session;
}

/// Builds the server client for a session token. Tests return a fake.
final syncApiFactoryProvider = Provider<SyncApi Function(String token)>(
  (ref) =>
      (token) => throw UnimplementedError('no server client for $token'),
);

/// The server, or null while signed out: with no account the app makes no
/// request (Stage 7 plan D1).
final syncApiProvider = Provider<SyncApi?>((ref) {
  final session = ref.watch(sessionProvider);
  if (session == null) return null;
  return ref.watch(syncApiFactoryProvider)(session.token);
});

/// Whether this build knows a server; a test overrides it.
final hasServerProvider = Provider<bool>((ref) => hasServer);

final accountServiceProvider = Provider<AccountService>(
  (ref) => AccountService(
    db: ref.watch(databaseProvider),
    gateway: ref.watch(authGatewayProvider),
    api: ref.watch(accountApiProvider),
    // Through the scheduler, so a failed first sync backs off and a later
    // write is noticed.
    runSync: () async =>
        await ref.read(syncSchedulerProvider)?.start() ?? SyncOutcome.failed,
    currentSession: () => ref.read(sessionProvider),
    setSession: ref.read(sessionProvider.notifier).set,
    hasServer: () => ref.read(hasServerProvider),
  ),
);

final syncServiceProvider = Provider<SyncService?>((ref) {
  final api = ref.watch(syncApiProvider);
  if (api == null) return null;
  return SyncService(
    db: ref.watch(databaseProvider),
    api: api,
    clock: ref.watch(clockProvider),
    appVersion: kAppVersion,
  );
});

/// Decides when to sync (plan D15). Every write to the outbox asks for a
/// run 5 s later.
final Provider<SyncScheduler?> syncSchedulerProvider = Provider<SyncScheduler?>(
  (ref) {
    final service = ref.watch(syncServiceProvider);
    if (service == null) return null;
    final scheduler = SyncScheduler(
      run: () async {
        final outcome = await service.sync();
        // A 401 means the account or session is gone: forget it (D18).
        if (outcome == SyncOutcome.signedOut) {
          await ref.read(accountServiceProvider).endSession();
        }
        return outcome;
      },
    );
    final db = ref.watch(databaseProvider);
    // The outbox is filled by triggers, which drift does not report, so
    // listen for writes to the synced tables themselves.
    final writes = db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            for (final t in db.allTables)
              if (kSyncedTables.containsKey(t.actualTableName)) t,
          ]),
        )
        .listen((_) => scheduler.localWrite());
    ref.onDispose(() {
      writes.cancel();
      scheduler.dispose();
    });
    return scheduler;
  },
);
