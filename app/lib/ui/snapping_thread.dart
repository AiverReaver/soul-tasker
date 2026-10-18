import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// A silk thread whose two halves pull apart and fade as [t] goes 0 to 1.
class SnappingThread extends StatelessWidget {
  const SnappingThread({super.key, required this.t});

  final double t;

  static const _maxGap = 32.0;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        children: [
          Expanded(
            child: Opacity(
              opacity: 1 - .6 * t,
              child: SizedBox(
                key: const ValueKey('thread-left'),
                height: 1,
                child: ColoredBox(color: context.palette.silk),
              ),
            ),
          ),
          SizedBox(width: _maxGap * t),
          Expanded(
            child: Opacity(
              opacity: 1 - .6 * t,
              child: SizedBox(
                key: const ValueKey('thread-right'),
                height: 1,
                child: ColoredBox(color: context.palette.silk),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
