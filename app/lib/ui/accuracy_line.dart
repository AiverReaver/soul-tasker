import 'package:material_ui/material_ui.dart';

/// Planning accuracy (§5.12): promises kept of promises made, today and over
/// the week. A span with no promises shows no number (plan D16).
class AccuracyLine extends StatelessWidget {
  const AccuracyLine({
    super.key,
    required this.todayKept,
    required this.todayMade,
    required this.weekKept,
    required this.weekMade,
  });

  final int todayKept;
  final int todayMade;
  final int weekKept;
  final int weekMade;

  @override
  Widget build(BuildContext context) {
    final parts = [
      if (todayMade > 0) 'Today: $todayKept of $todayMade kept.',
      if (weekMade > 0) 'This week: $weekKept of $weekMade.',
    ];
    if (parts.isEmpty) return const SizedBox.shrink();
    return Text(parts.join(' '), style: Theme.of(context).textTheme.bodySmall);
  }
}
