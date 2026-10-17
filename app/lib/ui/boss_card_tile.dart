import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'boss_art.dart';
import 'needle_frame.dart';
import 'shard_meter.dart';

/// One boss on the home list (§6.1). Pure presentation: values in, taps out.
class BossCardTile extends StatelessWidget {
  const BossCardTile({
    super.key,
    required this.title,
    required this.attemptNumber,
    required this.progressLabel,
    required this.health,
    required this.isPinned,
    required this.onTap,
    required this.onLongPress,
    this.showHealth = false,
    this.boilFrame = 0,
  });

  final String title;
  final int attemptNumber;
  final String progressLabel;
  final double health;
  final bool isPinned;

  /// Shows the shard meter.
  final bool showHealth;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  /// Which boil drawing the portrait's ink is on (see BossArt).
  final int boilFrame;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      label:
          'Boss $title, attempt $attemptNumber, '
          '${(health * 100).round()} percent health',
      button: true,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: NeedleFrame(
          key: const Key('boss-card-frame'),
          edge: isPinned ? context.palette.deep : null,
          fill: isPinned ? context.palette.raised2 : null,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              splashColor: context.palette.silk.withValues(alpha: 0.12),
              highlightColor: context.palette.dim.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(Space.md + Space.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _heading(context, text)),
                        const SizedBox(width: Space.sm),
                        BossArt(boilFrame: boilFrame, width: 72),
                      ],
                    ),
                    if (showHealth) ...[
                      const SizedBox(height: Space.md),
                      ShardMeter(filled: shardsFor(health), height: 8),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _heading(BuildContext context, TextTheme text) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (isPinned)
        Padding(
          padding: const EdgeInsets.only(bottom: Space.xs),
          child: Row(
            children: [
              const _PinMark(),
              const SizedBox(width: Space.sm),
              Text(
                'Pinned',
                style: text.labelSmall?.copyWith(color: context.palette.silk),
              ),
            ],
          ),
        ),
      Text(title, style: text.headlineMedium),
      const SizedBox(height: Space.xs),
      Text('Attempt $attemptNumber · $progressLabel', style: text.bodySmall),
    ],
  );
}

/// Small drawn diamond beside "Pinned" (no emoji, no icon font).
class _PinMark extends StatelessWidget {
  const _PinMark();

  @override
  Widget build(BuildContext context) => Padding(
    // Optically centers on the first line of the 14 px label.
    padding: const EdgeInsets.only(top: 7),
    child: Transform.rotate(
      key: const Key('pin-mark'),
      angle: 0.785398,
      child: SizedBox(
        width: 6,
        height: 6,
        child: ColoredBox(color: context.palette.silk),
      ),
    ),
  );
}
