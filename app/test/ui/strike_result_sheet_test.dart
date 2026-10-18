import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/strike_result_sheet.dart';
import 'package:material_ui/material_ui.dart';

Future<bool?> _open(WidgetTester tester, String tap) async {
  bool? result;
  var closed = false;
  await tester.pumpWidget(
    MaterialApp(
      theme: buildTheme(),
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showStrikeResultSheet(context, 'Run 3 km');
            closed = true;
          },
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  expect(find.text('HOW DID THE STRIKE LAND?'), findsOneWidget);
  expect(find.text('Run 3 km'), findsOneWidget);
  await tester.tap(find.text(tap));
  await tester.pumpAndSettle();
  expect(closed, isTrue);
  return result;
}

void main() {
  testWidgets('each choice says what it means', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: const Scaffold(body: StrikeResultSheet(title: 'Run 3 km')),
      ),
    );
    expect(find.text('Done in full. Promise kept.'), findsOneWidget);
    expect(find.text('Part done. Effort still earns embers.'), findsOneWidget);
  });

  testWidgets('Clean strike pops true', (tester) async {
    expect(await _open(tester, 'Clean strike'), isTrue);
  });

  testWidgets('A real try pops false', (tester) async {
    expect(await _open(tester, 'A real try'), isFalse);
  });

  testWidgets('Cancel pops null', (tester) async {
    expect(await _open(tester, 'Cancel'), isNull);
  });
}
