import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'ink_path.dart';

/// The beats of a landed strike, drawn like a cel: few frames, held long.
enum SlashBeat { arcRising, arcFull, hitStop, shatter }

/// Which beat a strike is on at [progress] 0..1 of its run.
SlashBeat slashBeat(double progress) => switch (progress) {
  < 0.12 => SlashBeat.arcRising,
  < 0.25 => SlashBeat.arcFull,
  < 0.38 => SlashBeat.hitStop,
  _ => SlashBeat.shatter,
};

const _shake = [
  Offset(-7, 3),
  Offset(6, -4),
  Offset(-5, -2),
  Offset(4, 3),
  Offset(-3, 1),
  Offset(2, -2),
  Offset(-1, 1),
];

/// Where the struck row is thrown during the shatter: on ones, decaying,
/// still again by 70% of the run. The hit-stop before it holds still.
Offset strikeShake(double progress) {
  if (slashBeat(progress) != SlashBeat.shatter || progress >= 0.7) {
    return Offset.zero;
  }
  final step = ((progress - 0.38) / 0.32 * _shake.length).floor();
  return _shake[step.clamp(0, _shake.length - 1)];
}

/// The beats of a strike on the clock since the hold completed (D8): the
/// row flashes for 110 ms, shatters to 500 ms, settles to 1300 ms, then rests.
enum StrikeBeat { idle, hit, shatter, settle }

const _shatterStart = Duration(milliseconds: 110);
const _settleStart = Duration(milliseconds: 500);
const _strikeEnd = Duration(milliseconds: 1300);

/// Which beat a strike is on [t] after its hold completed.
StrikeBeat strikeBeatAt(Duration t) {
  if (t.isNegative || t >= _strikeEnd) return StrikeBeat.idle;
  if (t < _shatterStart) return StrikeBeat.hit;
  if (t < _settleStart) return StrikeBeat.shatter;
  return StrikeBeat.settle;
}

const _rowShake = [
  Offset(-5, 2),
  Offset(4, -2),
  Offset(-3, -1),
  Offset(2, 1),
  Offset(-1, 0),
];
const _rowShakeStep = Duration(milliseconds: 56);

/// Where the struck row sits [t] after its hold completed: five held steps
/// across the 280 ms after the shatter starts, still before and after.
Offset rowShakeAt(Duration t) {
  final s = t - _shatterStart;
  if (s.isNegative || s >= _rowShakeStep * _rowShake.length) return Offset.zero;
  return _rowShake[s.inMilliseconds ~/ _rowShakeStep.inMilliseconds];
}

/// How many flecks and silk threads a strike throws.
int slashFlecks(bool isBossTier) => isBossTier ? 14 : 8;

// Drawn in a 370 x 80 box stretched over the row.
final _arcRising = inkPath('M30 66c100-30 200-46 310-54-100 12-200 30-306 58z');
final _arcFull = inkPath('M8 72c110-42 230-62 356-66-110 10-232 34-350 70z');
final _thread = inkPath('M30 66c100-34 200-50 300-56');
final _arcBroken = inkPath(
  'M20 70c40-16 80-28 120-36-36 10-76 24-116 40z'
  'M160 30c50-12 100-20 150-24-48 6-98 14-146 28z'
  'M322 8c10-1 22-2 34-2-10 2-22 3-32 5z',
);
// Impact star, centred on the origin.
final _star = inkPath(
  'M0-28l6 18 18-6-12 14 18 8-20 2 4 20-14-14-10 18-2-20-18 6 12-14-16-12 20 2z',
);

/// A silk slash over the row that was just struck: a white crescent cut in
/// two drawn frames, an inked impact star in the hit-stop, then flecks and
/// crimson threads thrown out as the cut breaks apart. Transient, so it
/// does not compete with the one resting accent (DESIGN.md).
class StrikeSweepView extends StatelessWidget {
  const StrikeSweepView({
    super.key,
    required this.progress,
    required this.isBossTier,
  });

  /// 0 as the cut begins, 1 when the last fleck has faded.
  final double progress;
  final bool isBossTier;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.infinite,
    painter: _SlashPainter(
      progress: progress,
      isBossTier: isBossTier,
      palette: context.palette,
    ),
  );
}

