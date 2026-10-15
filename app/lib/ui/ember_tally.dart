import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// Carried embers (at risk until the bonfire) and banked embers (safe).
class EmberTally extends StatelessWidget {
  const EmberTally({super.key, required this.carried, required this.banked});

  final int carried;
  final int banked;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Row(
      children: [
        Text('Carried $carried', style: style?.copyWith(color: kEmber)),
        const SizedBox(width: Space.lg),
        Text('Banked $banked', style: style?.copyWith(color: kTextMuted)),
      ],
    );
  }
}
