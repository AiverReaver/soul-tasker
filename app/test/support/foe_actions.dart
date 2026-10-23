import 'package:flutter_test/flutter_test.dart';

import '../features/pump.dart';

/// Taps the foe row titled [title] to open Foe actions.
Future<void> openFoeActions(WidgetTester tester, String title) async {
  final row = find.text(title);
  if (row.evaluate().isEmpty) {
    await tester.scrollUntilVisible(row, 100);
  } else {
    await tester.ensureVisible(row);
  }
  await settle(tester);
  await tester.tap(row);
  await settle(tester);
}

/// Opens Foe actions on [title] and taps [item].
Future<void> tapFoeAction(
  WidgetTester tester,
  String title,
  String item,
) async {
  await openFoeActions(tester, title);
  await tester.tap(find.text(item));
  await settle(tester);
}
