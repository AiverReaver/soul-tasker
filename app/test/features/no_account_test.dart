import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/providers.dart';
import 'package:material_ui/material_ui.dart';

import '../data/fake_sync_api.dart';
import '../data/harness.dart';
import '../support/fake_account.dart';
import 'pump.dart';

// Stage 7 gate item 4: with no account the app makes no call on the API.
// The fakes are wired as they would be with a server, but no one signs in.
void main() {
  testWidgets('start, strike and fall make no request', (tester) async {
    final h = Harness();
    final server = FakeSyncApi();
    final accounts = FakeAccountApi();
    final gateway = FakeAuthGateway();
    final view = await h.seed(reset: ResetOnFail.nothing);
    await h.setFlasks(0);

    await pumpApp(
      tester,
      h,
      tall: true,
      overrides: [
        authGatewayProvider.overrideWithValue(gateway),
        accountApiProvider.overrideWithValue(accounts),
        syncApiFactoryProvider.overrideWithValue((_) => server),
      ],
    );

    // Strike a task and fall the boss through the app's DAOs, as the screens
    // do, and let every timer a write could start run out.
    final task = view.phases.first.tasks.first.task.id;
    await h.attempts.strike(task);
    await h.attempts.failBoss(view.boss.id, FallCause.declared, null);
    await tester.pump(const Duration(seconds: 30));
    await settle(tester);

    expect(server.pullCalls, 0);
    expect(server.pushes, isEmpty);
    expect(accounts.calls, isEmpty);
    expect(gateway.token, isNull);
    expect(find.byType(Scaffold), findsWidgets);

    // Opening Settings shows the offer and still sends nothing.
    await tester.tap(find.bySemanticsLabel('Settings'));
    await settle(tester);
    expect(find.text('Back up and sync'), findsOneWidget);
    expect(server.pullCalls, 0);
    expect(server.pushes, isEmpty);
    await tearDownApp(tester, h);
  });
}
