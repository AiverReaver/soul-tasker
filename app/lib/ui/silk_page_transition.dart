import 'package:material_ui/material_ui.dart';

/// Pages cross-fade with a slight rise over the shared backdrop. The old
/// page fades out as the new one fades in, so transparent pages never show
/// through each other once the move is done.
class SilkPageTransitions extends PageTransitionsBuilder {
  const SilkPageTransitions();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
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
  }
}
