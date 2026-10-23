import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'glass_surface.dart';
import 'glass_tap_target.dart';

/// A 44 px glass pill with a label: Cancel and Close on sheet headers.
class GlassPillButton extends StatelessWidget {
  const GlassPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isPressed = false,
    this.onPressChanged,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isPressed;
  final ValueChanged<bool>? onPressChanged;

  @override
  Widget build(BuildContext context) => GlassTapTarget(
    semanticLabel: label,
    onTap: onTap,
    onPressChanged: onPressChanged,
    child: GlassSurface(
      shape: const GlassShape.stadium(),
      isPressed: isPressed,
      child: SizedBox(
        height: 44,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: TextStyle(
                color: context.palette.bone,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
