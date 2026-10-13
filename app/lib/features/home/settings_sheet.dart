import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/enums.dart';
import '../../data/providers.dart';
import '../feel_report/copy_feel_report_tile.dart';

/// Stage 1 settings (D7). Stage 3 replaces this with a Settings screen.
class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final dao = ref.read(settingsDaoProvider);
    final settings = ref.watch(settingsProvider).value;
    if (settings == null) return const SizedBox(height: 200);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, Space.lg, 20, Space.md),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Tap instead of hold', style: text.bodyMedium),
                value: settings.tapMode,
                activeThumbColor: kEmber,
                onChanged: dao.setTapMode,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Haptics', style: text.bodyMedium),
                value: settings.haptics,
                activeThumbColor: kEmber,
                onChanged: dao.setHaptics,
              ),
              const SizedBox(height: Space.md),
              Text(
                'On a failed attempt, reset (new bosses)',
                style: text.bodySmall,
              ),
              const SizedBox(height: Space.sm),
              SegmentedButton<ResetOnFail>(
                segments: [
                  for (final r in ResetOnFail.values)
                    ButtonSegment(value: r, label: Text(r.label)),
                ],
                selected: {settings.defaultResetOnFail},
                showSelectedIcon: false,
                onSelectionChanged: (s) => dao.setDefaultReset(s.single),
              ),
              const SizedBox(height: Space.md),
              const CopyFeelReportTile(),
            ],
          ),
        ),
      ),
    );
  }
}
