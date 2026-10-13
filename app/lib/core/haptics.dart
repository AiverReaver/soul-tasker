import 'package:flutter/services.dart';

/// The only place the app touches the platform haptics (design doc §8.3).
///
/// It never stores the on/off value: [_isEnabled] is asked on every haptic,
/// so a switch flipped in settings applies to objects that already exist,
/// including a hold in progress (plan D10).
class Haptics {
  const Haptics(this._isEnabled);

  /// Gap between the two impacts of [doubleHeavy] (Boss-tier landing).
  static const doubleGap = Duration(milliseconds: 120);

  final bool Function() _isEnabled;

  void tick() => _send(HapticFeedback.selectionClick);
  void light() => _send(HapticFeedback.lightImpact);
  void medium() => _send(HapticFeedback.mediumImpact);
  void heavy() => _send(HapticFeedback.heavyImpact);

  /// The second impact re-checks the setting when it fires.
  void doubleHeavy() {
    heavy();
    Future<void>.delayed(doubleGap, heavy);
  }

  void _send(Future<void> Function() haptic) {
    if (_isEnabled()) haptic();
  }
}
