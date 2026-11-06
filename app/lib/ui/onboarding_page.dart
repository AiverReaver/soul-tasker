import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'ember_button.dart';
import 'step_marks.dart';

/// One page of onboarding: a line, a body slot, "Next" or "Begin", "Skip".
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.line,
    required this.body,
    required this.onNext,
    required this.onSkip,
    required this.step,
    this.total = 5,
    this.isLast = false,
    this.canAdvance = true,
    this.kicker,
  });

  final String line;

  /// Optional plain sentence above the line (what the app is, on step 1).
  final String? kicker;
  final Widget body;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final int step;
  final int total;

  /// The last page says "Begin" instead of "Next".
  final bool isLast;

  /// False disables the forward button (a boss needs a title).
  final bool canAdvance;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: Space.lg),
                  Wrap(
                    spacing: Space.sm + 4,
                    runSpacing: Space.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      StepMarks(step: step, total: total),
                      Text('Step $step of $total', style: text.labelSmall),
                    ],
                  ),
                  const SizedBox(height: Space.md),
                  if (kicker != null) ...[
                    Text(
                      kicker!,
                      style: text.bodyMedium?.copyWith(
                        color: context.palette.ash,
                      ),
                    ),
                    const SizedBox(height: Space.sm),
                  ],
                  Text(line, style: text.displaySmall),
                  const SizedBox(height: Space.lg),
                  body,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Skip',
                    style: TextStyle(color: context.palette.ash),
                  ),
                ),
                canAdvance
                    ? EmberButton(
                        label: isLast ? 'Begin' : 'Next',
                        onPressed: onNext,
                      )
                    : TextButton(
                        onPressed: null,
                        child: Text(isLast ? 'Begin' : 'Next'),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
