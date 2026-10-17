import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'diamond_pip.dart';

/// A silk thread with a diamond at its centre.
class ThreadDivider extends StatelessWidget {
  const ThreadDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final silk = context.palette.silk;
    final line = Expanded(
      child: SizedBox(height: 1, child: ColoredBox(color: silk)),
    );
    return ExcludeSemantics(
      child: Row(
        children: [
          line,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.sm),
            child: DiamondPip(color: silk),
          ),
          line,
        ],
      ),
    );
  }
}
