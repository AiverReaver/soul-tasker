import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/sync_sql.dart';

import 'data/harness.dart';
import 'features/pump.dart';

/// The Stage 1 gate (STAGE1_PLAN.md §10.3): fail, write a lesson, restart,
/// and see the lesson at the start of the next attempt. No network.
void main() {
  testWidgets('a lesson survives an app restart', (tester) async {
    final dir = Directory.systemTemp.createTempSync('hearthrise_gate');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/hearthrise.sqlite');

    // First run: create, strike, fail with a lesson.
    final first = Harness(NativeDatabase(file, setup: registerSyncFunctions));
    final view = await first.seed();
    await first.attempts.strike(taskNamed(view, 'Read chapter 4').task.id);
    await first.attempts.fall(view.boss.id, 'Rushed the second phase.');
    await first.db.close();

    // Second run: a new database on the same file, then the boss screen.
    final second = Harness(NativeDatabase(file, setup: registerSyncFunctions));
    await pumpApp(tester, second, location: '/boss/${view.boss.id}');

    expect(
      find.text('Attempt 2. Last time: Rushed the second phase.'),
      findsOneWidget,
    );
    final after = await second.reload(view.boss.id);
    expect(taskNamed(after, 'Read chapter 4').isStruck, isTrue);

    await tearDownApp(tester, second);
  });
}
