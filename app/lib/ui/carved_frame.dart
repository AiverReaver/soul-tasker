import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// A square, carved frame: wine outer edge, an inner hairline and porcelain
/// corner brackets. [isLit] adds a low crimson halo (the pinned boss, an
/// unrested bonfire). No rounded corners: corners are cut by brackets.
class CarvedFrame extends StatelessWidget {
  const CarvedFrame({
    super.key,
    required this.child,
    this.isLit = false,
    this.padding = const EdgeInsets.all(Space.md + Space.xs),
  });

  final Widget child;
  final bool isLit;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: kSurface,
      border: Border.all(color: kWine),
      boxShadow: isLit
          ? [
              BoxShadow(
                color: kEmber.withValues(alpha: 0.32),
                blurRadius: 48,
                spreadRadius: -18,
                offset: const Offset(0, 18),
              ),
            ]
          : null,
    ),
    child: CustomPaint(
      foregroundPainter: const CarvedEdgePainter(),
      child: Padding(padding: padding, child: child),
    ),
  );
}

/// The inner hairline and corner brackets, painted over a frame's edge and
/// never under text. Shared by every carved surface.
class CarvedEdgePainter extends CustomPainter {
  const CarvedEdgePainter();

  static const _inset = 5.0;
  static const _bracket = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(
        _inset,
        _inset,
        size.width - 2 * _inset,
        size.height - 2 * _inset,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = kAshDim.withValues(alpha: 0.4),
    );
    final bracket = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = kDust;
    final w = size.width, h = size.height, b = _bracket;
    for (final (corner, dx, dy) in [
      (Offset.zero, 1.0, 1.0),
      (Offset(w, 0), -1.0, 1.0),
      (Offset(0, h), 1.0, -1.0),
      (Offset(w, h), -1.0, -1.0),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(corner.dx + dx * b, corner.dy)
          ..lineTo(corner.dx, corner.dy)
          ..lineTo(corner.dx, corner.dy + dy * b),
        bracket,
      );
    }
  }

  @override
  bool shouldRepaint(CarvedEdgePainter old) => false;
}
