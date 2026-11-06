import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'ember_button.dart';
import 'thread_divider.dart';

/// The bonfire's closing words once rested: the night, what the day held,
/// the line for tomorrow, and the way back to Today.
class RestRecap extends StatelessWidget {
  const RestRecap({
    super.key,
    required this.night,
    required this.strikes,
    required this.kept,
    required this.onDone,
    this.tomorrow,
  });

  /// Which rest this was: "Night {n}."
  final int night;
  final int strikes;

  /// Embers the rest banked.
  final int kept;

  /// The "One thing for tomorrow" line, if written.
  final String? tomorrow;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final ash = text.bodyMedium?.copyWith(color: context.palette.ash);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Space.sm,
      children: [
        Text(
          'Night $night.',
          textAlign: TextAlign.center,
          style: text.displayMedium?.copyWith(fontSize: 44),
        ),
        Text(
          '$strikes ${strikes == 1 ? 'task' : 'tasks'} struck. '
          '$kept ${kept == 1 ? 'ember' : 'embers'} kept.',
          textAlign: TextAlign.center,
          style: text.bodyLarge,
        ),
        if (tomorrow case final line?)
          Text('Tomorrow: $line', textAlign: TextAlign.center, style: ash),
        const SizedBox(height: Space.sm),
        const ThreadDivider(),
        const SizedBox(height: Space.sm),
        Text(
          'You’ve rested. See you tomorrow.',
          textAlign: TextAlign.center,
          style: ash,
        ),
        const SizedBox(height: Space.sm),
        EmberButton(label: 'Back to today', onPressed: onDone),
      ],
    );
  }
}
