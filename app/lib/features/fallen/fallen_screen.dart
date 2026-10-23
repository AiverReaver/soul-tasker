import 'package:material_ui/material_ui.dart';

import '../../core/deadlines.dart';
import '../../core/haptics.dart';
import '../../core/sounds.dart';
import '../../core/theme.dart';
import '../../ui/accuracy_line.dart';
import '../../ui/ember_button.dart';
import '../../ui/diamond_pip.dart';
import '../../ui/needle_frame.dart';
import '../../ui/snapping_thread.dart';

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

/// What the fallen screen says about the attempt that ended: the attempt
/// number, the boss, and the player's health in half points.
@immutable
class FallenStory {
  const FallenStory({
    required this.attempt,
    required this.bossTitle,
    this.health,
    this.maxHealth,
    this.embers,
  });

  final int attempt;
  final String bossTitle;
  final int? health;
  final int? maxHealth;

  /// Embers banked and kept.
  final int? embers;
}

/// The fallen moment (§5.5): slow dim, one quiet line, one question.
/// Pops with the lesson text, or null if skipped. A health death adds the
/// plain numbers and planning accuracy from [record].
class FallenScreen extends StatefulWidget {
  const FallenScreen({super.key, this.record, this.story});

  final FallenRecord? record;
  final FallenStory? story;

  static const _dimIn = Motion.dim;

  static Future<String?> show(
    BuildContext context,
    Haptics haptics, {
    FallenRecord? record,
    FallenStory? story,
    Sounds? sounds,
  }) {
    haptics.heavy();
    sounds?.fallen();
    return Navigator.of(context).push<String>(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: motionOf(context, _dimIn),
        reverseTransitionDuration: motionOf(context, kSlowFade),
        pageBuilder: (_, _, _) => FallenScreen(record: record, story: story),
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

class _FallenScreenState extends State<FallenScreen>
    with SingleTickerProviderStateMixin {
  final _lesson = TextEditingController();

  /// 2 s of story: the thread snaps at 1.2 s, the lost pip dims at 1.6 s.
  late final _clock = AnimationController(vsync: this, duration: _span);

  static const _span = Duration(milliseconds: 2000);
  static const _snapAt = 1200;
  static const _dimAt = 1600;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_clock.isAnimating || _clock.isCompleted) return;
    if (motionOf(context, _span) == Duration.zero) {
      _clock.value = 1;
    } else {
      _clock.forward();
    }
  }

  /// "The Certification" stays as it is; "Warden" becomes "The Warden".
  static String _the(String title) =>
      title.startsWith('The ') ? title : 'The $title';

  /// 0 to 1 over [ms] .. [ms] + 400.
  double _since(int ms) =>
      ((_clock.value * _span.inMilliseconds - ms) / 400).clamp(0.0, 1.0);

  @override
  void dispose() {
    _clock.dispose();
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

  /// The thread, then health and the embers kept.
  List<Widget> _story(FallenStory st, TextTheme text) => [
    const SizedBox(height: Space.md),
    AnimatedBuilder(
      animation: _clock,
      builder: (_, _) => SnappingThread(t: _since(_snapAt)),
    ),
    if (st.health case final health? when st.maxHealth != null) ...[
      const SizedBox(height: Space.md),
      AnimatedBuilder(
        animation: _clock,
        builder: (_, _) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: Space.sm,
          children: [
            DiamondPip(
              color: Color.lerp(
                context.palette.shard,
                context.palette.dim,
                _since(_dimAt),
              )!,
              size: 10,
            ),
            Text(
              '${formatHealth(health)} / ${formatHealth(st.maxHealth!)}',
              style: text.bodyMedium,
            ),
          ],
        ),
      ),
    ],
    const SizedBox(height: Space.xs),
    if (st.embers case final embers?)
      Text(
        embers.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
        ),
        textAlign: TextAlign.center,
        style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    Text('Embers kept', textAlign: TextAlign.center, style: text.bodySmall),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: context.palette.voidfall,
      // Scrolls so the keyboard never hides Rise; a tap outside closes it.
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Fallen.',
                      textAlign: TextAlign.center,
                      style: text.displayMedium?.copyWith(
                        fontSize: 60,
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      switch (widget.story) {
                        final st? =>
                          'Attempt ${st.attempt} ends. ${_the(st.bossTitle)} remains, '
                              'and so do you.',
                        null => 'Rest, then rise.',
                      },
                      textAlign: TextAlign.center,
                      style: text.bodySmall,
                    ),
                    if (widget.story case final st?) ..._story(st, text),
                    if (widget.record case final r?) ..._numbers(r, text),
                    const SizedBox(height: 56),
                    Text('What did this teach you?', style: text.titleMedium),
                    const SizedBox(height: 12),
                    NeedleFrame(
                      tier: Cut.md,
                      edge: context.palette.deep,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Space.md,
                        ),
                        child: TextField(
                          controller: _lesson,
                          maxLength: 120,
                          minLines: 3,
                          maxLines: 4,
                          textInputAction: TextInputAction.done,
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
                    if (widget.story case final st?)
                      Padding(
                        padding: const EdgeInsets.only(top: Space.sm),
                        child: Text(
                          'You will see it at the start of attempt '
                          '${st.attempt + 1}.',
                          style: text.bodySmall,
                        ),
                      ),
                    const SizedBox(height: 32),
                    EmberButton(
                      label: 'Rise',
                      onPressed: () =>
                          Navigator.pop(context, _lesson.text.trim()),
                    ),
                    const SizedBox(height: Space.sm),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Rest first. Write it tomorrow.',
                        style: TextStyle(color: context.palette.ash),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
