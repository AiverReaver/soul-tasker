import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/ids.dart';
import '../../core/theme.dart';
import '../../data/boss_draft.dart';
import '../../data/enums.dart';
import '../../data/providers.dart';
import '../boss/task_row.dart' show confirm;
import 'task_edit_sheet.dart';

/// Create ([bossId] null) or edit a boss with its phases and tasks.
class BossEditScreen extends ConsumerStatefulWidget {
  const BossEditScreen({super.key, this.bossId});

  final String? bossId;

  @override
  ConsumerState<BossEditScreen> createState() => _BossEditScreenState();
}

class _BossEditScreenState extends ConsumerState<BossEditScreen> {
  BossDraft? _draft;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.bossId;
    final BossDraft draft;
    if (id == null) {
      final settings = await ref.read(settingsDaoProvider).watch().first;
      draft = BossDraft.fresh(settings.defaultResetOnFail);
    } else {
      final view = await ref.read(bossDaoProvider).loadBoss(id);
      if (view == null) return setState(() => _error = 'This boss is gone.');
      draft = BossDraft.fromView(view);
    }
    // Every row gets its id up front so list keys stay stable while editing.
    if (mounted) setState(() => _draft = _withIds(draft));
  }

  BossDraft _withIds(BossDraft d) {
    TaskDraft task(TaskDraft t) => t.id != null
        ? t
        : TaskDraft(
            id: newId(),
            title: t.title,
            weight: t.weight,
            recurrence: t.recurrence,
          );
    return BossDraft(
      id: d.id,
      title: d.title,
      defeatMeaning: d.defeatMeaning,
      targetDate: d.targetDate,
      resetOnFail: d.resetOnFail,
      phases: [
        for (final p in d.phases)
          PhaseDraft(
            id: p.id ?? newId(),
            name: p.name,
            tasks: [for (final t in p.tasks) task(t)],
          ),
      ],
      standalone: [for (final t in d.standalone) task(t)],
    );
  }

  void _update(BossDraft Function(BossDraft d) change) =>
      setState(() => _draft = change(_draft!));

  Future<void> _save() async {
    try {
      final id = await ref.read(bossDaoProvider).saveBoss(_draft!);
      if (!mounted) return;
      // Opened by a deep link there is nothing to pop back to.
      widget.bossId != null && context.canPop()
          ? context.pop()
          : context.replace('/boss/$id');
    } on Exception catch (e) {
      setState(() => _error = 'Could not save: $e');
    }
  }

  Future<void> _deleteBoss() async {
    final ok = await confirm(
      context,
      'Delete "${_draft!.title}" and all its history?',
      action: 'Delete',
    );
    if (!ok || !mounted) return;
    await ref.read(bossDaoProvider).deleteBoss(widget.bossId!);
    if (mounted) context.go('/');
  }

  Future<void> _editTask(
    TaskDraft task,
    String? phaseId, {
    bool isNew = false,
  }) async {
    final result = await showTaskEditSheet(
      context,
      task: task,
      phaseId: phaseId,
      phases: _draft!.phases,
      isNew: isNew,
    );
    if (result == null) return;
    _update(
      (d) => result.isDelete
          ? d.withoutTask(result.task.id!)
          : d.withTask(result.task, result.phaseId),
    );
  }

  Future<void> _deletePhase(PhaseDraft phase) async {
    if (phase.tasks.isNotEmpty) {
      final ok = await confirm(
        context,
        'Delete this phase and its ${phase.tasks.length} tasks?',
        action: 'Delete',
      );
      if (!ok) return;
    }
    _update(
      (d) => d.copyWith(phases: [...d.phases.where((p) => p.id != phase.id)]),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft!.targetDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) _update((d) => d.copyWith(targetDate: picked));
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draft;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bossId == null ? 'A new boss' : 'Edit boss'),
        actions: [
          TextButton(
            onPressed: draft != null && draft.canSave ? _save : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: draft == null
            ? Center(child: Text(_error ?? ''))
            : _form(context, draft),
      ),
    );
  }

  Widget _form(BuildContext context, BossDraft draft) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, Space.md, 20, Space.xl),
      children: [
        if (_error != null)
          Text(
            _error!,
            style: text.bodyMedium?.copyWith(color: context.palette.silk),
          ),
        TextFormField(
          initialValue: draft.title,
          maxLength: 80,
          style: text.bodyLarge,
          decoration: const InputDecoration(labelText: 'Title'),
          onChanged: (v) => _update((d) => d.copyWith(title: v)),
        ),
        TextFormField(
          initialValue: draft.defeatMeaning,
          maxLength: 200,
          style: text.bodyLarge,
          decoration: const InputDecoration(
            labelText: 'What does defeat mean?',
          ),
          onChanged: (v) => _update((d) => d.copyWith(defeatMeaning: v)),
        ),
        _dateRow(context, draft),
        const SizedBox(height: Space.md),
        Text('On a failed attempt, reset', style: text.bodySmall),
        const SizedBox(height: Space.sm),
        SegmentedButton<ResetOnFail>(
          segments: [
            for (final r in ResetOnFail.values)
              ButtonSegment(value: r, label: Text(r.label)),
          ],
          selected: {draft.resetOnFail},
          showSelectedIcon: false,
          onSelectionChanged: (s) =>
              _update((d) => d.copyWith(resetOnFail: s.single)),
        ),
        const SizedBox(height: Space.lg),
        Text('PHASES', style: text.labelSmall),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorderItem: (from, to) => _update((d) {
            final list = [...d.phases];
            list.insert(to, list.removeAt(from));
            return d.copyWith(phases: list);
          }),
          children: [
            for (final (i, p) in draft.phases.indexed)
              Padding(
                key: ValueKey(p.id),
                padding: const EdgeInsets.symmetric(vertical: Space.sm),
                child: _PhaseCard(
                  index: i,
                  phase: p,
                  onRename: (name) => _update(
                    (d) => d.copyWith(
                      phases: [
                        for (final q in d.phases)
                          q.id == p.id ? q.copyWith(name: name) : q,
                      ],
                    ),
                  ),
                  onDelete: () => _deletePhase(p),
                  onAddTask: () => _editTask(
                    TaskDraft(id: newId(), title: ''),
                    p.id,
                    isNew: true,
                  ),
                  onEditTask: (t) => _editTask(t, p.id),
                ),
              ),
          ],
        ),
        TextButton(
          onPressed: () => _update(
            (d) => d.copyWith(
              phases: [
                ...d.phases,
                PhaseDraft(id: newId(), name: ''),
              ],
            ),
          ),
          child: const Text('Add a phase'),
        ),
        const SizedBox(height: Space.lg),
        Text('BEYOND THE PHASES', style: text.labelSmall),
        for (final t in draft.standalone)
          _TaskLine(task: t, onTap: () => _editTask(t, null)),
        TextButton(
          key: const ValueKey('add-standalone-task'),
          onPressed: () =>
              _editTask(TaskDraft(id: newId(), title: ''), null, isNew: true),
          child: const Text('Add a task'),
        ),
        if (widget.bossId != null) ...[
          const SizedBox(height: Space.xl),
          TextButton(
            onPressed: _deleteBoss,
            child: Text(
              'Delete boss',
              style: TextStyle(color: context.palette.ash),
            ),
          ),
        ],
      ],
    );
  }

  Widget _dateRow(BuildContext context, BossDraft draft) {
    final date = draft.targetDate;
    return Row(
      children: [
        Expanded(
          child: TextButton(
            style: TextButton.styleFrom(alignment: Alignment.centerLeft),
            onPressed: _pickDate,
            child: Text(
              date == null
                  ? 'Set a target date'
                  : 'Target: ${MaterialLocalizations.of(context).formatMediumDate(date)}',
            ),
          ),
        ),
        if (date != null)
          IconButton(
            tooltip: 'Clear target date',
            icon: Icon(Icons.close, color: context.palette.ash),
            onPressed: () => _update((d) => d.copyWith(clearTargetDate: true)),
          ),
      ],
    );
  }
}

