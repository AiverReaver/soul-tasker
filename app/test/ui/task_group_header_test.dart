import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/ui/task_group_header.dart';

import 'glass_host.dart';

void main() {
  testWidgets('shows the label in caps and the count', (tester) async {
    await tester.pumpWidget(
      glassHost(
        const TaskGroupHeader(label: 'The Day · daily', count: '1 of 3'),
      ),
    );
    expect(find.text('THE DAY · DAILY'), findsOneWidget);
    expect(find.text('1 of 3'), findsOneWidget);
  });
}
