import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/boss_draft.dart';
import '../../data/enums.dart';
import '../../ui/action_row.dart';
import '../../ui/glass_sheet.dart';
import '../../ui/needle_text_field.dart';
import '../../ui/setting_switch_row.dart';
import '../../ui/strength_segments.dart';

/// What the task sheet returns. [phaseId] null = "Beyond the phases".
class TaskEditResult {
  const TaskEditResult.save(this.task, this.phaseId) : isDelete = false;
  const TaskEditResult.delete(this.task) : phaseId = null, isDelete = true;

  final TaskDraft task;
  final String? phaseId;
  final bool isDelete;
}

/// Add or edit one task, including which phase it belongs to.
Future<TaskEditResult?> showTaskEditSheet(
  BuildContext context, {
  required TaskDraft task,
  required String? phaseId,
  required List<PhaseDraft> phases,
  required bool isNew,
}) {
  return showGlassSheet<TaskEditResult>(
    context,
    (_) => _TaskEditSheet(
      task: task,
      phaseId: phaseId,
      phases: phases,
      isNew: isNew,
    ),
  );
}

class _TaskEditSheet extends StatefulWidget {
  const _TaskEditSheet({
    required this.task,
    required this.phaseId,
    required this.phases,
    required this.isNew,
  });

  final TaskDraft task;
  final String? phaseId;
  final List<PhaseDraft> phases;
  final bool isNew;

  @override
  State<_TaskEditSheet> createState() => _TaskEditSheetState();
}

class _TaskEditSheetState extends State<_TaskEditSheet> {
  static const _beyond = '';

  late final _title = TextEditingController(text: widget.task.title);
  late TaskDraft _task = widget.task;
  late String _phase = widget.phaseId ?? _beyond;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _save() {
    final task = _task.copyWith(title: _title.text.trim());
    Navigator.pop(
      context,
      TaskEditResult.save(task, _phase == _beyond ? null : _phase),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GlassSheet(
      title: widget.isNew ? 'A new task' : 'Edit task',
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Space.md,
          children: [
            NeedleTextField(
              controller: _title,
              caption: 'Name the task',
              hint: 'What will you do?',
              autofocus: widget.isNew,
              onChanged: (_) => setState(() {}),
            ),
            StrengthSegments(
              options: [
                for (final w in Weight.values)
                  StrengthOption(
                    label: w.label,
                    pips: w.index + 1,
                    note: '+${w.embers} embers',
                  ),
              ],
              selected: _task.weight.index,
              onChanged: (i) => setState(
                () => _task = _task.copyWith(weight: Weight.values[i]),
              ),
            ),
            SettingSwitchRow(
              title: 'Every day',
              value: _task.recurrence == Recurrence.daily,
              onChanged: (v) => setState(
                () => _task = _task.copyWith(
                  recurrence: v ? Recurrence.daily : Recurrence.none,
                ),
              ),
            ),
            DropdownButtonFormField<String>(
              initialValue: _phase,
              style: text.bodyLarge,
              dropdownColor: context.palette.shell,
              decoration: const InputDecoration(labelText: 'Chapter'),
              items: [
                for (final p in widget.phases)
                  DropdownMenuItem(
                    value: p.id,
                    child: Text(p.name.isEmpty ? 'Unnamed chapter' : p.name),
                  ),
                const DropdownMenuItem(
                  value: _beyond,
                  child: Text('Beyond the chapters'),
                ),
              ],
              onChanged: (v) => setState(() => _phase = v ?? _beyond),
            ),
            if (_title.text.trim().isNotEmpty)
              ActionRow(label: 'Done', onTap: _save),
            if (!widget.isNew)
              ActionRow(
                label: 'Delete',
                onTap: () =>
                    Navigator.pop(context, TaskEditResult.delete(widget.task)),
              ),
          ],
        ),
      ),
    );
  }
}
