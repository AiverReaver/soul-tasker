import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/features/strike/boss_vanish.dart';
import 'package:hearthrise/ui/dust_vanish.dart';
import 'package:material_ui/material_ui.dart';

Widget _host(void Function() onDone, {bool reduceMotion = false}) =>
    MaterialApp(
      theme: buildTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: child!,
      ),
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            await showBossVanish(context, 'The Hollow King');
            onDone();
          },
          child: const Text('go'),
        ),
      ),
    );

void main() {
  testWidgets('the boss name dissolves into dust, then the future completes', (
    tester,
  ) async {
    var done = false;
    await tester.pumpWidget(_host(() => done = true));
    await tester.tap(find.text('go'));
    await tester.pump();
    expect(find.text('The Hollow King'), findsOneWidget);

    await tester.pump(kBossVanishDuration ~/ 2);
    expect(find.byKey(kDustPainterKey), findsOneWidget);
    expect(done, isFalse);

    await tester.pump(kBossVanishDuration);
    await tester.pumpAndSettle();
    expect(done, isTrue);
    expect(find.text('The Hollow King'), findsNothing);
  });

  testWidgets('reduced motion skips it', (tester) async {
    var done = false;
    await tester.pumpWidget(_host(() => done = true, reduceMotion: true));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(done, isTrue);
    expect(find.text('The Hollow King'), findsNothing);
  });
}
