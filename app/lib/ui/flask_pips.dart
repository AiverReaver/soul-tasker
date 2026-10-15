import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// Flask charges as a row of pips: [count] filled out of [cap].
class FlaskPips extends StatelessWidget {
  const FlaskPips({super.key, required this.count, required this.cap});

  final int count;
  final int cap;

  static const _size = 12.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Flasks $count of $cap',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < cap; i++)
            Padding(
              padding: const EdgeInsets.only(right: Space.sm),
              child: Container(
                key: ValueKey(i < count ? 'flask-full' : 'flask-empty'),
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < count ? kAsh : null,
                  border: Border.all(color: kAshDim),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
