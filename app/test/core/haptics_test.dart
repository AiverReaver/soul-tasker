import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/haptics.dart';
import 'package:hearthrise/data/providers.dart';

import '../data/harness.dart';
import '../support/recording_haptics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('each method sends its platform haptic', () {
    final sent = recordPlatformHaptics();
    Haptics(() => true)
      ..tick()
      ..light()
      ..medium()
      ..heavy();
    expect(sent, [
      'HapticFeedbackType.selectionClick',
      'HapticFeedbackType.lightImpact',
      'HapticFeedbackType.mediumImpact',
      'HapticFeedbackType.heavyImpact',
    ]);
  });

  testWidgets('doubleHeavy lands twice, doubleGap apart', (tester) async {
    final sent = recordPlatformHaptics();
    Haptics(() => true).doubleHeavy();
    expect(sent, ['HapticFeedbackType.heavyImpact']);

    await tester.pump(Haptics.doubleGap);

    expect(sent, [
      'HapticFeedbackType.heavyImpact',
      'HapticFeedbackType.heavyImpact',
    ]);
  });

  testWidgets(
    'doubleHeavy skips its second impact if switched off in between',
    (tester) async {
      final sent = recordPlatformHaptics();
      var isOn = true;
      Haptics(() => isOn).doubleHeavy();

      isOn = false;
      await tester.pump(Haptics.doubleGap);

      expect(sent, ['HapticFeedbackType.heavyImpact']);
    },
  );

  test('sends nothing when the lookup says off', () {
    final sent = recordPlatformHaptics();
    Haptics(() => false)
      ..tick()
      ..light()
      ..medium()
      ..heavy();
    expect(sent, isEmpty);
  });

  test('an existing object follows the lookup as it flips (D10)', () {
    final sent = recordPlatformHaptics();
    var isOn = true;
    final haptics = Haptics(() => isOn);

    haptics.tick();
    isOn = false;
    haptics.tick();
    haptics.heavy();
    isOn = true;
    haptics.light();

    expect(sent, [
      'HapticFeedbackType.selectionClick',
      'HapticFeedbackType.lightImpact',
    ]);
  });

  test(
    'hapticsProvider reads the live setting under an existing object',
    () async {
      final sent = recordPlatformHaptics();
      final h = Harness();
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(h.db)],
      );
      addTearDown(() async {
        container.dispose();
        await pumpEventQueue();
        await h.db.close();
      });
      container.listen(settingsProvider, (_, _) {});
      await container.read(settingsProvider.future);
      final haptics = container.read(hapticsProvider);

      haptics.tick();
      await h.settings.setHaptics(false);
      await pumpEventQueue();
      haptics.tick();
      await h.settings.setHaptics(true);
      await pumpEventQueue();
      haptics.light();

      expect(sent, [
        'HapticFeedbackType.selectionClick',
        'HapticFeedbackType.lightImpact',
      ]);
    },
  );

  test('hapticsProvider defaults on while settings are loading', () {
    final sent = recordPlatformHaptics();
    final h = Harness();
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(h.db)],
    );
    addTearDown(() async {
      container.dispose();
      await pumpEventQueue();
      await h.db.close();
    });

    container.read(hapticsProvider).tick();

    expect(sent, ['HapticFeedbackType.selectionClick']);
  });
}
