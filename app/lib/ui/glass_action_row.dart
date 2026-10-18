import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'glass_surface.dart';
import 'glass_tap_target.dart';

/// One full-width glass row in an actions sheet: a label, 52 px tall.
class GlassActionRow extends StatelessWidget {
  const GlassActionRow({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GlassTapTarget(
    semanticLabel: label,
    onTap: onTap,
    child: GlassSurface(
      shape: const GlassShape.stadium(),
      child: SizedBox(
        height: 52,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: context.palette.bone,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ),
  );
}
