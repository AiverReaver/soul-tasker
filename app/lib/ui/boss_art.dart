import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import '../core/boss_design.dart';
import 'ink_path.dart';

export '../core/boss_design.dart';

/// One original hand-drawn boss, outlined in ink. Decoration only; the
/// boss's name is the text a screen reader hears.
///
/// [boilFrame] picks one of three hand-redrawn versions of the same lines;
/// stepping it every ~140 ms makes the ink boil. [seconds] drives the
/// design's idle motion (0 holds it still). [hit] 0..1 burns the whole
/// figure to the biome's mask colour, the flash of a landed strike.
class BossArt extends StatelessWidget {
  const BossArt({
    super.key,
    required this.boilFrame,
    this.design = BossDesign.porcelain,
    this.seconds = 0,
    this.hit = 0,
    this.width = 200,
  });

  final int boilFrame;
  final BossDesign design;
  final double seconds;
  final double hit;
  final double width;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size(width, width * 0.9),
      painter: BossArtPainter(
        design: design,
        boilFrame: boilFrame % 3,
        seconds: seconds,
        hit: hit,
        palette: context.palette,
      ),
    ),
  );
}

typedef _Pose = ({Offset pivot, double turn, Offset scale, Offset shift});
typedef _Move = _Pose Function(double t);

/// One stroke of a drawing in the 200 x 180 box, drawn back to front.
class _Part {
  const _Part(
    this.d, {
    this.fill,
    this.stroke,
    this.width = 2.2,
    this.alpha = 1,
    this.glow = false,
    this.mirror = false,
    this.move,
  });

  final String d;
  final Color? fill, stroke;
  final double width, alpha;

  /// A soft halo under the part: eyes, embers, the heart.
  final bool glow;

  /// Drawn flipped across the middle, for the other side of a figure.
  final bool mirror;
  final _Move? move;
}

double _wave(double t, double period, [double phase = 0]) =>
    math.sin((t / period + phase) * 2 * math.pi);

_Pose _pose({
  Offset pivot = Offset.zero,
  double turn = 0,
  double scale = 1,
  double scaleY = 1,
  Offset shift = Offset.zero,
}) => (
  pivot: pivot,
  turn: turn,
  scale: Offset(scale, scale * scaleY),
  shift: shift,
);

/// Rocks a part about [pivot] by up to [degrees].
_Move _sway(Offset pivot, double degrees, double period, [double phase = 0]) =>
    (t) => _pose(
      pivot: pivot,
      turn: degrees * math.pi / 180 * _wave(t, period, phase),
    );

/// Lifts a part up and down by up to [dy].
_Move _bob(double dy, double period, [double phase = 0]) =>
    (t) => _pose(shift: Offset(0, dy * _wave(t, period, phase)));

/// Drifts a mote upward over [rise] units, then starts again below.
_Move _rise(double rise, double speed, double start) =>
    (t) => _pose(shift: Offset(0, -((t * speed + start) % rise)));

List<_Part> _drawing(BossDesign d, HearthPalette c) => switch (d) {
  BossDesign.porcelain => _porcelain(c),
  BossDesign.grafted => _grafted(c),
  BossDesign.rotBloom => _rotBloom(c),
  BossDesign.matron => _matron(c),
  BossDesign.host => _host(c),
  BossDesign.wyrm => _wyrm(c),
  BossDesign.lightless => _lightless(c),
  BossDesign.blister => _blister(c),
};

