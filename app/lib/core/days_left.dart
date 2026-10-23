/// "9 days left" until [target], rounding up; null with no date or once it
/// has passed.
String? daysLeftLabel(DateTime? target, DateTime now) {
  if (target == null || !target.isAfter(now)) return null;
  final days = (target.difference(now).inHours / 24).ceil();
  return days == 1 ? '1 day left' : '$days days left';
}
