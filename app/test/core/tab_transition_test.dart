import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hearthrise/core/tab_transition.dart';
import 'package:material_ui/material_ui.dart';

GoRoute _tab(String path, String label) => GoRoute(
  path: path,
  pageBuilder: (_, state) => tabPage(state.pageKey, Text(label)),
);

void main() {
  testWidgets('switching tabs cross-fades instead of snapping', (tester) async {
    final router = GoRouter(routes: [_tab('/', 'one'), _tab('/two', 'two')]);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    expect(find.text('one'), findsOneWidget);

    router.go('/two');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    // Mid-move: both pages are alive and the new one is not yet opaque.
    expect(find.text('one'), findsOneWidget);
    expect(find.text('two'), findsOneWidget);
    final fade = tester.widget<FadeTransition>(
      find
          .ancestor(of: find.text('two'), matching: find.byType(FadeTransition))
          .first,
    );
    expect(fade.opacity.value, inExclusiveRange(0, 1));

    await tester.pumpAndSettle();
    expect(find.text('one'), findsNothing);
    expect(find.text('two'), findsOneWidget);
  });
}
