import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/boss_draft.dart';
import '../../data/enums.dart';

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
  return showModalBottomSheet<TaskEditResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: kSurface,
    builder: (_) => _TaskEditSheet(
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        Space.lg,
        20,
        MediaQuery.viewInsetsOf(context).bottom + Space.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.isNew ? 'A new foe' : 'Edit foe',
              style: text.titleMedium,
            ),
            TextField(
              controller: _title,
              autofocus: widget.isNew,
              maxLength: 80,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'What will you do?'),
            ),
            SegmentedButton<Weight>(
              segments: [
                for (final w in Weight.values)
                  ButtonSegment(value: w, label: Text(w.label)),
              ],
              selected: {_task.weight},
              showSelectedIcon: false,
              onSelectionChanged: (s) =>
                  setState(() => _task = _task.copyWith(weight: s.single)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Every day', style: text.bodyMedium),
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
              dropdownColor: kSurface,
              decoration: const InputDecoration(labelText: 'Phase'),
              items: [
                for (final p in widget.phases)
                  DropdownMenuItem(
                    value: p.id,
                    child: Text(p.name.isEmpty ? 'Unnamed phase' : p.name),
                  ),
                const DropdownMenuItem(
                  value: _beyond,
                  child: Text('Beyond the phases'),
                ),
              ],
              onChanged: (v) => setState(() => _phase = v ?? _beyond),
            ),
            const SizedBox(height: Space.md),
            Row(
              children: [
                if (!widget.isNew)
                  TextButton(
                    onPressed: () => Navigator.pop(
                      context,
                      TaskEditResult.delete(widget.task),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: kTextMuted),
                    ),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: _title.text.trim().isEmpty ? null : _save,
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
