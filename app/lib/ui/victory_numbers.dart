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
    final style = Theme.of(context).textTheme.bodyLarge;
    final lines = [
      _n(attempts, 'attempt', 'attempts'),
      _n(days, 'day', 'days'),
      '${_n(effort, 'ember', 'embers')} of effort',
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final l in lines)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.xs),
            child: Text(l, textAlign: TextAlign.center, style: style),
          ),
      ],
    );
  }
}
