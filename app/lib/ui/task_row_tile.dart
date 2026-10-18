import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'diamond_pip.dart';
import 'needle_frame.dart';
import 'stroke_icon.dart';

/// Where a foe row is in a strike (D8). `charge` runs while the button is
/// held; `hit`, `shatter` and `settle` follow the strike timeline.
enum RowPhase { idle, charge, hit, shatter, settle }

/// A foe row: weight pips, title, a meta line, then the hold button in
/// [trailing]. A struck row swaps the button for a silk check, wears the
/// struck colours and draws an ink line through its title. Pure
/// presentation; hold logic lives in `features/strike/hold_to_strike.dart`.
class TaskRowTile extends StatelessWidget {
  const TaskRowTile({
    super.key,
    required this.title,
    required this.pips,
    required this.meta,
    required this.isDone,
    this.phase = RowPhase.idle,
    this.sweep,
    this.trailing,
    this.menu,
    this.deadline,
  });

  final String title;

  /// One diamond per weight step.
  final int pips;

  /// "{boss} · +N embers", or "Struck · +N embers" once struck.
  final String meta;
  final bool isDone;
  final RowPhase phase;

  /// Drawn over the row while a strike lands; null when idle.
  final Widget? sweep;

  /// The hold button.
  final Widget? trailing;

  /// A row menu, left of the button.
  final Widget? menu;

  /// The commitment's chip, when the task is promised today.
  final Widget? deadline;

  @override
  Widget build(BuildContext context) {
    // The slash sits outside the row so the cut lands at full strength, and
    // its flecks may fly past the row's edge.
    final stack = Stack(
      clipBehavior: Clip.none,
      children: [
        _row(context),
        if (sweep case final sweep?)
          Positioned.fill(
            top: 4,
            bottom: 4,
            child: IgnorePointer(child: sweep),
          ),
      ],
    );
    return isDone
        ? Semantics(
            label: '$title, struck',
            excludeSemantics: true,
            child: stack,
          )
        : stack;
  }

  Widget _row(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final isHit = phase == RowPhase.hit;
    final ink = isHit ? p.ink : null;
    final titleStyle = text.bodyLarge!.copyWith(
      fontSize: 16,
      height: 22 / 16,
      fontWeight: FontWeight.w500,
      color: ink ?? (isDone ? p.ash : p.bone),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: NeedleFrame(
        tier: Cut.md,
        edge: isDone
            ? p.struckEdge
            : phase == RowPhase.charge
            ? p.silk
            : null,
        fill: isHit
            ? p.bone
            : isDone
            ? p.struckBg
            : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.only(left: Space.md, right: Space.sm),
            child: Row(
              spacing: 14,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    for (var i = 0; i < pips; i++)
                      DiamondPip(color: isDone ? p.dim : p.silk),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Space.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Text(title, style: titleStyle),
                            if (isDone)
                              Positioned.fill(
                                child: Center(
                                  child: ColoredBox(
                                    key: const ValueKey('row-ink-line'),
                                    color: p.ink,
                                    child: const SizedBox(
                                      height: 1.5,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          meta,
                          style: text.bodySmall!.copyWith(
                            fontSize: 13,
                            height: 18 / 13,
                            color: ink ?? p.ash,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ?deadline,
                ?menu,
                if (isDone)
                  SizedBox.square(
                    dimension: 48,
                    child: Center(
                      child: StrokeIcon(
                        key: const ValueKey('row-check'),
                        path: StrokeIcons.check,
                        color: p.silk,
                      ),
                    ),
                  )
                else
                  ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
