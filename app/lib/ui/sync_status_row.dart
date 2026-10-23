import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// The "Back up and sync" block in Settings (Stage 7 plan D1, step 9):
/// an offer to sign in, or the account, when it last synced, and the ways
/// out. Values and callbacks only.
class SyncStatusRow extends StatelessWidget {
  const SyncStatusRow({
    super.key,
    required this.email,
    required this.lastSyncAt,
    required this.now,
    required this.hasError,
    required this.notBackedUp,
    required this.isBusy,
    required this.onSignIn,
    required this.onSignOut,
    required this.onDelete,
  });

  /// Null when signed out.
  final String? email;
  final DateTime? lastSyncAt;
  final DateTime now;

  /// The last run could not reach the server.
  final bool hasError;

  /// Entries the server refused (plan D14).
  final int notBackedUp;

  /// A sign-in or deletion is under way.
  final bool isBusy;
  final VoidCallback onSignIn;
  final VoidCallback onSignOut;
  final VoidCallback onDelete;

  static const _minTarget = Size(48, 48);

  /// "just now", "2 min ago", "3 h ago", "2 d ago".
  static String ago(DateTime then, DateTime now) {
    final d = now.difference(then);
    if (d.inMinutes < 1) return 'just now';
    if (d.inHours < 1) return '${d.inMinutes} min ago';
    if (d.inDays < 1) return '${d.inHours} h ago';
    return '${d.inDays} d ago';
  }

  String get _status {
    if (hasError) return 'Waiting for a connection';
    final at = lastSyncAt;
    return at == null ? 'Not synced yet' : 'Last synced ${ago(at, now)}';
  }

  Widget _button(String label, VoidCallback onTap) => TextButton(
    style: TextButton.styleFrom(
      minimumSize: _minTarget,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.centerLeft,
    ),
    onPressed: isBusy ? null : onTap,
    child: Text(label),
  );

  @override
  Widget build(BuildContext context) => _body(context);

  Widget _body(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = text.bodyMedium?.copyWith(color: context.palette.ash);
    final account = email;
    if (account == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Back up and sync', style: text.bodyMedium),
          const SizedBox(height: Space.xs),
          Text(
            'Optional. Sign in with Google to keep your bosses safe and '
            'bring them to another phone.',
            style: muted,
          ),
          _button('Sign in with Google', onSignIn),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Back up and sync', style: text.bodyMedium),
        const SizedBox(height: Space.xs),
        Text(account, style: text.bodyMedium),
        Text(_status, style: muted),
        if (notBackedUp > 0)
          Text(
            '$notBackedUp ${notBackedUp == 1 ? 'item' : 'items'} not backed up',
            style: muted,
          ),
        Wrap(
          children: [
            _button('Sign out', onSignOut),
            _button('Delete account', onDelete),
          ],
        ),
      ],
    );
  }
}
