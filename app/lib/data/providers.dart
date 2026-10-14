import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock.dart';
import '../core/haptics.dart';
import 'attempt_dao.dart';
import 'boss_dao.dart';
import 'boss_view.dart';
import 'database.dart';
import 'ember_dao.dart';
import 'settings_dao.dart';

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
  (ref) => SettingsDao(ref.watch(databaseProvider)),
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
