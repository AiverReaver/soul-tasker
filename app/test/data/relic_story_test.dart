import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/relic_story.dart';

void main() {
  const story = RelicStory(
    title: 'The Certification',
    defeatMeaning: 'I am certified',
    phases: ['Learn', 'Fight'],
    lessons: [
      RelicLesson(
        attempt: 1,
        cause: FallCause.declared,
        text: 'Started too late.',
      ),
      RelicLesson(
        attempt: 2,
        cause: FallCause.missedDay,
        text: 'Skipped the warm-up.',
      ),
    ],
  );

  test('round-trips through JSON text', () {
    final back = RelicStory.decode(story.encode());
    expect(back.title, story.title);
    expect(back.defeatMeaning, 'I am certified');
    expect(back.phases, ['Learn', 'Fight']);
    expect(back.lessons.map((l) => l.text), [
      'Started too late.',
      'Skipped the warm-up.',
    ]);
    expect(back.lessons.last.attempt, 2);
    expect(back.lessons.last.cause, FallCause.missedDay);
  });

  test('a missing defeat meaning stays null', () {
    const bare = RelicStory(
      title: 'T',
      defeatMeaning: null,
      phases: [],
      lessons: [],
    );
    expect(RelicStory.decode(bare.encode()).defeatMeaning, isNull);
  });

  test('bad JSON fails with a clear error', () {
    expect(
      () => RelicStory.decode('not json'),
      throwsA(isA<FormatException>()),
    );
    expect(() => RelicStory.decode('[]'), throwsA(isA<FormatException>()));
    expect(
      () => RelicStory.decode(jsonEncode({'title': 3})),
      throwsA(isA<FormatException>()),
    );
  });
}
