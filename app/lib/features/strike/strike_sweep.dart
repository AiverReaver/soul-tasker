import 'package:material_ui/material_ui.dart';

import '../../data/enums.dart';

const kStrikeSweepKey = ValueKey('strike-sweep');

/// The transform that throws a struck row during the shatter.
const kStrikeShakeKey = ValueKey('strike-shake');

/// How long a landed strike runs, from the first cut to the last fleck
/// (§7.2, §7.4). Boss-tier runs longer. Long enough for the slash's beats
/// (ui/strike_sweep_view.dart) to read; expected to move in tuning.
Duration sweepDuration(Weight weight) => weight == Weight.bossTier
    ? const Duration(milliseconds: 1100)
    : const Duration(milliseconds: 700);
