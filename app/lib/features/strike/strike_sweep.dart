import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/enums.dart';

const kStrikeSweepKey = ValueKey('strike-sweep');

/// How long the landing sweep runs (§7.2, §7.4). Boss-tier runs longer.
/// First-guess numbers, expected to move in tuning.
Duration sweepDuration(Weight weight) => weight == Weight.bossTier
    ? const Duration(milliseconds: 800)
    : const Duration(milliseconds: 400);

/// A brief ember line crossing the row that was just struck. It is
/// transient, so it does not compete with the one resting ember element
/// (DESIGN.md). Boss-tier is wider and brighter.
class StrikeSweep extends StatelessWidget {
  const StrikeSweep({super.key, required this.progress, required this.weight});

  /// 0 at the left edge, 1 at the right.
  final double progress;
  final Weight weight;

  @override
  Widget build(BuildContext context) {
    final isBoss = weight == Weight.bossTier;
    return Align(
      alignment: Alignment(progress * 2 - 1, 0),
      child: FractionallySizedBox(
        heightFactor: 1,
        child: SizedBox(
          width: isBoss ? 4 : 2,
          child: ColoredBox(color: kEmber.withValues(alpha: isBoss ? 1 : 0.7)),
        ),
      ),
    );
  }
}
