import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/glass_surface.dart';
import 'package:hearthrise/ui/glass_switch.dart';
import 'package:material_ui/material_ui.dart';

import 'glass_host.dart';

void main() {
  final p = Biome.pharloom.palette;
  double knobLeft(WidgetTester t) => t
      .widget<AnimatedPositioned>(
        find.byKey(const ValueKey('glass-switch-knob')),
      )
      .left!;

  testWidgets('off: knob at 8; on: knob at 30 and a silk tint', (tester) async {
    Future<void> show(bool v) => tester.pumpWidget(
      glassHost(
        GlassSwitch(value: v, onChanged: (_) {}, semanticLabel: 'Haptics'),
      ),
    );
    await show(false);
    expect(knobLeft(tester), 8);
    expect(
      tester.widget<GlassSurface>(find.byType(GlassSurface)).isTinted,
      isFalse,
    );
    await show(true);
    expect(knobLeft(tester), 30);
    expect(
      tester.widget<GlassSurface>(find.byType(GlassSurface)).isTinted,
      isTrue,
    );
  });

  testWidgets('a 52 x 32 track in a 48 px tall target', (tester) async {
    await tester.pumpWidget(
      glassHost(
        GlassSwitch(value: false, onChanged: (_) {}, semanticLabel: 'Haptics'),
      ),
    );
    expect(tester.getSize(find.byType(GlassSurface)), const Size(52, 32));
    expect(
      tester.getSize(find.byKey(const ValueKey('glass-switch-target'))).height,
      48,
    );
  });

  testWidgets('knob colour: ash off, bone on', (tester) async {
    Color knob() => (tester
        .widget<ColoredBox>(find.byKey(const ValueKey('glass-switch-diamond')))
        .color);
    await tester.pumpWidget(
      glassHost(
        GlassSwitch(value: false, onChanged: (_) {}, semanticLabel: 'x'),
      ),
    );
    expect(knob(), p.ash);
    await tester.pumpWidget(
      glassHost(
        GlassSwitch(value: true, onChanged: (_) {}, semanticLabel: 'x'),
      ),
    );
    expect(knob(), p.bone);
  });

  testWidgets(
    'a tap fires onChanged with the flipped value; semantics toggled',
    (tester) async {
      bool? got;
      await tester.pumpWidget(
        glassHost(
          GlassSwitch(
            value: true,
            onChanged: (v) => got = v,
            semanticLabel: 'Haptics',
          ),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Haptics')),
        matchesSemantics(
          label: 'Haptics',
          hasToggledState: true,
          isToggled: true,
          hasTapAction: true,
        ),
      );
      await tester.tap(find.byType(GlassSwitch));
      expect(got, isFalse);
    },
  );
}
