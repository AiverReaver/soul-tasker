import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef Clock = DateTime Function();

/// Overridden in tests with a fixed or advancing clock.
final clockProvider = Provider<Clock>((ref) => DateTime.now);

/// A day ends at this local hour, so a 1 AM bonfire belongs to the evening
/// before (§5.6). Stage 3 makes it a setting.
const kRolloverHour = 4;

/// The local day [time] belongs to, as `YYYY-MM-DD`.
///
/// Uses calendar fields, not hour arithmetic, so daylight-saving days still
/// roll over at 04:00 local time.
String dayOf(DateTime time, {int rolloverHour = kRolloverHour}) {
  final local = time.toLocal();
  final date = local.hour < rolloverHour
      ? DateTime(local.year, local.month, local.day - 1)
      : DateTime(local.year, local.month, local.day);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${date.year}-${two(date.month)}-${two(date.day)}';
}

/// [minutes] from midnight as a 12-hour time, such as `9:00 PM`.
String formatClock(int minutes) {
  final hour = minutes ~/ 60;
  final minute = (minutes % 60).toString().padLeft(2, '0');
  final twelve = hour % 12 == 0 ? 12 : hour % 12;
  return '$twelve:$minute ${hour < 12 ? 'AM' : 'PM'}';
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// A ritual [day] (`YYYY-MM-DD`) as `5 Oct 2026`.
String formatDayLabel(String day) {
  final parts = day.split('-');
  return '${int.parse(parts[2])} ${_months[int.parse(parts[1]) - 1]} ${parts[0]}';
}
