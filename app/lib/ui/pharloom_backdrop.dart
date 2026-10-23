import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// The ground behind every screen: void with a cold violet tint from above,
/// a vignette, and lavender motes drifting up. [drift] 0..1 is the motes'
/// place in their slow loop; hold it still for reduced motion. Atmosphere
/// goes around content, never under text, so it stays faint.
class PharloomBackdrop extends StatelessWidget {
  const PharloomBackdrop({super.key, required this.drift, required this.child});

  final double drift;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      ExcludeSemantics(
        child: CustomPaint(
          painter: _NightPainter(
            drift,
            context.palette,
            // Ink, not black, and lighter on the light biomes, so they stay clean.
            Theme.of(context).brightness == Brightness.dark ? 0.6 : 0.18,
          ),
        ),
      ),
      child,
    ],
  );
}

class _NightPainter extends CustomPainter {
  const _NightPainter(this.drift, this.palette, this.vignette);

  final double drift;
  final HearthPalette palette;
  final double vignette;

  static const _motes = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final box = Offset.zero & size;
    canvas
      ..drawRect(box, Paint()..color = palette.void_)
      ..drawRect(
        box,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(0, -1.15),
            radius: 1.1,
            colors: [
              palette.mote.withValues(alpha: 0.12),
              palette.ground,
              palette.void_,
            ],
            stops: const [0, 0.4, 0.8],
          ).createShader(box),
      )
      ..drawRect(
        box,
        Paint()
          ..shader = RadialGradient(
            radius: 0.95,
            colors: [
              Colors.transparent,
              palette.ink.withValues(alpha: vignette),
            ],
            stops: const [0.55, 1],
          ).createShader(box),
      );

    final random = Random(41); // the same sky every launch
    final glow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    for (var i = 0; i < _motes; i++) {
      final x0 = random.nextDouble(), speed = 0.6 + random.nextDouble() * 0.8;
      final phase = random.nextDouble();
      final rise = (drift * speed + phase) % 1; // 0 at the floor, 1 at the top
      final at = Offset(
        size.width * x0 + sin((rise + phase) * pi * 2) * 14,
        size.height + 10 - rise * (size.height + 20),
      );
      final alpha = sin(rise * pi) * 0.6; // fades in low, out high
      canvas
        ..drawCircle(
          at,
          3,
          glow..color = palette.mote.withValues(alpha: alpha * 0.5),
        )
        ..drawCircle(
          at,
          1.4,
          Paint()..color = palette.mote.withValues(alpha: alpha),
        );
    }
  }

  @override
  bool shouldRepaint(_NightPainter old) =>
      old.drift != drift || old.palette != palette || old.vignette != vignette;
}
