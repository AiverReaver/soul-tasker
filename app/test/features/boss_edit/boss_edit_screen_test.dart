import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/ui/glass_circle_button.dart';
import 'package:hearthrise/ui/phase_panel.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/harness.dart';
import '../pump.dart';

void main() {
  late Harness h;
  setUp(() => h = Harness());

  testWidgets('new mode: "A new boss", empty fields, one empty chapter', (
    tester,
  ) async {
    await pumpApp(tester, h, location: '/boss/new', tall: true);
    expect(find.text('A new boss'), findsOneWidget);
    expect(find.byType(PhasePanel, skipOffstage: false), findsOneWidget);
    final fields = tester.widgetList<TextField>(find.byType(TextField));
    expect(fields.every((f) => f.controller?.text.isEmpty ?? true), isTrue);
    expect(find.text('Delete boss', skipOffstage: false), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('edit mode loads the boss, its chapters and tasks', (
    tester,
  ) async {
    final view = await h.seed();
    await pumpApp(
      tester,
      h,
      location: '/boss/${view.boss.id}/edit',
      tall: true,
    );
    expect(find.text('Edit boss'), findsOneWidget);
    expect(find.text('The Certification'), findsOneWidget);
    expect(find.byType(PhasePanel, skipOffstage: false), findsNWidgets(2));
    expect(find.text('Read chapter 4'), findsOneWidget);
    expect(find.text('Delete boss', skipOffstage: false), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('Add a chapter adds a panel; Add a task opens the task sheet', (
    tester,
  ) async {
    final view = await h.seed();
    await pumpApp(
      tester,
      h,
      location: '/boss/${view.boss.id}/edit',
      tall: true,
    );
    await tester.ensureVisible(find.text('Add a chapter'));
    await tester.tap(find.text('Add a chapter'));
    await settle(tester);
    expect(find.byType(PhasePanel, skipOffstage: false), findsNWidgets(3));

    await tester.tap(find.text('Add a task').first);
    await settle(tester);
    expect(find.text('A new task'), findsOneWidget); // the task sheet
    await tearDownApp(tester, h);
  });

  testWidgets('tapping a task opens its sheet', (tester) async {
    final view = await h.seed();
    await pumpApp(
      tester,
      h,
      location: '/boss/${view.boss.id}/edit',
      tall: true,
    );
    await tester.tap(find.text('Read chapter 4'));
    await settle(tester);
    expect(find.text('Edit task'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('chapters reorder by the grip, and Save writes the order', (
    tester,
  ) async {
    final view = await h.seed();
    await pumpApp(
      tester,
      h,
      location: '/boss/${view.boss.id}/edit',
      tall: true,
    );
    final grip = find.byIcon(Icons.drag_handle).first;
    final gesture = await tester.startGesture(tester.getCenter(grip));
    await tester.pump(const Duration(milliseconds: 600));
    for (var i = 0; i < 20; i++) {
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await settle(tester);

    await tester.tap(find.text('Save'));
    await settle(tester);
    final saved = await h.reload(view.boss.id);
    expect(saved.phases.map((p) => p.phase.name), ['Fight', 'Learn']);
    await tearDownApp(tester, h);
  });

  testWidgets('back without saving changes nothing', (tester) async {
    final view = await h.seed();
    await pumpApp(
      tester,
      h,
      location: '/boss/${view.boss.id}/edit',
      tall: true,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'The Certification'),
      'Changed',
    );
    await tester.pump();
    await tester.tap(find.byType(GlassCircleButton).first);
    await settle(tester);
    expect((await h.reload(view.boss.id)).boss.title, 'The Certification');
    await tearDownApp(tester, h);
  });

  testWidgets('deleting a chapter with tasks, or the boss, asks first', (
    tester,
  ) async {
    final view = await h.seed();
    await pumpApp(
      tester,
      h,
      location: '/boss/${view.boss.id}/edit',
      tall: true,
    );

    await tester.tap(find.byTooltip('Delete chapter').first);
    await settle(tester);
    expect(find.textContaining('Delete this chapter'), findsOneWidget);
    await tester.tap(find.text('Not yet'));
    await settle(tester);
    expect(find.byType(PhasePanel, skipOffstage: false), findsNWidgets(2));

    await tester.scrollUntilVisible(
      find.text('Delete boss'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Delete boss'));
    await settle(tester);
    expect(find.textContaining('and all its history'), findsOneWidget);
    await tester.tap(find.text('Not yet'));
    await settle(tester);
    expect(await h.bosses.loadAll(), hasLength(1));
    await tearDownApp(tester, h);
  });
}
