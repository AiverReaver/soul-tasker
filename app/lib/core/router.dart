import 'package:go_router/go_router.dart';

import '../features/bonfire/bonfire_screen.dart';
import '../features/boss/boss_screen.dart';
import '../features/boss_edit/boss_edit_screen.dart';
import '../features/home/home_screen.dart';
import '../features/ritual/day_resolver.dart';
import '../features/settings/settings_screen.dart';

GoRouter buildRouter([String initialLocation = '/']) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(
      path: '/',
      builder: (_, _) => const DayResolver(child: HomeScreen()),
    ),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
    GoRoute(path: '/bonfire', builder: (_, _) => const BonfireScreen()),
    GoRoute(path: '/boss/new', builder: (_, _) => const BossEditScreen()),
    GoRoute(
      path: '/boss/:id',
      builder: (_, state) => BossScreen(bossId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/boss/:id/edit',
      builder: (_, state) => BossEditScreen(bossId: state.pathParameters['id']),
    ),
  ],
);
