import 'package:material_ui/material_ui.dart';

import '../../data/enums.dart';

const kStrikeSweepKey = ValueKey('strike-sweep');

/// How long the landing sweep runs (§7.2, §7.4). Boss-tier runs longer.
/// First-guess numbers, expected to move in tuning.
Duration sweepDuration(Weight weight) => weight == Weight.bossTier
    ? const Duration(milliseconds: 800)
    : const Duration(milliseconds: 400);
