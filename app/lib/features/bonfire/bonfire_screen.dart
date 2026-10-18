import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/clock.dart';
import '../../core/sounds.dart';
import '../../core/theme.dart';
import '../../data/day_dao.dart';
import '../../data/enums.dart';
import '../../data/plan_pick_dao.dart';
import '../../data/providers.dart';
import '../../ui/check_in_card.dart';
import '../../ui/ember_button.dart';
import '../../ui/flash_line.dart';
import '../../ui/flask_pips.dart';
import '../../ui/glass_sheet.dart';
import '../../ui/mood_choice.dart';
import '../../ui/needle_text_field.dart';
import '../../ui/tomorrow_pick_sheet.dart';
import '../../ui/tomorrow_row.dart';
import '../../ui/reminder_invite.dart';
import '../../ui/plan_banner.dart';
import '../ritual/reminder_coordinator.dart';

/// The bonfire (D9): a check-in, not a planner. Say how the day went, write
/// one thing for tomorrow, choose tomorrow's foes, rest. Holds the field and
/// the mood; the widgets are in `ui/`.
class BonfireScreen extends ConsumerStatefulWidget {
  const BonfireScreen({super.key});

  @override
  ConsumerState<BonfireScreen> createState() => _BonfireScreenState();
}

class _BonfireScreenState extends ConsumerState<BonfireScreen>
    with WidgetsBindingObserver {
  final _lesson = TextEditingController();
  int? _mood;
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

  static const _moods = ['Fought well', 'Held on', 'I fell'];

  Future<void> _pickMood(int i) async {
    setState(() => _mood = i);
    await ref.read(signalDaoProvider).add(SignalKind.mood, value: i);
  }

  Future<void> _openTomorrow() async {
    final candidates = await ref.read(pickCandidatesProvider.future);
    final picks = await ref.read(tomorrowPicksProvider.future);
    if (!mounted) return;
    final open = {for (final c in candidates) c.taskId};
    final chosen = await showGlassSheet<List<String>>(
      context,
      (_) => _TomorrowPicker(
        candidates: candidates,
        initial: [
          for (final p in picks)
            if (open.contains(p.task.id)) p.task.id,
        ],
      ),
    );
    if (chosen == null) return;
    await ref.read(planPickDaoProvider).setTomorrow(chosen);
    ref.invalidate(tomorrowPicksProvider);
  }

  Future<void> _rest() async {
    ref.read(hapticsProvider).medium();
    final days = ref.read(dayDaoProvider);
    final didRest = await days.rest(lesson: _lesson.text);
    if (!didRest || !mounted) return;
    await _inviteReminder(days);
    // A flash (reminder refused) stays readable here; otherwise on to Home.
    if (mounted && _flash == null) context.go('/');
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
    final isFallen = ref.watch(healthProvider).value == 0;
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
                  if (checkIn != null && !_isCheckInDone && !isFallen) ...[
                    CheckInCard(
                      onAnswer: _checkIn,
                      onDismiss: () => _checkIn(null),
                    ),
                    const SizedBox(height: Space.md),
                  ],
                  if (_checkInLine != null) FlashLine(_checkInLine),
                  if (isFallen)
                    ..._fallen(text)
                  else if (isRested)
                    _tomorrow()
                  else
                    ..._plan(text, status.flasks, summary.strikes),
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

  String? _moodNote(int strikes) => switch (_mood) {
    0 =>
      '$strikes ${strikes == 1 ? 'foe' : 'foes'} struck. The Warden felt it.',
    1 => 'Holding on is a kind of winning.',
    2 => 'You fell. Rise. Embers are kept.',
    _ => null,
  };

  List<Widget> _plan(TextTheme text, int flasks, int strikes) {
    final night = (ref.watch(restCountProvider).value ?? 0) + 1;
    final picks = ref.watch(tomorrowPicksProvider).value ?? const [];
    final titles = [for (final p in picks) p.task.title];
    final settings = ref.watch(settingsProvider).value;
    return [
      Text('Rest a while.', style: text.displayMedium?.copyWith(fontSize: 44)),
      const SizedBox(height: Space.sm),
      Text(
        'Night $night at the hearth. Tell it how the day went.',
        style: text.bodyMedium,
      ),
      const SizedBox(height: Space.lg),
      Text('How did today go?', style: text.titleMedium),
      const SizedBox(height: Space.sm),
      MoodChoice(
        labels: _moods,
        selected: _mood,
        note: _moodNote(strikes),
        onChanged: _pickMood,
      ),
      const SizedBox(height: Space.lg),
      Text('Flasks restored', style: text.titleMedium),
      const SizedBox(height: Space.xs),
      Text('$flasks of $kFlaskCap · ready for tomorrow', style: text.bodySmall),
      const SizedBox(height: Space.sm),
      FlaskPips(count: flasks, cap: kFlaskCap),
      const SizedBox(height: Space.lg),
      NeedleTextField(
        controller: _lesson,
        caption: 'One thing for tomorrow',
        hint: 'Write before noon',
        maxLength: 120,
      ),
      const SizedBox(height: Space.md),
      TomorrowRow(titles: titles, onTap: _openTomorrow, max: kMaxPicks),
      const SizedBox(height: Space.lg),
      Align(
        alignment: Alignment.centerRight,
        child: EmberButton(label: 'Rest at the hearth', onPressed: _rest),
      ),
      if (settings != null && settings.reminderEnabled) ...[
        const SizedBox(height: Space.sm),
        Text(
          'One gentle reminder tomorrow at ${formatClock(settings.reminderMinutes)}.',
          style: text.bodySmall,
        ),
      ],
    ];
  }
}

/// The picker sheet's state: the chosen ids and the "enough" flash. Pops the
/// chosen ids on "Set tomorrow"; Cancel pops nothing.
class _TomorrowPicker extends StatefulWidget {
  const _TomorrowPicker({required this.candidates, required this.initial});

  final List<PickCandidate> candidates;
  final List<String> initial;

  @override
  State<_TomorrowPicker> createState() => _TomorrowPickerState();
}

class _TomorrowPickerState extends State<_TomorrowPicker> {
  late final _picked = [...widget.initial];
  String? _flash;

  void _toggle(String id) {
    if (_picked.contains(id)) {
      setState(() {
        _flash = null;
        _picked.remove(id);
      });
    } else if (_picked.length >= kMaxPicks) {
      setState(() => _flash = 'Three is enough for one day.');
    } else {
      setState(() {
        _flash = null;
        _picked.add(id);
      });
    }
  }

  @override
  Widget build(BuildContext context) => TomorrowPickSheet(
    options: [
      for (final c in widget.candidates)
        PickOption(
          id: c.taskId,
          title: c.title,
          subtitle: '${c.bossTitle} · ${c.weight.label}',
          pips: c.weight.index + 1,
        ),
    ],
    picked: _picked.toSet(),
    flash: _flash,
    onToggle: _toggle,
    onSet: () => Navigator.pop(context, List.of(_picked)),
    max: kMaxPicks,
  );
}
