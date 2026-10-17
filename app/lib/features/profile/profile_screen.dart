import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/clock.dart';
import '../../core/theme.dart';
import '../../data/day_dao.dart';
import '../../data/providers.dart';
import '../../ui/accuracy_line.dart';
import '../../ui/flask_pips.dart';
import '../../ui/hall_of_relics.dart';
import '../../ui/level_line.dart';

/// The profile (§6.1, Stage 5 plan D10): level, banked embers, flasks,
/// planning accuracy, and the hall of relics.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final profile = ref.watch(profileProvider).value;
    final relics = ref.watch(relicListProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: Text('PROFILE', style: text.labelSmall)),
      body: SafeArea(
        child: profile == null
            ? const SizedBox.shrink()
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, Space.xl),
                children: [
                  LevelLine(
                    level: profile.level.level,
                    toNext: profile.level.toNext,
                  ),
                  const SizedBox(height: Space.md),
                  Text(
                    '${profile.banked} '
                    '${profile.banked == 1 ? 'ember' : 'embers'} banked',
                    style: text.bodyLarge,
                  ),
                  const SizedBox(height: Space.md),
                  Row(
                    children: [
                      Text('Flasks', style: text.bodyMedium),
                      const SizedBox(width: Space.md),
                      FlaskPips(count: profile.flasks, cap: kFlaskCap),
                    ],
                  ),
                  const SizedBox(height: Space.md),
                  AccuracyLine(
                    todayKept: profile.today.kept,
                    todayMade: profile.today.made,
                    weekKept: profile.week.kept,
                    weekMade: profile.week.made,
                  ),
                  const SizedBox(height: Space.xl),
                  Text('HALL OF RELICS', style: text.labelSmall),
                  const SizedBox(height: Space.sm),
                  HallOfRelics(
                    entries: [
                      for (final r in relics)
                        HallEntry(
                          id: r.id,
                          name: r.name,
                          weathering: r.emblem,
                          dateLabel: formatDayLabel(r.defeatedDay),
                        ),
                    ],
                    onOpen: (id) => context.push('/relic/$id'),
                  ),
                ],
              ),
      ),
    );
  }
}
