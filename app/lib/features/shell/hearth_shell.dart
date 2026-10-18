import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/enums.dart';
import '../../data/providers.dart';
import '../../ui/glass_tab_bar.dart';

/// The four tab routes, in bar order.
const kTabPaths = ['/', '/today', '/bonfire', '/profile'];

/// Keeps the floating glass bar on Home, Today, Bonfire and Profile. The
/// selected tab follows the location, so a deep link lights the right one.
/// "Today" opens the pinned boss's fight when there is one (Q1).
class HearthShell extends ConsumerWidget {
  const HearthShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  void _go(BuildContext context, WidgetRef ref, int i) {
    if (kTabPaths[i] == '/today') {
      final pinned = ref
          .read(bossListProvider)
          .value
          ?.where((b) => b.boss.isPinned && b.boss.status == BossStatus.active)
          .firstOrNull;
      if (pinned != null) return context.go('/boss/${pinned.boss.id}');
    }
    context.go(kTabPaths[i]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    extendBody: true,
    body: child,
    bottomNavigationBar: GlassTabBar(
      selected: kTabPaths.indexOf(location).clamp(0, kTabPaths.length - 1),
      onTap: (i) => _go(context, ref, i),
    ),
  );
}
