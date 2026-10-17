import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// A small rotated square: the ornament that replaces dots.
class DiamondPip extends StatelessWidget {
  const DiamondPip({super.key, required this.color, this.size = 6});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: math.pi / 4,
    child: SizedBox.square(
      dimension: size,
      child: ColoredBox(color: color),
    ),
  );
}
