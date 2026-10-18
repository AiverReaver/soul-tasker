import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/ids.dart';
import '../../core/theme.dart';
import '../../data/boss_draft.dart';
import '../../data/enums.dart';
import '../../data/providers.dart';
import '../../ui/glass_circle_button.dart';
import '../../ui/glass_pill_button.dart';
import '../../ui/needle_text_field.dart';
import '../../ui/phase_panel.dart';
import '../../ui/setting_choice_row.dart';
import '../../ui/stroke_icon.dart';
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
  final _title = TextEditingController();
  final _meaning = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _meaning.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.bossId;
    final BossDraft draft;
    if (id == null) {
      final settings = await ref.read(settingsDaoProvider).read();
      draft = BossDraft(
        resetOnFail: settings.defaultResetOnFail,
        phases: const [PhaseDraft(name: '')],
      );
    } else {
      final view = await ref.read(bossDaoProvider).loadBoss(id);
      if (view == null) return setState(() => _error = 'This boss is gone.');
      draft = BossDraft.fromView(view);
    }
    // Every row gets its id up front so list keys stay stable while editing.
    if (!mounted) return;
    _title.text = draft.title;
    _meaning.text = draft.defeatMeaning;
    setState(() => _draft = _withIds(draft));
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
        'Delete this chapter and its ${phase.tasks.length} tasks?',
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
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, Space.sm, 20, Space.sm),
              child: Row(
                spacing: Space.sm + 4,
                children: [
                  GlassCircleButton(
                    icon: StrokeIcons.back,
                    semanticLabel: 'Back',
                    onTap: () =>
                        context.canPop() ? context.pop() : context.go('/'),
                  ),
                  Expanded(
                    child: Text(
                      widget.bossId == null ? 'A new boss' : 'Edit boss',
                      style: text.titleLarge,
                    ),
                  ),
                  GlassPillButton(
                    label: 'Save',
                    onTap: draft != null && draft.canSave ? _save : null,
                  ),
                ],
              ),
            ),
            Expanded(
              child: draft == null
                  ? Center(child: Text(_error ?? ''))
                  : _form(context, draft),
            ),
          ],
        ),
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
        NeedleTextField(
          controller: _title,
          caption: 'Title',
          hint: 'A goal worth a fight',
          onChanged: (v) => _update((d) => d.copyWith(title: v)),
        ),
        const SizedBox(height: Space.md),
        NeedleTextField(
          controller: _meaning,
          caption: 'What does defeat mean?',
          maxLength: 200,
          onChanged: (v) => _update((d) => d.copyWith(defeatMeaning: v)),
        ),
        _dateRow(context, draft),
        const SizedBox(height: Space.md),
        SettingChoiceRow<ResetOnFail>(
          title: 'On a failed attempt, reset',
          options: {for (final r in ResetOnFail.values) r: r.label},
          selected: draft.resetOnFail,
          onChanged: (r) => _update((d) => d.copyWith(resetOnFail: r)),
        ),
        const SizedBox(height: Space.lg),
        Text('CHAPTERS', style: text.labelSmall),
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
              PhasePanel(
                key: ValueKey(p.id),
                index: i,
                name: p.name,
                foes: [for (final t in p.tasks) _foe(t)],
                onRename: (name) => _update(
                  (d) => d.copyWith(
                    phases: [
                      for (final q in d.phases)
                        q.id == p.id ? q.copyWith(name: name) : q,
                    ],
                  ),
                ),
                onDelete: () => _deletePhase(p),
                onAddFoe: () => _editTask(
                  TaskDraft(id: newId(), title: ''),
                  p.id,
                  isNew: true,
                ),
                onEditFoe: (i) => _editTask(p.tasks[i], p.id),
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
          child: const Text('Add a chapter'),
        ),
        const SizedBox(height: Space.lg),
        Text('BEYOND THE CHAPTERS', style: text.labelSmall),
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

  static PhaseFoe _foe(TaskDraft t) => PhaseFoe(
    title: t.title,
    note:
        '${t.weight.label}${t.recurrence == Recurrence.daily ? ' · daily' : ''}',
  );

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
