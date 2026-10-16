import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/clock.dart';
import '../../data/account_api.dart';
import '../../data/account_service.dart';
import '../../data/providers.dart';
import '../../ui/confirm_dialog.dart';
import '../../ui/flash_line.dart';
import '../../ui/notice_dialog.dart';
import '../../ui/sync_status_row.dart';

/// "Back up and sync" in Settings (Stage 7 plan step 9): a thin container
/// over `AccountService` that asks the questions and shows the answer.
class SyncSection extends ConsumerStatefulWidget {
  const SyncSection({super.key});

  @override
  ConsumerState<SyncSection> createState() => _SyncSectionState();
}

class _SyncSectionState extends ConsumerState<SyncSection> {
  bool _isBusy = false;
  String? _flash;

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _isBusy = true;
      _flash = null;
    });
    try {
      await action();
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _signIn() => _run(() async {
    final result = await ref
        .read(accountServiceProvider)
        .signIn(
          confirmBackup: (email) async =>
              await showDialog<bool>(
                context: context,
                builder: (_) => ConfirmDialog(
                  question: "Back up this phone's data to $email?",
                  action: 'Back up',
                ),
              ) ??
              false,
        );
    if (!mounted) return;
    if (result.outcome == SignInOutcome.failed) {
      setState(() => _flash = 'Could not sign in. Nothing changed.');
    } else if (result.outcome == SignInOutcome.unavailable) {
      setState(() => _flash = 'Sign-in is not available in this build.');
    }
    if (result.showMergeNotice) {
      await showDialog<void>(
        context: context,
        builder: (dialog) => NoticeDialog(
          message:
              'This account has data from another phone. Both will be kept.',
          onClose: () => Navigator.pop(dialog),
        ),
      );
    }
  });

  Future<void> _signOut() =>
      _run(() => ref.read(accountServiceProvider).signOut());

  Future<void> _delete() async {
    final isSure =
        await showDialog<bool>(
          context: context,
          builder: (_) => const ConfirmDialog(
            question:
                'Delete your account? Everything backed up is removed. '
                'This phone keeps its data.',
            action: 'Delete',
          ),
        ) ??
        false;
    if (!isSure || !mounted) return;
    await _run(() async {
      try {
        await ref.read(accountServiceProvider).deleteAccount();
      } on AccountException {
        if (mounted) {
          setState(() => _flash = 'Could not delete the account. Try again.');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final state = ref.watch(_syncStateProvider).value;
    final parked = ref.watch(_parkedCountProvider).value ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SyncStatusRow(
          email: session == null
              ? null
              : (state?.accountEmail ?? session.email),
          lastSyncAt: state?.lastSyncAt,
          now: ref.read(clockProvider)(),
          hasError: state?.lastError != null,
          notBackedUp: parked,
          isBusy: _isBusy,
          onSignIn: _signIn,
          onSignOut: _signOut,
          onDelete: _delete,
        ),
        FlashLine(_flash),
      ],
    );
  }
}

final _syncStateProvider = StreamProvider(
  (ref) => ref
      .watch(databaseProvider)
      .select(ref.watch(databaseProvider).syncState)
      .watchSingle(),
);

final _parkedCountProvider = StreamProvider((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.syncOutbox)..where((e) => e.rejectedReason.isNotNull()))
      .watch()
      .map((rows) => rows.length);
});
