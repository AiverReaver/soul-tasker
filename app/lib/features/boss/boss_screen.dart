import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/boss_view.dart';
import '../../data/enums.dart';
import '../../data/providers.dart';
import '../fallen/fallen_screen.dart';
import '../../ui/boss_health_bar.dart';
import '../../ui/flash_line.dart';
import 'rule_of_three_sheet.dart';
import 'task_row.dart';

/// "Attempt N." or "Attempt N. Last time: `lesson`" (§5.4).
String attemptLine(BossView view) => view.lastLesson == null
    ? 'Attempt ${view.boss.attemptNumber}.'
    : 'Attempt ${view.boss.attemptNumber}. Last time: ${view.lastLesson}';

enum _Menu { edit, pin, status, victory }

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
    final lesson = await FallenScreen.show(context, ref.read(hapticsProvider));
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

  Future<void> _onMenu(_Menu item, BossView view) async {
    final dao = ref.read(bossDaoProvider);
    final boss = view.boss;
    switch (item) {
      case _Menu.edit:
        context.push('/boss/${boss.id}/edit');
      case _Menu.pin:
        await dao.setPinned(boss.id, isPinned: !boss.isPinned);
      case _Menu.status:
        await dao.setStatus(
          boss.id,
          boss.status == BossStatus.active
              ? BossStatus.waiting
              : BossStatus.active,
        );
      case _Menu.victory:
        await confirmDefeat(context, ref, boss.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final boss = ref.watch(bossDetailProvider(widget.bossId));
    final tapMode = ref.watch(settingsProvider).value?.tapMode ?? false;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackground,
        actions: [if (boss.value case final view?) _menu(view)],
      ),
      body: SafeArea(
        child: switch (boss) {
          AsyncData(value: final view?) => _body(context, view, tapMode),
          AsyncData() => const Center(child: Text('This boss is gone.')),
          AsyncError() => const Center(
            child: Text('Could not load this boss.'),
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  Widget _menu(BossView view) {
    final boss = view.boss;
    return PopupMenuButton<_Menu>(
      tooltip: 'Boss actions',
      onSelected: (item) => _onMenu(item, view),
      itemBuilder: (_) => [
        const PopupMenuItem(value: _Menu.edit, child: Text('Edit')),
        PopupMenuItem(
          value: _Menu.pin,
          child: Text(boss.isPinned ? 'Unpin' : 'Pin'),
        ),
        if (boss.status != BossStatus.defeated) ...[
          PopupMenuItem(
            value: _Menu.status,
            child: Text(
              boss.status == BossStatus.active ? 'Set waiting' : 'Set active',
            ),
          ),
          const PopupMenuItem(
            value: _Menu.victory,
            child: Text('Declare victory'),
          ),
        ],
      ],
    );
  }

  Widget _body(BuildContext context, BossView view, bool tapMode) {
    final text = Theme.of(context).textTheme;
    Widget row(TaskView t) =>
        TaskRow(view: t, tapMode: tapMode, onMessage: _say);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, Space.xl),
      children: [
        Text(view.boss.title, style: text.displaySmall),
        if (view.boss.defeatMeaning case final meaning?) ...[
          const SizedBox(height: Space.xs),
          Text(meaning, style: text.bodySmall),
        ],
        const SizedBox(height: 20),
        if (view.hasSegments)
          BossHealthBar(groups: view.healthGroups, health: view.health)
        else
          Text('This foe is worn down by habit.', style: text.bodySmall),
        const SizedBox(height: Space.md),
        Text(attemptLine(view), style: text.bodyMedium),
        FlashLine(_flash),
        for (final p in view.phases) ...[
          _header(context, p.phase.name, isDone: p.isDone),
          for (final t in p.tasks) row(t),
        ],
        if (view.standalone.isNotEmpty) ...[
          _header(context, 'Beyond the phases'),
          for (final t in view.standalone) row(t),
        ],
        const SizedBox(height: Space.xl),
        if (view.boss.status == BossStatus.active)
          OutlinedButton(
            onPressed: _fall,
            style: OutlinedButton.styleFrom(
              foregroundColor: kAsh,
              side: const BorderSide(color: kAshDim),
              minimumSize: const Size.fromHeight(kMinTarget),
            ),
            child: const Text('This attempt failed'),
          ),
      ],
    );
  }

  Widget _header(BuildContext context, String name, {bool isDone = false}) {
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
