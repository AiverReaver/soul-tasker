import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'glass_alert.dart';
import 'needle_frame.dart';

/// A short list of options in a glass alert; tapping one reports it.
class ChoiceDialog<T> extends StatelessWidget {
  const ChoiceDialog({
    super.key,
    required this.title,
    required this.options,
    required this.onPicked,
  });

  final String title;

  /// Option value to its label, in display order.
  final Map<T, String> options;
  final ValueChanged<T> onPicked;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GlassAlert(
      title: title,
      actions: const [],
      content: Column(
        spacing: Space.sm,
        children: [
          for (final e in options.entries)
            Semantics(
              button: true,
              label: e.value,
              onTap: () => onPicked(e.key),
              excludeSemantics: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onPicked(e.key),
                child: NeedleFrame(
                  tier: Cut.md,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: kMinTarget),
                    child: Center(
                      child: Text(
                        e.value,
                        style: text.bodyMedium!.copyWith(
                          color: context.palette.bone,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
