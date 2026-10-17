import '../data/enums.dart' show SignalKind;
import 'clock.dart';
import 'signals.dart' show SignalMark;

/// The answer to "Has Hearthrise left you feeling worse?" (Stage 6 plan
/// D6). Here, not in `data/`, so `ui/` can use it.
enum CheckInAnswer { never, sometimes, often }

/// The check-in opens on these days, counting the install day as day 1
/// (Stage 6 plan D6). Each window runs until the next one opens.
const kCheckInDays = [7, 14];

/// The card stops coming back after this many "Not now" in one window.
const kCheckInMaxShows = 3;

/// The window [day] (a day number) falls in, or null before the first.
int? checkInWindowOf(int day) {
  int? window;
  for (final from in kCheckInDays) {
    if (day >= from) window = from;
  }
  return window;
}

/// Converts a day string to its day number from [firstDay].
int? checkInWindowOn(String firstDay, String day) =>
    checkInWindowOf(dayNumber(firstDay, day));

/// The window whose card should show at today's bonfire, or null (Stage 6
/// plan D6). Closed by an answer or by [kCheckInMaxShows] dismissals; a
/// dismissal also hides it for the rest of that day.
int? dueCheckIn(String firstDay, String today, List<SignalMark> marks) {
  final window = checkInWindowOn(firstDay, today);
  if (window == null) return null;
  final inWindow = [
    for (final m in marks)
      if (checkInWindowOn(firstDay, m.day) == window) m,
  ];
  if (inWindow.any((m) => m.kind == SignalKind.checkIn)) return null;
  final dismissals = inWindow.where(
    (m) => m.kind == SignalKind.checkInDismissed,
  );
  if (dismissals.length >= kCheckInMaxShows) return null;
  if (dismissals.any((m) => m.day == today)) return null;
  return window;
}
