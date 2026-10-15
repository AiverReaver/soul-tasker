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
}
