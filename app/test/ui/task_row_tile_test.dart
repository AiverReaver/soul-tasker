import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/diamond_pip.dart';
import 'package:hearthrise/ui/needle_frame.dart';
import 'package:hearthrise/ui/task_row_tile.dart';
import 'package:material_ui/material_ui.dart';

import 'glass_host.dart';

const _button = SizedBox(key: ValueKey('btn'), width: 48, height: 48);

TaskRowTile _tile({
  bool isDone = false,
  RowPhase phase = RowPhase.idle,
  int pips = 2,
  String meta = 'Thesis Warden · +3 embers',
  Widget? trailing = _button,
  VoidCallback? onTap,
  Widget? sweep,
  Widget? deadline,
}) => TaskRowTile(
  title: 'Write 500 words',
  pips: pips,
  meta: meta,
  isDone: isDone,
  phase: phase,
  trailing: trailing,
  onTap: onTap,
  sweep: sweep,
  deadline: deadline,
);

void main() {
  final p = Biome.pharloom.palette;
  Color? pipColor(WidgetTester t) =>
      t.widget<DiamondPip>(find.byType(DiamondPip).first).color;

  testWidgets('idle shows the pips, title, meta and the trailing button', (
    tester,
  ) async {
    await tester.pumpWidget(glassHost(_tile()));
    expect(find.byType(DiamondPip), findsNWidgets(2));
    expect(pipColor(tester), p.silk);
    expect(find.text('Write 500 words'), findsOneWidget);
    expect(find.text('Thesis Warden · +3 embers'), findsOneWidget);
    expect(find.byKey(const ValueKey('btn')), findsOneWidget);
    expect(find.byKey(const ValueKey('row-check')), findsNothing);
    expect(find.byKey(const ValueKey('row-ink-line')), findsNothing);
  });

  testWidgets('compact: 52 inside the edge, the meta shares the title line', (
    tester,
  ) async {
    await tester.pumpWidget(
      glassHost(
        TaskRowTile(
          title: 'Write 500 words',
          pips: 1,
          meta: '+3',
          isDone: false,
          compact: true,
          trailing: const SizedBox.square(key: ValueKey('btn'), dimension: 44),
        ),
      ),
    );
    expect(tester.getSize(find.byType(NeedleFrame)).height, 54);
    expect(
      tester.getCenter(find.text('+3')).dy,
      tester.getCenter(find.text('Write 500 words')).dy,
    );
  });

  testWidgets('one pip per weight step', (tester) async {
    await tester.pumpWidget(glassHost(_tile(pips: 3)));
    expect(find.byType(DiamondPip), findsNWidgets(3));
  });

  testWidgets('charge gives the row a silk edge', (tester) async {
    await tester.pumpWidget(glassHost(_tile(phase: RowPhase.charge)));
    expect(tester.widget<NeedleFrame>(find.byType(NeedleFrame)).edge, p.silk);
  });

  testWidgets('hit fills the row with bone', (tester) async {
    await tester.pumpWidget(glassHost(_tile(phase: RowPhase.hit)));
    expect(tester.widget<NeedleFrame>(find.byType(NeedleFrame)).fill, p.bone);
  });

  testWidgets('idle uses the seam edge and the shell fill', (tester) async {
    await tester.pumpWidget(glassHost(_tile()));
    final frame = tester.widget<NeedleFrame>(find.byType(NeedleFrame));
    expect(frame.edge, isNull);
    expect(frame.fill, isNull);
  });

  testWidgets('struck: struckBg, struckEdge, the ink line and the check', (
    tester,
  ) async {
    await tester.pumpWidget(
      glassHost(_tile(isDone: true, meta: 'Struck · +3 embers')),
    );
    final frame = tester.widget<NeedleFrame>(find.byType(NeedleFrame));
    expect(frame.fill, p.struckBg);
    expect(frame.edge, p.struckEdge);
    expect(find.byKey(const ValueKey('row-ink-line')), findsOneWidget);
    expect(find.byKey(const ValueKey('row-check')), findsOneWidget);
    expect(find.text('Struck · +3 embers'), findsOneWidget);
    expect(find.byKey(const ValueKey('btn')), findsNothing);
    expect(pipColor(tester), p.dim);
  });

  testWidgets('a struck row is announced as struck', (tester) async {
    await tester.pumpWidget(glassHost(_tile(isDone: true)));
    expect(find.bySemanticsLabel('Write 500 words, struck'), findsOneWidget);
  });

  testWidgets('tapping the row fires onTap, but not on the trailing button', (
    tester,
  ) async {
    var taps = 0, buttons = 0;
    await tester.pumpWidget(
      glassHost(
        TaskRowTile(
          title: 'Write 500 words',
          pips: 1,
          meta: 'Thesis · +1 embers',
          isDone: false,
          onTap: () => taps++,
          trailing: GestureDetector(
            key: const ValueKey('btn'),
            behavior: HitTestBehavior.opaque,
            onTap: () => buttons++,
            child: const SizedBox.square(dimension: 48),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Write 500 words'));
    expect(taps, 1);
    await tester.tap(find.byKey(const ValueKey('btn')));
    expect((taps, buttons), (1, 1));
  });

  testWidgets('the slash and the deadline have their slots', (tester) async {
    await tester.pumpWidget(
      glassHost(
        _tile(
          sweep: const SizedBox(key: ValueKey('sw')),
          deadline: const Text('by 11:00 PM'),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('sw')), findsOneWidget);
    expect(find.text('by 11:00 PM'), findsOneWidget);
  });

  testWidgets('the slash is drawn at full strength over a struck row', (
    tester,
  ) async {
    await tester.pumpWidget(
      glassHost(
        _tile(isDone: true, sweep: const SizedBox(key: ValueKey('sw'))),
      ),
    );
    expect(
      find.ancestor(
        of: find.byKey(const ValueKey('sw')),
        matching: find.byType(Opacity),
      ),
      findsNothing,
    );
  });

  testWidgets('at 200% text the row grows instead of overflowing', (
    tester,
  ) async {
    await tester.pumpWidget(glassHost(_tile(), text: 2));
    expect(tester.takeException(), isNull);
  });
}
