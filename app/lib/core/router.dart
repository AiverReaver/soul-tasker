import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/bonfire/bonfire_screen.dart';
import '../features/boss/boss_screen.dart';
import '../features/boss_edit/boss_edit_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_flow.dart';
import '../features/onboarding/start_gate.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/relic_screen.dart';
import '../features/ritual/day_resolver.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/hearth_shell.dart';
import '../features/victory/victory_screen.dart';

// Tabs swap in place: no page transition between them.
GoRoute _tab(String path, Widget screen) => GoRoute(
  path: path,
  pageBuilder: (_, state) =>
      NoTransitionPage(key: state.pageKey, child: screen),
);

GoRouter buildRouter([String initialLocation = '/']) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    ShellRoute(
      builder: (_, state, child) =>
          HearthShell(location: state.uri.path, child: child),
      routes: [
        _tab('/', const StartGate(child: DayResolver(child: HomeScreen()))),
        _tab(
          '/today',
          const StartGate(
            child: DayResolver(child: HomeScreen(showToday: true)),
          ),
        ),
        _tab('/bonfire', const BonfireScreen()),
        _tab('/profile', const ProfileScreen()),
      ],
    ),
    GoRoute(path: '/welcome', builder: (_, _) => const OnboardingFlow()),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
    GoRoute(
      path: '/relic/:id',
      builder: (_, state) => RelicScreen(relicId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/boss/new', builder: (_, _) => const BossEditScreen()),
    GoRoute(
      path: '/boss/:id',
      builder: (_, state) => BossScreen(bossId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/victory/:relicId',
      builder: (_, state) =>
          VictoryScreen(relicId: state.pathParameters['relicId']!),
    ),
    GoRoute(
      path: '/boss/:id/edit',
      builder: (_, state) => BossEditScreen(bossId: state.pathParameters['id']),
    ),
  ],
);
