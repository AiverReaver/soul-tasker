import 'clock.dart';

/// The deadlines a commitment can take (§5.12, Stage 4 plan D2).
enum DeadlinePreset {
  oneHour('In 1 hour'),
  threeHours('In 3 hours'),
  tonight('Tonight');

  const DeadlinePreset(this.label);
  final String label;
}

/// "Tonight" means this local hour.
const kTonightHour = 23;

/// When the ritual day holding [now] ends: the next rollover.
DateTime dayEnd(DateTime now, {required int rolloverHour}) {
  final p = dayOf(now, rolloverHour: rolloverHour).split('-').map(int.parse);
  final [y, m, d] = p.toList();
  return DateTime(y, m, d + 1, rolloverHour);
}

/// The deadline [preset] gives at [now], never past the end of the ritual
/// day, so every commitment stays inside one day (plan D2).
DateTime deadlineFor(
  DeadlinePreset preset,
  DateTime now, {
  required int rolloverHour,
}) {
  final end = dayEnd(now, rolloverHour: rolloverHour);
  final tonight = DateTime(now.year, now.month, now.day, kTonightHour);
  final wanted = switch (preset) {
    DeadlinePreset.oneHour => now.add(const Duration(hours: 1)),
    DeadlinePreset.threeHours => now.add(const Duration(hours: 3)),
    DeadlinePreset.tonight => now.isBefore(tonight) ? tonight : end,
  };
  return wanted.isAfter(end) ? end : wanted;
}
