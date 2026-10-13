import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/haptics.dart';
import 'package:hearthrise/data/providers.dart';

/// Records the haptic types that reach the platform channel, so the real
/// [Haptics] and its setting can be tested end to end.
List<String> recordPlatformHaptics() {
  final sent = <String>[];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    if (call.method == 'HapticFeedback.vibrate') {
      sent.add(call.arguments as String);
    }
    return null;
  });
  addTearDown(
    () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
  );
  return sent;
}

/// Records haptic calls by name instead of touching the platform.
class RecordingHaptics implements Haptics {
  final events = <String>[];

  @override
  void tick() => events.add('tick');

  @override
  void light() => events.add('light');

  @override
  void medium() => events.add('medium');

  @override
  void heavy() => events.add('heavy');

  @override
  void doubleHeavy() => events.add('doubleHeavy');

  Override get asOverride => hapticsProvider.overrideWithValue(this);
}
