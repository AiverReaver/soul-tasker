import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/enums.dart';

void main() {
  const task = TaskDraft(title: 'Jog', weight: Weight.light);

  group('BossDraft.missing says why Save is refused', () {
    test('no title', () {
      expect(
        const BossDraft(
          resetOnFail: ResetOnFail.nothing,
          title: ' ',
          standalone: [task],
        ).missing,
        'Name the boss first.',
      );
    });

    test('an unnamed chapter', () {
      expect(
        const BossDraft(
          resetOnFail: ResetOnFail.nothing,
          title: 'Run a 5k',
          phases: [
            PhaseDraft(name: '', tasks: [task]),
          ],
        ).missing,
        'Name every chapter, or remove the empty one.',
      );
    });

    test('no task anywhere', () {
      expect(
        const BossDraft(
          resetOnFail: ResetOnFail.nothing,
          title: 'Run a 5k',
          phases: [PhaseDraft(name: 'Base')],
        ).missing,
        'Add a task to fight.',
      );
    });

    test('nothing when it can save', () {
      const draft = BossDraft(
        resetOnFail: ResetOnFail.nothing,
        title: 'Run a 5k',
        standalone: [task],
      );
      expect(draft.canSave, isTrue);
      expect(draft.missing, isNull);
    });
  });

  test('Weight.emberNote is singular for one ember', () {
    expect(Weight.light.emberNote, '+1 ember');
    expect(Weight.heavy.emberNote, '+3 embers');
  });
}
