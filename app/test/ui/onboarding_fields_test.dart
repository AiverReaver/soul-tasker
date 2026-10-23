import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/onboarding_fields.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: buildTheme(),
    home: Scaffold(body: child),
  ),
);

NameListEditor _editor(
  List<NameListItem> items, {
  void Function(int, String)? onChanged,
  ValueChanged<int>? onRemove,
  VoidCallback? onAdd,
  int? autofocusId,
  String? help,
}) => NameListEditor(
  items: items,
  keyPrefix: 'row',
  hint: 'Name',
  removeLabel: 'Remove row',
  addLabel: 'Add a row',
  max: 2,
  onChanged: onChanged ?? (_, _) {},
  onRemove: onRemove ?? (_) {},
  onAdd: onAdd ?? () {},
  autofocusId: autofocusId,
  help: help,
);

void main() {
  testWidgets('LineField reports edits', (tester) async {
    String? seen;
    await _pump(
      tester,
      LineField(label: 'The boss', hint: 'Goal', onChanged: (t) => seen = t),
    );
    expect(find.text('The boss'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Garage');
    expect(seen, 'Garage');
  });

  testWidgets('NameListEditor shows its help line and numbers the rows', (
    tester,
  ) async {
    await _pump(
      tester,
      _editor([
        NameListItem(id: 1, text: 'a'),
        NameListItem(id: 2, text: 'b'),
      ], help: 'Two or three is plenty.'),
    );
    expect(find.text('Two or three is plenty.'), findsOneWidget);
    expect(find.text('I'), findsOneWidget);
    expect(find.text('II'), findsOneWidget);
  });

  testWidgets('NameListEditor edits, removes and adds', (tester) async {
    (int, String)? edited;
    int? removed;
    var added = 0;
    await _pump(
      tester,
      _editor(
        const [NameListItem(id: 7, text: 'One')],
        onChanged: (id, t) => edited = (id, t),
        onRemove: (id) => removed = id,
        onAdd: () => added++,
      ),
    );
    await tester.enterText(find.text('One'), 'Uno');
    expect(edited, (7, 'Uno'));
    await tester.tap(find.byTooltip('Remove row 1'));
    expect(removed, 7);
    await tester.tap(find.text('Add a row'));
    expect(added, 1);
  });

  testWidgets('NameListEditor hides Add at the maximum', (tester) async {
    await _pump(
      tester,
      _editor(const [
        NameListItem(id: 0, text: 'a'),
        NameListItem(id: 1, text: 'b'),
      ]),
    );
    expect(find.text('Add a row'), findsNothing);
  });

  testWidgets('NameListEditor focuses the row named by autofocusId', (
    tester,
  ) async {
    await _pump(
      tester,
      _editor(const [
        NameListItem(id: 0, text: 'a'),
        NameListItem(id: 1, text: ''),
      ], autofocusId: 1),
    );
    await tester.pump();
    final focused = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const ValueKey('row-1')),
        matching: find.byType(EditableText),
      ),
    );
    expect(focused.focusNode.hasFocus, isTrue);
  });
}
