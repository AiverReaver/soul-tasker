import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/ui/needle_frame.dart';
import 'package:hearthrise/ui/phase_panel.dart';
import 'package:material_ui/material_ui.dart';

import 'glass_host.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    ValueChanged<String>? onRename,
    VoidCallback? onDelete,
    VoidCallback? onAddFoe,
    ValueChanged<int>? onEditFoe,
  }) => tester.pumpWidget(
    glassHost(
      ReorderableListView(
        buildDefaultDragHandles: false,
        onReorderItem: (_, _) {},
        children: [
          PhasePanel(
            key: const ValueKey('p'),
            index: 0,
            name: 'Learn',
            foes: const [
              PhaseFoe(title: 'Read chapter 4', note: 'Heavy'),
              PhaseFoe(title: 'Walk', note: 'Light · daily'),
            ],
            onRename: onRename ?? (_) {},
            onDelete: onDelete ?? () {},
            onAddFoe: onAddFoe ?? () {},
            onEditFoe: onEditFoe ?? (_) {},
          ),
        ],
      ),
    ),
  );

  testWidgets('a framed panel: name, grip, tasks with notes, Add a task', (
    tester,
  ) async {
    await pump(tester);
    // the panel, then one framed row per task
    expect(find.byType(NeedleFrame), findsNWidgets(3));
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
    expect(find.byIcon(Icons.drag_handle), findsOneWidget);
    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('Read chapter 4'), findsOneWidget);
    expect(find.text('Light · daily'), findsOneWidget);
    expect(find.text('Add a task'), findsOneWidget);
  });

  testWidgets('callbacks: rename, delete, add a task, edit a task', (
    tester,
  ) async {
    String? renamed;
    var deleted = 0, added = 0;
    int? edited;
    await pump(
      tester,
      onRename: (n) => renamed = n,
      onDelete: () => deleted++,
      onAddFoe: () => added++,
      onEditFoe: (i) => edited = i,
    );
    await tester.enterText(find.byType(TextFormField), 'Fight');
    await tester.tap(find.byTooltip('Delete chapter'));
    await tester.tap(find.text('Add a task'));
    await tester.tap(find.text('Walk'));
    expect((renamed, deleted, added, edited), ('Fight', 1, 1, 1));
  });
}
