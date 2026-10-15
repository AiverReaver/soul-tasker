import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock.dart';
import '../core/haptics.dart';
import '../core/sounds.dart';
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
import 'settings_dao.dart';
import 'signal_dao.dart';
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