class _PhaseCard extends StatelessWidget {
  const _PhaseCard({
    required this.index,
    required this.phase,
    required this.onRename,
    required this.onDelete,
    required this.onAddTask,
    required this.onEditTask,
  });

  final int index;
  final PhaseDraft phase;
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;
  final VoidCallback onAddTask;
  final ValueChanged<TaskDraft> onEditTask;

  @override
  Widget build(BuildContext context) {
    // Material (not a colored box) so the task ListTiles can paint ink.
    return Material(
      color: context.palette.shell,
      shape: Border.all(color: context.palette.dim.withValues(alpha: 0.3)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.sm, 0, Space.sm, Space.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: SizedBox(
                    width: kMinTarget,
                    height: kMinTarget,
                    child: Icon(Icons.drag_handle, color: context.palette.ash),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: phase.name,
                    maxLength: 60,
                    decoration: const InputDecoration(
                      hintText: 'Phase name',
                      counterText: '',
                    ),
                    onChanged: onRename,
                  ),
                ),
                IconButton(
                  tooltip: 'Delete phase',
                  icon: Icon(Icons.close, color: context.palette.ash),
                  onPressed: onDelete,
                ),
              ],
            ),
            for (final t in phase.tasks)
              _TaskLine(task: t, onTap: () => onEditTask(t)),
            TextButton(onPressed: onAddTask, child: const Text('Add a task')),
          ],
        ),
      ),
    );
  }
}

class _TaskLine extends StatelessWidget {
  const _TaskLine({required this.task, required this.onTap});

  final TaskDraft task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final daily = task.recurrence == Recurrence.daily ? ' · daily' : '';
    return ListTile(
      minTileHeight: kMinTarget,
      contentPadding: const EdgeInsets.symmetric(horizontal: Space.sm),
      title: Text(task.title, style: text.bodyMedium),
      trailing: Text('${task.weight.label}$daily', style: text.bodySmall),
      onTap: onTap,
    );
  }
}
