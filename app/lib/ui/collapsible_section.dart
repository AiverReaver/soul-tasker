import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// A titled section that folds away: "Waiting (2)" with a chevron. The
/// caller holds [isExpanded]; the header reports its state to screen readers.
class CollapsibleSection extends StatelessWidget {
  const CollapsibleSection({
    super.key,
    required this.title,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
  });

  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: isExpanded,
          label: title,
          onTap: onToggle,
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: kMinTarget),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? .25 : 0,
                    duration: Motion.quick,
                    child: Text(
                      '›',
                      style: TextStyle(color: p.ash, fontSize: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isExpanded) child,
      ],
    );
  }
}
