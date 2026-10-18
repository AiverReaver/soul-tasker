import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/diamond_pip.dart';
import 'package:hearthrise/ui/strength_segments.dart';
import 'package:material_ui/material_ui.dart';

const _options = [
  StrengthOption(label: 'Light', pips: 1, note: '+1 embers'),
  StrengthOption(label: 'Heavy', pips: 2, note: '+3 embers'),
  StrengthOption(label: 'Boss-tier', pips: 3, note: '+6 embers'),
];

void main() {
  Future<void> pump(WidgetTester tester, int selected, ValueChanged<int> on) =>
      tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(),
          home: Scaffold(
            body: StrengthSegments(
              options: _options,
              selected: selected,
              onChanged: on,
            ),
          ),
        ),
      );

  testWidgets('each segment shows its label, pips and embers note', (
    tester,
  ) async {
    await pump(tester, 0, (_) {});
    for (final o in _options) {
      expect(find.text(o.label), findsOneWidget);
      expect(find.text(o.note), findsOneWidget);
    }
    expect(find.byType(DiamondPip), findsNWidgets(6));
  });

  testWidgets('the selected one is marked, and taps report the index', (
    tester,
  ) async {
    int? tapped;
    await pump(tester, 1, (i) => tapped = i);
    bool? selectedOf(String label) => tester
        .widget<Semantics>(
          find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.label == label,
          ),
        )
        .properties
        .selected;
    expect(selectedOf('Heavy, +3 embers'), isTrue);
    expect(selectedOf('Light, +1 embers'), isFalse);
    await tester.tap(find.text('Boss-tier'));
    expect(tapped, 2);
  });
}