List<_Part> _porcelain(HearthPalette c) {
  final lance = _sway(const Offset(150, 176), 2, 4);
  final cloak = _sway(const Offset(100, 40), 1.2, 3.2);
  final head = _bob(1.5, 3.2, 0.25);
  return [
    _Part('M150 176 174 26', stroke: c.ink, width: 6, move: lance),
    _Part('M150 176 174 26', stroke: c.shard, width: 2.6, move: lance),
    _Part(
      'M174 28c12-12 18-22 12-28-8 8-16 14-18 30z',
      fill: c.deep,
      stroke: c.ink,
      width: 2,
      move: lance,
    ),
    _Part(
      'M100 40c-30 10-42 50-48 90-4 20-12 35-18 42l16-6 8 8 12-10 12 12 12-10 '
      '12 10 12-11 12 10 12-10 8 8 16-1c-6-7-14-22-18-42-6-40-18-80-48-90z',
      fill: c.raised,
      stroke: c.ink,
      width: 2.6,
      move: cloak,
    ),
    _Part(
      'M76 92c-6 26-10 52-18 72M124 92c6 26 10 52 18 72',
      stroke: c.mote,
      width: 1.4,
      alpha: 0.3,
      move: cloak,
    ),
    _Part(
      'M82 120c4 20 2 36-4 48M100 100c1 30 0 50 0 70M118 120c-4 20-2 36 4 48',
      stroke: c.ink,
      width: 1.6,
      move: cloak,
    ),
    _Part('M136 112c8-4 14-10 20-16l6 4', stroke: c.ink, width: 2.4),
    _Part(
      'M84 34C76 20 66 12 54 10c10 8 16 18 20 32z'
      'M116 34c8-14 18-22 30-24-10 8-16 18-20 32z',
      fill: c.bone,
      stroke: c.ink,
      move: head,
    ),
    _Part(
      'M100 26c-16 0-24 12-22 28 2 14 12 22 22 26 10-4 20-12 22-26 '
      '2-16-6-28-22-28z',
      fill: c.bone,
      stroke: c.ink,
      width: 2.6,
      move: head,
    ),
    _Part(
      'M90 46c-4 6-3 16 2 20 3-6 3-14-2-20zM110 46c4 6 3 16-2 20-3-6-3-14 2-20z',
      fill: c.ink,
      move: head,
    ),
  ];
}

/// A grafted limb: a thick ink line, a bone core and a three-claw hand,
/// all rocking about the shoulder.
List<_Part> _limb(
  HearthPalette c,
  String arm,
  String claws,
  Offset shoulder,
  double phase, {
  bool mirror = false,
}) {
  final move = _sway(shoulder, 7, 2.4, phase);
  return [
    _Part(arm, stroke: c.ink, width: 10, mirror: mirror, move: move),
    _Part(arm, stroke: c.bone, width: 5.6, mirror: mirror, move: move),
    _Part(claws, stroke: c.ink, width: 4.4, mirror: mirror, move: move),
    _Part(claws, stroke: c.bone, width: 1.8, mirror: mirror, move: move),
  ];
}

List<_Part> _grafted(HearthPalette c) {
  const arms = [
    (
      'M70 80C58 64 46 58 34 60',
      'M34 60l-8-4M34 60l-6 6M34 60l0-10',
      70.0,
      80.0,
    ),
    ('M70 96C52 84 36 82 24 92', 'M24 92l-8-6M24 92l-10 2M24 92l-6 8', 70, 96),
    (
      'M66 116C46 112 32 120 22 134',
      'M22 134l-10-2M22 134l-6 8M22 134l2 10',
      66,
      116,
    ),
  ];
  final head = _bob(1.2, 2.8);
  return [
    for (final (i, (arm, claws, x, y)) in arms.indexed) ...[
      ..._limb(c, arm, claws, Offset(x.toDouble(), y.toDouble()), i * 0.31),
      ..._limb(
        c,
        arm,
        claws,
        Offset(x.toDouble(), y.toDouble()),
        i * 0.31 + 0.5,
        mirror: true,
      ),
    ],
    _Part(
      'M60 172c-8-30-6-62 10-82 14-16 46-16 60 0 16 20 18 52 10 82z',
      fill: c.raised,
      stroke: c.ink,
      width: 2.6,
    ),
    _Part(
      'M72 130c18 6 38 6 56 0M76 152c16 5 32 5 48 0',
      stroke: c.ink,
      width: 1.6,
    ),
    _Part(
      'M80 100c-4 20-6 46-10 70M120 100c4 20 6 46 10 70',
      stroke: c.mote,
      width: 1.4,
      alpha: 0.3,
    ),
    _Part(
      'M88 84c2 12 6 18 12 22 6-4 10-10 12-22z',
      fill: c.deep,
      stroke: c.ink,
      width: 1.8,
      move: head,
    ),
    _Part(
      'M88 74c0-12 6-18 12-18s12 6 12 18-6 14-12 14-12-2-12-14z',
      fill: c.bone,
      stroke: c.ink,
      width: 2.4,
      move: head,
    ),
    _Part('M93 71h5M102 71h5', stroke: c.ink, width: 2.4, move: head),
    _Part(
      'M85 59l3-16 7 9 5-13 5 13 7-9 3 16z',
      fill: c.shard,
      stroke: c.ink,
      width: 2,
      move: head,
    ),
  ];
}

