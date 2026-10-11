// ponytail: in-memory prototype models; Drift tables replace these in Stage 1.

enum Weight {
  light(Duration(milliseconds: 300), 'Light'),
  heavy(Duration(milliseconds: 600), 'Heavy'),
  bossTier(Duration(milliseconds: 1200), 'Boss-tier');

  const Weight(this.holdDuration, this.label);
  final Duration holdDuration;
  final String label;
}

class Task {
  const Task(this.title, this.weight, {this.isDone = false});
  final String title;
  final Weight weight;
  final bool isDone;

  Task strike() => Task(title, weight, isDone: true);
}

class Phase {
  const Phase(this.name, this.tasks);
  final String name;
  final List<Task> tasks;

  Phase replaceTask(int index, Task task) =>
      Phase(name, [...tasks]..[index] = task);
}

class Boss {
  const Boss({
    required this.title,
    required this.phases,
    this.attempt = 1,
    this.lastLesson,
  });

  final String title;
  final List<Phase> phases;
  final int attempt;
  final String? lastLesson;

  int get totalTasks => phases.fold(0, (sum, p) => sum + p.tasks.length);
  int get doneTasks =>
      phases.fold(0, (sum, p) => sum + p.tasks.where((t) => t.isDone).length);

  /// Remaining health as 0..1. Each task is one segment.
  double get health => totalTasks == 0 ? 0 : 1 - doneTasks / totalTasks;

  Boss strike(int phaseIndex, int taskIndex) {
    final phase = phases[phaseIndex];
    final updated =
        phase.replaceTask(taskIndex, phase.tasks[taskIndex].strike());
    return copyWith(phases: [...phases]..[phaseIndex] = updated);
  }

  /// A failed attempt: counter rises, lesson carries forward, progress stays.
  Boss fall(String? lesson) {
    final trimmed = lesson?.trim() ?? '';
    return copyWith(
      attempt: attempt + 1,
      lastLesson: trimmed.isEmpty ? lastLesson : trimmed,
    );
  }

  Boss copyWith({List<Phase>? phases, int? attempt, String? lastLesson}) =>
      Boss(
        title: title,
        phases: phases ?? this.phases,
        attempt: attempt ?? this.attempt,
        lastLesson: lastLesson ?? this.lastLesson,
      );
}

Boss sampleBoss() => const Boss(
      title: 'The Certification',
      attempt: 3,
      lastLesson: 'Rushed the second phase.',
      phases: [
        Phase('Learn the pattern', [
          Task('Read chapter 4', Weight.heavy),
          Task('Review flashcards', Weight.light),
        ]),
        Phase('Practice', [
          Task('Timed practice test', Weight.heavy),
          Task('Fix weak topics', Weight.heavy),
        ]),
        Phase('The fight', [
          Task('Sit the exam', Weight.bossTier),
        ]),
      ],
    );
