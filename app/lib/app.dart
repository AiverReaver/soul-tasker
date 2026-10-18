import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'data/providers.dart';
import 'features/shell/atmosphere.dart';
import 'features/shell/tilt_controller.dart';

class HearthriseApp extends ConsumerStatefulWidget {
  const HearthriseApp({
    super.key,
    this.initialLocation = '/',
    this.isAmbient = true,
  });

  /// Tests can start on a given route; the app starts on home.
  final String initialLocation;

  /// False holds the backdrop and ink still (tests), so frames settle.
  final bool isAmbient;

  @override
  ConsumerState<HearthriseApp> createState() => _HearthriseAppState();
}

class _HearthriseAppState extends ConsumerState<HearthriseApp> {
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
      theme: buildTheme(ref.watch(biomeProvider) ?? Biome.pharloom),
      themeAnimationDuration: Motion.fade,
      routerConfig: _router,
      builder: (context, child) => Atmosphere(
        isStill: !widget.isAmbient,
        tiltSource: widget.isAmbient ? const SensorsTiltSource() : null,
        motionEffects: ref.watch(motionEffectsProvider),
        child: child!,
      ),
    );
  }
}
