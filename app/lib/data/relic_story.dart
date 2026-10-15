import 'dart:convert';

import 'package:flutter/foundation.dart' show immutable;

import 'enums.dart';

/// One lesson in a relic's story: the attempt it followed and why it fell.
@immutable
class RelicLesson {
  const RelicLesson({
    required this.attempt,
    required this.cause,
    required this.text,
  });

  final int attempt;
  final FallCause cause;
  final String text;

  Map<String, Object?> toJson() => {
    'attempt': attempt,
    'cause': cause.index,
    'text': text,
  };

  factory RelicLesson.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) _bad('lesson is not an object');
    final attempt = json['attempt'];
    final cause = json['cause'];
    final text = json['text'];
    if (attempt is! int || text is! String) _bad('lesson has wrong fields');
    if (cause is! int || cause < 0 || cause >= FallCause.values.length) {
      _bad('lesson has an unknown cause');
    }
    return RelicLesson(
      attempt: attempt,
      cause: FallCause.values[cause],
      text: text,
    );
  }
}

/// The boss as it was at defeat: the relic's own copy (Stage 5 plan D1).
/// Immutable; stored as one JSON text column.
@immutable
class RelicStory {
  const RelicStory({
    required this.title,
    required this.defeatMeaning,
    required this.phases,
    required this.lessons,
  });

  final String title;
  final String? defeatMeaning;
  final List<String> phases;
  final List<RelicLesson> lessons;

  String encode() => jsonEncode({
    'title': title,
    'defeatMeaning': defeatMeaning,
    'phases': phases,
    'lessons': [for (final l in lessons) l.toJson()],
  });

  /// Throws a [FormatException] naming the problem, never a cast error.
  factory RelicStory.decode(String text) {
    final Object? json;
    try {
      json = jsonDecode(text);
    } on FormatException {
      _bad('relic story is not JSON');
    }
    if (json is! Map<String, dynamic>) _bad('relic story is not an object');
    final title = json['title'];
    final meaning = json['defeatMeaning'];
    final phases = json['phases'];
    final lessons = json['lessons'];
    if (title is! String ||
        (meaning != null && meaning is! String) ||
        phases is! List ||
        phases.any((p) => p is! String) ||
        lessons is! List) {
      _bad('relic story has wrong fields');
    }
    return RelicStory(
      title: title,
      defeatMeaning: meaning as String?,
      phases: phases.cast<String>(),
      lessons: [for (final l in lessons) RelicLesson.fromJson(l)],
    );
  }
}

Never _bad(String why) => throw FormatException(why);
