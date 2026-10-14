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
  });

  final int strikes;
  final int tried;
  final int falls;
  final List<String> lessons;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    if (strikes + tried + falls == 0) {
      return Text('A quiet day so far.', style: text.bodyMedium);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Struck $strikes', style: text.bodyMedium),
        Text('Tried $tried', style: text.bodyMedium),
        Text('Fallen $falls', style: text.bodyMedium),
        for (final lesson in lessons)
          Padding(
            padding: const EdgeInsets.only(top: Space.sm),
            child: Text(
              lesson,
              style: text.bodyMedium?.copyWith(color: kTextMuted),
            ),
          ),
      ],
    );
  }
}
