import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/clock.dart';
import '../../core/theme.dart';
import '../../data/day_dao.dart';
import '../../data/providers.dart';
import '../../core/commitment_resolver.dart' show kMaxHealthHalfPoints;
import '../../core/level.dart';
import '../../ui/accuracy_line.dart';
import '../../ui/flask_pips.dart';
import '../../ui/hall_of_relics.dart';
import '../../ui/glass_circle_button.dart';
import '../../ui/level_badge.dart';
import '../../ui/level_line.dart';
import '../../ui/player_health_bar.dart';
import '../../ui/stroke_icon.dart';

/// The profile (§6.1, Stage 5 plan D10): level, banked embers, flasks,
/// planning accuracy, and the hall of relics.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final profile = ref.watch(profileProvider).value;
    final relics = ref.watch(relicListProvider).value ?? const [];
    final health = ref.watch(healthProvider).value;
    return Scaffold(
      body: SafeArea(
        child: profile == null
            ? const SizedBox.shrink()
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, Space.sm, 20, Space.xl),
                children: [
                  Row(
                    spacing: Space.sm + 4,
                    children: [
                      GlassCircleButton(
                        icon: StrokeIcons.back,
                        semanticLabel: 'Back',
                        onTap: () => context.go('/'),
                      ),
                      Text('PROFILE', style: text.labelSmall),
                    ],
                  ),
                  const SizedBox(height: Space.lg),
                  LevelBadge(
                    level: profile.level.level,
                    embers: profile.banked,
                    percentToNext: _share(profile.level, 100),
                    bars: _share(profile.level, 5),
                    isLarge: true,
                  ),
                  const SizedBox(height: Space.md),
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
                  if (health != null) ...[
                    PlayerHealthBar(health: health, max: kMaxHealthHalfPoints),
                    const SizedBox(height: Space.sm),
                  ],
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
                          name: r.name.replaceFirst('Relic of ', ''),
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

  /// How far through this level, scaled to [of] (5 bars, 100 percent).
  static int _share(LevelInfo level, int of) =>
      (of * (1 - level.toNext / (level.level * kLevelStep))).round().clamp(
        0,
        of,
      );
}
