import 'package:material_ui/material_ui.dart';

import '../../data/enums.dart';

const kStrikeSweepKey = ValueKey('strike-sweep');

/// The transform that throws a struck row during the shatter.
const kStrikeShakeKey = ValueKey('strike-shake');

/// How long a landed strike runs, from the hit to the end of the settle
/// (§7.2, D8): the beats of `strikeBeatAt` end at 1300 ms. Boss-tier rests
/// a little longer on its heavier flecks.
Duration sweepDuration(Weight weight) => weight == Weight.bossTier
    ? const Duration(milliseconds: 1600)
    : const Duration(milliseconds: 1300);
