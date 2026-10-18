import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/collapsible_section.dart';
import 'package:material_ui/material_ui.dart';

Widget _host({required bool isExpanded, required VoidCallback onToggle}) =>
    MaterialApp(
      theme: buildTheme(),
      home: Scaffold(
        body: CollapsibleSection(
          title: 'Waiting (2)',
          isExpanded: isExpanded,
          onToggle: onToggle,
          child: const Text('inside'),
        ),
      ),
    );

bool? _expanded(WidgetTester tester) => tester
    .getSemantics(find.bySemanticsLabel('Waiting (2)'))
    .getSemanticsData()
    .flagsCollection
    .isExpanded
    .toBoolOrNull();

void main() {
  testWidgets('collapsed: the child is hidden and the header says so', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(isExpanded: false, onToggle: () {}));
    expect(find.text('Waiting (2)'), findsOneWidget);
    expect(find.text('inside'), findsNothing);
    expect(_expanded(tester), isFalse);
    handle.dispose();
  });

  testWidgets('expanded: the child shows and the header says so', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(isExpanded: true, onToggle: () {}));
    expect(find.text('inside'), findsOneWidget);
    expect(_expanded(tester), isTrue);
    handle.dispose();
  });

  testWidgets('tapping the header asks to toggle', (tester) async {
    var toggles = 0;
    await tester.pumpWidget(
      _host(isExpanded: false, onToggle: () => toggles++),
    );
    await tester.tap(find.text('Waiting (2)'));
    expect(toggles, 1);
  });
}
