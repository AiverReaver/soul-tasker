import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/boss_draft.dart';
import '../../data/boss_view.dart';
import '../../data/enums.dart';
import '../../data/providers.dart';
import '../../ui/ember_button.dart';
import '../../ui/glass_action_row.dart';
import '../../ui/glass_sheet.dart';
import '../../ui/needle_frame.dart';
import '../../ui/needle_text_field.dart';
import '../../ui/strength_segments.dart';
import '../../ui/stroke_icon.dart';

/// Opens "A new foe": name it, pick its strength and the boss it strikes at,
/// then "Add to today" saves it as a standalone task on that boss, through
/// the same path as the boss editor. [bosses] are the active ones.
Future<void> showNewFoeSheet(
  BuildContext context,
  WidgetRef ref, {
  required List<BossView> bosses,
}) async {
  final result = await showGlassSheet<(BossView, TaskDraft)>(
    context,
    (_) => NewFoeSheet(bosses: bosses),
  );
  if (result == null) return;
  final (boss, task) = result;
  await ref
      .read(bossDaoProvider)
      .saveBoss(BossDraft.fromView(boss).withTask(task, null));
}

class NewFoeSheet extends StatefulWidget {
  const NewFoeSheet({super.key, required this.bosses});

  final List<BossView> bosses;

  @override
  State<NewFoeSheet> createState() => _NewFoeSheetState();
}

class _NewFoeSheetState extends State<NewFoeSheet> {
  final _name = TextEditingController();
  Weight _weight = Weight.light;
  late BossView _boss =
      widget.bosses.where((b) => b.boss.isPinned).firstOrNull ??
      widget.bosses.first;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickBoss() async {
    final picked = await showGlassSheet<BossView>(
      context,
      (sheet) => GlassSheet(
        label: 'Strikes at',
        title: 'Which boss?',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            for (final b in widget.bosses)
              GlassActionRow(
                label: b.boss.title,
                onTap: () => Navigator.pop(sheet, b),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _boss = picked);
  }

  void _add() {
    final title = _name.text.trim();
    if (title.isEmpty) return;
    Navigator.pop(context, (_boss, TaskDraft(title: title, weight: _weight)));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return GlassSheet(
      label: 'Today’s tasks',
      title: 'A new task',
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Space.md,
          children: [
            NeedleTextField(
              controller: _name,
              caption: 'Name the task',
              isPlainCaption: true,
              hint: 'What will you do?',
              autofocus: true,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Space.xs + 2,
              children: [
                Text('Strength', style: text.labelSmall),
                StrengthSegments(
                  options: [
                    for (final w in Weight.values)
                      StrengthOption(
                        label: w.label,
                        pips: w.index + 1,
                        note: '+${w.embers} embers',
                      ),
                  ],
                  selected: _weight.index,
                  onChanged: (i) => setState(() => _weight = Weight.values[i]),
                ),
              ],
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _pickBoss,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Space.sm,
                children: [
                  Text('Strikes at', style: text.labelSmall),
                  NeedleFrame(
                    tier: Cut.md,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 56),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Space.md,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _boss.boss.title,
                                style: text.bodyLarge!.copyWith(
                                  color: p.bone,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              '›',
                              style: TextStyle(color: p.ash, fontSize: 22),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            EmberButton(
              label: 'Add to today',
              icon: StrokeIcons.strike,
              onPressed: _add,
            ),
          ],
        ),
      ),
    );
  }
}
