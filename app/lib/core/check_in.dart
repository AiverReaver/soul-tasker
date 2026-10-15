import 'signals.dart';

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
