import 'package:material_ui/material_ui.dart';

import 'ink_path.dart';

/// Glyph paths on the design's 24 px grid, as SVG path data.
abstract final class StrokeIcons {
  static const back = 'M15 5 8 12l7 7';
  static const more =
      'M5.2 10.4 7 12.2 5.2 14 3.4 12.2zM12 10.4l1.8 1.8L12 14l-1.8-1.8z'
      'M18.8 10.4l1.8 1.8-1.8 1.8-1.8-1.8z';
  static const check = 'M5 12.5 10 17.5 19 7';
  static const profile = 'M12 4 15 8 12 12 9 8zM5 20 8 15.5h8L19 20';
  static const settings = 'M4 8h16M4 16h16M9 6l2 2-2 2-2-2zM15 14l2 2-2 2-2-2z';
  static const plus = 'M12 5v14M5 12h14';
  static const flame = 'M12 2l5 8-2.6-.6L18 15l-6 7-6-7 3.6-5.6L7 10z';
  static const strike = 'M4 20 16 8M18.5 3 21 5.5 18.5 8 16 5.5z';
}

/// A path drawn as a square-capped, round-joined stroke (1.6 px on the 24 px
/// grid), or filled when [filled]. Scales with [size].
class StrokeIcon extends StatelessWidget {
  const StrokeIcon({
    super.key,
    required this.path,
    required this.color,
    this.size = 22,
    this.strokeWidth = 1.6,
    this.filled = false,
  });

  final String path;
  final Color color;
  final double size;
  final double strokeWidth;
  final bool filled;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _StrokeIconPainter(path, color, strokeWidth, filled),
  );
}

class _StrokeIconPainter extends CustomPainter {
  _StrokeIconPainter(this.d, this.color, this.width, this.filled);

  final String d;
  final Color color;
  final double width;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = width * k
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      inkPath(d)
          .transform((Matrix4.identity()..scaleByDouble(k, k, 1, 1)).storage),
      paint,
    );
  }

  @override
  bool shouldRepaint(_StrokeIconPainter old) =>
      old.d != d ||
      old.color != color ||
      old.width != width ||
      old.filled != filled;
}
