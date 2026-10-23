import 'package:flutter_test/flutter_test.dart';

import '../features/pump.dart';

/// Opens the ⋯ Boss actions sheet on the Boss screen and taps [label].
Future<void> tapBossAction(
  WidgetTester tester,
  String label, {
  bool settleAfter = true,
}) async {
  await tester.tap(find.bySemanticsLabel('Boss actions'));
  await settle(tester);
  await tester.tap(find.text(label));
  if (settleAfter) await settle(tester);
}
