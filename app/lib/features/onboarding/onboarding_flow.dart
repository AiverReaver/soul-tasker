import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/boss_draft.dart';
import '../../data/providers.dart';
import '../../ui/onboarding_fields.dart';
import '../../ui/onboarding_page.dart';

/// First run (§6.2, Stage 5 plan D11): three short pages that end in a saved
/// boss and its very next step. Only a boss title is required; Skip is on
/// every page. Chapters, dailies and the reminder come later (first-session
/// audit #7): the bonfire asks about the reminder after the first rest.
/// A thin container: it holds the draft and the page, and passes values down.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _pages = PageController();
  String _title = '';
  String _meaning = '';
  String _nextStep = '';
  bool _isBusy = false;

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
      2,
      duration: motionOf(context, Motion.fade),
      curve: Motion.ease,
    );
  }

  /// Saves the boss, and its next step as a one-time task in a first
  /// chapter, if it has a title.
  Future<void> _finish() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    final settings = ref.read(settingsDaoProvider);
    final reset = (await settings.read()).defaultResetOnFail;
    if (_hasTitle) {
      await ref
          .read(bossDaoProvider)
          .saveBoss(
            BossDraft(
              title: _title,
              defeatMeaning: _meaning,
              resetOnFail: reset,
              // In a chapter: only chapter tasks are health segments.
              phases: [
                if (_nextStep.trim().isNotEmpty)
                  PhaseDraft(
                    name: 'First steps',
                    tasks: [TaskDraft(title: _nextStep)],
                  ),
              ],
            ),
            allowEmpty: true,
          );
    }
    await settings.setOnboarded(true);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    var step = 0;
    Widget page({
      required String line,
      required Widget body,
      bool isLast = false,
      bool canAdvance = true,
      String? kicker,
    }) => OnboardingPage(
      step: ++step,
      total: 3,
      kicker: kicker,
      line: line,
      body: body,
      isLast: isLast,
      canAdvance: canAdvance,
      onNext: isLast ? _finish : _next,
      // Skip on the last page still keeps the boss typed so far.
      onSkip: isLast ? _finish : _skipToEnd,
    );

    return Scaffold(
      body: PageView(
        controller: _pages,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          page(
            kicker:
                'Turn the goal you keep avoiding into a boss. '
                'Fight it a little every day.',
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
            line: "What's the very next step?",
            isLast: true,
            canAdvance: _hasTitle && !_isBusy,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LineField(
                  key: const ValueKey('next-step'),
                  label: 'One task, done once (optional)',
                  hint: 'Book the exam',
                  onChanged: (t) => _nextStep = t,
                ),
                const SizedBox(height: Space.md),
                Text(
                  'Chapters and daily tasks can come later, from the boss.',
                  style: text.bodyMedium?.copyWith(color: context.palette.ash),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
