import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import '../core/weathering.dart';

/// The emblem of a relic (Stage 5 plan D5): one abstract shape, with more
/// marks the more attempts it took. Ash and ember only, no red and no rank.
class RelicEmblem extends StatelessWidget {
  const RelicEmblem({super.key, required this.weathering, this.size = 96});

  final Weathering weathering;
  final double size;

  static String labelFor(Weathering w) => switch (w) {
    Weathering.unmarked => 'An unmarked emblem',
    Weathering.worn => 'A worn emblem',
    Weathering.scarred => 'A scarred emblem',
    Weathering.weathered => 'A weathered emblem',
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: labelFor(weathering),
      image: true,
      excludeSemantics: true,
      child: CustomPaint(
        key: ValueKey('emblem-${weathering.name}'),
        size: Size.square(size),
        painter: EmblemPainter(weathering, context.palette),
      ),
    );
  }
}

/// Marks per level: how many nicks cut across the rim.
const _marks = {
  Weathering.unmarked: 0,
  Weathering.worn: 3,
  Weathering.scarred: 6,
  Weathering.weathered: 10,
};

class EmblemPainter extends CustomPainter {
  const EmblemPainter(this.weathering, this.palette);

  final Weathering weathering;
  final HearthPalette palette;

  /// Nicks drawn for this level, exposed for tests.
  int get markCount => _marks[weathering]!;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 2;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide / 28
      ..color = palette.text;
    canvas.drawCircle(c, r, stroke);

    // A diamond inside the ring, with a single ember at its heart.
    final d = r * 0.62;
    final diamond = Path()
      ..moveTo(c.dx, c.dy - d)
      ..lineTo(c.dx + d, c.dy)
      ..lineTo(c.dx, c.dy + d)
      ..lineTo(c.dx - d, c.dy)
      ..close();
    canvas.drawPath(
      diamond,
      stroke..color = palette.text.withValues(alpha: 0.8),
    );
    canvas.drawCircle(c, r * 0.14, Paint()..color = palette.silk);

    // Weathering: dim nicks across the rim and the diamond, evenly spread
    // but skewed so no two levels look like a rotation of each other.
    final nick = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.shortestSide / 40
      ..color = palette.void_;
    for (var i = 0; i < markCount; i++) {
      final a = i * 2 * math.pi / markCount + i * 0.35;
      final inner = r * (0.78 + 0.1 * (i % 3));
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * inner,
        c + Offset(math.cos(a + 0.12), math.sin(a + 0.12)) * (r + 2),
        nick,
      );
    }
  }

  @override
  bool shouldRepaint(EmblemPainter old) =>
      old.weathering != weathering || old.palette != palette;
}
