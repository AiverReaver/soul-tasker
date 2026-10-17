import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'boss_art.dart';
import 'ember_button.dart';
import 'needle_frame.dart';
import 'shard_meter.dart';

/// The pinned boss on Home: a featured panel with a deep edge, a small
/// portrait, the shard meter and a way into the fight.
class PinnedBossPanel extends StatelessWidget {
  const PinnedBossPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.health,
    required this.onEnter,
    required this.onLongPress,
    this.boilFrame = 0,
  });

  final String title;
  final String subtitle;

  /// Remaining health, 0..1.
  final double health;
  final VoidCallback onEnter;
  final VoidCallback onLongPress;
  final int boilFrame;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: NeedleFrame(
        key: const Key('pinned-boss-panel'),
        edge: p.deep,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [p.raised2, p.shell],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Space.md + Space.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onLongPress: onLongPress,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pinned', style: text.labelSmall),
                            const SizedBox(height: Space.xs),
                            Text(
                              title,
                              style: text.displaySmall?.copyWith(fontSize: 28),
                            ),
                            const SizedBox(height: Space.xs),
                            Text(subtitle, style: text.bodySmall),
                          ],
                        ),
                      ),
                      BossArt(boilFrame: boilFrame, width: 72),
                    ],
                  ),
                ),
                const SizedBox(height: Space.md),
                ShardMeter(filled: shardsFor(health)),
                const SizedBox(height: Space.md),
                EmberButton(label: 'Enter the fight', onPressed: onEnter),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
