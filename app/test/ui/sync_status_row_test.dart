import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/notice_dialog.dart';
import 'package:hearthrise/ui/sync_status_row.dart';
import 'package:material_ui/material_ui.dart';

final _now = DateTime(2026, 10, 16, 12);

Widget _app(Widget child, {double textScale = 1}) => MaterialApp(
  theme: buildTheme(),
  home: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
    child: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

SyncStatusRow _row({
  String? email,
  DateTime? lastSyncAt,
  bool hasError = false,
  int notBackedUp = 0,
  bool isBusy = false,
  VoidCallback? onSignIn,
  VoidCallback? onSignOut,
  VoidCallback? onDelete,
}) => SyncStatusRow(
  email: email,
  lastSyncAt: lastSyncAt,
  now: _now,
  hasError: hasError,
  notBackedUp: notBackedUp,
  isBusy: isBusy,
  onSignIn: onSignIn ?? () {},
  onSignOut: onSignOut ?? () {},
  onDelete: onDelete ?? () {},
);

void main() {
  testWidgets('signed out: offers backup and sign-in only', (tester) async {
    var signIns = 0;
    await tester.pumpWidget(_app(_row(onSignIn: () => signIns++)));
    expect(find.text('Back up and sync'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text('Sign out'), findsNothing);
    expect(find.text('Delete account'), findsNothing);

    await tester.tap(find.text('Sign in with Google'));
    expect(signIns, 1);
  });

  testWidgets('signed in: email and when it last synced', (tester) async {
    await tester.pumpWidget(
      _app(
        _row(
          email: 'ash@example.com',
          lastSyncAt: _now.subtract(const Duration(minutes: 2)),
        ),
      ),
    );
    expect(find.text('ash@example.com'), findsOneWidget);
    expect(find.text('Last synced 2 min ago'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsNothing);
  });

  testWidgets('says so when it has never synced or cannot reach the server', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_row(email: 'a@b.c')));
    expect(find.text('Not synced yet'), findsOneWidget);

    await tester.pumpWidget(
      _app(
        _row(
          email: 'a@b.c',
          hasError: true,
          lastSyncAt: _now.subtract(const Duration(hours: 3)),
        ),
      ),
    );
    expect(find.text('Waiting for a connection'), findsOneWidget);
    expect(find.textContaining('Last synced'), findsNothing);
  });

  testWidgets('counts items that could not be backed up', (tester) async {
    await tester.pumpWidget(_app(_row(email: 'a@b.c', notBackedUp: 3)));
    expect(find.text('3 items not backed up'), findsOneWidget);
    await tester.pumpWidget(_app(_row(email: 'a@b.c', notBackedUp: 1)));
    expect(find.text('1 item not backed up'), findsOneWidget);
    await tester.pumpWidget(_app(_row(email: 'a@b.c')));
    expect(find.textContaining('not backed up'), findsNothing);
  });

  testWidgets('sign out and delete fire their callbacks', (tester) async {
    var out = 0;
    var del = 0;
    await tester.pumpWidget(
      _app(_row(email: 'a@b.c', onSignOut: () => out++, onDelete: () => del++)),
    );
    await tester.tap(find.text('Sign out'));
    await tester.tap(find.text('Delete account'));
    expect([out, del], [1, 1]);
  });

  testWidgets('while busy the buttons do nothing', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_app(_row(isBusy: true, onSignIn: () => taps++)));
    await tester.tap(find.text('Sign in with Google'));
    expect(taps, 0);
  });

  testWidgets('targets are at least 48 dp', (tester) async {
    await tester.pumpWidget(_app(_row(email: 'a@b.c')));
    for (final label in ['Sign out', 'Delete account']) {
      final size = tester.getSize(
        find.ancestor(of: find.text(label), matching: find.byType(TextButton)),
      );
      expect(size.height, greaterThanOrEqualTo(48), reason: label);
      expect(size.width, greaterThanOrEqualTo(48), reason: label);
    }
  });

  for (final signedIn in [false, true]) {
    testWidgets(
      'no overflow at 320 x 568 and 200% text (signed ${signedIn ? 'in' : 'out'})',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          _app(
            _row(
              email: signedIn ? 'a.very.long.address@example-domain.com' : null,
              lastSyncAt: _now.subtract(const Duration(minutes: 2)),
              notBackedUp: 12,
            ),
            textScale: 2,
          ),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  group('NoticeDialog', () {
    testWidgets('shows the message and closes on its one button', (
      tester,
    ) async {
      var closed = 0;
      await tester.pumpWidget(
        _app(
          NoticeDialog(message: 'Both will be kept.', onClose: () => closed++),
        ),
      );
      expect(find.text('Both will be kept.'), findsOneWidget);
      await tester.tap(find.text('OK'));
      expect(closed, 1);
    });
  });
}
