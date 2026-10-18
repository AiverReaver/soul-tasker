import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'glass_surface.dart';
import 'glass_tap_target.dart';
import 'stroke_icon.dart';

/// A 44 px glass circle with a 22 px icon, in a 48 px hit area: back,
/// the ⋯ menu, profile and settings. [icon] is path data from [StrokeIcons].
class GlassCircleButton extends StatelessWidget {
  const GlassCircleButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.isPressed = false,
    this.isTinted = false,
    this.onPressChanged,
    this.isFilled = false,
  });

  final String icon;
  final String semanticLabel;
  final VoidCallback? onTap;
  final bool isPressed;
  final bool isTinted;
  final ValueChanged<bool>? onPressChanged;

  /// Draw the icon filled, like the ⋯ diamonds.
  final bool isFilled;

  @override
  Widget build(BuildContext context) => GlassTapTarget(
    semanticLabel: semanticLabel,
    onTap: onTap,
    onPressChanged: onPressChanged,
    child: GlassSurface(
      shape: const GlassShape.circle(),
      isPressed: isPressed,
      isTinted: isTinted,
      child: SizedBox.square(
        dimension: 44,
        child: Center(
          child: StrokeIcon(
            path: icon,
            color: context.palette.bone,
            filled: isFilled || icon == StrokeIcons.more,
          ),
        ),
      ),
    ),
  );
}