List<_Part> _rotBloom(HearthPalette c) {
  const heart = Offset(100, 96);
  _Move petal(int i, double offset) =>
      (t) => _pose(
        pivot: heart,
        turn: (i + offset) * math.pi / 3 + 0.06 * _wave(t, 6),
        scale: 1 + 0.07 * _wave(t, 3),
      );
  final wings = _sway(const Offset(86, 50), 5, 2.6);
  final blade = _sway(const Offset(134, 114), 2.5, 3.6);
  final head = _bob(1.2, 3.6, 0.2);
  return [
    for (var i = 0; i < 6; i++)
      _Part(
        'M100 96c-16-16-18-42 0-60 18 18 16 44 0 60z',
        fill: c.deep,
        stroke: c.ink,
        width: 1.8,
        move: petal(i, 0),
      ),
    for (var i = 0; i < 6; i++)
      _Part(
        'M100 96c-9-10-10-26 0-36 10 10 9 26 0 36z',
        fill: c.silk,
        alpha: 0.75,
        move: petal(i, 0.5),
      ),
    for (final (i, x) in const [40.0, 62, 140, 160, 120].indexed)
      _Part(
        'M$x 150l3 3-3 3-3-3z',
        fill: c.silk,
        alpha: 0.8,
        glow: true,
        move: _rise(70, 14, i * 17),
      ),
    _Part(
      'M100 70c-14 4-20 22-22 50-2 22-8 40-14 52h72c-6-12-12-30-14-52-2-28-8-46-22-50z',
      fill: c.raised,
      stroke: c.ink,
      width: 2.6,
    ),
    _Part(
      'M92 100c-2 26-6 50-12 70M108 100c2 26 6 50 12 70',
      stroke: c.mote,
      width: 1.4,
      alpha: 0.3,
    ),
    _Part('M112 90c10 6 18 14 22 24', stroke: c.ink, width: 3.4, move: blade),
    _Part('M134 114 170 170', stroke: c.ink, width: 6, move: blade),
    _Part('M134 114 170 170', stroke: c.shard, width: 2.6, move: blade),
    _Part(
      'M112 56c16 6 22 20 20 38-4-8-10-14-18-16',
      stroke: c.silk,
      width: 3,
      move: _sway(const Offset(112, 56), 4, 2.2),
    ),
    _Part(
      'M86 50c-10-10-22-14-36-12 8 4 14 8 18 14-8 0-14 2-20 6 12 2 22 2 32-2z',
      fill: c.bone,
      stroke: c.ink,
      width: 2,
      move: wings,
    ),
    _Part(
      'M86 50c-10-10-22-14-36-12 8 4 14 8 18 14-8 0-14 2-20 6 12 2 22 2 32-2z',
      fill: c.bone,
      stroke: c.ink,
      width: 2,
      mirror: true,
      move: wings,
    ),
    _Part(
      'M100 40c-10 0-16 8-16 20 0 10 6 16 16 18 10-2 16-8 16-18 0-12-6-20-16-20z',
      fill: c.bone,
      stroke: c.ink,
      width: 2.6,
      move: head,
    ),
    _Part('M90 60h20', stroke: c.ink, width: 2.6, move: head),
  ];
}

