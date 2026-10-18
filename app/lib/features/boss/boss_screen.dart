import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/commitment_resolver.dart' show kMaxHealthHalfPoints;
import '../../core/roman.dart';
import '../../core/theme.dart';
import '../../data/boss_view.dart';
import '../../data/enums.dart';
import '../../data/providers.dart';
import '../fallen/fallen_screen.dart';
import '../../core/clock.dart';
import '../../core/days_left.dart';
import '../../ui/boss_actions_sheet.dart';
import '../../ui/flash_line.dart';
import '../../ui/glass_alert.dart';
import '../../ui/glass_circle_button.dart';
import '../../ui/glass_sheet.dart';
import '../../ui/shard_meter.dart';
import '../../ui/stroke_icon.dart';
import '../../ui/thread_divider.dart';
import 'boss_stage.dart';
import 'rule_of_three_sheet.dart';
import 'task_row.dart';

class BossScreen extends ConsumerStatefulWidget {
  const BossScreen({super.key, required this.bossId});

  final String bossId;

  @override
  ConsumerState<BossScreen> createState() => _BossScreenState();
}

class _BossScreenState extends ConsumerState<BossScreen> {
  String? _flash;

  void _say(String message) {
    if (mounted) setState(() => _flash = message);
  }

  Future<void> _fall() async {
    final boss = (await ref.read(bossDaoProvider).loadBoss(widget.bossId))
        ?.boss;
    if (!mounted) return;
    final lesson = await FallenScreen.show(
      context,
      ref.read(hapticsProvider),
      sounds: ref.read(soundsProvider),
      story: boss == null
          ? null
          : FallenStory(
              attempt: boss.attemptNumber,
              bossTitle: boss.title,
              health: ref.read(healthProvider).value,
              maxHealth: kMaxHealthHalfPoints,
            ),
    );
    if (!mounted) return;
    final prompt = await ref
        .read(attemptDaoProvider)
        .fall(widget.bossId, lesson);
    if (!mounted) return;
    setState(() => _flash = null);
    if (prompt) {
      await showRuleOfThree(
        context,
        ref,
        bossId: widget.bossId,
        onMessage: _say,
      );
    }
  }

  Future<void> _openActions(BossView view) async {
    final boss = view.boss;
    final action = await showGlassSheet<BossAction>(
      context,
      (_) => BossActionsSheet(
        bossName: boss.title,
        isActive: boss.status == BossStatus.active,
        isWaiting: boss.status == BossStatus.waiting,
        isPinned: boss.isPinned,
      ),
    );
    if (action == null || !mounted) return;
    final dao = ref.read(bossDaoProvider);
    switch (action) {
      case BossAction.leave:
        final kept = ref.read(profileProvider).value?.banked ?? 0;
        final choice = await showGlassAlert(
          context,
          label: boss.title,
          title: 'Leave the fight?',
          body:
              'Struck foes stay struck and you keep $kept embers. '
              '${boss.title} waits where you left it.',
          actions: const ['Keep fighting', 'Leave for now'],
        );
        if (choice != 1 || !mounted) return;
        await dao.setStatus(boss.id, BossStatus.waiting);
        if (mounted) context.go('/');
      case BossAction.resume:
        await dao.setStatus(boss.id, BossStatus.active);
      case BossAction.edit:
        context.push('/boss/${boss.id}/edit');
      case BossAction.pin:
        await dao.setPinned(boss.id, isPinned: !boss.isPinned);
      case BossAction.victory:
        await confirmDefeat(context, ref, boss.id);
      case BossAction.failed:
        await _fall();
    }
  }

  void _back() => context.canPop() ? context.pop() : context.go('/');

