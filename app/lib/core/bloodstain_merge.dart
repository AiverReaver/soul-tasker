/// The fields of a bloodstain that can change after it is dropped.
typedef StainTimes = ({DateTime? recoveredAt, DateTime? lostAt});

/// Merges two copies of one bloodstain field by field (Stage 7 plan D19):
/// the earliest recovery and the earliest loss win, but a recovery clears
/// the loss, so a merge never takes back what was earned. The same answer
/// in either argument order.
StainTimes mergeStainTimes(StainTimes a, StainTimes b) {
  final recoveredAt = _earliest(a.recoveredAt, b.recoveredAt);
  return (
    recoveredAt: recoveredAt,
    lostAt: recoveredAt == null ? _earliest(a.lostAt, b.lostAt) : null,
  );
}

DateTime? _earliest(DateTime? a, DateTime? b) {
  if (a == null) return b;
  if (b == null) return a;
  return a.isBefore(b) ? a : b;
}
