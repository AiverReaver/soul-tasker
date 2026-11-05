import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'diamond_pip.dart';
import 'needle_frame.dart';
import 'stroke_icon.dart';

/// Where a foe row is in a strike (D8). `charge` runs while the button is
/// held; `hit`, `shatter` and `settle` follow the strike timeline.
enum RowPhase { idle, charge, hit, shatter, settle }

/// A foe row: weight pips, title, a meta line, then the hold button in
/// [trailing]; tapping the rest of the row calls [onTap]. A struck row swaps the button for a silk check, wears the
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
    this.onTap,
    this.deadline,
    this.compact = false,
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

  /// Tapping the row away from the button: opens the foe's actions.
  final VoidCallback? onTap;

  /// The commitment's chip, when the task is promised today.
  final Widget? deadline;

  /// Grouped lists: 52 high, the meta (just the embers) on the title line.
  final bool compact;

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
    // Line-through, not an overlay, so every line of a wrapped title is
    // crossed out.
    final titleLine = Text(
      title,
      style: isDone
          ? titleStyle.copyWith(
              decoration: TextDecoration.lineThrough,
              decorationColor: p.ink,
              decorationThickness: 1.5,
            )
          : titleStyle,
    );
    final metaLine = Text(
      meta,
      style: text.bodySmall!.copyWith(
        fontSize: 13,
        height: 18 / 13,
        color: ink ?? p.ash,
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: _TapRegion(
        onTap: onTap,
        builder: (absorb) => NeedleFrame(
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
            constraints: BoxConstraints(minHeight: compact ? 52 : 64),
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
                      padding: EdgeInsets.symmetric(
                        vertical: compact ? 0 : Space.sm,
                      ),
                      child: compact
                          ? Row(
                              spacing: 8,
                              children: [
                                Flexible(child: titleLine),
                                metaLine,
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [titleLine, metaLine],
                            ),
                    ),
                  ),
                  ?deadline,
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
                  else if (trailing case final trailing?)
                    absorb(trailing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Turns a quick press on the row into [onTap] without joining the gesture
/// arena, so a drag that starts on the row still scrolls the list. A press
/// that starts on a child wrapped with `absorb` (the hold button) is not a
/// row tap.
class _TapRegion extends StatefulWidget {
  const _TapRegion({required this.onTap, required this.builder});

  final VoidCallback? onTap;
  final Widget Function(Widget Function(Widget child) absorb) builder;

  @override
  State<_TapRegion> createState() => _TapRegionState();
}

class _TapRegionState extends State<_TapRegion> {
  Offset? _down;
  bool _absorbed = false;

  Widget _absorb(Widget child) =>
      Listener(onPointerDown: (_) => _absorbed = true, child: child);

  @override
  Widget build(BuildContext context) => Listener(
    behavior: HitTestBehavior.opaque,
    onPointerDown: (e) {
      // Children run first: an absorbed press has already set the flag.
      _down = _absorbed ? null : e.position;
      _absorbed = false;
    },
    onPointerUp: (e) {
      final down = _down;
      _down = null;
      if (down != null && (e.position - down).distance <= kTouchSlop) {
        widget.onTap?.call();
      }
    },
    onPointerCancel: (_) => _down = null,
    child: widget.builder(_absorb),
  );
}
