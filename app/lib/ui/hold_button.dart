import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'glass_surface.dart';
import 'stroke_icon.dart';

/// The foe row's strike button, drawn only: a 48 px glass ring (no blur: it
/// sits on a solid row) with a silk fill rising to [progress] and the strike
/// icon in bone. [isReady] turns the edge bone. The gesture stays in
/// `HoldToStrike`.
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
  static const _inner = 46.0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      label: semanticLabel,
      button: true,
      excludeSemantics: true,
      child: GlassSurface(
        shape: const GlassShape.circle(),
        blur: 0,
        edge: isReady ? p.bone : p.ink,
        edgeWidth: 1.5,
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 1,
                child: SizedBox(
                  key: const ValueKey('hold-fill'),
                  height: progress.clamp(0, 1) * _inner,
                  child: ColoredBox(color: p.silk.withValues(alpha: .78)),
                ),
              ),
              StrokeIcon(
                path: StrokeIcons.strike,
                color: p.bone,
                size: 18,
                strokeWidth: 1.8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
