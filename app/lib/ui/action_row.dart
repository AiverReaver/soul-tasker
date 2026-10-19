import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'needle_frame.dart';

/// One full-width plain row in an actions sheet: a label, 52 px tall.
/// Sheets with several rows use this, not glass, so they stay cheap to draw.
class ActionRow extends StatelessWidget {
  const ActionRow({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    onTap: onTap,
    excludeSemantics: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: NeedleFrame(
        tier: Cut.md,
        child: SizedBox(
          height: 50, // plus the 1 px frame each side
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
    ),
  );
}
