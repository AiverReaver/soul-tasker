import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/ui/step_marks.dart';
import 'package:material_ui/material_ui.dart';

import 'glass_host.dart';

void main() {
  testWidgets('lights the steps done so far and speaks the step', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(glassHost(const StepMarks(step: 3, total: 5)));
    expect(find.byKey(const ValueKey('step-on')), findsNWidgets(3));
    expect(find.byKey(const ValueKey('step-off')), findsNWidgets(2));
    expect(find.bySemanticsLabel('Step 3 of 5'), findsOneWidget);
    semantics.dispose();
  });
}
