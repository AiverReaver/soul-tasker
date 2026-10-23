import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// The tap area under a glass control: at least 48 px each way, a labelled
/// semantics button (or toggle, when [toggled] is set), and press reports.
/// Press state itself lives in the caller's container (see `PressTracker`).
class GlassTapTarget extends StatelessWidget {
  const GlassTapTarget({
    super.key,
    required this.child,
    required this.semanticLabel,
    required this.onTap,
    this.onPressChanged,
    this.toggled,
  });

  final Widget child;
  final String semanticLabel;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onPressChanged;

  /// Non-null makes this a toggle rather than a button.
  final bool? toggled;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    button: toggled == null,
    toggled: toggled,
    enabled: null,
    onTap: onTap,
    excludeSemantics: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onTapDown: (_) => onPressChanged?.call(true),
      onTapUp: (_) => onPressChanged?.call(false),
      onTapCancel: () => onPressChanged?.call(false),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: kMinTarget,
          minHeight: kMinTarget,
        ),
        child: Center(widthFactor: 1, heightFactor: 1, child: child),
      ),
    ),
  );
}
