import 'package:material_ui/material_ui.dart';

/// The four home-bar glyphs, drawn on the design's 24 px grid with a square
/// 1.6 px stroke. Index matches `HearthNavBar.labels`.
class NavIcon extends StatelessWidget {
  const NavIcon({
    super.key,
    required this.index,
    required this.color,
    this.size = 22,
  });

  final int index;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _NavIconPainter(index, color),
  );
}

typedef _Poly = (List<Offset>, {bool closed});

Offset _o(double x, double y) => Offset(x, y);

// Bosses: a mask. Today: a blade. Bonfire: flame over crossed logs.
// Relics: a cut gem.
final List<List<_Poly>> _glyphs = [
  [
    (
      [_o(5, 4), _o(12, 6), _o(19, 4), _o(18, 13), _o(12, 21), _o(6, 13)],
      closed: true,
    ),
    ([_o(9, 11), _o(11, 12)], closed: false),
    ([_o(15, 11), _o(13, 12)], closed: false),
  ],
  [
    ([_o(4, 20), _o(16, 8)], closed: false),
    ([_o(18.5, 3), _o(21, 5.5), _o(18.5, 8), _o(16, 5.5)], closed: true),
    ([_o(4, 8), _o(10, 8), _o(10, 14)], closed: false),
  ],
  [
    (
      [
        _o(12, 3),
        _o(16, 9),
        _o(14, 8.6),
        _o(16.5, 13),
        _o(12, 17),
        _o(7.5, 13),
        _o(10, 8.6),
        _o(8, 9),
      ],
      closed: true,
    ),
    ([_o(4, 21), _o(20, 21)], closed: false),
    ([_o(7, 18.5), _o(17, 21)], closed: false),
    ([_o(17, 18.5), _o(7, 21)], closed: false),
  ],
  [
    ([_o(12, 3), _o(19, 10), _o(12, 21), _o(5, 10)], closed: true),
    ([_o(5, 10), _o(19, 10)], closed: false),
    ([_o(12, 3), _o(12, 21)], closed: false),
  ],
];

class _NavIconPainter extends CustomPainter {
  const _NavIconPainter(this.index, this.color);

  final int index;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 * s
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.round;
    for (final (points, :closed) in _glyphs[index]) {
      final path = Path()..addPolygon([for (final p in points) p * s], closed);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_NavIconPainter old) =>
      old.index != index || old.color != color;
}
