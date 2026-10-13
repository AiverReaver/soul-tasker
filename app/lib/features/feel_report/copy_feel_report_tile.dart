import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/clock.dart';
import '../../data/providers.dart';
import 'feel_report.dart';

/// Settings row that copies the feel report to the clipboard (§12).
/// The confirmation is a quiet line on the row itself.
class CopyFeelReportTile extends ConsumerStatefulWidget {
  const CopyFeelReportTile({super.key});

  @override
  ConsumerState<CopyFeelReportTile> createState() => _CopyFeelReportTileState();
}

class _CopyFeelReportTileState extends ConsumerState<CopyFeelReportTile> {
  String? _status;

  Future<void> _copy() async {
    final data = await ref.read(attemptDaoProvider).feelReportData();
    final report = buildFeelReport(
      data,
      ref.read(clockProvider)(),
      kAppVersion,
    );
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
      title: Text('Copy feel report', style: text.bodyMedium),
      subtitle: _status == null ? null : Text(_status!, style: text.bodySmall),
      onTap: _copy,
    );
  }
}
