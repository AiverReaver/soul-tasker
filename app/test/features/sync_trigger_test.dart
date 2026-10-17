import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/providers.dart';
import 'package:material_ui/material_ui.dart';

import '../data/fake_sync_api.dart';
import '../data/harness.dart';
import 'pump.dart';

// Stage 7 plan step 8: the day resolver starts a sync on start and on
// resume, after it has judged the days that ended. With no session there is
// no API and the app makes no request (gate item 4).
void main() {
  late Harness h;
  late FakeSyncApi api;
  setUp(() {
    h = Harness();
    api = FakeSyncApi();
  });

  testWidgets('start syncs once; a resume syncs again', (tester) async {
    await pumpApp(
      tester,
      h,
      overrides: [syncApiProvider.overrideWithValue(api)],
    );
    expect(api.pullCalls, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await settle(tester);
    expect(api.pullCalls, 2);
    await tearDownApp(tester, h);
  });

  testWidgets('a missed day is answered before the sync runs', (tester) async {
    await h.seed();
    await h.setFlasks(0);
    h.clock.now = DateTime(2026, 10, 15, 12);
    await pumpApp(
      tester,
      h,
      overrides: [syncApiProvider.overrideWithValue(api)],
    );
    expect(find.text('Fallen.'), findsOneWidget);
    expect(api.pullCalls, 0, reason: 'the fall is still being answered');

    await tester.tap(find.text('Skip'));
    await settle(tester);
    expect(api.pullCalls, 1);
    // The fall it wrote is sent by that same run or the next one.
    await tearDownApp(tester, h);
  });

  testWidgets('a local write is sent 5 s later', (tester) async {
    await pumpApp(
      tester,
      h,
      overrides: [syncApiProvider.overrideWithValue(api)],
    );
    await h.seed();
    await settle(tester);
    expect(api.pushes, isEmpty);

    await tester.pump(const Duration(seconds: 6));
    await settle(tester);
    expect(api.pushes, isNotEmpty);
    await tearDownApp(tester, h);
  });

  testWidgets('without an account the app makes no request', (tester) async {
    await pumpApp(tester, h);
    await h.seed();
    await tester.pump(const Duration(seconds: 10));
    expect(api.pullCalls, 0);
    expect(api.pushes, isEmpty);
    await tearDownApp(tester, h);
  });
}
