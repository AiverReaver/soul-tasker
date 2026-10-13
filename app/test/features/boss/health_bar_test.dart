import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/data/boss_view.dart';
import 'package:hearthrise/features/boss/boss_health_bar.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/harness.dart';

Widget _bar(BossView view, {bool reduceMotion = false}) => MaterialApp(
  theme: buildTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
    child: child!,
  ),
  home: Scaffold(body: BossHealthBar(view: view)),
);

/// Fill of each segment, left to right: 1 full, 0 empty.
List<double> _fills(WidgetTester tester) => [
  for (final box in tester.widgetList<FractionallySizedBox>(
    find.descendant(
      of: find.byType(BossHealthBar),
      matching: find.byType(FractionallySizedBox),
    ),
  ))
    box.widthFactor!,
];

void main() {
  late Harness h;
  late BossView view;
  setUp(() async {
    h = Harness();
    view = await h.seed(); // segments: Read chapter 4, Flashcards, Sit the exam
  });
  tearDown(() => h.db.close());

  testWidgets('a struck segment drains from full to empty over Motion.drain', (
    tester,
  ) async {
    await tester.pumpWidget(_bar(view));
    expect(_fills(tester), [1, 1, 1]);

    await h.attempts.strike(taskNamed(view, 'Flashcards').task.id);
    await tester.pumpWidget(_bar(await h.reload(view.boss.id)));
    await tester.pump(Motion.drain * 0.5);

    final midway = _fills(tester);
    expect(midway[0], 1);
    expect(midway[1], inExclusiveRange(0, 1));
    expect(midway[2], 1);

    await tester.pump(Motion.drain);
    expect(_fills(tester), [1, 0, 1]);
  });

  testWidgets('reduced motion empties the segment at once', (tester) async {
    await tester.pumpWidget(_bar(view, reduceMotion: true));

    await h.attempts.strike(taskNamed(view, 'Flashcards').task.id);
    await tester.pumpWidget(
      _bar(await h.reload(view.boss.id), reduceMotion: true),
    );
    await tester.pump();

    expect(_fills(tester), [1, 0, 1]);
  });

  testWidgets('a daily task does not change the bar (Stage 1 D1)', (
    tester,
  ) async {
    await tester.pumpWidget(_bar(view));

    await h.attempts.strike(taskNamed(view, 'Walk').task.id);
    await tester.pumpWidget(_bar(await h.reload(view.boss.id)));
    await tester.pump(Motion.drain);

    expect(_fills(tester), [1, 1, 1]);
  });
}
