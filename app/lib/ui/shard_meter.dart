import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// Shards lit for a boss with [health] left (0..1), in twelfths.
int shardsFor(double health) => (health * ShardMeter.count).round();

/// Boss health as 12 skewed shards; [filled] of them are lit.
class ShardMeter extends StatelessWidget {
  const ShardMeter({super.key, required this.filled, this.height = 10});

  static const count = 12;

  final int filled;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      label: 'Boss health $filled of $count',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 3),
            Expanded(
              child: Transform(
                transform: Matrix4.skewX(-0.42),
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: TweenAnimationBuilder<Color?>(
                    tween: ColorTween(
                      end: i < filled ? p.shard : p.dim.withValues(alpha: 0.35),
                    ),
                    duration: motionOf(context, Motion.drain),
                    curve: Curves.easeInOut,
                    builder: (context, color, _) => SizedBox(
                      height: height,
                      child: ColoredBox(
                        key: ValueKey(i < filled ? 'shard-on' : 'shard-off'),
                        color: color!,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
