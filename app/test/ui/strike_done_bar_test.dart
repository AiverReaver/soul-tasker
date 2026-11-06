import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/strike_done_bar.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('says it is done and offers Only partly and Undo', (
    tester,
  ) async {
    var partly = 0, undo = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(
          body: StrikeDoneBar(onPartly: () => partly++, onUndo: () => undo++),
        ),
      ),
    );
    expect(find.text('It is done.'), findsOneWidget);
    await tester.tap(find.text('Only partly'));
    await tester.tap(find.text('Undo'));
    expect((partly, undo), (1, 1));
  });
}
