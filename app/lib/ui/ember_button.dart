import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'needle_frame.dart';
import 'stroke_icon.dart';

/// The one silk-coloured action on a screen ("Rest", "Rise", "Enter the
/// fight"): solid silk, onSilk text, 52 px tall.
class EmberButton extends StatelessWidget {
  const EmberButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;

  /// Null disables the button: it fades and reads as disabled.
  final VoidCallback? onPressed;

  /// Optional [StrokeIcons] path drawn before the label.
  final String? icon;

  static const height = 52.0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final button = NeedleFrame(
      tier: Cut.md,
      edge: p.silk,
      fill: p.silk,
      child: InkWell(
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: height),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.lg),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  if (icon != null)
                    StrokeIcon(
                      path: icon!,
                      color: p.onSilk,
                      size: 18,
                      strokeWidth: 1.8,
                    ),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: p.onSilk,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: Opacity(opacity: onPressed == null ? .4 : 1, child: button),
    );
  }
}
