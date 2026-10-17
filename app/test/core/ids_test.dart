import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/ids.dart';

void main() {
  final uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-([0-9a-f])[0-9a-f]{3}-[0-9a-f]{4}-[0-9a-f]{12}$',
  );
  int versionOf(String id) => int.parse(uuid.firstMatch(id)!.group(1)!);

  test('systemId is a uuid v5', () {
    expect(versionOf(systemId(['b1', '2026-10-13', 'missedDay'])), 5);
  });

  test('the same parts give the same id', () {
    expect(systemId(['b1', 'missedDay']), systemId(['b1', 'missedDay']));
  });

  test('different parts give different ids', () {
    expect(systemId(['b1', 'x']), isNot(systemId(['b2', 'x'])));
    // Parts are not simply concatenated.
    expect(systemId(['ab', 'c']), isNot(systemId(['a', 'bc'])));
  });

  test('newId stays a v4 and never equals a system id', () {
    final id = newId();
    expect(versionOf(id), 4);
    expect(id, isNot(systemId([id])));
  });
}
