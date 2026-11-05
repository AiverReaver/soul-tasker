import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'stroke_icon.dart';

/// The foe row's strike button, drawn only: the strike icon in silk, with no
/// surface of its own. While held, a silk fill rises to [progress] behind a
/// bone icon. The gesture stays in `HoldToStrike`.
class HoldButton extends StatelessWidget {
  const HoldButton({
    super.key,
    required this.progress,
    required this.isReady,
    required this.semanticLabel,
  });

  final double progress;
  final bool isReady;
  final String semanticLabel;

  static const size = 48.0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      label: semanticLabel,
      button: true,
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Cut.md),
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SizedBox(
                  key: const ValueKey('hold-fill'),
                  height: progress.clamp(0, 1) * size,
                  child: ColoredBox(
                    color: p.silk.withValues(alpha: isReady ? 1 : .78),
                  ),
                ),
              ),
              StrokeIcon(
                path: StrokeIcons.strike,
                color: progress > 0 ? p.bone : p.silk,
                size: 20,
                strokeWidth: 1.8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
