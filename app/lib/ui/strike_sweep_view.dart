import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// A brief ember line crossing the row that was just struck. It is
/// transient, so it does not compete with the one resting ember element
/// (DESIGN.md). Boss-tier is wider and brighter.
class StrikeSweepView extends StatelessWidget {
  const StrikeSweepView({
    super.key,
    required this.progress,
    required this.isBossTier,
  });

  /// 0 at the left edge, 1 at the right.
  final double progress;
  final bool isBossTier;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(progress * 2 - 1, 0),
      child: FractionallySizedBox(
        heightFactor: 1,
        child: SizedBox(
          width: isBossTier ? 4 : 2,
          child: ColoredBox(
            color: kEmber.withValues(alpha: isBossTier ? 1 : 0.7),
          ),
        ),
      ),
    );
  }
}
