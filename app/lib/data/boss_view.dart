import 'database.dart';
import 'enums.dart';

// Derived state for one boss (STAGE1_PLAN.md §6.2). Pure functions over rows,
// so every rule lives in one place and is testable without a database.

class TaskView {
  const TaskView(this.task, {required this.isStruck});

  final Task task;
  final bool isStruck;

  bool get isDaily => task.recurrence == Recurrence.daily;
  bool get isSegment => !isDaily && task.phaseId != null;
}

class PhaseView {
  const PhaseView(this.phase, this.tasks);

  final Phase phase;
  final List<TaskView> tasks;

  bool get isDone {
    final oneTime = tasks.where((t) => !t.isDaily);
    return oneTime.isNotEmpty && oneTime.every((t) => t.isStruck);
  }
}

class BossView {
  const BossView({
    required this.boss,
    required this.phases,
    required this.standalone,
    required this.lastLesson,
  });

  final Boss boss;
  final List<PhaseView> phases;

  /// Tasks "Beyond the phases" (no phase).
  final List<TaskView> standalone;
  final String? lastLesson;

  /// Health bar segments: one-time phase tasks, in order (D1).
  List<TaskView> get segments => [
    for (final p in phases) ...p.tasks.where((t) => t.isSegment),
  ];

  bool get hasSegments => segments.isNotEmpty;
  bool get isVanquished => hasSegments && segments.every((t) => t.isStruck);

  /// Remaining health, 0..1.
  double get health {
    final all = segments;
    if (all.isEmpty) return 0;
    return all.where((t) => !t.isStruck).length / all.length;
  }

  /// First phase with an unstruck one-time task.
  PhaseView? get currentPhase {
    for (final p in phases) {
      if (p.tasks.any((t) => !t.isDaily && !t.isStruck)) return p;
    }
    return null;
  }

  int? get currentPhaseNumber {
    final current = currentPhase;
    return current == null ? null : phases.indexOf(current) + 1;
  }

  List<TaskView> get allTasks => [
    for (final p in phases) ...p.tasks,
    ...standalone,
  ];
}

/// Builds the view for [boss]. Rows may include other bosses' data.
BossView buildBossView({
  required Boss boss,
  required List<Phase> phases,
  required List<Task> tasks,
  required List<Attempt> attempts,
  required String today,
}) {
  final strikes = <String, List<Attempt>>{};
  String? lastLesson;
  for (final a in attempts) {
    if (a.bossId != boss.id) continue;
    if (a.outcome == Outcome.strike && a.taskId != null) {
      (strikes[a.taskId!] ??= []).add(a);
    }
    if (a.outcome == Outcome.fallen && a.lesson != null) lastLesson = a.lesson;
  }

  bool isStruck(Task t, int floor) {
    final hits = strikes[t.id] ?? const [];
    return t.recurrence == Recurrence.daily
        ? hits.any((a) => a.day == today)
        : hits.any((a) => a.bossAttempt >= floor);
  }

  List<TaskView> viewsOf(Iterable<Task> list, int floor) => [
    for (final t
        in list.where((t) => !t.isSplit).toList()
          ..sort((a, b) => a.position.compareTo(b.position)))
      TaskView(t, isStruck: isStruck(t, floor)),
  ];

  final own = tasks.where((t) => t.bossId == boss.id).toList();
  final ownPhases = phases.where((p) => p.bossId == boss.id).toList()
    ..sort((a, b) => a.position.compareTo(b.position));

  return BossView(
    boss: boss,
    phases: [
      for (final p in ownPhases)
        PhaseView(
          p,
          viewsOf(own.where((t) => t.phaseId == p.id), p.openFromAttempt),
        ),
    ],
    standalone: viewsOf(
      own.where((t) => t.phaseId == null),
      boss.openFromAttempt,
    ),
    lastLesson: lastLesson,
  );
}

/// Rule of three fires at every non-zero multiple of 3 (D11).
bool isRuleOfThree(int count) => count > 0 && count % 3 == 0;

/// `tried` attempts for [taskId] after its newest strike. [attempts] must be
/// in time order.
int triesSinceStrike(String taskId, List<Attempt> attempts) {
  var count = 0;
  for (final a in attempts) {
    if (a.taskId != taskId) continue;
    if (a.outcome == Outcome.strike) count = 0;
    if (a.outcome == Outcome.tried) count++;
  }
  return count;
}

/// Consecutive newest falls of [bossId] sharing one non-null phase (D6).
/// [attempts] must be in time order.
int samePhaseFallRun(String bossId, List<Attempt> attempts) {
  final falls = attempts
      .where((a) => a.bossId == bossId && a.outcome == Outcome.fallen)
      .toList()
      .reversed;
  if (falls.isEmpty || falls.first.phaseId == null) return 0;
  final phaseId = falls.first.phaseId;
  return falls.takeWhile((a) => a.phaseId == phaseId).length;
}

/// Home order: pinned first, then most recently fought, then newest.
int compareBosses(Boss a, Boss b) {
  if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
  final fought = _compareDesc(a.lastFoughtAt, b.lastFoughtAt);
  return fought != 0 ? fought : b.createdAt.compareTo(a.createdAt);
}

int _compareDesc(DateTime? a, DateTime? b) {
  if (a == b) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return b.compareTo(a);
}
