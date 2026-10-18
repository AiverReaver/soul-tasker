import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/features/shell/press_tracker.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('tells its builder when it is held, then released', (
    tester,
  ) async {
    final seen = <bool>[];
    await tester.pumpWidget(
      MaterialApp(
        home: PressTracker(
          builder: (context, isPressed, onPressChanged) {
            seen.add(isPressed);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => onPressChanged(true),
              onTapUp: (_) => onPressChanged(false),
              child: const SizedBox.square(dimension: 50),
            );
          },
        ),
      ),
    );
    final g = await tester.startGesture(
      tester.getCenter(find.byType(GestureDetector)),
    );
    await tester.pump(const Duration(milliseconds: 150)); // tap-down delay
    expect(seen.last, isTrue);
    await g.up();
    await tester.pump();
    expect(seen.last, isFalse);
  });
}