List<_Part> _matron(HearthPalette c) {
  final head = _sway(const Offset(100, 64), 2, 4.4);
  final arm = _sway(const Offset(114, 72), 3, 3);
  _Move claws(double phase) => (t) {
    final a = arm(t), flex = _sway(const Offset(148, 52), 8, 1.8, phase)(t);
    return _pose(pivot: a.pivot, turn: a.turn + flex.turn);
  };
  return [
    _Part(
      'M100 62c-16 2-22 16-24 40-2 30-12 56-28 72h104c-16-16-26-42-28-72-2-24-8-38-24-40z',
      fill: c.bone,
      stroke: c.ink,
      width: 2.6,
    ),
    _Part(
      'M86 110c-6 24-14 44-26 60M100 102v70M114 110c6 24 14 44 26 60',
      stroke: c.ink,
      width: 1.4,
    ),
    _Part('M82 98c10 6 26 6 36 0', stroke: c.ink, width: 2.2),
    _Part(
      'M92 66l2 2-2 2-2-2zM100 68l2 2-2 2-2-2zM108 66l2 2-2 2-2-2z',
      fill: c.bone,
      stroke: c.ink,
      width: 1,
    ),
    _Part('M114 72c14-2 26-8 34-20', stroke: c.ink, width: 3.6, move: arm),
    _Part(
      'M148 52l18-22M150 54l22-12M150 58l24-4M146 50l8-26',
      stroke: c.ink,
      width: 3.6,
      move: claws(0),
    ),
    _Part(
      'M148 52l18-22M150 54l22-12M150 58l24-4M146 50l8-26',
      stroke: c.shard,
      width: 1.6,
      move: claws(0),
    ),
    _Part(
      'M100 34c-8 0-12 7-12 15 0 9 5 14 12 15 7-1 12-6 12-15 0-8-4-15-12-15z',
      fill: c.bone,
      stroke: c.ink,
      width: 2.4,
      move: head,
    ),
    _Part('M93 48h5M102 48h5', stroke: c.ink, width: 2.2, move: head),
    _Part('M96 57c2 1.5 6 1.5 8 0', stroke: c.silk, width: 2.2, move: head),
    _Part(
      'M60 36c10-9 70-9 80 0-12 5-68 5-80 0z',
      fill: c.ink,
      stroke: c.ink,
      width: 1.6,
      move: head,
    ),
    _Part(
      'M84 34c0-12 8-20 16-20s16 8 16 20z',
      fill: c.ink,
      stroke: c.ink,
      width: 1.6,
      move: head,
    ),
    _Part('M84 29c10 2 22 2 32 0', stroke: c.silk, width: 2.6, move: head),
  ];
}

