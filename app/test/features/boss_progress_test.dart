import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/day_boss.dart';
import 'package:hearthrise/features/home/boss_card.dart';

import '../data/harness.dart';

void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() => h.db.close());

  test('The Day counts today’s tasks, never chapters', () async {
    await h.bosses.ensureDayBoss();
    expect(bossProgressLabel((await h.reload(dayBossId))), 'No tasks today');

    final walk = await h.bosses.addQuickTask('Call the bank');
    await h.bosses.addQuickTask('Water plants');
    expect(bossProgressLabel(await h.reload(dayBossId)), '0 of 2 struck today');

    await h.attempts.strike(walk);
    expect(bossProgressLabel(await h.reload(dayBossId)), '1 of 2 struck today');
  });

  test('a boss with chapters still names the chapter', () async {
    final view = await h.seed();
    expect(bossProgressLabel(view), 'Chapter I of II');
  });
}
