import 'package:material_ui/material_ui.dart';

import '../core/roman.dart';
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
    final p = context.palette;
    final seam = BorderSide(color: p.seam);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < lessons.length; i++)
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: seam,
                bottom: i == lessons.length - 1 ? seam : BorderSide.none,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 38,
                    child: Text(
                      romanNumeral(lessons[i].attempt),
                      style: text.bodySmall?.copyWith(
                        color: p.silk,
                        fontWeight: FontWeight.w600,
                        height: 24 / 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lessons[i].text,
                          style: text.titleMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            fontSize: 19,
                            height: 24 / 19,
                          ),
                        ),
                        if (lessons[i].isMissedDay)
                          Text('a missed day', style: text.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
