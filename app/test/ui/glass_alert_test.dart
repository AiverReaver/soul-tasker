import 'dart:ui' show SemanticsRole;

import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/ui/glass_alert.dart';
import 'package:material_ui/material_ui.dart';

import 'glass_host.dart';

void main() {
  int? result;
  var done = false;
  Future<void> open(WidgetTester tester) async {
    result = null;
    done = false;
    await tester.pumpWidget(
      glassHost(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showGlassAlert(
                context,
                label: 'The Thesis Warden',
                title: 'Leave the fight?',
                body: 'Struck tasks stay struck.',
                actions: const ['Keep fighting', 'Leave for now'],
              );
              done = true;
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the label, title, body and both actions', (tester) async {
    await open(tester);
    expect(find.text('THE THESIS WARDEN'), findsOneWidget);
    expect(find.text('Leave the fight?'), findsOneWidget);
    expect(find.text('Struck tasks stay struck.'), findsOneWidget);
    expect(find.text('Keep fighting'), findsOneWidget);
    expect(find.text('Leave for now'), findsOneWidget);
  });

  testWidgets('is an alert dialog', (tester) async {
    await open(tester);
    final data = tester
        .getSemantics(find.byKey(const ValueKey('glass-alert')))
        .getSemanticsData();
    expect(data.role, SemanticsRole.alertDialog);
  });

  testWidgets('an action pops its index', (tester) async {
    await open(tester);
    await tester.tap(find.text('Leave for now'));
    await tester.pumpAndSettle();
    expect(done, isTrue);
    expect(result, 1);
  });

  testWidgets('the first action is index 0', (tester) async {
    await open(tester);
    await tester.tap(find.text('Keep fighting'));
    await tester.pumpAndSettle();
    expect(result, 0);
  });

  testWidgets('a tap outside pops null', (tester) async {
    await open(tester);
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(done, isTrue);
    expect(result, isNull);
  });
}
