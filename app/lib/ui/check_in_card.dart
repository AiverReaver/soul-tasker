import 'package:material_ui/material_ui.dart';

import '../core/check_in.dart';
import '../core/theme.dart';

/// "Has Hearthrise left you feeling worse?" (Stage 6 plan D6). Neutral
/// choices and a way out; no score, nothing follows an answer.
class CheckInCard extends StatelessWidget {
  const CheckInCard({
    super.key,
    required this.onAnswer,
    required this.onDismiss,
  });

  final ValueChanged<CheckInAnswer> onAnswer;
  final VoidCallback onDismiss;

  static const _labels = {
    CheckInAnswer.never: 'Never',
    CheckInAnswer.sometimes: 'Sometimes',
    CheckInAnswer.often: 'Often',
  };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.shell,
        border: Border.all(color: context.palette.dim),
        borderRadius: BorderRadius.circular(Space.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Has Hearthrise left you feeling worse?',
              style: text.titleMedium,
            ),
            const SizedBox(height: Space.sm),
            Wrap(
              spacing: Space.sm,
              children: [
                for (final a in CheckInAnswer.values)
                  OutlinedButton(
                    onPressed: () => onAnswer(a),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(kMinTarget, kMinTarget),
                      side: BorderSide(color: context.palette.dim),
                    ),
                    child: Text(_labels[a]!, style: text.bodyMedium),
                  ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onDismiss,
                style: TextButton.styleFrom(
                  minimumSize: const Size(kMinTarget, kMinTarget),
                ),
                child: Text(
                  'Not now',
                  style: TextStyle(color: context.palette.ash),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
