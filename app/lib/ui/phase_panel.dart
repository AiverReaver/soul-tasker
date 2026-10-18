import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'needle_frame.dart';

/// One foe line inside a [PhasePanel]: its title and a short note such as
/// "Heavy · daily".
class PhaseFoe {
  const PhaseFoe({required this.title, required this.note});

  final String title;
  final String note;
}

/// A phase in the boss editor: a needle frame with a drag grip (for a
/// `ReorderableListView`, by [index]), the editable name, its foes and "Add a
/// foe". Values in, callbacks out.
class PhasePanel extends StatelessWidget {
  const PhasePanel({
    super.key,
    required this.index,
    required this.name,
    required this.foes,
    required this.onRename,
    required this.onDelete,
    required this.onAddFoe,
    required this.onEditFoe,
  });

  final int index;
  final String name;
  final List<PhaseFoe> foes;
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;
  final VoidCallback onAddFoe;
  final ValueChanged<int> onEditFoe;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.sm),
      child: NeedleFrame(
        tier: Cut.md,
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
                      child: Icon(Icons.drag_handle, color: p.ash),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      initialValue: name,
                      maxLength: 60,
                      style: text.bodyLarge,
                      cursorColor: p.silk,
                      decoration: InputDecoration(
                        hintText: 'Chapter name',
                        hintStyle: TextStyle(color: p.ash),
                        counterText: '',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      onChanged: onRename,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete chapter',
                    icon: Icon(Icons.close, color: p.ash),
                    onPressed: onDelete,
                  ),
                ],
              ),
              for (final (i, f) in foes.indexed)
                InkWell(
                  onTap: () => onEditFoe(i),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: kMinTarget),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Space.sm),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(f.title, style: text.bodyMedium),
                          ),
                          Text(f.note, style: text.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
              TextButton(onPressed: onAddFoe, child: const Text('Add a task')),
            ],
          ),
        ),
      ),
    );
  }
}
