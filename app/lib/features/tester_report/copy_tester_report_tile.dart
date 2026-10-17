import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/clock.dart';
import '../../data/providers.dart';
import '../../core/signals.dart';
import 'tester_report.dart';

/// Settings row that copies the tester report to the clipboard (§12).
/// The confirmation is a quiet line on the row itself.
class CopyTesterReportTile extends ConsumerStatefulWidget {
  const CopyTesterReportTile({super.key});

  @override
  ConsumerState<CopyTesterReportTile> createState() =>
      _CopyTesterReportTileState();
}

class _CopyTesterReportTileState extends ConsumerState<CopyTesterReportTile> {
  String? _status;

  Future<void> _copy() async {
    final input = await ref.read(signalDaoProvider).input();
    final today = dayOf(
      ref.read(clockProvider)(),
      rolloverHour: input.rolloverHour,
    );
    final report = buildTesterReport(computeSignals(input, today), kAppVersion);
    try {
      await Clipboard.setData(ClipboardData(text: report));
    } on PlatformException {
      if (mounted) setState(() => _status = 'Could not copy.');
      return;
    }
    if (mounted) setState(() => _status = 'Copied.');
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('Copy tester report', style: text.bodyMedium),
      subtitle: _status == null ? null : Text(_status!, style: text.bodySmall),
      onTap: _copy,
    );
  }
}