  @override
  Widget build(BuildContext context) {
    final boss = ref.watch(bossDetailProvider(widget.bossId));
    final tapMode = ref.watch(settingsProvider).value?.tapMode ?? false;
    return Scaffold(
      body: SafeArea(
        child: switch (boss) {
          AsyncData(value: final view?) => Column(
            children: [
              _header(view),
              Expanded(child: _body(context, view, tapMode)),
            ],
          ),
          AsyncData() => Column(
            children: [
              _header(null),
              const Expanded(child: Center(child: Text('This boss is gone.'))),
            ],
          ),
          AsyncError() => const Center(
            child: Text('Could not load this boss.'),
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  Widget _header(BossView? view) => Padding(
    padding: const EdgeInsets.fromLTRB(20, Space.sm, 20, Space.sm),
    child: Row(
      children: [
        GlassCircleButton(
          icon: StrokeIcons.back,
          semanticLabel: 'Back',
          onTap: _back,
        ),
        Expanded(
          child: Center(
            child: Text(
              (view == null ? null : _phaseLabel(view)) ?? '',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
        if (view != null)
          GlassCircleButton(
            icon: StrokeIcons.more,
            semanticLabel: 'Boss actions',
            onTap: () => _openActions(view),
          )
        else
          const SizedBox(width: 48),
      ],
    ),
  );

  Widget _body(BuildContext context, BossView view, bool tapMode) {
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    final boss = view.boss;
    Widget row(TaskView t) => TaskRow(
      view: t,
      tapMode: tapMode,
      onMessage: _say,
      canCommit: boss.status == BossStatus.active,
      bossName: boss.title,
    );

    final current = view.currentPhase;
    // The boss kneels between phases: an earlier phase is done and the
    // next has not been touched yet.
    final isFelled =
        current != null &&
        view.phases.indexOf(current) > 0 &&
        view.phases.any((ph) => ph != current && ph.isDone) &&
        !current.tasks.any((t) => t.isStruck && !t.isDaily);
    final days = daysLeftLabel(boss.targetDate, ref.read(clockProvider)());
    final lesson = view.lastLesson;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, Space.xl),
      children: [
        BossStage(health: view.health, felled: isFelled),
        const SizedBox(height: Space.sm),
        Text(boss.title, style: text.displaySmall),
        if (boss.defeatMeaning case final meaning?) ...[
          const SizedBox(height: Space.xs),
          Text(meaning, style: text.bodySmall),
        ],
        const SizedBox(height: Space.sm),
        Text.rich(
          TextSpan(
            style: text.bodyMedium,
            children: [
              TextSpan(
                text: ['Attempt ${boss.attemptNumber}', ?days].join(' · '),
              ),
              if (lesson != null) ...[
                const TextSpan(text: ' · Last lesson: '),
                TextSpan(
                  text: lesson,
                  style: text.titleMedium!.copyWith(
                    fontStyle: FontStyle.italic,
                    fontSize: text.bodyMedium?.fontSize,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: Space.md),
        if (view.hasSegments) ...[
          Row(
            children: [
              Expanded(child: Text('Boss health', style: text.labelSmall)),
              Text(
                '${shardsFor(view.health)} / ${ShardMeter.count}',
                style: text.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: Space.xs),
          ShardMeter(filled: shardsFor(view.health)),
        ] else
          Text('This foe is worn down by habit.', style: text.bodySmall),
        const SizedBox(height: Space.sm),
        // Always one child here, so the rows below keep their elements when
        // the hint goes away with the last phase.
        if (view.hasSegments && current != null)
          Text(
            isFelled
                ? '${boss.title} kneels. Phase '
                      '${romanNumeral(view.phases.indexOf(current) + 1)} awaits.'
                : 'Each strike takes shards from ${_withThe(boss.title)}.',
            style: text.bodySmall?.copyWith(color: p.ash),
          )
        else
          const SizedBox.shrink(),
        FlashLine(_flash),
        for (final ph in view.phases) ...[
          if (ph == current)
            _currentHeading(context, ph)
          else
            _header2(context, ph.phase.name, isDone: ph.isDone),
          for (final t in ph.tasks) row(t),
        ],
        if (view.standalone.isNotEmpty) ...[
          _header2(context, 'Beyond the phases'),
          for (final t in view.standalone) row(t),
        ],
      ],
    );
  }

  /// "the Certification" for "The Certification", "the Habit" for "Habit".
  static String _withThe(String title) =>
      title.startsWith('The ') ? 'the ${title.substring(4)}' : 'the $title';

  Widget _currentHeading(BuildContext context, PhaseView ph) {
    final text = Theme.of(context).textTheme;
    final struck = ph.tasks.where((t) => t.isStruck).length;
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ph.phase.name,
            style: text.titleMedium!.copyWith(fontSize: 22, height: 26 / 22),
          ),
          const SizedBox(height: Space.xs),
          Text(
            '$struck of ${ph.tasks.length} struck · hold to strike',
            style: text.bodySmall,
          ),
          const SizedBox(height: Space.sm),
          const ThreadDivider(),
        ],
      ),
    );
  }

  /// "Phase II of III" while a fight has a phase under way.
  String? _phaseLabel(BossView view) {
    final fighting = view.phases
        .where((p) => p.tasks.any((t) => t.isSegment))
        .toList();
    final current = view.currentPhase;
    if (current == null || !fighting.contains(current)) return null;
    return 'Phase ${romanNumeral(fighting.indexOf(current) + 1)} '
        'of ${romanNumeral(fighting.length)}';
  }

  Widget _header2(BuildContext context, String name, {bool isDone = false}) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(name.toUpperCase(), style: text.labelSmall)),
          if (isDone) Text('Done', style: text.bodySmall),
        ],
      ),
    );
  }
}
