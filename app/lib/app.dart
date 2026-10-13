import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'core/router.dart';
import 'core/theme.dart';

class HearthriseApp extends StatefulWidget {
  const HearthriseApp({super.key, this.initialLocation = '/'});

  /// Tests can start on a given route; the app starts on home.
  final String initialLocation;

  @override
  State<HearthriseApp> createState() => _HearthriseAppState();
}

class _HearthriseAppState extends State<HearthriseApp> {
  late final GoRouter _router = buildRouter(widget.initialLocation);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hearthrise',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: _router,
    );
  }
}
