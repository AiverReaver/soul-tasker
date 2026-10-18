import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'glass_pill_button.dart';
import 'glass_surface.dart';
import 'thread_divider.dart';

/// A glass bottom sheet: a grabber, a header with the small [label] and
/// serif [title] on the left and a glass pill on the right, a thread, then
/// [child], which scrolls when it is tall or the text is large. The glint
/// stays top left, so the header is padded down to clear it.
class GlassSheet extends StatelessWidget {
  const GlassSheet({
    super.key,
    required this.title,
    required this.child,
    this.label,
    this.closeLabel = 'Cancel',
  });

  final String title;
  final String? label;
  final String closeLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final screen = MediaQuery.sizeOf(context);
    return Padding(
      padding: const EdgeInsets.all(Space.sm),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screen.height * .9),
        child: GlassSurface(
          shape: GlassShape.rounded(44),
          blur: 28,
          glintSize: 88,
          child: ColoredBox(
            color: p.shell.withValues(alpha: .58),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.lg - 4,
                26,
                Space.lg - 4,
                Space.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 18,
                children: [
                  Center(
                    child: Transform(
                      transform: Matrix4.skewX(-.42),
                      child: DecoratedBox(
                        key: const ValueKey('glass-grabber'),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .45),
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: p.glassKey, width: 1),
                        ),
                        child: const SizedBox(width: 40, height: 6),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Space.sm + 4,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (label != null)
                              Text(
                                label!.toUpperCase(),
                                style: text.labelSmall,
                              ),
                            Text(
                              title,
                              style: text.titleMedium!.copyWith(
                                fontSize: 26,
                                height: 30 / 26,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GlassPillButton(
                        label: closeLabel,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                  const ThreadDivider(),
                  Flexible(child: SingleChildScrollView(child: child)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows [builder] (a [GlassSheet]) over a 62% ink scrim.
Future<T?> showGlassSheet<T>(BuildContext context, WidgetBuilder builder) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: context.palette.ink.withValues(alpha: .62),
      builder: builder,
    );
