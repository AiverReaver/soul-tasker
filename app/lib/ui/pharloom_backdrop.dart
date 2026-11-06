import 'dart:math';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

typedef GroundGlow = ({Offset at, double rx, double ry, Color color});

/// The ground's lights, as fractions of the screen: silk from two corners and
/// a cold mote glow between them. Faint on the light biomes, so they stay clean.
List<GroundGlow> groundGlows(HearthPalette p, {required bool isDark}) {
  final k = isDark ? 1.0 : .4;
  return [
    (
      at: const Offset(.12, 0),
      rx: .9,
      ry: .4,
      color: p.silk.withValues(alpha: .34 * k),
    ),
    (
      at: const Offset(.95, .62),
      rx: .8,
      ry: .36,
      color: p.mote.withValues(alpha: .22 * k),
    ),
    (
      at: const Offset(.2, 1),
      rx: .7,
      ry: .3,
      color: p.silk.withValues(alpha: .28 * k),
    ),
  ];
}

/// The ground behind every screen: void lit by [groundGlows], with lavender
/// motes drifting up. [drift] 0..1 is the motes'
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
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      ),
      // Cards cast blurred shadows: the motes' 30 Hz must not repaint them.
      RepaintBoundary(child: child),
    ],
  );
}

class _NightPainter extends CustomPainter {
  const _NightPainter(this.drift, this.palette, {required this.isDark});

  final double drift;
  final HearthPalette palette;
  final bool isDark;

  static const _motes = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final box = Offset.zero & size;
    canvas
      ..drawRect(box, Paint()..color = palette.void_)
      ..save()
      ..clipRect(box);
    for (final g in groundGlows(palette, isDark: isDark)) {
      final rx = g.rx * size.width, ry = g.ry * size.height;
      // A unit circle scaled to the ellipse: gradients only come round.
      canvas
        ..save()
        ..translate(g.at.dx * size.width, g.at.dy * size.height)
        ..scale(rx, ry)
        ..drawCircle(
          Offset.zero,
          1,
          Paint()
            ..shader = ui.Gradient.radial(
              Offset.zero,
              1,
              [g.color, g.color.withValues(alpha: 0)],
              const [0, .7],
            ),
        )
        ..restore();
    }
    canvas.restore();

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
      old.drift != drift || old.palette != palette || old.isDark != isDark;
}
