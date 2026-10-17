import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// "3 attempts", "12 days", "48 embers of effort" (§5.11). Plain counts:
/// one attempt reads "1 attempt", never "first try".
class VictoryNumbers extends StatelessWidget {
  const VictoryNumbers({
    super.key,
    required this.attempts,
    required this.days,
    required this.effort,
  });

  final int attempts;
  final int days;
  final int effort;

  static String _n(int n, String one, String many) =>
      '$n ${n == 1 ? one : many}';

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$attempts',
          key: const ValueKey('victory-attempts'),
          style: text.displayMedium?.copyWith(fontSize: 88, height: 1),
        ),
        Text(attempts == 1 ? 'attempt' : 'attempts', style: text.labelSmall),
        const SizedBox(height: Space.md),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: Space.md,
          runSpacing: Space.xs,
          children: [
            Text(_n(days, 'day', 'days'), style: text.bodyLarge),
            SizedBox(height: 18, width: 1, child: ColoredBox(color: p.seam)),
            Text(
              '${_n(effort, 'ember', 'embers')} of effort',
              textAlign: TextAlign.center,
              style: text.bodyLarge,
            ),
          ],
        ),
      ],
    );
  }
}
