import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'boss_art.dart';
import 'needle_frame.dart';
import 'shard_meter.dart';

/// The pinned boss on Home: a featured card with a deep edge, a portrait and
/// the shard meter. The whole card is the way into the fight.
class PinnedBossPanel extends StatelessWidget {
  const PinnedBossPanel({
    super.key,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.health,
    required this.onEnter,
    required this.onLongPress,
    this.boilFrame = 0,
    this.design = BossDesign.porcelain,
    this.seconds = 0,
  });

  /// The line over the name, such as "Boss · Chapter I of III".
  final String label;
  final String title;
  final String subtitle;

  /// Remaining health, 0..1.
  final double health;
  final VoidCallback onEnter;
  final VoidCallback onLongPress;
  final int boilFrame;

  /// Which of the cast the portrait shows, and its idle clock (see BossArt).
  final BossDesign design;
  final double seconds;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      // The detector stays outside: excluding semantics would hide its actions.
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onEnter,
        onLongPress: onLongPress,
        child: Semantics(
          button: true,
          label:
              'Enter the fight: $title. $subtitle. '
              'Boss health ${shardsFor(health)} of ${ShardMeter.count}',
          excludeSemantics: true,
          child: NeedleFrame(
            key: const Key('pinned-boss-panel'),
            edge: p.deep,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  // 160 degrees.
                  begin: const Alignment(-.34, -.94),
                  end: const Alignment(.34, .94),
                  colors: [p.raised, p.shell],
                  stops: const [0, .62],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Space.md,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: Space.xs,
                            children: [
                              Text(label.toUpperCase(), style: text.labelSmall),
                              Text(title, style: text.headlineMedium),
                              Text(subtitle, style: text.bodySmall),
                            ],
                          ),
                        ),
                        BossArt(
                          boilFrame: boilFrame,
                          design: design,
                          seconds: seconds,
                          width: 92,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: Space.sm),
                      child: ShardMeter(filled: shardsFor(health), height: 9),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
