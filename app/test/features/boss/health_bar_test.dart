import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/data/boss_view.dart';
import 'package:hearthrise/ui/shard_meter.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/harness.dart';

Widget _meter(int filled, {bool reduceMotion = false}) => MaterialApp(
  theme: buildTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
    child: child!,
  ),
  home: Scaffold(body: ShardMeter(filled: filled)),
);

final _p = Biome.pharloom.palette;
final _off = _p.dim.withValues(alpha: 0.35);

/// Colour of each shard, left to right.
List<Color> _colors(WidgetTester tester) => [
  for (final box in tester.widgetList<ColoredBox>(
    find.descendant(
      of: find.byType(ShardMeter),
      matching: find.byType(ColoredBox),
    ),
  ))
    box.color,
];

void main() {
  late Harness h;
  late BossView view;
  setUp(() async {
    h = Harness();
    view = await h.seed(); // segments: Read chapter 4, Flashcards, Sit the exam
  });
  tearDown(() => h.db.close());

  test('a struck segment takes a third of the shards (Stage 1 D1)', () async {
    expect(shardsFor(view.health), 12);
    await h.attempts.strike(taskNamed(view, 'Flashcards').task.id);
    expect(shardsFor((await h.reload(view.boss.id)).health), 8);
  });

  test('a daily task does not change the meter', () async {
    await h.attempts.strike(taskNamed(view, 'Walk').task.id);
    expect(shardsFor((await h.reload(view.boss.id)).health), 12);
  });

  testWidgets('a lost shard drains from lit to dim over Motion.drain', (
    tester,
  ) async {
    await tester.pumpWidget(_meter(12));
    expect(_colors(tester).last, _p.shard);

    await tester.pumpWidget(_meter(11));
    await tester.pump(Motion.drain * 0.5);
    final midway = _colors(tester);
    expect(midway[10], _p.shard);
    expect(midway[11], isNot(_p.shard));
    expect(midway[11], isNot(_off));

    await tester.pump(Motion.drain);
    expect(_colors(tester).last, _off);
  });

  testWidgets('reduced motion dims the shard at once', (tester) async {
    await tester.pumpWidget(_meter(12, reduceMotion: true));
    await tester.pumpWidget(_meter(11, reduceMotion: true));
    await tester.pump();
    expect(_colors(tester).last, _off);
  });
}