List<_Part> _host(HearthPalette c) {
  const eyeAt = Offset(145, 90);
  // Shut for a quarter second in every four.
  double blink(double t) => t % 4.2 < 0.25 ? 0.1 : 1;
  _Move eye(bool iris) =>
      (t) => _pose(
        pivot: eyeAt,
        scaleY: blink(t),
        shift: iris
            ? Offset(4 * _wave(t, 3.7), 1.2 * _wave(t, 2.3))
            : Offset.zero,
      );
  // Two quick beats, then a rest.
  _Move beat() => (t) {
    final p = t % 1.1;
    final thump = p < 0.12 || (p > 0.24 && p < 0.34) ? 0.14 : 0.0;
    return _pose(pivot: const Offset(96, 118), scale: 1 + thump);
  };
  const tendrils = [
    ('M60 120c-14 4-22 14-24 28', 60.0, 120.0),
    ('M58 140c-12 8-16 20-14 32', 58, 140),
    ('M150 130c14 6 20 18 20 32', 150, 130),
  ];
  return [
    for (final (i, (d, x, y)) in tendrils.indexed) ...[
      _Part(
        d,
        stroke: c.ink,
        width: 5,
        move: _sway(Offset(x.toDouble(), y.toDouble()), 9, 1.9, i * 0.3),
      ),
      _Part(
        d,
        stroke: c.silk,
        width: 2,
        move: _sway(Offset(x.toDouble(), y.toDouble()), 9, 1.9, i * 0.3),
      ),
    ],
    _Part(
      'M48 172c-6-30 0-62 18-84 10-12 24-18 36-18 24 0 46 10 58 34 12 22 14 46 8 68z',
      fill: c.raised,
      stroke: c.ink,
      width: 2.6,
    ),
    _Part(
      'M96 128c-4 14-12 24-22 30M104 128c6 12 14 20 26 24',
      stroke: c.silk,
      width: 1.4,
      alpha: 0.5,
    ),
    _Part('M160 108c10 18 12 36 6 56', stroke: c.ink, width: 8),
    _Part('M160 108c10 18 12 36 6 56', stroke: c.raised, width: 4.4),
    _Part(
      'M166 164l-6 10M166 164l2 12M166 164l10 6',
      stroke: c.ink,
      width: 2.6,
    ),
    _Part(
      'M118 84c10-20 34-28 52-14 12 12 10 32-6 42-14 8-34 4-46-6z',
      fill: c.deep,
      stroke: c.ink,
      width: 2.4,
    ),
    _Part(
      'M128 90c8-10 24-12 34-2-8 10-24 12-34 2z',
      fill: c.bone,
      stroke: c.ink,
      width: 2,
      move: eye(false),
    ),
    _Part(
      'M145 86c3 0 5 2 5 4s-2 4-5 4-5-2-5-4 2-4 5-4z',
      fill: c.silk,
      glow: true,
      move: eye(true),
    ),
    _Part(
      'M74 68c-8 0-12 6-12 12 0 8 6 12 12 12s12-4 12-12c0-6-4-12-12-12z',
      fill: c.bone,
      stroke: c.ink,
      width: 2.2,
      move: _sway(const Offset(74, 92), 4, 5),
    ),
    _Part(
      'M68 76c1 3 3 4 5 3 0-3-3-4-5-3zM80 76c-1 3-3 4-5 3 0-3 3-4 5-3z'
      'M71 84c1 5 5 5 6 0z',
      fill: c.ink,
      stroke: c.ink,
      width: 1.2,
      move: _sway(const Offset(74, 92), 4, 5),
    ),
    _Part(
      'M96 112c-6-8-18-4-14 6 2 6 8 10 14 14 6-4 12-8 14-14 4-10-8-14-14-6z',
      fill: c.silk,
      stroke: c.ink,
      width: 1.8,
      glow: true,
      move: beat(),
    ),
  ];
}

