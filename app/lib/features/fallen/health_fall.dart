import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/missed_days.dart';
import '../../data/providers.dart';
import 'fallen_screen.dart';

/// Health-death falls already offered in this run of the app, so a skipped
/// lesson is not asked again until the next start.
final offeredDeathsProvider = Provider<Set<String>>((ref) => <String>{});

/// The newcomer grace week length (plan D13).
const _graceDays = 7;

/// What the fallen screen shows for a health death on [day]: promises made
/// and kept, the week's accuracy, and the grace line in week one.
Future<FallenRecord> fallenRecord(WidgetRef ref, String day) async {
  final commits = ref.read(commitmentDaoProvider);
  final today = await commits.record(day);
  final week = await commits.week(day);
  final first = (await ref.read(settingsDaoProvider).read()).firstDay;
  return FallenRecord(
    promised: today.made,
    kept: today.kept,
    weekMade: week.made,
    weekKept: week.kept,
    isGraceWeek:
        first != null && shiftDay(first, _graceDays).compareTo(day) > 0,
  );
}

/// Shows the fallen moment for a health death on [day] and stores the
/// lesson on its fall rows. Returns the lesson, or null if skipped.
Future<String?> showHealthFall(
  BuildContext context,
  WidgetRef ref,
  String day, {
  List<String>? attemptIds,
}) async {
  final health = ref.read(healthDaoProvider);
  // Read before the await: the caller may be gone when the screen closes.
  final attempts = ref.read(attemptDaoProvider);
  final offered = ref.read(offeredDeathsProvider);
  final ids = attemptIds ?? await health.deathsWithoutLesson(day);
  final record = await fallenRecord(ref, day);
  if (!context.mounted) return null;
  offered.addAll(ids);
  final lesson = await FallenScreen.show(
    context,
    ref.read(hapticsProvider),
    record: record,
  );
  await attempts.addLesson(ids, lesson);
  return lesson;
}
