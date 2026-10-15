import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:hearthrise/core/sounds.dart';
import 'package:hearthrise/data/providers.dart';

/// Records what reaches the audio player, so cues can be tested without
/// audio. [throws] makes every call fail, to test that errors are swallowed.
class FakeSoundPlayer implements SoundPlayer {
  FakeSoundPlayer({this.throws = false});

  final bool throws;
  final calls = <String>[];

  Future<void> _log(String call) async {
    calls.add(call);
    if (throws) throw StateError('no audio device');
  }

  @override
  Future<void> play(Cue cue) => _log('play:${cue.name}');

  @override
  Future<void> startHum() => _log('hum:start');

  @override
  Future<void> stopHum() => _log('hum:stop');

  Override get asOverride => soundPlayerProvider.overrideWithValue(this);
}
