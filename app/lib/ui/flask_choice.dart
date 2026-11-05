import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../core/deadlines.dart';
import 'glass_alert.dart';

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
    final spend = min(flasks, daysMissed);
    final days = countWord(daysMissed);
    return GlassAlert(
      title: daysMissed == 1
          ? 'A day passed without rest.'
          : '${days[0].toUpperCase()}${days.substring(1)} days passed '
                'without rest.',
      body: 'You hold $flasks ${flasks == 1 ? 'flask' : 'flasks'}.',
      actions: [
        spend == 1 ? 'Use a flask' : 'Use ${countWord(spend)} flasks',
        'Let it fall',
      ],
      onAction: (i) => i == 0 ? onUseFlask() : onLetFall(),
    );
  }
}