List<_Part> _wyrm(HearthPalette c) {
  _Move head([Offset pivot = Offset.zero, double open = 0]) =>
      (t) => _pose(
        pivot: pivot,
        // The jaw only drops, never rises past shut.
        turn: open * math.pi / 180 * math.max(0, _wave(t, 3)),
        shift: Offset(0, 1.6 * _wave(t, 3, 0.25)),
      );
  return [
    _Part(
      'M60 120c-20-30-30-70-20-100 14 20 30 34 50 44-10 4-16 10-18 18 10-2 20 0 26 6-14 4-26 14-38 32z',
      fill: c.deep,
      stroke: c.ink,
      width: 2.2,
      move: _sway(const Offset(60, 120), 3, 4),
    ),
    _Part(
      'M42 24c6 30 10 60 18 96M52 50c8 20 14 44 14 66',
      stroke: c.ink,
      width: 1.4,
      move: _sway(const Offset(60, 120), 3, 4),
    ),
    _Part(
      'M40 176c10-40 24-74 50-96 10-8 24-10 34-6l-6 30c-20 10-34 36-40 72z',
      fill: c.raised,
      stroke: c.ink,
      width: 2.6,
    ),
    _Part(
      'M58 150c8-4 16-4 22 0M66 126c8-4 16-4 22 0M80 104c8-4 14-4 20 0',
      stroke: c.ink,
      width: 1.4,
    ),
    _Part(
      'M108 84c18 4 36 4 54 0',
      stroke: c.shard,
      width: 3,
      glow: true,
      move: head(),
    ),
    _Part(
      'M104 84c18 4 40 6 62 2l-4 8c-18 6-40 8-56 2z',
      fill: c.raised,
      stroke: c.ink,
      width: 2.2,
      move: head(const Offset(104, 84), 12),
    ),
    _Part(
      'M100 78c16-16 46-20 70-10 8 4 14 8 18 14l-30 4c-18 2-38 4-58 0z',
      fill: c.raised,
      stroke: c.ink,
      width: 2.4,
      move: head(),
    ),
    _Part(
      'M130 85l2 5 2-5M146 84l2 5 2-5M162 83l2 5 2-5',
      stroke: c.bone,
      width: 1.6,
      move: head(),
    ),
    _Part(
      'M112 72c-8-16-6-34 6-48-2 16 2 30 8 42z'
      'M128 66c0-18 10-32 26-38-8 12-12 26-12 38z',
      fill: c.bone,
      stroke: c.ink,
      width: 2.2,
      move: head(),
    ),
    _Part('M140 73l10-2-4 5z', fill: c.shard, glow: true, move: head()),
    for (final (i, x) in const [176.0, 184, 170, 190].indexed)
      _Part(
        'M$x 80l2.5 2.5-2.5 2.5-2.5-2.5z',
        fill: c.shard,
        glow: true,
        move: _rise(60, 12, i * 15),
      ),
  ];
}

