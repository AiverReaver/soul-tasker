import '../data/enums.dart';
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

/// What a commitment's chip says, and whether it is due within the hour.
typedef DeadlineLabel = ({String text, bool isSoon});

/// The chip text for a commitment: time left while open, the outcome once
/// closed. Never alarming: no red and no exclamation (§5.8 tone).
DeadlineLabel deadlineLabel(
  CommitmentOutcome? outcome,
  DateTime deadline,
  DateTime now,
) {
  final closed = switch (outcome) {
    null => null,
    CommitmentOutcome.kept => 'kept',
    CommitmentOutcome.tried => 'tried',
    CommitmentOutcome.missed => 'missed',
    CommitmentOutcome.frozen => 'frozen',
    CommitmentOutcome.lateStrike => 'done late',
    CommitmentOutcome.cancelled => 'set aside',
  };
  if (closed != null) return (text: closed, isSoon: false);
  final left = deadline.difference(now);
  if (left <= const Duration(hours: 1)) {
    final minutes = left.inMinutes.clamp(0, 60);
    return (text: 'in $minutes min', isSoon: true);
  }
  return (
    text: 'by ${formatClock(deadline.hour * 60 + deadline.minute)}',
    isSoon: false,
  );
}

/// Health in half points as points: 7 reads "3.5".
String formatHealth(int halfPoints) =>
    halfPoints.isEven ? '${halfPoints ~/ 2}' : '${halfPoints ~/ 2}.5';

const _words = [
  'none',
  'one',
  'two',
  'three',
  'four',
  'five',
  'six',
  'seven',
  'eight',
  'nine',
  'ten',
  'eleven',
  'twelve',
  'thirteen',
  'fourteen',
  'fifteen',
  'sixteen',
  'seventeen',
  'eighteen',
  'nineteen',
  'twenty',
];

/// A count as a word up to twenty ("nine promised"), digits after.
String countWord(int n) => n >= 0 && n < _words.length ? _words[n] : '$n';
