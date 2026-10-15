import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/sounds.dart';

import '../support/fake_sounds.dart';

void main() {
  test('with sound off, nothing reaches the player', () async {
    final player = FakeSoundPlayer();
    final sounds = Sounds(player, () => false);
    await sounds.victory();
    await sounds.fallen();
    await sounds.startHum();
    expect(player.calls, isEmpty);
  });

  test('with sound on, each cue reaches the player once', () async {
    final player = FakeSoundPlayer();
    final sounds = Sounds(player, () => true);
    await sounds.victory();
    await sounds.fallen();
    expect(player.calls, ['play:victory', 'play:fallen']);
  });

  test('the hum starts and stops', () async {
    final player = FakeSoundPlayer();
    final sounds = Sounds(player, () => true);
    await sounds.startHum();
    await sounds.stopHum();
    expect(player.calls, ['hum:start', 'hum:stop']);
  });

  test('the hum stops even if sound was turned off while it played', () async {
    final player = FakeSoundPlayer();
    var isOn = true;
    final sounds = Sounds(player, () => isOn);
    await sounds.startHum();
    isOn = false;
    await sounds.stopHum();
    expect(player.calls, ['hum:start', 'hum:stop']);
  });

  test('a player error is logged and swallowed', () async {
    final errors = <Object>[];
    final sounds = Sounds(
      FakeSoundPlayer(throws: true),
      () => true,
      onError: (e, _) => errors.add(e),
    );
    await sounds.victory();
    await sounds.startHum();
    await sounds.stopHum();
    expect(errors, hasLength(3));
  });

  test('the silent player does nothing and never throws', () async {
    final sounds = Sounds(const SilentSoundPlayer(), () => true);
    await sounds.victory();
    await sounds.startHum();
    await sounds.stopHum();
  });
}
