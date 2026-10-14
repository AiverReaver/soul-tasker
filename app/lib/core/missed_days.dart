/// The calendar day [delta] days from [day] (`YYYY-MM-DD`).
///
/// Uses calendar fields, so a daylight-saving day is still one day.
String shiftDay(String day, int delta) {
  final p = day.split('-').map(int.parse).toList();
  final d = DateTime(p[0], p[1], p[2] + delta);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}

/// Days that ended after [lastResolved] and before [today] with no cover,
/// oldest first (Stage 3 plan D3).
///
/// A day is covered by a bonfire or flask row ([restedDays]), or by a light
/// day that also had a strike. Striking alone does not cover it. [today] has
/// not ended, so it is never judged.
List<String> missedDays({
  required String lastResolved,
  required String today,
  required Set<String> restedDays,
  required Set<String> lightDays,
  required Set<String> strikeDays,
}) {
  bool isCovered(String d) =>
      restedDays.contains(d) ||
      (lightDays.contains(d) && strikeDays.contains(d));
  // ISO dates compare correctly as strings.
  return [
    for (
      var d = shiftDay(lastResolved, 1);
      d.compareTo(today) < 0;
      d = shiftDay(d, 1)
    )
      if (!isCovered(d)) d,
  ];
}
