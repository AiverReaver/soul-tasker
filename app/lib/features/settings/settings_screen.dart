import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/clock.dart';
import '../../core/theme.dart';
import '../../data/enums.dart';
import '../../data/providers.dart';
import '../../ui/choice_dialog.dart';
import '../../ui/flash_line.dart';
import '../../ui/setting_choice_row.dart';
import '../../ui/setting_switch_row.dart';
import '../../ui/setting_value_row.dart';
import '../tester_report/copy_tester_report_tile.dart';
import 'sync_section.dart';
import '../ritual/reminder_coordinator.dart';

/// Settings: hold or tap, haptics, the evening reminder, when a day ends, and
/// the default reset. Each control writes straight through.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _flash;

  /// The latest hour a day may end at (plan D10).
  static const _lastRolloverHour = 6;

  Future<void> _setReminder(bool isOn) async {
    final reminders = ref.read(reminderCoordinatorProvider);
    if (!isOn) {
      await reminders.disable();
      if (mounted) setState(() => _flash = null);
      return;
    }
    final isGranted = await reminders.enable();
    if (mounted) {
      setState(
        () => _flash = isGranted ? null : 'No reminder without permission.',
      );
    }
  }

  Future<void> _pickTime(int minutes) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (picked == null || !mounted) return;
    await ref
        .read(reminderCoordinatorProvider)
        .setTime(picked.hour * 60 + picked.minute);
  }

  Future<void> _pickRollover() async {
    final hour = await showDialog<int>(
      context: context,
      builder: (dialog) => ChoiceDialog<int>(
        title: 'Day starts at',
        options: {
          for (var h = 0; h <= _lastRolloverHour; h++) h: formatClock(h * 60),
        },
        onPicked: (h) => Navigator.pop(dialog, h),
      ),
    );
    if (hour == null || !mounted) return;
    await ref.read(settingsDaoProvider).setRolloverHour(hour);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final dao = ref.read(settingsDaoProvider);
    final s = ref.watch(settingsProvider).value;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackground,
        title: Text('SETTINGS', style: text.labelSmall),
      ),
      body: SafeArea(
        child: s == null
            ? const SizedBox.shrink()
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, Space.xl),
                children: [
                  SettingSwitchRow(
                    title: 'Tap instead of hold',
                    value: s.tapMode,
                    onChanged: dao.setTapMode,
                  ),
                  SettingSwitchRow(
                    title: 'Haptics',
                    value: s.haptics,
                    onChanged: dao.setHaptics,
                  ),
                  SettingSwitchRow(
                    title: 'Evening reminder',
                    value: s.reminderEnabled,
                    onChanged: _setReminder,
                  ),
                  FlashLine(_flash),
                  SettingValueRow(
                    title: 'Reminder time',
                    value: formatClock(s.reminderMinutes),
                    onTap: () => _pickTime(s.reminderMinutes),
                  ),
                  SettingValueRow(
                    title: 'Day starts at',
                    value: formatClock(s.rolloverHour * 60),
                    onTap: _pickRollover,
                  ),
                  const SizedBox(height: Space.md),
                  SettingChoiceRow<ResetOnFail>(
                    title: 'On a failed attempt, reset (new bosses)',
                    options: {for (final r in ResetOnFail.values) r: r.label},
                    selected: s.defaultResetOnFail,
                    onChanged: dao.setDefaultReset,
                  ),
                  const SizedBox(height: Space.md),
                  const CopyTesterReportTile(),
                  const SizedBox(height: Space.md),
                  const SyncSection(),
                ],
              ),
      ),
    );
  }
}
