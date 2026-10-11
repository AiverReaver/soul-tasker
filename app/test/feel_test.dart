import 'package:flutter_test/flutter_test.dart';
import 'package:soul_tracker/main.dart';
import 'package:soul_tracker/models.dart';

void main() {
  test('fall raises attempt, keeps progress, keeps old lesson on skip', () {
    final boss = sampleBoss().strike(0, 0);

    final skipped = boss.fall(null);

    expect(skipped.attempt, boss.attempt + 1);
    expect(skipped.doneTasks, 1);
    expect(skipped.lastLesson, boss.lastLesson);
    expect(boss.fall('  Sleep more. ').lastLesson, 'Sleep more.');
  });

  testWidgets('full hold strikes, early release does not', (tester) async {
    await tester.pumpWidget(const SoulTrackerApp());
    final row = find.text('Read chapter 4'); // Heavy: 600 ms hold

    var gesture = await tester.startGesture(tester.getCenter(row));
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('It is done.'), findsNothing);

    gesture = await tester.startGesture(tester.getCenter(row));
    await tester.pump(); // first frame sets the animation start time
    await tester.pump(Weight.heavy.holdDuration);
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('It is done.'), findsOneWidget);
  });
}
