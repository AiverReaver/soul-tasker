import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/ui/filter_chips.dart';
import 'package:material_ui/material_ui.dart';

import 'glass_host.dart';

void main() {
  testWidgets('shows every label, marks the selected, reports a tap', (
    tester,
  ) async {
    String? picked = 'unset';
    await tester.pumpWidget(
      glassHost(
        FilterChips(
          labels: const {null: 'All', 'a': 'Certification', 'b': 'Garage'},
          selected: 'a',
          onChanged: (v) => picked = v,
        ),
      ),
    );
    for (final l in ['All', 'Certification', 'Garage']) {
      expect(find.text(l), findsOneWidget);
    }
    bool? selectedOf(String label) => tester
        .widget<Semantics>(
          find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.label == label,
          ),
        )
        .properties
        .selected;
    expect(selectedOf('Certification'), isTrue);
    expect(selectedOf('All'), isFalse);
    await tester.tap(find.text('All'));
    expect(picked, isNull);
    await tester.tap(find.text('Garage'));
    expect(picked, 'b');
  });
}
