import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// One lesson in the timeline.
class LessonRow {
  const LessonRow({
    required this.attempt,
    required this.text,
    this.isMissedDay = false,
  });

  final int attempt;
  final String text;

  /// Written for a day left unkept, not a declared fall: a quiet marker.
  final bool isMissedDay;
}

/// The lessons in the order they were learned: "Attempt 2. Rushed it."
/// Shows nothing when there are none.
class LessonTimeline extends StatelessWidget {
  const LessonTimeline({super.key, required this.lessons});

  final List<LessonRow> lessons;

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final l in lessons)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.sm),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Attempt ${l.attempt}. ',
                    style: text.bodyMedium?.copyWith(color: kTextMuted),
                  ),
                  TextSpan(text: l.text),
                  if (l.isMissedDay)
                    TextSpan(text: '  (a missed day)', style: text.bodySmall),
                ],
              ),
              style: text.bodyMedium,
            ),
          ),
      ],
    );
  }
}
