import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/glass_surface.dart';
import 'package:hearthrise/ui/hold_button.dart';
import 'package:hearthrise/ui/stroke_icon.dart';
import 'package:material_ui/material_ui.dart';

import 'glass_host.dart';

void main() {
  final p = Biome.pharloom.palette;
  double fill(WidgetTester t) =>
      t.getSize(find.byKey(const ValueKey('hold-fill'))).height;
  Color icon(WidgetTester t) =>
      t.widget<StrokeIcon>(find.byType(StrokeIcon)).color;

  Future<void> show(WidgetTester tester, double v, {bool isReady = false}) =>
      tester.pumpWidget(
        glassHost(
          HoldButton(progress: v, isReady: isReady, semanticLabel: 'x'),
        ),
      );

  testWidgets('a 48 px target whose fill height is progress x 48', (
    tester,
  ) async {
    await show(tester, 0);
    expect(tester.getSize(find.byType(HoldButton)), const Size.square(48));
    expect(fill(tester), 0);
    await show(tester, .5);
    expect(fill(tester), 24);
    await show(tester, 1);
    expect(fill(tester), 48);
  });

  testWidgets('no glass: at rest it is only the strike icon', (tester) async {
    await show(tester, 0);
    expect(find.byType(GlassSurface), findsNothing);
    expect(find.byType(ClipOval), findsNothing);
    expect(icon(tester), p.silk);
  });

  testWidgets('the icon turns bone over the fill', (tester) async {
    await show(tester, .3);
    expect(icon(tester), p.bone);
    await show(tester, .9, isReady: true);
    expect(icon(tester), p.bone);
  });

  testWidgets('the semantics label is the label passed in', (tester) async {
    await tester.pumpWidget(
      glassHost(
        const HoldButton(
          progress: 0,
          isReady: false,
          semanticLabel: 'Hold to strike Run 3 km',
        ),
      ),
    );
    expect(find.bySemanticsLabel('Hold to strike Run 3 km'), findsOneWidget);
  });
}