List<_Part> _lightless(HearthPalette c) {
  // The lantern gutters; when it flares she leans away from it.
  double flare(double t) =>
      math.max(0, _wave(t, 2.2)) * (0.6 + 0.4 * _wave(t, 0.35));
  const lantern = Offset(48, 166), feet = Offset(110, 172);
  _Pose flame(double t) => _pose(
    pivot: lantern,
    scale: 1 + 0.25 * flare(t),
    scaleY: (1 + 0.45 * flare(t)) / (1 + 0.25 * flare(t)),
  );
  double lean(double t) => 5 * math.pi / 180 * flare(t);
  // The head snaps between tilts on held beats, never easing.
  const tilts = [0, 9, -5, 14, 2, -9];
  double tilt(double t) =>
      lean(t) + tilts[(t * 1.4).floor() % tilts.length] * 0.6 * math.pi / 180;
  _Pose body(double t) => _pose(pivot: feet, turn: lean(t));
  _Pose head(double t) => _pose(pivot: feet, turn: tilt(t));
  _Pose hair(double t) =>
      _pose(pivot: feet, turn: tilt(t) + 2 * math.pi / 180 * _wave(t, 1.3));
  const leftArm = 'M100 80c-8 20-12 44-12 74';
  const rightArm = 'M120 80c8 20 12 44 12 74';
  return [
    _Part(
      'M48 162 128 112 132 176 48 172z',
      fill: c.shard,
      alpha: 0.07,
      move: (t) => _pose(pivot: lantern, scaleY: 0.8 + 0.3 * flare(t)),
    ),
    _Part('M48 140v10', stroke: c.ink, width: 2),
    _Part('M40 150h16l-2 22h-12z', fill: c.raised, stroke: c.ink, width: 2),
    _Part(
      'M48 156c-3 4-3 8 0 10 3-2 3-6 0-10z',
      fill: c.shard,
      glow: true,
      move: flame,
    ),
    _Part(leftArm, stroke: c.ink, width: 4.6, move: body),
    _Part(leftArm, stroke: c.bone, width: 2.2, move: body),
    _Part(
      'M88 154l-5 9M88 154l-1 11M88 154l4 10',
      stroke: c.ink,
      width: 2,
      move: body,
    ),
    _Part(
      'M110 70c-10 4-14 20-16 42-2 22-8 40-12 60h56c-4-20-10-38-12-60-2-22-6-38-16-42z',
      fill: c.raised,
      stroke: c.ink,
      width: 2.6,
      move: body,
    ),
    _Part(
      'M100 112c-2 22-6 42-10 58M120 112c2 22 6 42 10 58',
      stroke: c.mote,
      width: 1.4,
      alpha: 0.3,
      move: body,
    ),
    _Part(rightArm, stroke: c.ink, width: 4.6, move: body),
    _Part(rightArm, stroke: c.bone, width: 2.2, move: body),
    _Part(
      'M132 154l5 9M132 154l1 11M132 154l-4 10',
      stroke: c.ink,
      width: 2,
      move: body,
    ),
    _Part(
      'M110 44c-9 0-14 7-14 15 0 9 5 15 14 15s14-6 14-15c0-8-5-15-14-15z',
      fill: c.bone,
      stroke: c.ink,
      width: 2.4,
      move: head,
    ),
    _Part('M113 60l3 1-3 1z', fill: c.silk, glow: true, move: head),
    _Part(
      'M95 58c0-14 6-22 15-22s15 8 15 22c-3-8-8-12-15-12s-12 4-15 12z',
      fill: c.ink,
      stroke: c.ink,
      width: 1.6,
      move: head,
    ),
    _Part(
      'M96 54c-4 20-4 40 0 56M101 50c-2 22 0 40 2 58M106 48c-1 24 0 44 1 60'
      'M117 48c1 24 0 44-1 60M120 50c2 22 0 40-2 58M124 54c4 20 4 40 0 56',
      stroke: c.ink,
      width: 2.4,
      move: hair,
    ),
  ];
}

/// A swollen blob of radius [r] about ([x], [y]), closed in four quarters.
String _cyst(double x, double y, double r) {
  final k = r * 0.55, q = r * 0.45;
  return 'M$x ${y - r}c$k 0 $r $q $r ${r}s${-q} $r ${-r} $r '
      '${-r} ${-q} ${-r} ${-r} $q ${-r} $r ${-r}z';
}

