import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// What the day held: strikes, tries, falls and the lessons written.
class DaySummary extends StatelessWidget {
  const DaySummary({
    super.key,
    required this.strikes,
    required this.tried,
    required this.falls,
    required this.lessons,
    this.dayLesson,
  });

  final int strikes;
  final int tried;
  final int falls;
  final List<String> lessons;

  /// The line written at the bonfire, once rested.
  final String? dayLesson;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final isQuiet = strikes + tried + falls == 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isQuiet)
          Text('A quiet day so far.', style: text.bodyMedium)
        else ...[
          Text('Struck $strikes', style: text.bodyMedium),
          Text('Tried $tried', style: text.bodyMedium),
          Text('Fallen $falls', style: text.bodyMedium),
        ],
        for (final lesson in [...lessons, ?dayLesson])
          Padding(
            padding: const EdgeInsets.only(top: Space.sm),
            child: Text(
              lesson,
              style: text.bodyMedium?.copyWith(color: context.palette.ash),
            ),
          ),
      ],
    );
  }
}
