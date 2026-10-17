import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/needle_frame.dart';
import 'package:hearthrise/ui/strike_choice_dialog.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('asks how the strike landed, with a ghost Tried and a solid '
      'Strike', (tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await showDialog<bool>(
              context: context,
              builder: (_) => const StrikeChoiceDialog(title: 'Run 3 km'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final title = tester.widget<Text>(find.text('Run 3 km'));
    expect(title.style?.fontStyle, FontStyle.italic);
    expect(find.text('How did the strike land?'), findsOneWidget);

    final p = Biome.pharloom.palette;
    expect(
      tester
          .widget<NeedleFrame>(find.byKey(const ValueKey('choice-Strike')))
          .fill,
      p.silk,
    );
    expect(
      tester
          .widget<NeedleFrame>(find.byKey(const ValueKey('choice-Tried')))
          .fill,
      isNull,
    );

    await tester.tap(find.text('Strike'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });
}
