import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/clock.dart';
import '../../core/theme.dart';
import '../../data/enums.dart';
import '../../data/providers.dart';
import '../../data/relic_dao.dart';
import '../../ui/glass_circle_button.dart';
import '../../ui/inscription_field.dart';
import '../../ui/lesson_timeline.dart';
import '../../ui/relic_emblem.dart';
import '../../ui/stroke_icon.dart';
import '../../ui/victory_numbers.dart';

/// "3 attempts. Every one of them counted." One attempt reads "One attempt.
/// It counted."
String attemptsLine(int attempts) => attempts == 1
    ? 'One attempt. It counted.'
    : '$attempts attempts. Every one of them counted.';

/// One relic: its numbers, its lessons in order, and its inscription, which
/// is the only thing that can still change (Stage 5 plan D7).
class RelicScreen extends ConsumerStatefulWidget {
  const RelicScreen({super.key, required this.relicId});

  final String relicId;

  @override
  ConsumerState<RelicScreen> createState() => _RelicScreenState();
}

class _RelicScreenState extends ConsumerState<RelicScreen> {
  final _inscription = TextEditingController();
  bool _isFilled = false;

  @override
  void dispose() {
    _inscription.dispose();
    super.dispose();
  }

  Future<void> _save(String text) async {
    await ref.read(relicDaoProvider).setInscription(widget.relicId, text);
    if (mounted) FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(relicProvider(widget.relicId)).value;
    if (view != null && !_isFilled) {
      _isFilled = true;
      _inscription.text = view.relic.inscription ?? '';
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, Space.sm, 20, Space.sm),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GlassCircleButton(
                  icon: StrokeIcons.back,
                  semanticLabel: 'Back',
                  onTap: () => context.pop(),
                ),
              ),
            ),
            Expanded(
              child: view == null
                  ? const SizedBox.shrink()
                  : _body(context, view),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, RelicView view) {
    final text = Theme.of(context).textTheme;
    final relic = view.relic;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: RelicEmblem(weathering: relic.emblem)),
          const SizedBox(height: Space.md),
          Text(
            relic.name,
            textAlign: TextAlign.center,
            style: text.displaySmall,
          ),
          const SizedBox(height: Space.xs),
          Text(
            formatDayLabel(relic.defeatedDay),
            textAlign: TextAlign.center,
            style: text.bodySmall,
          ),
          if (view.story.defeatMeaning case final meaning?) ...[
            const SizedBox(height: Space.sm),
            Text(meaning, textAlign: TextAlign.center, style: text.bodySmall),
          ],
          const SizedBox(height: Space.lg),
          VictoryNumbers(
            attempts: relic.attempts,
            days: relic.days,
            effort: relic.effort,
          ),
          const SizedBox(height: Space.md),
          Text(
            attemptsLine(relic.attempts),
            textAlign: TextAlign.center,
            style: text.titleMedium,
          ),
          if (view.story.phases.isNotEmpty) ...[
            const SizedBox(height: Space.lg),
            Text(
              view.story.phases.join(' · '),
              textAlign: TextAlign.center,
              style: text.bodySmall,
            ),
          ],
          if (view.story.lessons.isNotEmpty) ...[
            const SizedBox(height: Space.lg),
            Text('What the falls taught you', style: text.titleMedium),
          ],
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
          const SizedBox(height: Space.xl),
          InscriptionField(controller: _inscription, onSaved: _save),
        ],
      ),
    );
  }
}
