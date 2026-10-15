import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/check_in.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/check_in_card.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(412, 915),
  double text = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildTheme(),
      home: MediaQuery(
        data: MediaQueryData(size: size, textScaler: TextScaler.linear(text)),
        child: Scaffold(body: ListView(children: [child])),
      ),
    ),
  );
}

void main() {
  testWidgets('asks the question and fires each answer', (tester) async {
    final answers = <CheckInAnswer>[];
    var dismissed = 0;
    await _pump(
      tester,
      CheckInCard(onAnswer: answers.add, onDismiss: () => dismissed++),
    );

    expect(find.text('Has Hearthrise left you feeling worse?'), findsOneWidget);
    await tester.tap(find.text('Never'));
    await tester.tap(find.text('Sometimes'));
    await tester.tap(find.text('Often'));
    await tester.tap(find.text('Not now'));
    expect(answers, CheckInAnswer.values);
    expect(dismissed, 1);
  });

  testWidgets('every choice is at least 48 dp tall', (tester) async {
    await _pump(tester, CheckInCard(onAnswer: (_) {}, onDismiss: () {}));
    for (final label in ['Never', 'Sometimes', 'Often', 'Not now']) {
      final button = find.ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      );
      expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
    }
  });

  testWidgets('fits 320 x 568 at 200% text', (tester) async {
    await _pump(
      tester,
      CheckInCard(onAnswer: (_) {}, onDismiss: () {}),
      size: const Size(320, 568),
      text: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
