import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'diamond_pip.dart';

/// A row of [total] diamonds, the first [step] lit silk.
class StepMarks extends StatelessWidget {
  const StepMarks({super.key, required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      label: 'Step $step of $total',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Space.sm,
        children: [
          for (var i = 0; i < total; i++)
            KeyedSubtree(
              key: ValueKey('step-slot-$i'),
              child: KeyedSubtree(
                key: ValueKey(i < step ? 'step-on' : 'step-off'),
                child: DiamondPip(color: i < step ? p.silk : p.dim, size: 8),
              ),
            ),
        ],
      ),
    );
  }
}
