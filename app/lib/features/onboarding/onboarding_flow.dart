import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/clock.dart';
import '../../core/theme.dart';
import '../../data/boss_draft.dart';
import '../../data/enums.dart';
import '../../data/providers.dart';
import '../../ui/onboarding_fields.dart';
import '../../ui/onboarding_page.dart';
import '../../ui/setting_switch_row.dart';
import '../../ui/setting_value_row.dart';
import '../ritual/reminder_coordinator.dart';

const _maxPhases = 3;
const _maxDailies = 3;

/// First run (§6.2, Stage 5 plan D11): five short pages that end in a saved
/// boss. Only a boss title is required; Skip is on every page. A thin
/// container: it holds the draft and the page, and passes values down.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _pages = PageController();
  int _nextId = 0;
  String _title = '';
  String _meaning = '';
  late List<NameListItem> _phases = [
    for (final p in BossDraft.fresh(ResetOnFail.nothing).phases)
      NameListItem(id: _nextId++, text: p.name),
  ];
  late List<NameListItem> _dailies = [NameListItem(id: _nextId++, text: '')];
  bool _wantsReminder = false;
  int _reminderMinutes = 21 * 60;
  bool _isBusy = false;
  int? _addedId;

  bool get _hasTitle => _title.trim().isNotEmpty;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  // Autofocus is ignored while something else holds focus.
  void _release() => FocusManager.instance.primaryFocus?.unfocus();

  // A field on the page we leave would keep the keyboard offscreen.
  void _next() {
    _release();
    _pages.nextPage(
      duration: motionOf(context, Motion.fade),
      curve: Motion.ease,
    );
  }

  /// Skip leaves the setup for the last page, where a boss is still optional.
  void _skipToEnd() {
    _release();
    _pages.animateToPage(
      4,
      duration: motionOf(context, Motion.fade),
      curve: Motion.ease,
    );
  }

  Future<void> _finish({required bool save}) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    final bosses = ref.read(bossDaoProvider);
    final settings = ref.read(settingsDaoProvider);
    final reset = (await settings.read()).defaultResetOnFail;
    if (save && _hasTitle) {
      await bosses.saveBoss(
        BossDraft(
          title: _title,
          defeatMeaning: _meaning,
          resetOnFail: reset,
          phases: [
            for (final p in _phases)
              if (p.text.trim().isNotEmpty) PhaseDraft(name: p.text),
          ],
          standalone: [
            for (final d in _dailies)
              if (d.text.trim().isNotEmpty)
                TaskDraft(
                  title: d.text,
                  weight: Weight.light,
                  recurrence: Recurrence.daily,
                ),
          ],
        ),
        allowEmpty: true,
      );
      if (_wantsReminder) {
        // A refusal leaves the reminder off; onboarding still finishes.
        await ref
            .read(reminderCoordinatorProvider)
            .enable(minutes: _reminderMinutes);
      }
    }
    await settings.setOnboarded(true);
    if (mounted) context.go('/');
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _reminderMinutes ~/ 60,
        minute: _reminderMinutes % 60,
      ),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (picked != null && mounted) {
      setState(() => _reminderMinutes = picked.hour * 60 + picked.minute);
    }
  }

  List<NameListItem> _edit(List<NameListItem> list, int id, String text) => [
    for (final i in list) i.id == id ? NameListItem(id: id, text: text) : i,
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    var step = 0;
    Widget page({
      required String line,
      required Widget body,
      bool isLast = false,
      bool canAdvance = true,
    }) => OnboardingPage(
      step: ++step,
      line: line,
      body: body,
      isLast: isLast,
      canAdvance: canAdvance,
      onNext: isLast ? () => _finish(save: true) : _next,
      onSkip: isLast ? () => _finish(save: false) : _skipToEnd,
    );

    return Scaffold(
      body: PageView(
        controller: _pages,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          page(
            line: "Failing is fine. Quitting isn't.",
            body: Text(
              'Hearthrise keeps the story of the fight: every fall becomes a '
              'lesson, and nothing you earn is taken away.',
              style: text.bodyLarge,
            ),
          ),
          page(
            line: 'Name your first boss.',
            canAdvance: _hasTitle,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LineField(
                  key: const ValueKey('boss-title'),
                  label: 'The boss',
                  hint: 'A goal worth a fight',
                  onChanged: (t) => setState(() => _title = t),
                ),
                const SizedBox(height: Space.md),
                LineField(
                  key: const ValueKey('boss-meaning'),
                  label: 'What does defeating it mean? (optional)',
                  hint: 'One line',
                  maxLength: 120,
                  onChanged: (t) => _meaning = t,
                ),
              ],
            ),
          ),
          page(
            line: 'Break it into phases.',
            body: NameListEditor(
              items: _phases,
              keyPrefix: 'phase',
              hint: 'Phase name',
              removeLabel: 'Remove phase',
              addLabel: 'Add a phase',
              max: _maxPhases,
              onChanged: (id, t) => _phases = _edit(_phases, id, t),
              onRemove: (id) => setState(
                () => _phases = [
                  for (final p in _phases)
                    if (p.id != id) p,
                ],
              ),
              autofocusId: _addedId,
              onAdd: () => setState(() {
                _release();
                _addedId = _nextId++;
                _phases = [..._phases, NameListItem(id: _addedId!, text: '')];
              }),
            ),
          ),
          page(
            line: 'What will you do every day?',
            body: NameListEditor(
              items: _dailies,
              keyPrefix: 'daily',
              hint: 'A small daily foe',
              removeLabel: 'Remove daily foe',
              addLabel: 'Add a daily foe',
              max: _maxDailies,
              onChanged: (id, t) => _dailies = _edit(_dailies, id, t),
              onRemove: (id) => setState(
                () => _dailies = [
                  for (final d in _dailies)
                    if (d.id != id) d,
                ],
              ),
              autofocusId: _addedId,
              onAdd: () => setState(() {
                _release();
                _addedId = _nextId++;
                _dailies = [..._dailies, NameListItem(id: _addedId!, text: '')];
              }),
            ),
          ),
          page(
            line: 'One last thing.',
            isLast: true,
            canAdvance: _hasTitle && !_isBusy,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Gentle mode: nothing is lost but health.',
                  style: text.bodyLarge,
                ),
                const SizedBox(height: Space.lg),
                SettingSwitchRow(
                  title: 'Evening reminder',
                  value: _wantsReminder,
                  onChanged: (v) => setState(() => _wantsReminder = v),
                ),
                SettingValueRow(
                  title: 'Reminder time',
                  value: formatClock(_reminderMinutes),
                  onTap: _pickTime,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
