import 'package:material_ui/material_ui.dart';

import '../../core/haptics.dart';
import '../../core/theme.dart';

/// The fallen moment (§5.5): slow dim, one quiet line, one question.
/// Pops with the lesson text, or null if skipped.
class FallenScreen extends StatefulWidget {
  const FallenScreen({super.key});

  static const _dimIn = Motion.dim;

  static Future<String?> show(BuildContext context, Haptics haptics) {
    haptics.heavy();
    return Navigator.of(context).push<String>(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: motionOf(context, _dimIn),
        reverseTransitionDuration: motionOf(context, kSlowFade),
        pageBuilder: (_, _, _) => const FallenScreen(),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
          child: child,
        ),
      ),
    );
  }

  @override
  State<FallenScreen> createState() => _FallenScreenState();
}

class _FallenScreenState extends State<FallenScreen> {
  final _lesson = TextEditingController();

  @override
  void dispose() {
    _lesson.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.94),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Fallen.',
                textAlign: TextAlign.center,
                style: text.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Rest, then rise.',
                textAlign: TextAlign.center,
                style: text.bodySmall,
              ),
              const SizedBox(height: 56),
              Text('What did this teach you?', style: text.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _lesson,
                maxLength: 120,
                style: text.bodyMedium,
                cursorColor: kEmber,
                decoration: const InputDecoration(
                  hintText: 'One line.',
                  hintStyle: TextStyle(color: kTextMuted),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kAshDim),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kEmber),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: kTextMuted),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(context, _lesson.text.trim()),
                    child: const Text(
                      'Rise',
                      style: TextStyle(color: kEmber, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
