import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../core/glass_tilt.dart';
import '../core/palette.dart';

/// The outline a [GlassSurface] is cut to.
class GlassShape {
  const GlassShape._(this.border);

  const GlassShape.circle() : this._(const CircleBorder());

  const GlassShape.stadium() : this._(const StadiumBorder());

  GlassShape.rounded(double radius)
    : this._(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      );

  final ShapeBorder border;
}

/// Glass chrome: back and header circles, pills, the switch, the tab bar,
/// sheets and alerts. Layers, bottom to top: shadow, clip, backdrop blur,
/// fill, [child], then [GlassPainter] for the key line, ring, sheen, rim and
/// glint. The light follows [tilt], or the ambient [GlassTilt] when null.
/// High contrast swaps blur and sheen for a flat shell fill.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    required this.shape,
    this.tilt,
    this.isPressed = false,
    this.isTinted = false,
    this.blur = 16,
    this.glintSize,
    this.edge,
    this.edgeWidth = 2,
  });

  final Widget child;
  final GlassShape shape;
  final ValueListenable<Offset>? tilt;
  final bool isPressed;
  final bool isTinted;

  /// Backdrop blur sigma. 0 skips the filter, for glass over a known fill.
  final double blur;

  /// The glint's size; defaults to the shorter side, at most 88.
  final double? glintSize;

  /// The key line's colour; defaults to the palette's `glassKey`.
  final Color? edge;

  /// The key line's width in px.
  final double edgeWidth;

  static const pressDuration = Duration(milliseconds: 350);

  /// Saturation 1.7 over the blurred backdrop (the CSS `saturate()` matrix).
  @visibleForTesting
  static const saturateValues = <double>[
    1.5511, -0.5005, -0.0504, 0, 0, //
    -0.1491, 1.1998, -0.0504, 0, 0, //
    -0.1491, -0.5005, 1.6496, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  static const _saturate = ColorFilter.matrix(saturateValues);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final flat = MediaQuery.highContrastOf(context);
    final light = tilt ?? GlassTilt.of(context);
    final fill = flat
        ? p.shell
        : isTinted
        ? p.silk.withValues(alpha: .55)
        : isPressed
        ? p.glassFillHi
        : p.glassFill;
    final filled = ColoredBox(key: const ValueKey('glass-fill'), color: fill);
    final blurred = !flat && blur > 0;
    final backdrop = blurred
        ? BackdropFilter(
            filter: ui.ImageFilter.compose(
              outer: _saturate,
              inner: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            ),
            child: filled,
          )
        : filled;
    final border = shape.border;
    return AnimatedScale(
      scale: isPressed ? 1.04 : 1,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : pressDuration,
      curve: Curves.easeOutBack,
      child: CustomPaint(
        painter: flat ? null : GlassShadowPainter(border: border, tilt: light),
        child: ClipPath(
          clipper: ShapeBorderClipper(shape: border),
          child: Stack(
            children: [
              Positioned.fill(child: backdrop),
              child,
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: GlassPainter(
                      border: border,
                      keyColor: edge ?? p.glassKey,
                      edgeWidth: edgeWidth,
                      lightColor: p.glassLight,
                      tilt: light,
                      glintSize: glintSize,
                      isFlat: flat,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Path _outline(ShapeBorder border, Size size) =>
    border.getOuterPath(Offset.zero & size);

/// The soft shadow, offset away from the light, and cut out under the glass
/// so it never shows through.
class GlassShadowPainter extends CustomPainter {
  GlassShadowPainter({required this.border, required this.tilt})
    : super(repaint: tilt);

  final ShapeBorder border;
  final ValueListenable<Offset> tilt;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _outline(border, size);
    final reach = Offset.zero & size;
    canvas
      ..save()
      ..clipPath(
        Path.combine(
          PathOperation.difference,
          Path()..addRect(reach.inflate(80)),
          path,
        ),
      )
      ..drawPath(
        path.shift(Offset(-tilt.value.dx * 8, 8)),
        Paint()
          ..color = Colors.black.withValues(alpha: .35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      )
      ..restore();
  }

  /// Decoration only: it must not catch taps the clip would miss.
  @override
  bool? hitTest(Offset position) => false;

  @override
  bool shouldRepaint(GlassShadowPainter old) => old.border != border;
}

/// The glass finish drawn over the child: key line, bottom shade, inner
/// ring, sheen, rim light and the glint. All strokes sit inside the shape.
/// Only [tilt] moves it, and it repaints this painter alone.
class GlassPainter extends CustomPainter {
  GlassPainter({
    required this.border,
    required this.keyColor,
    required this.lightColor,
    required this.tilt,
    this.glintSize,
    this.isFlat = false,
    this.edgeWidth = 2,
  }) : super(repaint: tilt);

  final ShapeBorder border;
  final Color keyColor;
  final Color lightColor;
  final ValueListenable<Offset> tilt;
  final double? glintSize;
  final double edgeWidth;

  /// High contrast: the key line only.
  final bool isFlat;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _outline(border, size);
    final t = tilt.value;
    canvas
      ..save()
      ..clipPath(path);
    // Key line: a 4 px stroke whose outer half the clip cuts away.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = edgeWidth * 2
        ..color = keyColor,
    );
    if (!isFlat) {
      _paintFinish(canvas, size, path, t);
      _paintGlint(canvas, size, t);
    }
    canvas.restore();
  }

  void _paintFinish(Canvas canvas, Size size, Path path, Offset t) {
    final box = Offset.zero & size;
    // Bottom shade: the shape minus itself lifted 5 px.
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        path,
        path.shift(const Offset(0, -5)),
      ),
      Paint()..color = keyColor.withValues(alpha: .28),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = glassRing,
    );
    // Sheen: the top third of a diagonal, leaning with tilt.
    final lean = (152 + t.dx * 14) * math.pi / 180;
    final dir = Offset(math.sin(lean), -math.cos(lean));
    final reach = (size.width * dir.dx).abs() + (size.height * dir.dy).abs();
    final from = box.center - dir * (reach / 2);
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          from,
          from + dir * reach,
          [
            glassSheen,
            glassSheen,
            glassSheen.withValues(alpha: 0),
            Colors.transparent,
          ],
          [0, .33, .33, 1],
        ),
    );
    // Rim: a conic ring, brightest at the upper left (CSS angles start up).
    final start = (230 + t.dx * 40 - 90) * math.pi / 180;
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..shader = SweepGradient(
          transform: GradientRotation(start),
          colors: [
            lightColor,
            lightColor,
            glassRim.withValues(alpha: 0),
            glassRim.withValues(alpha: 0),
            glassRim,
            glassRim,
            glassRim.withValues(alpha: 0),
            glassRim.withValues(alpha: 0),
          ],
          stops: const [0, .18, .18, .5, .5, .62, .62, 1],
        ).createShader(box),
    );
  }

  /// A small arc and dot fixed at the top left; tilt rotates it up to 9°.
  void _paintGlint(Canvas canvas, Size size, Offset t) {
    final side = glintSize ?? math.min(math.min(size.width, size.height), 88.0);
    final unit = side / 100;
    final ink = 3 + side * .04;
    canvas
      ..save()
      ..translate(side / 2, side / 2)
      ..rotate(t.dx * 9 * math.pi / 180)
      ..translate(-side / 2, -side / 2)
      ..scale(unit);
    final arc = Path()
      ..moveTo(14.3, 37)
      ..arcToPoint(const Offset(37, 14.3), radius: const Radius.circular(38));
    final dot = const Offset(53.3, 12.1);
    final k = 1 / unit;
    canvas
      ..drawPath(
        arc,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = ink * k
          ..color = keyColor,
      )
      ..drawPath(
        arc,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = ink * .6 * k
          ..color = glassGlint,
      )
      ..drawCircle(dot, ink * .65 * k, Paint()..color = keyColor)
      ..drawCircle(dot, ink * .45 * k, Paint()..color = glassGlint)
      ..restore();
  }

  @override
  bool shouldRepaint(GlassPainter old) =>
      old.border != border ||
      old.keyColor != keyColor ||
      old.lightColor != lightColor ||
      old.glintSize != glintSize ||
      old.edgeWidth != edgeWidth ||
      old.isFlat != isFlat;
}
