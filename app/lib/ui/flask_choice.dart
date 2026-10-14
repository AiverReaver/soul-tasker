import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'ember_button.dart';

/// Asked when days passed without rest: spend a flask, or let the attempt
/// fall. Calm and plain; nothing is lost by choosing either.
class FlaskChoice extends StatelessWidget {
  const FlaskChoice({
    super.key,
    required this.daysMissed,
    required this.flasks,
    required this.onUseFlask,
    required this.onLetFall,
  });

  final int daysMissed;
  final int flasks;
  final VoidCallback onUseFlask;
  final VoidCallback onLetFall;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AlertDialog(
      backgroundColor: kSurface,
      title: Text(
        daysMissed == 1
            ? 'A day passed without rest.'
            : '$daysMissed days passed without rest.',
        style: text.titleMedium,
      ),
      content: Text(
        'You hold $flasks ${flasks == 1 ? 'flask' : 'flasks'}.',
        style: text.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: onLetFall,
          child: Text('Let it fall', style: TextStyle(color: kTextMuted)),
        ),
        EmberButton(label: 'Use a flask', onPressed: onUseFlask),
      ],
    );
  }
}
