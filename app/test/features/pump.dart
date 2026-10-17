import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/app.dart';
import 'package:hearthrise/core/clock.dart';
import 'package:hearthrise/data/providers.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import '../support/fake_reminders.dart';

// The in-memory database runs synchronously on this isolate, so its futures
// complete as microtasks inside the widget test's fake async zone. Do not
// wrap database calls in tester.runAsync: that crosses zones and hangs.

/// Pumps the whole app on [location] against [h]'s database and clock.
Future<void> pumpApp(
  WidgetTester tester,
  Harness h, {
  String location = '/',
  List<Override> overrides = const [],
  FakeReminders? reminders,

  /// Existing installs skip onboarding; pass false to see it, or null to
  /// leave what is stored (Stage 5 D11).
  bool? onboarded = true,

  /// A phone-sized, tall surface for Home, whose header and Today list need
  /// more room than the default 800 x 600 landscape stub.
  bool tall = false,
}) async {
  if (tall) {
    tester.view
      ..physicalSize = const Size(900, 1800)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }
  if (onboarded != null) await h.settings.setOnboarded(onboarded);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(h.db),
        clockProvider.overrideWithValue(h.clock.call),
        (reminders ?? FakeReminders()).asOverride, // never the real plugin
        ...overrides,
      ],
      // Still: a looping backdrop would never let pumpAndSettle finish.
      child: HearthriseApp(initialLocation: location, isAmbient: false),
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
