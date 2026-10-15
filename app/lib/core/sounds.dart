import 'package:flutter/foundation.dart';

/// The one-shot cues (Stage 5 plan D12). The bonfire hum is a loop and has its
/// own start and stop.
enum Cue { victory, fallen }

/// The audio side: plays what it is told, no rules. The real one is
/// `AudioSoundPlayer`; tests use a fake.
abstract interface class SoundPlayer {
  Future<void> play(Cue cue);
  Future<void> startHum();
  Future<void> stopHum();
}

/// Plays nothing. The default until real audio is wired in.
class SilentSoundPlayer implements SoundPlayer {
  const SilentSoundPlayer();

  @override
  Future<void> play(Cue cue) async {}

  @override
  Future<void> startHum() async {}

  @override
  Future<void> stopHum() async {}
}

typedef SoundErrorHandler = void Function(Object error, StackTrace stack);

void _logSoundError(Object error, StackTrace stack) => FlutterError.reportError(
  FlutterErrorDetails(exception: error, stack: stack, library: 'sounds'),
);

/// The only place screens ask for sound (§8.2), like `Haptics`. It asks
/// [_isEnabled] on every cue, so the setting applies at once, and it never
/// lets an audio failure reach a screen: errors go to [onError].
class Sounds {
  const Sounds(this._player, this._isEnabled, {this.onError = _logSoundError});

  final SoundPlayer _player;
  final bool Function() _isEnabled;
  final SoundErrorHandler onError;

  Future<void> victory() => _guard(() => _player.play(Cue.victory));

  Future<void> fallen() => _guard(() => _player.play(Cue.fallen));

  Future<void> startHum() => _guard(_player.startHum);

  /// Always reaches the player, so a hum never outlives the setting.
  Future<void> stopHum() => _guard(_player.stopHum, isGated: false);

  Future<void> _guard(
    Future<void> Function() action, {
    bool isGated = true,
  }) async {
    if (isGated && !_isEnabled()) return;
    try {
      await action();
    } catch (e, s) {
      onError(e, s);
    }
  }
}
