import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/ui/boss_card_actions_sheet.dart';
import 'package:hearthrise/ui/glass_sheet.dart';

import 'glass_host.dart';

void main() {
  testWidgets('a glass sheet with pin and the status change', (tester) async {
    await tester.pumpWidget(
      glassHost(
        const BossCardActionsSheet(
          title: 'Run a 10K',
          isPinned: false,
          statusLabel: 'Set waiting',
        ),
      ),
    );
    expect(find.byType(GlassSheet), findsOneWidget);
    expect(find.text('Run a 10K'), findsOneWidget);
    expect(find.text('Pin'), findsOneWidget);
    expect(find.text('Set waiting'), findsOneWidget);
  });

  testWidgets('no status row when there is none to offer', (tester) async {
    await tester.pumpWidget(
      glassHost(
        const BossCardActionsSheet(title: 'The Day', isPinned: true),
      ),
    );
    expect(find.text('Unpin'), findsOneWidget);
    expect(find.textContaining('Set '), findsNothing);
  });
}
