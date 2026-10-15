import 'package:flutter/foundation.dart' show immutable;

/// Each level needs this many more embers than the one before (Stage 5 plan
/// D9): level 2 at 10, level 3 at 30, level 4 at 60.
const kLevelStep = 10;

@immutable
class LevelInfo {
  const LevelInfo({required this.level, required this.toNext});

  final int level;

  /// Banked embers still needed for the next level.
  final int toNext;
}

int _threshold(int level) => kLevelStep * (level - 1) * level ~/ 2;

/// The single level for [banked] lifetime embers. Nothing is spent, so it
/// never goes down; never below 1.
LevelInfo levelFor(int banked) {
  var level = 1;
  while (banked >= _threshold(level + 1)) {
    level++;
  }
  return LevelInfo(level: level, toNext: _threshold(level + 1) - banked);
}
