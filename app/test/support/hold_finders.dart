import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/features/strike/hold_to_strike.dart';
import 'package:hearthrise/ui/hold_button.dart';

/// The hold button of the foe row titled [title]: where a hold or a tap-mode
/// tap lands now that the row itself only opens its actions.
Finder holdButton(String title) => find.descendant(
  of: find.ancestor(of: find.text(title), matching: find.byType(HoldToStrike)),
  matching: find.byType(HoldButton),
);
