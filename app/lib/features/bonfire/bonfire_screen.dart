import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/day_dao.dart';
import '../../data/plan_pick_dao.dart';
import '../../data/providers.dart';
import '../../ui/day_summary.dart';
import '../../ui/ember_button.dart';
import '../../ui/ember_tally.dart';
import '../../ui/flash_line.dart';
import '../../ui/flask_pips.dart';
import '../../ui/pick_row.dart';
import '../../ui/plan_banner.dart';

/// The bonfire (§5.6): review the day, write one lesson, pick tomorrow's
/// three, rest. Holds the lesson field and the picks; the widgets are in `ui/`.
class BonfireScreen extends ConsumerStatefulWidget {
  const BonfireScreen({super.key});

  @override
  ConsumerState<BonfireScreen> createState() => _BonfireScreenState();
}

class _BonfireScreenState extends ConsumerState<BonfireScreen> {
  final _lesson = TextEditingController();
  final _picked = <String>[];
  String? _flash;

  @override
  void dispose() {
    _lesson.dispose();
    super.dispose();
  }

  void _toggle(String taskId, {required bool isOn}) {
    if (isOn && _picked.length >= kMaxPicks) {
      setState(() => _flash = 'Three is enough for one day.');
      return;
    }
    setState(() {
      _flash = null;
      isOn ? _picked.add(taskId) : _picked.remove(taskId);
    });
  }

  Future<void> _rest() async {
    ref.read(hapticsProvider).medium();
    await ref
        .read(dayDaoProvider)
        .rest(lesson: _lesson.text, pickTaskIds: List.of(_picked));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final status = ref.watch(dayStatusProvider).value;
    final summary = ref.watch(daySummaryProvider).value;
    final isRested = status?.isRested ?? false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackground,
        title: Text('BONFIRE', style: text.labelSmall),
      ),
      body: SafeArea(
        child: status == null || summary == null
            ? const SizedBox.shrink()
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, Space.xl),
                children: [
                  if (isRested) ...[
                    Text('You have rested.', style: text.titleMedium),
                    const SizedBox(height: Space.md),
                  ],
                  DaySummary(
                    strikes: summary.strikes,
                    tried: summary.tried,
                    falls: summary.falls,
                    lessons: summary.lessons,
                  ),
                  const SizedBox(height: Space.md),
                  EmberTally(
                    carried: summary.embers.carried,
                    banked: summary.embers.banked,
                  ),
                  const SizedBox(height: Space.md),
                  FlaskPips(count: status.flasks, cap: kFlaskCap),
                  const SizedBox(height: Space.lg),
                  if (isRested) _tomorrow() else ..._plan(text),
                ],
              ),
      ),
    );
  }

  Widget _tomorrow() {
    final picks = ref.watch(tomorrowPicksProvider).value ?? const [];
    if (picks.isEmpty) return const SizedBox.shrink();
    return PlanBanner(
      title: "TOMORROW'S THREE",
      items: [
        for (final p in picks)
          PlanItem(title: p.task.title, bossTitle: p.bossTitle, isDone: false),
      ],
    );
  }

  List<Widget> _plan(TextTheme text) {
    final candidates = ref.watch(pickCandidatesProvider).value ?? const [];
    return [
      Text('What did today teach you?', style: text.titleMedium),
      TextField(
        controller: _lesson,
        maxLength: 120,
        style: text.bodyMedium,
        cursorColor: kEmber,
        decoration: const InputDecoration(
          hintText: 'One line, if you like.',
          hintStyle: TextStyle(color: kTextMuted),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: kAshDim),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: kEmber),
          ),
        ),
      ),
      const SizedBox(height: Space.lg),
      Text("TOMORROW'S THREE", style: text.labelSmall),
      FlashLine(_flash),
      for (final c in candidates)
        PickRow(
          title: c.title,
          bossTitle: c.bossTitle,
          isSelected: _picked.contains(c.taskId),
          onChanged: (isOn) => _toggle(c.taskId, isOn: isOn),
        ),
      const SizedBox(height: Space.md),
      Align(
        alignment: Alignment.centerRight,
        child: EmberButton(label: 'Rest', onPressed: _rest),
      ),
    ];
  }
}
