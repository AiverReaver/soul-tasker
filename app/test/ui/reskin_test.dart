import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/check_in.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/check_in_card.dart';
import 'package:hearthrise/ui/choice_dialog.dart';
import 'package:hearthrise/ui/confirm_dialog.dart';
import 'package:hearthrise/ui/glass_alert.dart';
import 'package:hearthrise/ui/needle_frame.dart';
import 'package:hearthrise/ui/notice_dialog.dart';
import 'package:hearthrise/ui/reminder_invite.dart';
import 'package:hearthrise/ui/sync_status_row.dart';
import 'package:material_ui/material_ui.dart';

import 'glass_host.dart';

void main() {
  group('dialogs sit on GlassAlert', () {
    testWidgets('ConfirmDialog: action first, Not yet pops false', (
      tester,
    ) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(),
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async => result = await showDialog<bool>(
                context: context,
                builder: (_) => const ConfirmDialog(
                  question: 'Delete it?',
                  action: 'Delete',
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(GlassAlert), findsOneWidget);
      expect(find.text('Delete it?'), findsOneWidget);
      await tester.tap(find.text('Not yet'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });

    testWidgets('NoticeDialog: OK fires onClose', (tester) async {
      var closed = 0;
      await tester.pumpWidget(
        glassHost(NoticeDialog(message: 'Saved.', onClose: () => closed++)),
      );
      expect(find.byType(GlassAlert), findsOneWidget);
      await tester.tap(find.text('OK'));
      expect(closed, 1);
    });

    testWidgets('ChoiceDialog: framed options report the pick', (tester) async {
      int? picked;
      await tester.pumpWidget(
        glassHost(
          ChoiceDialog<int>(
            title: 'Day starts at',
            options: const {0: '12:00 AM', 2: '2:00 AM'},
            onPicked: (v) => picked = v,
          ),
        ),
      );
      expect(find.byType(GlassAlert), findsOneWidget);
      expect(find.byType(NeedleFrame), findsNWidgets(2));
      await tester.tap(find.text('2:00 AM'));
      expect(picked, 2);
    });

    testWidgets('ReminderInvite: accept and decline', (tester) async {
      var yes = 0, no = 0;
      await tester.pumpWidget(
        glassHost(ReminderInvite(onAccept: () => yes++, onDecline: () => no++)),
      );
      expect(find.byType(GlassAlert), findsOneWidget);
      await tester.tap(find.text('Yes, remind me'));
      await tester.tap(find.text('Not now'));
      expect((yes, no), (1, 1));
    });
  });

  testWidgets('CheckInCard is a needle-cut panel', (tester) async {
    await tester.pumpWidget(
      glassHost(CheckInCard(onAnswer: (_) {}, onDismiss: () {})),
    );
    expect(find.byType(NeedleFrame), findsWidgets);
    CheckInAnswer? got;
    await tester.pumpWidget(
      glassHost(CheckInCard(onAnswer: (a) => got = a, onDismiss: () {})),
    );
    await tester.tap(find.text('Never'));
    expect(got, CheckInAnswer.never);
  });

  testWidgets('SyncStatusRow sits in a needle frame', (tester) async {
    await tester.pumpWidget(
      glassHost(
        SyncStatusRow(
          email: null,
          lastSyncAt: null,
          now: DateTime(2026, 10, 14),
          hasError: false,
          notBackedUp: 0,
          isBusy: false,
          onSignIn: () {},
          onSignOut: () {},
          onDelete: () {},
        ),
      ),
    );
    expect(find.byType(NeedleFrame), findsOneWidget);
  });

  testWidgets('system pickers take the palette', (tester) async {
    for (final b in Biome.values) {
      final t = buildTheme(b);
      expect(t.timePickerTheme.backgroundColor, b.palette.shell);
      expect(t.datePickerTheme.backgroundColor, b.palette.shell);
    }
  });
}
