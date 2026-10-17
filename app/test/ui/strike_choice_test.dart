import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/dust_vanish.dart';
import 'package:hearthrise/ui/strike_choice_dialog.dart';
import 'package:material_ui/material_ui.dart';

Future<bool?> _open(WidgetTester tester, String tap) async {
  bool? result;
  var closed = false;
  await tester.pumpWidget(
    MaterialApp(
      theme: buildTheme(),
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showDialog<bool>(
              context: context,
              builder: (_) => const StrikeChoiceDialog(title: 'The task'),
            );
            closed = true;
          },
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  expect(find.text('The task'), findsOneWidget);
  await tester.tap(find.text(tap));
  await tester.pumpAndSettle();
  expect(closed, isTrue);
  return result;
}

void main() {
  testWidgets('Strike pops true', (tester) async {
    expect(await _open(tester, 'Strike'), isTrue);
  });

  testWidgets('Tried pops false', (tester) async {
    expect(await _open(tester, 'Tried'), isFalse);
  });

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
