import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'ink_path.dart';

/// An original hand-drawn boss: porcelain mask with horns, a ragged cloak
/// and a quill lance, outlined in ink. Decoration only; the boss's name is
/// the text a screen reader hears.
///
/// [boilFrame] picks one of three hand-redrawn versions of the same lines;
/// stepping it every ~140 ms makes the ink boil. [hit] 0..1 burns the whole
/// figure to the biome's mask colour, the flash of a landed strike.
class BossArt extends StatelessWidget {
  const BossArt({
    super.key,
    required this.boilFrame,
    this.hit = 0,
    this.width = 200,
  });

  final int boilFrame;
  final double hit;
  final double width;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size(width, width * 0.9),
      painter: BossArtPainter(
        boilFrame: boilFrame % 3,
        hit: hit,
        palette: context.palette,
      ),
    ),
  );
}

// (path, fill, stroke, stroke width), drawn back to front in a 200 x 180 box.
typedef _Stroke = (String, Color?, Color?, double);

List<_Stroke> _drawing(HearthPalette c) => [
  ('M150 176 174 26', null, c.ink, 6), // lance, inked edge
  ('M150 176 174 26', null, c.shard, 2.6),
  ('M174 28c12-12 18-22 12-28-8 8-16 14-18 30z', c.deep, c.ink, 2),
  (
    'M100 40c-30 10-42 50-48 90-4 20-12 35-18 42l16-6 8 8 12-10 12 12 12-10 '
        '12 10 12-11 12 10 12-10 8 8 16-1c-6-7-14-22-18-42-6-40-18-80-48-90z',
    c.raised,
    c.ink,
    2.6,
  ),
  ('M76 92c-6 26-10 52-18 72M124 92c6 26 10 52 18 72', null, c.mote, 1.4),
  (
    'M82 120c4 20 2 36-4 48M100 100c1 30 0 50 0 70M118 120c-4 20-2 36 4 48',
    null,
    c.ink,
    1.6,
  ),
  ('M136 112c8-4 14-10 20-16l6 4', null, c.ink, 2.4),
  (
    'M84 34C76 20 66 12 54 10c10 8 16 18 20 32z'
        'M116 34c8-14 18-22 30-24-10 8-16 18-20 32z',
    c.bone,
    c.ink,
    2.2,
  ),
  (
    'M100 26c-16 0-24 12-22 28 2 14 12 22 22 26 10-4 20-12 22-26 2-16-6-28-22-28z',
    c.bone,
    c.ink,
    2.6,
  ),
  (
    'M90 46c-4 6-3 16 2 20 3-6 3-14-2-20zM110 46c4 6 3 16-2 20-3-6-3-14 2-20z',
    c.ink,
    null,
    0,
  ),
];

// Parsed once per boil frame: three hands drawing the same figure.
final _frames = List.generate(
  3,
  (f) => [
    for (final s in _drawing(Biome.pharloom.palette))
      inkPath(s.$1, jitter: 1.4, seed: 7 + f * 13),
  ],
);

class BossArtPainter extends CustomPainter {
  const BossArtPainter({
    required this.boilFrame,
    required this.hit,
    required this.palette,
  });

  final int boilFrame;
  final double hit;
  final HearthPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 200, size.height / 180);
    final paths = _frames[boilFrame % 3];
    // A landed hit burns everything to one flat colour, ink included. Mask
    // is white on dark biomes and shell on light ones, so it shows in both.
    Color burn(Color c, {double alpha = 1}) =>
        Color.lerp(c, palette.mask, hit)!.withValues(alpha: alpha);
    for (final (i, (_, fill, stroke, width)) in _drawing(palette).indexed) {
      if (fill != null) {
        canvas.drawPath(paths[i], Paint()..color = burn(fill));
      }
      if (stroke != null) {
        canvas.drawPath(
          paths[i],
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = width
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..color = burn(stroke, alpha: stroke == palette.mote ? 0.3 : 1),
        );
      }
    }
  }

  @override
  bool shouldRepaint(BossArtPainter old) =>
      old.boilFrame != boilFrame || old.hit != hit || old.palette != palette;
}
