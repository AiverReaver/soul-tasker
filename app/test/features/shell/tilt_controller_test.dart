import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/features/shell/tilt_controller.dart';

class FakeTiltSource implements TiltSource {
  final controller = StreamController<Gravity>.broadcast();

  @override
  Stream<Gravity> get gravity => controller.stream;

  bool get isListening => controller.hasListener;
}

const _frame = Duration(milliseconds: 16);
const _sample = Duration(milliseconds: 64);

void main() {
  late FakeTiltSource source;
  late TiltController tilt;
  var now = Duration.zero;
  var out = Offset.zero;

  setUp(() {
    source = FakeTiltSource();
    tilt = TiltController(source)..start();
    now = Duration.zero;
    out = Offset.zero;
  });
  tearDown(() => tilt.stop());

  /// Runs [seconds] of 16 ms frames, sending [g] every 64 ms unless null.
  Future<void> run(
    double seconds,
    Gravity? g, {
    Offset idle = Offset.zero,
  }) async {
    final end = now + Duration(milliseconds: (seconds * 1000).round());
    var sinceSample = _sample;
    while (now < end) {
      if (g != null && sinceSample >= _sample) {
        source.controller.add(g);
        await pumpEventQueue();
        sinceSample = Duration.zero;
      }
      now += _frame;
      sinceSample += _frame;
      out = tilt.step(now, _frame, idle);
    }
  }

  const held = (0.0, 6.3, 7.5);
  const rolled = (3.7, 6.3, 7.5); // about 21 degrees of roll from [held]

  test('the first pose it sees is the neutral: no tilt', () async {
    await run(2, held);
    expect(out.dx.abs(), lessThan(0.02));
    expect(out.dy.abs(), lessThan(0.02));
  });

  test('rolling the phone steers the light', () async {
    await run(1, held);
    await run(2, rolled);
    expect(out.dx, greaterThan(0.7));
  });

  test('the tilt fades in over about 0.8 s, from the idle drift', () async {
    const idle = Offset(0.5, 0.5);
    await run(0.05, held, idle: idle);
    expect(out.dx, closeTo(0.5, 0.1), reason: 'first frames are still idle');
    await run(0.4, held, idle: idle);
    expect(out.dx, closeTo(0.25, 0.12), reason: 'about half way');
    await run(0.6, held, idle: idle);
    expect(out.dx.abs(), lessThan(0.05), reason: 'now all tilt, which is zero');
  });

  test('with no event for a second it eases back to the idle drift', () async {
    const idle = Offset(0.5, 0.5);
    await run(2, held, idle: idle);
    expect(out.dx.abs(), lessThan(0.05));
    await run(2.5, null, idle: idle);
    expect(out.dx, closeTo(0.5, 0.05));
  });

  test('lying flat does not move the light or the neutral', () async {
    const idle = Offset(0.5, 0.5);
    await run(2, held, idle: idle);
    await run(3, (0.0, 0.1, 9.8), idle: idle);
    expect(out.dx, closeTo(0.5, 0.05), reason: 'back on the idle drift');
    await run(3, held, idle: idle);
    expect(
      out.dx.abs(),
      lessThan(0.05),
      reason: 'neutral was not recalibrated',
    );
  });

  test('the neutral follows a pose held for a while', () async {
    await run(1, held);
    await run(40, rolled);
    expect(out.dx.abs(), lessThan(0.1));
  });

  test('stop cancels the subscription; start listens and re-centres', () async {
    expect(source.isListening, isTrue);
    await run(1, held);
    tilt.stop();
    expect(source.isListening, isFalse);

    tilt.start();
    expect(source.isListening, isTrue);
    await run(1, rolled); // a new first pose, so a new neutral
    expect(out.dx.abs(), lessThan(0.05));
  });
}
