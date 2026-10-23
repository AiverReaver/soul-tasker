import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/auth_gateway.dart';
import 'data/account_api.dart';
import 'data/boss_dao.dart';
import 'data/database.dart';
import 'data/providers.dart';
import 'server_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase.open();
  await BossDao(db, DateTime.now).ensureDayBoss();
  final gateway = DeviceAuthGateway();
  // A phone signed in last time stays signed in; one that never signed in
  // has no token and makes no request (Stage 7 plan D1).
  final token = await gateway.readToken();
  final state = await db.select(db.syncState).getSingle();
  final session = token == null || state.accountEmail == null
      ? null
      : AccountSession(
          token: token,
          userId: state.lastAccountId ?? '',
          email: state.accountEmail!,
        );
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        authGatewayProvider.overrideWithValue(gateway),
        initialSessionProvider.overrideWithValue(session),
        if (hasServer) ...[
          accountApiProvider.overrideWithValue(buildAccountApi()),
          syncApiFactoryProvider.overrideWithValue(buildSyncApi),
        ],
      ],
      child: const HearthriseApp(),
    ),
  );
}
