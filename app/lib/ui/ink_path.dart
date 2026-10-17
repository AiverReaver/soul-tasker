import 'dart:math';

import 'package:material_ui/material_ui.dart';

final _token = RegExp(r'[MmLlHhVvCcSsZz]|-?(?:\d*\.\d+|\d+)(?:[eE]-?\d+)?');
final _command = RegExp(r'^[A-Za-z]$');

/// Reads SVG path data (M L H V C S Z, absolute and relative) into a [Path],
/// so hand-drawn art can be kept as the strings it was drawn in.
///
/// [jitter] nudges every drawn point by up to that many units. Each [seed]
/// gives the same line drawn again by a slightly different hand; cycling
/// three seeds is the "boiling line" of cel animation.
Path inkPath(String d, {double jitter = 0, int seed = 0}) {
  final tokens = _token.allMatches(d).map((m) => m[0]!).toList();
  final random = Random(seed);
  final path = Path();
  Offset nudge(Offset p) => jitter == 0
      ? p
      : p +
            Offset(
              (random.nextDouble() * 2 - 1) * jitter,
              (random.nextDouble() * 2 - 1) * jitter,
            );

  var i = 0;
  var cmd = '';
  var cur = Offset.zero, start = Offset.zero;
  Offset? lastControl;
  double number() {
    if (i >= tokens.length || _command.hasMatch(tokens[i])) {
      throw FormatException('Expected a number in path data', d);
    }
    return double.parse(tokens[i++]);
  }

  while (i < tokens.length) {
    if (_command.hasMatch(tokens[i])) {
      cmd = tokens[i++];
    } else if (cmd.isEmpty || cmd == 'Z' || cmd == 'z') {
      throw FormatException('Number without a command in path data', d);
    }
    final isRelative = cmd == cmd.toLowerCase();
    Offset point() {
      final p = Offset(number(), number());
      return isRelative ? cur + p : p;
    }

    Offset? control;
    switch (cmd.toUpperCase()) {
      case 'M':
        cur = start = point();
        final p = nudge(cur);
        path.moveTo(p.dx, p.dy);
        cmd = isRelative ? 'l' : 'L'; // further pairs are lines
      case 'L':
        cur = point();
        final p = nudge(cur);
        path.lineTo(p.dx, p.dy);
      case 'H':
        final x = number();
        cur = Offset(isRelative ? cur.dx + x : x, cur.dy);
        final p = nudge(cur);
        path.lineTo(p.dx, p.dy);
      case 'V':
        final y = number();
        cur = Offset(cur.dx, isRelative ? cur.dy + y : y);
        final p = nudge(cur);
        path.lineTo(p.dx, p.dy);
      case 'C' || 'S':
        final c1 = cmd.toUpperCase() == 'C'
            ? point()
            : cur + (cur - (lastControl ?? cur));
        final c2 = point(), end = point();
        final (a, b, e) = (nudge(c1), nudge(c2), nudge(end));
        path.cubicTo(a.dx, a.dy, b.dx, b.dy, e.dx, e.dy);
        control = c2;
        cur = end;
      case 'Z':
        path.close();
        cur = start;
    }
    lastControl = control;
  }
  return path;
}
