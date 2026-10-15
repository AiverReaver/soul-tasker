import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/choice_dialog.dart';
import 'package:hearthrise/ui/setting_choice_row.dart';
import 'package:hearthrise/ui/setting_switch_row.dart';
import 'package:hearthrise/ui/setting_value_row.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: buildTheme(),
    home: Scaffold(body: child),
  ),
);

void main() {
  testWidgets('SettingSwitchRow shows its state and fires onChanged', (
    tester,
  ) async {
    bool? changed;
    await _pump(
      tester,
      SettingSwitchRow(
        title: 'Haptics',
        value: true,
        onChanged: (v) => changed = v,
      ),
    );
    expect(find.text('Haptics'), findsOneWidget);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      true,
    );

    await tester.tap(find.text('Haptics'));
    expect(changed, isFalse);
  });

  testWidgets('SettingValueRow shows title and value and fires onTap', (
    tester,
  ) async {
    var taps = 0;
    await _pump(
      tester,
      SettingValueRow(
        title: 'Reminder time',
        value: '9:00 PM',
        onTap: () => taps++,
      ),
    );
    expect(find.text('Reminder time'), findsOneWidget);
    expect(find.text('9:00 PM'), findsOneWidget);
    await tester.tap(find.text('Reminder time'));
    expect(taps, 1);
  });

  testWidgets('SettingChoiceRow marks the selected option and reports a pick', (
    tester,
  ) async {
    String? picked;
    await _pump(
      tester,
      SettingChoiceRow<String>(
        title: 'On a failed attempt',
        options: const {'a': 'Nothing', 'b': 'Whole boss'},
        selected: 'a',
        onChanged: (v) => picked = v,
      ),
    );
    expect(find.text('On a failed attempt'), findsOneWidget);
    await tester.tap(find.text('Whole boss'));
    expect(picked, 'b');
  });

  testWidgets('ChoiceDialog lists its options and reports the pick', (
    tester,
  ) async {
    int? picked;
    await _pump(
      tester,
      ChoiceDialog<int>(
        title: 'Day starts at',
        options: const {0: '12:00 AM', 2: '2:00 AM'},
        onPicked: (v) => picked = v,
      ),
    );
    expect(find.text('Day starts at'), findsOneWidget);
    expect(find.byType(SimpleDialogOption), findsNWidgets(2));
    await tester.tap(find.text('2:00 AM'));
    expect(picked, 2);
  });
}
