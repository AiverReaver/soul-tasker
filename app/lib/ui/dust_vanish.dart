import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

const kDustPainterKey = ValueKey('dust-painter');

/// Fades [child] away while glowing white-gold motes rise from it and drift
/// apart. [progress] runs 0 (whole) to 1 (gone). The motes are fixed by
/// [seed], so the same progress always draws the same frame.
class DustVanish extends StatelessWidget {
  const DustVanish({
    super.key,
    required this.progress,
    required this.child,
    this.seed = 7,
    this.motes = 48,
  });

  final double progress;
  final Widget child;
  final int seed;
  final int motes;

  @override
  Widget build(BuildContext context) {
    final t = progress.clamp(0.0, 1.0);
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Opacity(opacity: 1 - Curves.easeIn.transform(t), child: child),
        if (t > 0 && t < 1)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                key: kDustPainterKey,
                painter: _DustPainter(t, seed, motes, context.palette.bone),
              ),
            ),
          ),
      ],
    );
  }
}

class _DustPainter extends CustomPainter {
  _DustPainter(this.t, this.seed, this.motes, this.color);

  final double t;
  final int seed;
  final int motes;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    for (var i = 0; i < motes; i++) {
      final x = rng.nextDouble();
      final y = 0.2 + rng.nextDouble() * 0.6;
      final delay = rng.nextDouble() * 0.4;
      final rise = 20 + rng.nextDouble() * 70;
      final sway = (rng.nextDouble() - 0.5) * 40;
      final radius = 0.8 + rng.nextDouble() * 1.8;
      final local = ((t - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final fade = math.sin(local * math.pi); // in, then out
      final center = Offset(
        x * size.width + sway * local,
        y * size.height - rise * local,
      );
      canvas.drawCircle(
        center,
        radius * 3,
        Paint()
          ..color = color.withValues(alpha: 0.18 * fade)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()..color = color.withValues(alpha: 0.9 * fade),
      );
    }
  }

  @override
  bool shouldRepaint(_DustPainter old) => old.t != t || old.color != color;
}
