import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/commitment_resolver.dart';
import '../../core/sounds.dart';
import '../../core/theme.dart';
import '../../data/day_dao.dart';
import '../../data/enums.dart';
import '../../data/plan_pick_dao.dart';
import '../../data/providers.dart';
import '../../ui/accuracy_line.dart';
import '../../ui/check_in_card.dart';
import '../../ui/day_summary.dart';
import '../../ui/ember_button.dart';
import '../../ui/ember_tally.dart';
import '../../ui/flash_line.dart';
import '../../ui/flask_pips.dart';
import '../../ui/pick_row.dart';
import '../../ui/player_health_bar.dart';
import '../../ui/reminder_invite.dart';
import '../../ui/plan_banner.dart';
import '../ritual/reminder_coordinator.dart';

/// The bonfire (§5.6): review the day, write one lesson, pick tomorrow's
/// three, rest. Holds the lesson field and the picks; the widgets are in `ui/`.
class BonfireScreen extends ConsumerStatefulWidget {
  const BonfireScreen({super.key});

  @override
  ConsumerState<BonfireScreen> createState() => _BonfireScreenState();
}

class _BonfireScreenState extends ConsumerState<BonfireScreen>
    with WidgetsBindingObserver {
  final _lesson = TextEditingController();
  final _picked = <String>[];
  String? _flash;

  /// The check-in line after answering or dismissing; the card then leaves
  /// for this visit (Stage 6 plan D6).
  bool _isCheckInDone = false;
  String? _checkInLine;

  // Held here: ref is not safe to read in dispose.
  late final Sounds _sounds = ref.read(soundsProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sounds.startHum();
  }

  /// The hum plays only while the bonfire is on screen and the app is open.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sounds.startHum();
    } else {
      _sounds.stopHum();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sounds.stopHum();
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
    final days = ref.read(dayDaoProvider);
    final didRest = await days.rest(
      lesson: _lesson.text,
      pickTaskIds: List.of(_picked),
    );
    if (!didRest || !mounted) return;
    await _inviteReminder(days);
  }

  Future<void> _checkIn(CheckInAnswer? answer) async {
    setState(() {
      _isCheckInDone = true;
      _checkInLine = answer == null ? null : 'Thank you.';
    });
    final signals = ref.read(signalDaoProvider);
    await (answer == null
        ? signals.add(SignalKind.checkInDismissed)
        : signals.add(SignalKind.checkIn, value: answer.index));
  }

  /// Rest after a fall (§5.6): full health and banked embers, nothing more.
  Future<void> _rise() async {
    ref.read(hapticsProvider).medium();
    await ref.read(dayDaoProvider).rise();
  }

  /// Once, after the very first rest, if the reminder is still off (D6).
  Future<void> _inviteReminder(DayDao days) async {
    final isOn = (await ref.read(settingsDaoProvider).read()).reminderEnabled;
    if (isOn || await days.restCount() != 1 || !mounted) return;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialog) => ReminderInvite(
        onAccept: () => Navigator.pop(dialog, true),
        onDecline: () => Navigator.pop(dialog, false),
      ),
    );
    if (!(accepted ?? false) || !mounted) return;
    final isGranted = await ref.read(reminderCoordinatorProvider).enable();
    if (!isGranted && mounted) {
      setState(() => _flash = 'No reminder without permission.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final status = ref.watch(dayStatusProvider).value;
    final summary = ref.watch(daySummaryProvider).value;
    final isRested = status?.isRested ?? false;
    final health = ref.watch(healthProvider).value;
    final isFallen = health == 0;
    final accuracy = ref.watch(accuracyProvider).value;
    final checkIn = ref.watch(checkInDueProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text('BONFIRE', style: text.labelSmall)),
      body: SafeArea(
        child: status == null || summary == null
            ? const SizedBox.shrink()
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, Space.xl),
                children: [
                  if (isRested) ...[
                    Text('You have rested.', style: text.titleMedium),
                    FlashLine(_flash),
                    const SizedBox(height: Space.md),
                  ],
                  if (!isRested && !isFallen) ...[
                    Text('Rest a while.', style: text.displayMedium),
                    const SizedBox(height: Space.md),
                  ],
                  DaySummary(
                    strikes: summary.strikes,
                    tried: summary.tried,
                    falls: summary.falls,
                    lessons: summary.lessons,
                    dayLesson: summary.dayLesson,
                  ),
                  if (checkIn != null && !_isCheckInDone && !isFallen) ...[
                    const SizedBox(height: Space.md),
                    CheckInCard(
                      onAnswer: _checkIn,
                      onDismiss: () => _checkIn(null),
                    ),
                  ],
                  if (_checkInLine != null) FlashLine(_checkInLine),
                  const SizedBox(height: Space.md),
                  EmberTally(
                    carried: summary.embers.carried,
                    banked: summary.embers.banked,
                  ),
                  const SizedBox(height: Space.md),
                  FlaskPips(count: status.flasks, cap: kFlaskCap),
                  if (health != null) ...[
                    const SizedBox(height: Space.md),
                    PlayerHealthBar(health: health, max: kMaxHealthHalfPoints),
                  ],
                  if (accuracy != null) ...[
                    const SizedBox(height: Space.sm),
                    AccuracyLine(
                      todayKept: accuracy.today.kept,
                      todayMade: accuracy.today.made,
                      weekKept: accuracy.week.kept,
                      weekMade: accuracy.week.made,
                    ),
                  ],
                  const SizedBox(height: Space.lg),
                  if (isFallen)
                    ..._fallen(text)
                  else if (isRested)
                    _tomorrow()
                  else
                    ..._plan(text),
                ],
              ),
      ),
    );
  }

  /// While fallen only Rise is offered (Stage 4 plan D15).
  List<Widget> _fallen(TextTheme text) => [
    Text('You have fallen.', style: text.titleMedium),
    const SizedBox(height: Space.sm),
    Text('Rest here to rise again today.', style: text.bodySmall),
    const SizedBox(height: Space.md),
    Align(
      alignment: Alignment.centerRight,
      child: EmberButton(label: 'Rise', onPressed: _rise),
    ),
  ];

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
        cursorColor: context.palette.silk,
        decoration: InputDecoration(
          hintText: 'One line, if you like.',
          hintStyle: TextStyle(color: context.palette.ash),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: context.palette.dim),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: context.palette.silk),
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
        child: EmberButton(label: 'Rest at the hearth', onPressed: _rest),
      ),
    ];
  }
}
