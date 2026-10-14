import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/app.dart';
import 'package:hearthrise/core/clock.dart';
import 'package:hearthrise/data/providers.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';

// The in-memory database runs synchronously on this isolate, so its futures
// complete as microtasks inside the widget test's fake async zone. Do not
// wrap database calls in tester.runAsync: that crosses zones and hangs.

/// Pumps the whole app on [location] against [h]'s database and clock.
Future<void> pumpApp(
  WidgetTester tester,
  Harness h, {
  String location = '/',
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(h.db),
        clockProvider.overrideWithValue(h.clock.call),
        ...overrides,
      ],
      child: HearthriseApp(initialLocation: location),
    ),
  );
  await settle(tester);
}

/// Lets database futures and streams run, then settles frames.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 10));
  }
  await tester.pumpAndSettle();
}

/// Unmounts the app so stream subscriptions close, then closes the database.
Future<void> tearDownApp(WidgetTester tester, Harness h) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 10));
  await h.db.close();
}