List<_Part> _blister(HearthPalette c) {
  final head = _bob(1.4, 2.4);
  final arm = _sway(const Offset(56, 104), 3, 2.4, 0.1);
  const cysts = <(double, double, double)>[
    (124, 62, 13),
    (150, 84, 10),
    (104, 52, 8),
    (160, 112, 12),
    (136, 96, 7),
    (70, 84, 9),
    (58, 130, 8),
  ];
  // Each cyst swells in turn, a wave rolling over the back.
  _Move swell(double x, double y, int i) =>
      (t) => _pose(
        pivot: Offset(x, y),
        scale: 1 + 0.18 * math.max(0, _wave(t, 1.6, -i * 0.14)),
      );
  const club = 'M56 104c-16 20-20 44-16 70';
  return [
    _Part(
      'M30 174c-4-40 8-80 40-102 24-16 64-16 88 4 22 20 30 60 26 98z',
      fill: c.raised,
      stroke: c.ink,
      width: 2.6,
    ),
    _Part(
      'M64 120c-6 16-8 36-6 54M150 128c4 16 4 32 2 46',
      stroke: c.mote,
      width: 1.4,
      alpha: 0.3,
    ),
    _Part('M120 120c8 14 10 34 8 54', stroke: c.ink, width: 1.6),
    for (final (i, (x, y, r)) in cysts.indexed) ...[
      _Part(
        _cyst(x, y, r),
        fill: c.silk,
        stroke: c.ink,
        width: 2,
        glow: true,
        move: swell(x, y, i),
      ),
      _Part(
        _cyst(x - r * 0.3, y - r * 0.3, r * 0.28),
        fill: c.shard,
        alpha: 0.85,
        move: swell(x, y, i),
      ),
    ],
    _Part(club, stroke: c.ink, width: 13, move: arm),
    _Part(club, stroke: c.raised, width: 8.6, move: arm),
    _Part(
      _cyst(42, 168, 7),
      fill: c.silk,
      stroke: c.ink,
      width: 1.8,
      glow: true,
      move: arm,
    ),
    _Part(
      'M90 92c-9 0-13 7-13 14s5 14 13 14 13-7 13-14-4-14-13-14z',
      fill: c.bone,
      stroke: c.ink,
      width: 2.2,
      move: head,
    ),
    _Part(
      'M83 100c1 4 4 5 6 3 0-3-3-5-6-3zM97 100c-1 4-4 5-6 3 0-3 3-5 6-3z'
      'M87 108c-1 6 0 10 3 11 3-1 4-5 3-11-2-1-4-1-6 0z',
      fill: c.ink,
      stroke: c.ink,
      width: 1.2,
      move: head,
    ),
    _Part(
      'M90 115c0 4 1 8 0 12',
      stroke: c.mote,
      width: 1.2,
      alpha: 0.5,
      move: head,
    ),
  ];
}

// Parsed once per design and boil frame: three hands drawing each figure.
final _frames = {
  for (final d in BossDesign.values)
    d: List.generate(
      3,
      (f) => [
        for (final s in _drawing(d, Biome.pharloom.palette))
          inkPath(s.d, jitter: 1.4, seed: 7 + f * 13),
      ],
    ),
};

class BossArtPainter extends CustomPainter {
  const BossArtPainter({
    required this.design,
    required this.boilFrame,
    required this.seconds,
    required this.hit,
    required this.palette,
  });

  final BossDesign design;
  final int boilFrame;
  final double seconds;
  final double hit;
  final HearthPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 200, size.height / 180);
    final paths = _frames[design]![boilFrame % 3];
    // Motion is held on twelfths of a second, like redrawn cels.
    final t = (seconds * 12).floor() / 12;
    // A landed hit burns everything to one flat colour, ink included. Mask
    // is white on dark biomes and shell on light ones, so it shows in both.
    Color burn(Color c, double alpha) =>
        Color.lerp(c, palette.mask, hit)!.withValues(alpha: alpha);
    for (final (i, part) in _drawing(design, palette).indexed) {
      canvas.save();
      if (part.mirror) {
        canvas
          ..translate(200, 0)
          ..scale(-1, 1);
      }
      if (part.move?.call(t) case final p?) {
        canvas
          ..translate(p.shift.dx + p.pivot.dx, p.shift.dy + p.pivot.dy)
          ..rotate(p.turn)
          ..scale(p.scale.dx, p.scale.dy)
          ..translate(-p.pivot.dx, -p.pivot.dy);
      }
      final path = paths[i];
      if (part.glow && hit < 1) {
        canvas.drawPath(
          path,
          Paint()
            ..color = burn(part.fill ?? part.stroke!, 0.55 * part.alpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = part.width + 4
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
      if (part.fill case final fill?) {
        canvas.drawPath(path, Paint()..color = burn(fill, part.alpha));
      }
      if (part.stroke case final stroke?) {
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = part.width
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..color = burn(stroke, part.alpha),
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(BossArtPainter old) =>
      old.design != design ||
      old.boilFrame != boilFrame ||
      old.seconds != seconds ||
      old.hit != hit ||
      old.palette != palette;
}
