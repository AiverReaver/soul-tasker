import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/boss_actions_sheet.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('The Day can only be edited or pinned', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: const Scaffold(
          body: BossActionsSheet(
            bossName: 'The Day',
            isActive: true,
            isWaiting: false,
            isPinned: false,
            isDay: true,
          ),
        ),
      ),
    );
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Pin'), findsOneWidget);
    for (final gone in [
      'Leave for now',
      'Declare victory',
      'This attempt failed',
    ]) {
      expect(find.text(gone), findsNothing);
    }
  });
}
