import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/enums.dart';
import '../../data/providers.dart';
import '../../data/relic_dao.dart';
import '../../ui/ember_button.dart';
import '../../ui/inscription_field.dart';
import '../../ui/lesson_timeline.dart';
import '../../ui/relic_emblem.dart';
import '../../ui/victory_numbers.dart';

/// How long the whole reveal takes; five sections fade in one after another.
const _reveal = Duration(milliseconds: 5000);
const _sections = 5;

/// The victory screen (§5.11, Stage 5 plan D6): one line, the numbers, the
/// lessons, the relic, and a final inscription. Slow fades, no confetti.
class VictoryScreen extends ConsumerStatefulWidget {
  const VictoryScreen({super.key, required this.relicId});

  final String relicId;

  @override
  ConsumerState<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends ConsumerState<VictoryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: _reveal,
  );
  final _inscription = TextEditingController();
  bool _didStart = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didStart) return;
    _didStart = true;
    ref.read(hapticsProvider).doubleHeavy();
    if (motionOf(context, _reveal) == Duration.zero) {
      _fade.value = 1;
    } else {
      _fade.forward();
    }
  }

  @override
  void dispose() {
    _fade.dispose();
    _inscription.dispose();
    super.dispose();
  }

  Animation<double> _section(int i) => CurvedAnimation(
    parent: _fade,
    curve: Interval(i / _sections, (i + 1) / _sections, curve: Motion.ease),
  );

  Widget _fadeIn(int i, Widget child) =>
      FadeTransition(opacity: _section(i), child: child);

  /// Saves the inscription, if any, and goes home. Done and back both end here.
  Future<void> _finish() async {
    final text = _inscription.text.trim();
    if (text.isNotEmpty) {
      await ref.read(relicDaoProvider).setInscription(widget.relicId, text);
    }
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(relicProvider(widget.relicId)).value;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _finish();
      },
      child: Scaffold(
        body: SafeArea(
          child: view == null ? const SizedBox.shrink() : _body(context, view),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, RelicView view) {
    final text = Theme.of(context).textTheme;
    final relic = view.relic;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _fadeIn(
            0,
            Text(
              'Foe vanquished.',
              textAlign: TextAlign.center,
              style: text.displayMedium,
            ),
          ),
          const SizedBox(height: Space.lg),
          _fadeIn(
            1,
            VictoryNumbers(
              attempts: relic.attempts,
              days: relic.days,
              effort: relic.effort,
            ),
          ),
          const SizedBox(height: Space.lg),
          _fadeIn(
            2,
            LessonTimeline(
              lessons: [
                for (final l in view.story.lessons)
                  LessonRow(
                    attempt: l.attempt,
                    text: l.text,
                    isMissedDay: l.cause == FallCause.missedDay,
                  ),
              ],
            ),
          ),
          const SizedBox(height: Space.xl),
          _fadeIn(
            3,
            Column(
              children: [
                Text('A relic remains.', style: text.titleMedium),
                const SizedBox(height: Space.md),
                RelicEmblem(weathering: relic.emblem),
                const SizedBox(height: Space.md),
                Text(
                  relic.name,
                  textAlign: TextAlign.center,
                  style: text.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.xl),
          _fadeIn(4, InscriptionField(controller: _inscription)),
          const SizedBox(height: Space.md),
          Align(
            alignment: Alignment.centerRight,
            child: _fadeIn(4, EmberButton(label: 'Done', onPressed: _finish)),
          ),
        ],
      ),
    );
  }
}
