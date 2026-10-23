import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/ui/glass_sheet.dart';
import 'package:material_ui/material_ui.dart';

import 'glass_host.dart';

void main() {
  Future<void> open(
    WidgetTester tester,
    Widget content, {
    double text = 1,
  }) async {
    await tester.pumpWidget(
      glassHost(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showGlassSheet<void>(context, (_) => content),
            child: const Text('open'),
          ),
        ),
        text: text,
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the label, title, grabber and a Cancel pill', (
    tester,
  ) async {
    await open(
      tester,
      const GlassSheet(
        label: 'Boss actions',
        title: 'The Thesis Warden',
        child: Text('body'),
      ),
    );
    expect(find.text('BOSS ACTIONS'), findsOneWidget);
    expect(find.text('The Thesis Warden'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.byKey(const ValueKey('glass-grabber')), findsOneWidget);
    expect(find.text('body'), findsOneWidget);
  });

  testWidgets('the Cancel pill pops the sheet', (tester) async {
    await open(tester, const GlassSheet(title: 'T', child: SizedBox()));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(GlassSheet), findsNothing);
  });

  testWidgets('closeLabel renames the pill', (tester) async {
    await open(
      tester,
      const GlassSheet(title: 'T', closeLabel: 'Close', child: SizedBox()),
    );
    expect(find.text('Close'), findsOneWidget);
  });

  testWidgets('tall content scrolls at 200% text', (tester) async {
    await open(
      tester,
      GlassSheet(
        title: 'T',
        child: Column(children: [for (var i = 0; i < 40; i++) Text('row $i')]),
      ),
      text: 2,
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsWidgets);
    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(0, -300),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
