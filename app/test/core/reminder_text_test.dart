import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/reminder_text.dart';

void main() {
  test('the notification text is fixed and names no boss or task', () {
    expect(kReminderTitle, 'The fire is lit.');
    expect(kReminderBody, 'Come rest when you are ready.');
    // Plain constants: nothing a boss or task title could be mixed into.
    expect(kReminderTitle, isNot(contains(r'$')));
    expect(kReminderBody, isNot(contains(r'$')));
  });
}
