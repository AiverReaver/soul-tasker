import 'package:material_ui/material_ui.dart';

/// "Level 4" and how far the next one is.
class LevelLine extends StatelessWidget {
  const LevelLine({super.key, required this.level, required this.toNext});

  final int level;
  final int toNext;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Level $level', style: text.titleMedium),
        Text(
          '$toNext ${toNext == 1 ? 'ember' : 'embers'} to the next',
          style: text.bodySmall,
        ),
      ],
    );
  }
}
