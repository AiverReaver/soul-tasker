import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/ui/day_panel.dart';
import 'package:hearthrise/ui/shard_meter.dart';

import 'glass_host.dart';

void main() {
  testWidgets('title, line, open count and one shard per task', (tester) async {
    await tester.pumpWidget(glassHost(const DayPanel(open: 3, total: 5)));
    expect(find.text('The Day'), findsOneWidget);
    expect(
      find.text('Quick tasks live here. It refills every morning.'),
      findsOneWidget,
    );
    expect(find.text('Day health'), findsOneWidget);
    expect(find.text('3 / 5 open'), findsOneWidget);
    final meter = tester.widget<ShardMeter>(find.byType(ShardMeter));
    expect((meter.filled, meter.total), (3, 5));
    expect(
      find.bySemanticsLabel('Day health: 3 of 5 tasks still open'),
      findsOneWidget,
    );
  });

  testWidgets('empty: no meter, a line that says how to start', (tester) async {
    await tester.pumpWidget(glassHost(const DayPanel(open: 0, total: 0)));
    expect(find.byType(ShardMeter), findsNothing);
    expect(
      find.text('Nothing here yet. Add a quick task and it fights here today.'),
      findsOneWidget,
    );
  });
}
