import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// The one quiet line a screen speaks after an action ("It is done.").
class FlashLine extends StatelessWidget {
  const FlashLine(this.message, {super.key});

  final String? message;

  static const _height = 36.0;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium
        ?.copyWith(color: kEmber);
    return SizedBox(
      height: _height,
      child: AnimatedSwitcher(
        duration: motionOf(context, kSlowFade),
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.centerLeft,
          children: [...previous, ?current],
        ),
        child: Text(message ?? '', key: ValueKey(message), style: style),
      ),
    );
  }
}
