import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show immutable;

import '../core/clock.dart';
import '../core/ids.dart';
import 'database.dart';
import 'enums.dart';
import 'relic_story.dart';

/// A relic row with its decoded story.
@immutable
class RelicView {
  const RelicView(this.relic, this.story);

  final Relic relic;
  final RelicStory story;
}

/// Relics: written once when a boss is defeated, then read-only except for
/// the inscription (Stage 5 plan D1, D7).
class RelicDao {
  RelicDao(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  /// Builds the relic for a defeated boss from its rows, or returns the one
  /// it already has. Call inside the defeat transaction.
  Future<String> createFor(String bossId) async {
    final existing = await (_db.select(
      _db.relics,
    )..where((r) => r.bossId.equals(bossId))).getSingleOrNull();
    if (existing != null) return existing.id;

    final boss = await (_db.select(
      _db.bosses,
    )..where((b) => b.id.equals(bossId))).getSingle();
    final hour = await _db.rolloverHour();
    final defeatedAt = boss.defeatedAt ?? _clock();
    final defeatedDay = dayOf(defeatedAt, rolloverHour: hour);

    final phases =
        await (_db.select(_db.phases)
              ..where((p) => p.bossId.equals(bossId))
              ..orderBy([(p) => OrderingTerm.asc(p.position)]))
            .get();
    final attempts =
        await (_db.select(_db.attempts)
              ..where((a) => a.bossId.equals(bossId) & a.outcome.equals(2))
              ..orderBy([(a) => OrderingTerm.asc(a.at)]))
            .get();
    final earns =
        await (_db.select(_db.emberEvents)..where(
              (e) =>
                  e.bossId.equals(bossId) & e.kind.equals(EmberKind.earn.index),
            ))
            .get();

    final story = RelicStory(
      title: boss.title,
      defeatMeaning: boss.defeatMeaning,
      phases: [for (final p in phases) p.name],
      lessons: [
        for (final a in attempts)
          if ((a.lesson ?? '').trim().isNotEmpty)
            RelicLesson(
              attempt: a.bossAttempt,
              cause: a.cause ?? FallCause.declared,
              text: a.lesson!,
            ),
      ],
    );
    final id = newId();
    await _db
        .into(_db.relics)
        .insert(
          RelicsCompanion.insert(
            id: id,
            bossId: Value(bossId),
            name: 'Relic of ${boss.title}',
            emblem: Weathering.forAttempts(boss.attemptNumber),
            attempts: boss.attemptNumber,
            days: _days(dayOf(boss.createdAt, rolloverHour: hour), defeatedDay),
            effort: earns.fold(0, (sum, e) => sum + e.amount),
            story: story.encode(),
            defeatedDay: defeatedDay,
            createdAt: defeatedAt,
            updatedAt: defeatedAt,
          ),
        );
    return id;
  }

  /// A relic for every defeated boss that lacks one: the v5 upgrade.
  Future<void> backfill() => _db.transaction(() async {
    final defeated = await (_db.select(
      _db.bosses,
    )..where((b) => b.status.equals(BossStatus.defeated.index))).get();
    for (final boss in defeated) {
      await createFor(boss.id);
    }
  });

  /// Ritual days from [from] to [to], both counted; at least 1.
  static int _days(String from, String to) {
    final span = DateTime.parse('${to}T00:00:00Z')
        .difference(DateTime.parse('${from}T00:00:00Z'))
        .inDays;
    return span < 0 ? 1 : span + 1;
  }

  /// Saves the inscription: trimmed, empty as null, 120 characters at most.
  Future<void> setInscription(String relicId, String? text) async {
    final clean = (text ?? '').trim();
    if (clean.length > kInscriptionMax) {
      throw ArgumentError(
        'An inscription is at most $kInscriptionMax characters.',
      );
    }
    await (_db.update(_db.relics)..where((r) => r.id.equals(relicId))).write(
      RelicsCompanion(
        inscription: Value(clean.isEmpty ? null : clean),
        updatedAt: Value(_clock()),
      ),
    );
  }

  /// Most recent first.
  Stream<List<Relic>> watchAll() => (_db.select(
    _db.relics,
  )..orderBy([(r) => OrderingTerm.desc(r.createdAt)])).watch();

  Future<RelicView?> load(String id) async {
    final relic = await (_db.select(
      _db.relics,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
    return relic == null
        ? null
        : RelicView(relic, RelicStory.decode(relic.story));
  }

  Stream<RelicView?> watch(String id) =>
      (_db.select(
        _db.relics,
      )..where((r) => r.id.equals(id))).watchSingleOrNull().map(
        (relic) => relic == null
            ? null
            : RelicView(relic, RelicStory.decode(relic.story)),
      );
}
