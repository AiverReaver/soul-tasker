import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/biome_choice_row.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('shows five biomes with swatches and fires onChanged', (
    tester,
  ) async {
    Biome? picked;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: BiomeChoiceRow(
              selected: Biome.pharloom,
              onChanged: (b) => picked = b,
            ),
          ),
        ),
      ),
    );
    for (final b in Biome.values) {
      expect(find.text(b.label), findsOneWidget, reason: b.label);
      expect(find.byKey(ValueKey('swatches-${b.name}')), findsOneWidget);
    }
    await tester.tap(find.text('Moss Grotto'));
    expect(picked, Biome.moss);
  });

  testWidgets('the selected row has a silk edge, the others seam', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: BiomeChoiceRow(selected: Biome.docks, onChanged: (_) {}),
          ),
        ),
      ),
    );
    final p = Biome.pharloom.palette;
    Color edge(Biome b) =>
        ((tester
                            .widget<Container>(
                              find.byKey(ValueKey('biome-${b.name}')),
                            )
                            .decoration!
                        as BoxDecoration)
                    .border!
                as Border)
            .top
            .color;
    expect(edge(Biome.docks), p.silk);
    expect(edge(Biome.moss), p.seam);
  });
}
