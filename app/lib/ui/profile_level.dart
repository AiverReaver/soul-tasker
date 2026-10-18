import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// The Profile's level block: a framed diamond holding the numeral, then
/// "Level N", five bars and how far the next level is. Values in only.
class ProfileLevel extends StatelessWidget {
  const ProfileLevel({
    super.key,
    required this.level,
    required this.toNext,
    required this.bars,
    required this.percentToNext,
  });

  final int level;
  final int toNext;

  /// 0 to 5 lit bars.
  final int bars;

  /// For the spoken label.
  final int percentToNext;

  static const _size = 64.0;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    return Semantics(
      label: 'Level $level, $percentToNext percent to level ${level + 1}',
      excludeSemantics: true,
      child: Row(
        spacing: 16,
        children: [
          SizedBox.square(
            key: const ValueKey('level-diamond'),
            dimension: _size,
            child: CustomPaint(
              painter: _DiamondPainter(
                fill: p.shell,
                edge: p.deep,
                ring: p.silk,
              ),
              child: Center(
                child: Text(
                  '$level',
                  style: text.titleMedium!.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(
                  'Level $level',
                  style: text.titleMedium!.copyWith(
                    fontSize: 30,
                    height: 34 / 30,
                  ),
                ),
                Row(
                  spacing: 3,
                  children: [
                    for (var i = 0; i < 5; i++)
                      KeyedSubtree(
                        key: ValueKey('level-slot-$i'),
                        child: SizedBox(
                          key: ValueKey(
                            i < bars ? 'level-bar-on' : 'level-bar-off',
                          ),
                          width: 10,
                          height: 4,
                          child: ColoredBox(color: i < bars ? p.silk : p.dim),
                        ),
                      ),
                  ],
                ),
                Text(
                  '$toNext ${toNext == 1 ? 'ember' : 'embers'} to the next',
                  style: text.bodyMedium!.copyWith(color: p.ash, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiamondPainter extends CustomPainter {
  _DiamondPainter({required this.fill, required this.edge, required this.ring});

  final Color fill;
  final Color edge;
  final Color ring;

  Path _diamond(Size s, double inset) => Path()
    ..moveTo(s.width / 2, inset)
    ..lineTo(s.width - inset, s.height / 2)
    ..lineTo(s.width / 2, s.height - inset)
    ..lineTo(inset, s.height / 2)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final outer = _diamond(size, 1.5);
    canvas.drawPath(outer, Paint()..color = fill);
    canvas.drawPath(
      outer,
      Paint()
        ..color = edge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawPath(
      _diamond(size, size.width * 7 / 44),
      Paint()
        ..color = ring.withValues(alpha: .6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_DiamondPainter old) =>
      old.fill != fill || old.edge != edge || old.ring != ring;
}
