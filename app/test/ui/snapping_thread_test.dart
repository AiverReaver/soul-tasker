import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/ui/snapping_thread.dart';
import 'package:material_ui/material_ui.dart';

import 'glass_host.dart';

void main() {
  Future<double> gap(WidgetTester tester, double t) async {
    await tester.pumpWidget(
      glassHost(SizedBox(width: 200, child: SnappingThread(t: t))),
    );
    final left = tester.getRect(find.byKey(const ValueKey('thread-left')));
    final right = tester.getRect(find.byKey(const ValueKey('thread-right')));
    return right.left - left.right;
  }

  testWidgets('joined at t = 0, pulled apart at t = 1', (tester) async {
    expect(await gap(tester, 0), 0);
    expect(await gap(tester, 1), greaterThan(20));
  });

  testWidgets('the halves fade out as they part', (tester) async {
    await tester.pumpWidget(glassHost(const SnappingThread(t: 1)));
    final fade = tester.widget<Opacity>(
      find.ancestor(
        of: find.byKey(const ValueKey('thread-left')),
        matching: find.byType(Opacity),
      ),
    );
    expect(fade.opacity, lessThan(1));
  });
}
