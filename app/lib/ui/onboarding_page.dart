import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'ember_button.dart';

/// One page of onboarding: a line, a body slot, "Next" or "Begin", "Skip".
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.line,
    required this.body,
    required this.onNext,
    required this.onSkip,
    this.isLast = false,
    this.canAdvance = true,
  });

  final String line;
  final Widget body;
  final VoidCallback onNext;
  final VoidCallback onSkip;

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
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: kTextMuted),
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