class _SlashPainter extends CustomPainter {
  const _SlashPainter({
    required this.progress,
    required this.isBossTier,
    required this.palette,
  });

  final double progress;
  final bool isBossTier;
  final HearthPalette palette;

  Paint _ink([double alpha = 1]) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.2
    ..strokeJoin = StrokeJoin.round
    ..color = palette.ink.withValues(alpha: alpha);

  // Into the 370 x 80 drawing box: scaled evenly by width so the crescent
  // keeps its shape, centred on the row and free to overhang it.
  static void _toRow(Canvas canvas, Size size) {
    final s = size.width / 370;
    canvas
      ..translate(0, size.height / 2 - 40 * s)
      ..scale(s);
  }

  void _cut(Canvas canvas, Size size, Path arc, {double alpha = 1}) {
    canvas.save();
    _toRow(canvas, size);
    canvas
      ..drawPath(arc, Paint()..color = palette.bone.withValues(alpha: alpha))
      ..drawPath(arc, _ink(alpha))
      ..restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width * 0.62, size.height / 2);
    switch (slashBeat(progress)) {
      case SlashBeat.arcRising:
        _cut(canvas, size, _arcRising);
      case SlashBeat.arcFull:
        _cut(canvas, size, _arcFull);
        canvas.save();
        _toRow(canvas, size);
        canvas
          ..drawPath(
            _thread,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..strokeCap = StrokeCap.round
              ..color = palette.silk,
          )
          ..restore();
      case SlashBeat.hitStop:
        // Everything holds; the row burns white under the impact star.
        canvas.drawRect(
          Offset.zero & size,
          Paint()..color = palette.bone.withValues(alpha: 0.55),
        );
        _cut(canvas, size, _arcBroken);
        canvas
          ..save()
          ..translate(centre.dx, centre.dy)
          ..scale(isBossTier ? 1.1 : 0.8)
          ..drawPath(_star, Paint()..color = palette.bone)
          ..drawPath(_star, _ink())
          ..restore();
      case SlashBeat.shatter:
        final u = (progress - 0.38) / 0.62; // 0..1 through the shatter
        final fade = (1 - (u - 0.6) / 0.4).clamp(0.0, 1.0);
        // The broken cut is gone in three held steps.
        final stepped = (3 - (u * 12).floor()).clamp(0, 3) / 3;
        if (stepped > 0) _cut(canvas, size, _arcBroken, alpha: stepped);
        _flecks(canvas, centre, Curves.easeOutCubic.transform(u), fade);
    }
  }

  void _flecks(Canvas canvas, Offset centre, double travel, double alpha) {
    final count = slashFlecks(isBossTier);
    for (var i = 0; i < count; i++) {
      final angle = i * 2.39996; // golden angle: an even, unpatterned spray
      final reach = (40 + (i % 4) * 18) * (isBossTier ? 1.3 : 1) * travel;
      final at = centre + Offset(cos(angle), sin(angle) * 0.6) * reach;
      if (i % 3 == 0) {
        // A loose crimson silk thread.
        final dir = Offset(cos(angle), sin(angle)) * 9;
        canvas.drawLine(
          at - dir,
          at + dir,
          Paint()
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round
            ..color = palette.silk.withValues(alpha: alpha),
        );
        continue;
      }
      // A porcelain fleck with an inked edge, tumbling as it flies.
      final fleck = Path()
        ..moveTo(-4, -1)
        ..lineTo(-1, -3)
        ..lineTo(4, -1)
        ..lineTo(2, 3)
        ..lineTo(-3, 2)
        ..close();
      canvas
        ..save()
        ..translate(at.dx, at.dy)
        ..rotate(angle + travel * 4)
        ..drawPath(
          fleck,
          Paint()..color = palette.bone.withValues(alpha: alpha),
        )
        ..drawPath(fleck, _ink(alpha)..strokeWidth = 1.2)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_SlashPainter old) =>
      old.progress != progress ||
      old.isBossTier != isBossTier ||
      old.palette != palette;
}
