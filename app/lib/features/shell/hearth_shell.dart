import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../ui/hearth_nav_bar.dart';

/// The four tab routes, in bar order.
const kTabPaths = ['/', '/today', '/bonfire', '/profile'];

/// Keeps the bottom bar on Bosses, Today, Bonfire and Relics. The selected
/// tab follows the location, so a deep link lights the right one.
class HearthShell extends StatelessWidget {
  const HearthShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: child,
    bottomNavigationBar: HearthNavBar(
      selected: kTabPaths.indexOf(location).clamp(0, kTabPaths.length - 1),
      onTap: (i) => context.go(kTabPaths[i]),
    ),
  );
}
