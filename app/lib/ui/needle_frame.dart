import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// The one surface shape: a 1 px edge round a clipped fill. [tier] is a
/// [Cut] radius. Above a tag it has depth: a 2 px ink line outside the edge
/// and a soft shadow below, neither taking layout. State changes [edge] (seam
/// at rest, silk selected, bone ready, deep featured), never the shape.
/// [isFocused] adds a 2 px bone ring outside the clip.
class NeedleFrame extends StatelessWidget {
  const NeedleFrame({
    super.key,
    required this.child,
    this.tier = Cut.lg,
    this.edge,
    this.fill,
    this.isFocused = false,
  });

  final Widget child;
  final double tier;
  final Color? edge;
  final Color? fill;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final frame = DecoratedBox(
      key: const ValueKey('needle-edge'),
      decoration: BoxDecoration(
        color: edge ?? p.seam,
        borderRadius: BorderRadius.circular(tier),
        boxShadow: tier > Cut.sm
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? .45 : .12),
                  offset: const Offset(0, 8),
                  blurRadius: 18,
                ),
                BoxShadow(color: p.ink, spreadRadius: 2),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(tier - 1),
          child: ColoredBox(color: fill ?? p.shell, child: child),
        ),
      ),
    );
    if (!isFocused) return frame;
    return DecoratedBox(
      key: const ValueKey('needle-focus'),
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border.all(color: p.bone, width: 2),
        borderRadius: BorderRadius.circular(tier),
      ),
      child: frame,
    );
  }
}
