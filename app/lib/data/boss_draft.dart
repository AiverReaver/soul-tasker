import 'boss_view.dart';
import 'enums.dart';

// Immutable form state for the boss editor. Saved in one transaction by
// BossDao.saveBoss. A null id means "not saved yet".

class TaskDraft {
  const TaskDraft({
    this.id,
    required this.title,
    this.weight = Weight.heavy,
    this.recurrence = Recurrence.none,
  });

  final String? id;
  final String title;
  final Weight weight;
  final Recurrence recurrence;

  TaskDraft copyWith({String? title, Weight? weight, Recurrence? recurrence}) =>
      TaskDraft(
        id: id,
        title: title ?? this.title,
        weight: weight ?? this.weight,
        recurrence: recurrence ?? this.recurrence,
      );
}

class PhaseDraft {
  const PhaseDraft({this.id, required this.name, this.tasks = const []});

  final String? id;
  final String name;
  final List<TaskDraft> tasks;

  PhaseDraft copyWith({String? name, List<TaskDraft>? tasks}) =>
      PhaseDraft(id: id, name: name ?? this.name, tasks: tasks ?? this.tasks);
}

class BossDraft {
  const BossDraft({
    this.id,
    this.title = '',
    this.defeatMeaning = '',
    this.targetDate,
    required this.resetOnFail,
    this.phases = const [],
    this.standalone = const [],
  });

  /// A new boss starts with two suggested phases (§6.2).
  factory BossDraft.fresh(ResetOnFail reset) => BossDraft(
    resetOnFail: reset,
    phases: const [
      PhaseDraft(name: 'Learn the pattern'),
      PhaseDraft(name: 'The fight'),
    ],
  );

  factory BossDraft.fromView(BossView view) {
    TaskDraft task(TaskView t) => TaskDraft(
      id: t.task.id,
      title: t.task.title,
      weight: t.task.weight,
      recurrence: t.task.recurrence,
    );
    return BossDraft(
      id: view.boss.id,
      title: view.boss.title,
      defeatMeaning: view.boss.defeatMeaning ?? '',
      targetDate: view.boss.targetDate,
      resetOnFail: view.boss.resetOnFail,
      phases: [
        for (final p in view.phases)
          PhaseDraft(
            id: p.phase.id,
            name: p.phase.name,
            tasks: [for (final t in p.tasks) task(t)],
          ),
      ],
      standalone: [for (final t in view.standalone) task(t)],
    );
  }

  final String? id;
  final String title;
  final String defeatMeaning;
  final DateTime? targetDate;
  final ResetOnFail resetOnFail;
  final List<PhaseDraft> phases;
  final List<TaskDraft> standalone;

  bool get canSave =>
      title.trim().isNotEmpty &&
      phases.every((p) => p.name.trim().isNotEmpty) &&
      (standalone.isNotEmpty || phases.any((p) => p.tasks.isNotEmpty));

  /// Removes the task with [taskId] from wherever it is.
  BossDraft withoutTask(String taskId) => copyWith(
    phases: [
      for (final p in phases)
        p.copyWith(tasks: [...p.tasks.where((t) => t.id != taskId)]),
    ],
    standalone: [...standalone.where((t) => t.id != taskId)],
  );

  /// Puts [task] in phase [phaseId] (null = standalone). Keeps its place
  /// when it stays in the same list; appends when it moves or is new.
  BossDraft withTask(TaskDraft task, String? phaseId) {
    List<TaskDraft> place(List<TaskDraft> list) {
      final i = list.indexWhere((t) => t.id == task.id);
      return i < 0 ? [...list, task] : ([...list]..[i] = task);
    }

    bool isHere(List<TaskDraft> list) => list.any((t) => t.id == task.id);
    final staysPut = phaseId == null
        ? isHere(standalone)
        : phases.any((p) => p.id == phaseId && isHere(p.tasks));
    final base = staysPut ? this : withoutTask(task.id ?? '');
    return base.copyWith(
      phases: [
        for (final p in base.phases)
          p.id == phaseId ? p.copyWith(tasks: place(p.tasks)) : p,
      ],
      standalone: phaseId == null ? place(base.standalone) : base.standalone,
    );
  }

  BossDraft copyWith({
    String? title,
    String? defeatMeaning,
    DateTime? targetDate,
    bool clearTargetDate = false,
    ResetOnFail? resetOnFail,
    List<PhaseDraft>? phases,
    List<TaskDraft>? standalone,
  }) => BossDraft(
    id: id,
    title: title ?? this.title,
    defeatMeaning: defeatMeaning ?? this.defeatMeaning,
    targetDate: clearTargetDate ? null : targetDate ?? this.targetDate,
    resetOnFail: resetOnFail ?? this.resetOnFail,
    phases: phases ?? this.phases,
    standalone: standalone ?? this.standalone,
  );
}
