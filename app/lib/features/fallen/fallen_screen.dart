import 'package:material_ui/material_ui.dart';

import '../../core/deadlines.dart';
import '../../core/haptics.dart';
import '../../core/sounds.dart';
import '../../core/theme.dart';
import '../../ui/accuracy_line.dart';
import '../../ui/ember_button.dart';
import '../../ui/needle_frame.dart';

/// What the fallen screen says about the day's promises (§5.12).
@immutable
class FallenRecord {
  const FallenRecord({
    required this.promised,
    required this.kept,
    required this.weekMade,
    required this.weekKept,
    this.isGraceWeek = false,
  });

  final int promised;
  final int kept;
  final int weekMade;
  final int weekKept;

  /// The newcomer week: a calm line only, no softer losses (plan D13).
  final bool isGraceWeek;
}

/// The fallen moment (§5.5): slow dim, one quiet line, one question.
/// Pops with the lesson text, or null if skipped. A health death adds the
/// plain numbers and planning accuracy from [record].
class FallenScreen extends StatefulWidget {
  const FallenScreen({super.key, this.record});

  final FallenRecord? record;

  static const _dimIn = Motion.dim;

  static Future<String?> show(
    BuildContext context,
    Haptics haptics, {
    FallenRecord? record,
    Sounds? sounds,
  }) {
    haptics.heavy();
    sounds?.fallen();
    return Navigator.of(context).push<String>(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: motionOf(context, _dimIn),
        reverseTransitionDuration: motionOf(context, kSlowFade),
        pageBuilder: (_, _, _) => FallenScreen(record: record),
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

  List<Widget> _numbers(FallenRecord r, TextTheme text) {
    String cap(String s) => s[0].toUpperCase() + s.substring(1);
    return [
      const SizedBox(height: Space.lg),
      if (r.promised > 0)
        Text(
          '${cap(countWord(r.promised))} promised, ${countWord(r.kept)} kept.',
          textAlign: TextAlign.center,
          style: text.bodyMedium,
        ),
      const SizedBox(height: Space.sm),
      Center(
        child: AccuracyLine(
          todayKept: r.kept,
          todayMade: r.promised,
          weekKept: r.weekKept,
          weekMade: r.weekMade,
        ),
      ),
      if (r.isGraceWeek)
        Padding(
          padding: const EdgeInsets.only(top: Space.sm),
          child: Text(
            'Your first week: nothing is lost but health.',
            textAlign: TextAlign.center,
            style: text.bodySmall,
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: context.palette.voidfall,
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
                style: text.displayMedium?.copyWith(
                  fontSize: 60,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rest, then rise.',
                textAlign: TextAlign.center,
                style: text.bodySmall,
              ),
              if (widget.record case final r?) ..._numbers(r, text),
              const SizedBox(height: 56),
              Text('What did this teach you?', style: text.titleMedium),
              const SizedBox(height: 12),
              NeedleFrame(
                tier: Cut.md,
                edge: context.palette.deep,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.md),
                  child: TextField(
                    controller: _lesson,
                    maxLength: 120,
                    style: text.bodyMedium,
                    cursorColor: context.palette.silk,
                    decoration: InputDecoration(
                      hintText: 'One line.',
                      hintStyle: TextStyle(color: context.palette.ash),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              EmberButton(
                label: 'Rise',
                onPressed: () => Navigator.pop(context, _lesson.text.trim()),
              ),
              const SizedBox(height: Space.sm),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Rest first',
                  style: TextStyle(color: context.palette.ash),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
