import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'boss_health_bar.dart';

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
    this.healthGroups,
  });

  final String title;
  final int attemptNumber;
  final String progressLabel;
  final double health;
  final bool isPinned;

  /// Health bar segments; null hides the bar.
  final List<List<bool>>? healthGroups;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final groups = healthGroups;
    return Semantics(
      label:
          'Boss $title, attempt $attemptNumber, '
          '${(health * 100).round()} percent health',
      button: true,
      excludeSemantics: true,
      child: Card(
        color: kSurface,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: const RoundedRectangleBorder(),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          splashColor: kAshDim.withValues(alpha: 0.18),
          highlightColor: kAshDim.withValues(alpha: 0.1),
          child: CustomPaint(
            key: const Key('boss-card-frame'),
            foregroundPainter: const _FramePainter(),
            child: Padding(
              // Extra inset keeps content clear of the inner hairline.
              padding: const EdgeInsets.all(Space.md + Space.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(title, style: text.titleMedium)),
                      if (isPinned) ...[
                        const SizedBox(width: Space.sm),
                        const _PinMark(),
                        const SizedBox(width: Space.xs),
                        Text('Pinned', style: text.bodySmall),
                      ],
                    ],
                  ),
                  const SizedBox(height: Space.xs),
                  Text(
                    'Attempt $attemptNumber · $progressLabel',
                    style: text.bodySmall,
                  ),
                  if (groups != null) ...[
                    const SizedBox(height: Space.md),
                    BossHealthBar(groups: groups, health: health, height: 6),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
      child: const SizedBox(
        width: 6,
        height: 6,
        child: ColoredBox(color: kTextMuted),
      ),
    ),
  );
}

/// Double hairline frame with a diamond at each corner: a quiet carved-stone
/// edge in ash tones only, so ember stays reserved. Painted over the card
/// edges, never under text.
class _FramePainter extends CustomPainter {
  const _FramePainter();

  static const _inset = 4.0;
  static const _diamond = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Paint()
      ..style = PaintingStyle.stroke
      ..color = kAshDim.withValues(alpha: 0.5);
    final inner = Paint()
      ..style = PaintingStyle.stroke
      ..color = kAshDim.withValues(alpha: 0.2);
    canvas.drawRect(Offset.zero & size, outer);
    final box = Rect.fromLTWH(
      _inset,
      _inset,
      size.width - 2 * _inset,
      size.height - 2 * _inset,
    );
    canvas.drawRect(box, inner);

    final fill = Paint()..color = kAshDim;
    for (final c in [
      box.topLeft,
      box.topRight,
      box.bottomLeft,
      box.bottomRight,
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy - _diamond)
          ..lineTo(c.dx + _diamond, c.dy)
          ..lineTo(c.dx, c.dy + _diamond)
          ..lineTo(c.dx - _diamond, c.dy)
          ..close(),
        fill,
      );
    }
  }

  @override
  bool shouldRepaint(_FramePainter old) => false;
}
