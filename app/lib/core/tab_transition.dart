import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// A tab page: the old tab fades out as the new one fades in with a slight
/// rise, so switching tabs never snaps.
CustomTransitionPage<void> tabPage(LocalKey key, Widget child) =>
    CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final enter = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return FadeTransition(
          opacity: ReverseAnimation(secondaryAnimation),
          child: FadeTransition(
            opacity: enter,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(enter),
              child: child,
            ),
          ),
        );
      },
    );
