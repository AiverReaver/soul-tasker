import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/ui/dust_vanish.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget dust(double progress) => MaterialApp(
    home: DustVanish(progress: progress, child: const Text('Boss')),
  );

  testWidgets('dust: child intact at 0, no particles', (tester) async {
    await tester.pumpWidget(dust(0));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
    expect(find.byKey(kDustPainterKey), findsNothing);
  });

  testWidgets('dust: child fades and particles drift mid-way', (tester) async {
    await tester.pumpWidget(dust(0.5));
    final opacity = tester.widget<Opacity>(find.byType(Opacity)).opacity;
    expect(opacity, lessThan(1));
    expect(opacity, greaterThan(0));
    expect(find.byKey(kDustPainterKey), findsOneWidget);
  });

  testWidgets('dust: child gone at 1', (tester) async {
    await tester.pumpWidget(dust(1));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0);
  });
}
