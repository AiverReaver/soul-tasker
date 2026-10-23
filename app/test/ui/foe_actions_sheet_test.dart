import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/foe_actions_sheet.dart';
import 'package:material_ui/material_ui.dart';

Future<FoeAction?> _open(
  WidgetTester tester, {
  bool canPromise = false,
  bool canExtend = false,
  bool canTry = false,
  String? tap,
}) async {
  FoeAction? result;
  await tester.pumpWidget(
    MaterialApp(
      theme: buildTheme(),
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await showGlassFoeActions(
            context,
            title: 'Read chapter 4',
            canPromise: canPromise,
            canExtend: canExtend,
            canTry: canTry,
          ),
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  if (tap != null) {
    await tester.tap(find.text(tap));
    await tester.pumpAndSettle();
  }
  return result;
}

void main() {
  testWidgets('every task offers Edit and Delete; the title heads the sheet', (
    tester,
  ) async {
    await _open(tester);
    expect(find.text('Read chapter 4'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Promise by…'), findsNothing);
    expect(find.text('Move it later'), findsNothing);
    expect(find.text('Mark as tried'), findsNothing);
  });

  testWidgets('rows appear only when they apply', (tester) async {
    await _open(tester, canPromise: true, canExtend: true, canTry: true);
    expect(find.text('Promise by…'), findsOneWidget);
    expect(find.text('Move it later'), findsOneWidget);
    expect(find.text('Mark as tried'), findsOneWidget);
  });

  testWidgets('a row pops its action', (tester) async {
    expect(
      await _open(tester, canPromise: true, tap: 'Promise by…'),
      FoeAction.promise,
    );
    expect(
      await _open(tester, canTry: true, tap: 'Mark as tried'),
      FoeAction.tried,
    );
    expect(
      await _open(tester, canExtend: true, tap: 'Move it later'),
      FoeAction.extend,
    );
    expect(await _open(tester, tap: 'Edit'), FoeAction.edit);
    expect(await _open(tester, tap: 'Delete'), FoeAction.delete);
  });

  testWidgets('Cancel pops null', (tester) async {
    expect(await _open(tester, tap: 'Cancel'), isNull);
  });
}
