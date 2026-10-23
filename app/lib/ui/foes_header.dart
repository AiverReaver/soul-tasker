import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'glass_tap_target.dart';
import 'stroke_icon.dart';

/// Home's "Today's foes" row: a serif title, the struck count and a plus
/// that opens the new-foe sheet.
class FoesHeader extends StatelessWidget {
  const FoesHeader({
    super.key,
    required this.countLabel,
    required this.onNewFoe,
  });

  final String countLabel;
  final VoidCallback onNewFoe;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    return Row(
      children: [
        Expanded(
          child: Text(
            'Today’s tasks',
            style: text.titleMedium!.copyWith(fontSize: 22, height: 28 / 22),
          ),
        ),
        Text(countLabel, style: text.bodyMedium!.copyWith(color: p.ash)),
        GlassTapTarget(
          key: const ValueKey('new-foe'),
          semanticLabel: 'New task',
          onTap: onNewFoe,
          child: SizedBox.square(
            dimension: kMinTarget,
            child: Center(
              child: StrokeIcon(
                path: StrokeIcons.plus,
                color: p.silk,
                size: 20,
                strokeWidth: 1.8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
