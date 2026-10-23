import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/glass_surface.dart';
import 'package:hearthrise/ui/hold_button.dart';
import 'package:material_ui/material_ui.dart';

import 'glass_host.dart';

void main() {
  final p = Biome.pharloom.palette;
  double fill(WidgetTester t) =>
      t.getSize(find.byKey(const ValueKey('hold-fill'))).height;

  testWidgets('a 48 px circle whose fill height is progress x 46', (
    tester,
  ) async {
    Future<void> show(double v) => tester.pumpWidget(
      glassHost(
        HoldButton(
          progress: v,
          isReady: false,
          semanticLabel: 'Hold to strike',
        ),
      ),
    );
    await show(0);
    expect(tester.getSize(find.byType(HoldButton)), const Size.square(48));
    expect(fill(tester), 0);
    await show(.5);
    expect(fill(tester), 23);
    await show(1);
    expect(fill(tester), 46);
  });

  testWidgets('the edge is ink at rest and bone when ready; no blur', (
    tester,
  ) async {
    await tester.pumpWidget(
      glassHost(
        const HoldButton(progress: .2, isReady: false, semanticLabel: 'x'),
      ),
    );
    var s = tester.widget<GlassSurface>(find.byType(GlassSurface));
    expect(s.edge, p.ink);
    expect(s.blur, 0);
    expect(find.byType(BackdropFilter), findsNothing);
    await tester.pumpWidget(
      glassHost(
        const HoldButton(progress: .9, isReady: true, semanticLabel: 'x'),
      ),
    );
    s = tester.widget<GlassSurface>(find.byType(GlassSurface));
    expect(s.edge, p.bone);
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
