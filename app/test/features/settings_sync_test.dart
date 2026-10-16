import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/providers.dart';
import 'package:hearthrise/data/sync_dao.dart';
import 'package:hearthrise_api/hearthrise_api.dart'
    show ChangeDto, ChangeDtoOpEnum;
import 'package:material_ui/material_ui.dart';

import '../data/fake_sync_api.dart';
import '../data/harness.dart';
import '../support/fake_account.dart';
import 'pump.dart';

// Stage 7 plan step 9: sign in, sign out, delete, and the sheets between.
void main() {
  late Harness h;
  late FakeAuthGateway gateway;
  late FakeAccountApi accounts;
  late FakeSyncApi server;

  setUp(() {
    h = Harness();
    gateway = FakeAuthGateway();
    accounts = FakeAccountApi();
    server = FakeSyncApi(now: () => DateTime.utc(2026, 10, 16));
  });

  Future<void> open(WidgetTester tester) async {
    // Tall enough that the whole Settings list is on screen.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(
      tester,
      h,
      overrides: [
        authGatewayProvider.overrideWithValue(gateway),
        accountApiProvider.overrideWithValue(accounts),
        syncApiFactoryProvider.overrideWithValue((_) => server),
      ],
    );
    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
    await tester.scrollUntilVisible(
      find.text('Back up and sync'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }

  Future<void> signIn(WidgetTester tester) async {
    await tester.tap(find.text('Sign in with Google'));
    await settle(tester);
  }

  Future<int> count(String table) async =>
      (await h.db.customSelect('SELECT COUNT(*) AS c FROM $table').getSingle())
              .data['c']!
          as int;

  Future<void> remoteBoss() => server.push('phone-b', [
    ChangeDto(
      table: 'bosses',
      id: 'remote-boss',
      op: ChangeDtoOpEnum.upsert,
      updatedAt: '2026-10-10T00:00:00.000Z',
      row: {
        'title': 'From phone B',
        'defeat_meaning': null,
        'status': 0,
        'attempt_number': 1,
        'reset_on_fail': 0,
        'is_pinned': false,
        'target_date': null,
        'last_fought_at': null,
        'open_from_attempt': 1,
        'created_at': '2026-10-10T00:00:00.000Z',
        'defeated_at': null,
      },
    ),
  ]);

  testWidgets('signed out, the app is as before and makes no request', (
    tester,
  ) async {
    await h.seed();
    await open(tester);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(gateway.token, isNull);
    expect(server.pullCalls, 0);
    expect(server.pushes, isEmpty);
    await tearDownApp(tester, h);
  });

  testWidgets(
    'signing in stores the token, queues every row, and runs a first sync',
    (tester) async {
      await h.seed();
      await open(tester);
      await signIn(tester);

      expect(gateway.token, 'session-1');
      expect(find.text('ash@example.com'), findsOneWidget);
      expect(find.text('Sign in with Google'), findsNothing);
      // Every local boss, phase and task reached the server.
      expect(server.liveIds('bosses'), hasLength(1));
      expect(server.liveIds('tasks'), hasLength(await count('tasks')));
      expect(await SyncDao(h.db).pending(), isEmpty);
      final state = await h.db.select(h.db.syncState).getSingle();
      expect(state.accountEmail, 'ash@example.com');
      expect(state.lastAccountId, 'user-ash');
      expect(state.sessionEnded, isFalse);
      await tearDownApp(tester, h);
    },
  );

  testWidgets(
    'if the app stops between push and pull, the next run finishes the job',
    (tester) async {
      await h.seed();
      await remoteBoss();
      server.pushes.clear();
      // The push goes through; the pull that follows fails.
      server.duringPush = () async => server.failCalls = 1;
      await open(tester);
      await signIn(tester);

      expect(server.liveIds('bosses'), hasLength(2));
      expect(await count('bosses'), 1, reason: 'the pull has not run yet');

      // The failed run backs off 30 s, then pulls.
      await tester.pump(const Duration(seconds: 31));
      await settle(tester);
      expect(await count('bosses'), 2);
      expect(server.liveIds('bosses'), hasLength(2), reason: 'no duplicates');
      await tearDownApp(tester, h);
    },
  );

  testWidgets('an account that has bosses shows the merge notice once', (
    tester,
  ) async {
    await h.seed();
    await remoteBoss();
    await open(tester);
    await signIn(tester);

    expect(
      find.text('This account has data from another phone. Both will be kept.'),
      findsOneWidget,
    );
    await tester.tap(find.text('OK'));
    await settle(tester);
    expect(await count('bosses'), 2);

    await tester.tap(find.text('Sign out'));
    await settle(tester);
    await signIn(tester);
    expect(find.textContaining('Both will be kept'), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('sign out forgets the token, empties the outbox, keeps data', (
    tester,
  ) async {
    await h.seed();
    await open(tester);
    await signIn(tester);
    final before = await count('bosses');
    // A write the next run would have sent.
    await h.db.customStatement("UPDATE bosses SET title = 'Edited'");
    expect(await SyncDao(h.db).pending(), isNotEmpty);

    await tester.tap(find.text('Sign out'));
    await settle(tester);

    expect(gateway.token, isNull);
    expect(gateway.googleSignOuts, 1);
    expect(accounts.calls, contains('signOut:session-1'));
    expect(await SyncDao(h.db).pending(), isEmpty);
    final state = await h.db.select(h.db.syncState).getSingle();
    expect(state.cursor, 0);
    expect(state.accountEmail, isNull);
    expect(state.lastAccountId, 'user-ash');
    expect(await count('bosses'), before);
    expect(find.text('Sign in with Google'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('signing back in to the same account shows no sheet', (
    tester,
  ) async {
    await h.seed();
    await open(tester);
    await signIn(tester);
    await tester.tap(find.text('Sign out'));
    await settle(tester);
    await signIn(tester);

    expect(find.textContaining('Back up this phone'), findsNothing);
    expect(find.text('ash@example.com'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('a different account asks first; cancel queues nothing', (
    tester,
  ) async {
    await h.seed();
    await open(tester);
    await signIn(tester);
    await tester.tap(find.text('Sign out'));
    await settle(tester);

    gateway.idToken = 'google-token-bo';
    await signIn(tester);
    expect(
      find.text("Back up this phone's data to bo@example.com?"),
      findsOneWidget,
    );
    await tester.tap(find.text('Not yet'));
    await settle(tester);

    expect(gateway.token, isNull);
    expect(await SyncDao(h.db).pending(), isEmpty);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(accounts.calls.last, startsWith('signOut:'), reason: 'revoked');

    await signIn(tester);
    await tester.tap(find.text('Back up'));
    await settle(tester);
    expect(find.text('bo@example.com'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('after the session ended elsewhere, signing in asks first', (
    tester,
  ) async {
    final boss = (await h.seed()).boss;
    await open(tester);
    await signIn(tester);
    // Another phone deleted the account: the next sync gets a 401.
    server.unauthorized = true;
    await h.bosses.setPinned(boss.id, isPinned: true);
    await tester.pump(const Duration(seconds: 6));
    await settle(tester);

    expect(gateway.token, isNull, reason: 'the dead session is forgotten');
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(await count('bosses'), 1, reason: 'local data is kept');

    server.unauthorized = false;
    await signIn(tester);
    expect(find.textContaining("Back up this phone's data to"), findsOneWidget);
    await tester.tap(find.text('Not yet'));
    await settle(tester);
    await tearDownApp(tester, h);
  });

  testWidgets('delete account asks, calls the API, and keeps local data', (
    tester,
  ) async {
    await h.seed();
    await open(tester);
    await signIn(tester);
    final before = await count('bosses');

    await tester.tap(find.text('Delete account'));
    await settle(tester);
    expect(find.textContaining('Delete your account'), findsOneWidget);
    await tester.tap(find.text('Not yet'));
    await settle(tester);
    expect(accounts.calls.where((c) => c.startsWith('delete')), isEmpty);

    await tester.tap(find.text('Delete account'));
    await settle(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await settle(tester);

    expect(accounts.calls, contains('delete:session-1'));
    expect(gateway.token, isNull);
    expect(await count('bosses'), before);
    expect(find.text('Sign in with Google'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('a failed sign-in says so quietly and changes nothing', (
    tester,
  ) async {
    await h.seed();
    await open(tester);
    final queued = (await SyncDao(h.db).pending()).length;
    accounts.failSignIn = true;
    await signIn(tester);

    expect(find.text('Could not sign in. Nothing changed.'), findsOneWidget);
    expect(gateway.token, isNull);
    expect((await SyncDao(h.db).pending()).length, queued);
    expect(server.pushes, isEmpty);

    gateway.fails = true;
    await signIn(tester);
    expect(find.text('Could not sign in. Nothing changed.'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('backing out of the Google sheet does nothing', (tester) async {
    await h.seed();
    await open(tester);
    gateway.idToken = null;
    await signIn(tester);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(accounts.calls, isEmpty);
    expect(find.textContaining('Could not sign in'), findsNothing);
    await tearDownApp(tester, h);
  });
}
