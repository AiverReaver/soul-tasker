import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/visit_dao.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import 'pump.dart';

void main() {
  late Harness h;
  setUp(() => h = Harness());

  Future<List<String>> days() => VisitDao(h.db, h.clock.call).days();

  /// Steps through every state, as `AppLifecycleListener` demands.
  void walk(WidgetTester tester, List<AppLifecycleState> states) {
    for (final s in states) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
  }

  const away = [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
  ];
  const back = [
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ];

  testWidgets('opening the app records today', (tester) async {
    await pumpApp(tester, h);
    expect(await days(), ['2026-10-13']);
    await tearDownApp(tester, h);
  });

  testWidgets('a resume on the next day records that day', (tester) async {
    await pumpApp(tester, h);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    h.clock.now = DateTime(2026, 10, 14, 12);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await settle(tester);

    expect(await days(), ['2026-10-13', '2026-10-14']);
    await tearDownApp(tester, h);
  });

  testWidgets('pausing records nothing', (tester) async {
    await pumpApp(tester, h);
    h.clock.now = DateTime(2026, 10, 14, 12);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await settle(tester);

    expect(await days(), ['2026-10-13']);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tearDownApp(tester, h);
  });

  testWidgets('a resume while the fallen moment is open still counts', (
    tester,
  ) async {
    await h.seed();
    await (h.db.update(h.db.settings))
        .write(const SettingsCompanion(flasks: Value(0)));
    h.clock.now = DateTime(2026, 10, 15, 12); // the 14th was missed
    await pumpApp(tester, h);
    expect(find.text('Fallen.'), findsOneWidget);

    walk(tester, away);
    h.clock.now = DateTime(2026, 10, 16, 12);
    walk(tester, back);
    await settle(tester);

    expect(await days(), ['2026-10-15', '2026-10-16']);
    await tearDownApp(tester, h);
  });
}
