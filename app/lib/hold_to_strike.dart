import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models.dart';
import 'theme.dart';

/// Hold to complete (design doc §7). Release early rolls progress back.
/// [tapMode] turns the hold into a single tap for accessibility (§7.5).
class HoldToStrike extends StatefulWidget {
  const HoldToStrike({
    super.key,
    required this.task,
    required this.onStrike,
    this.tapMode = false,
  });

  final Task task;
  final VoidCallback onStrike;
  final bool tapMode;

  @override
  State<HoldToStrike> createState() => _HoldToStrikeState();
}

class _HoldToStrikeState extends State<HoldToStrike>
    with SingleTickerProviderStateMixin {
  static const _tickCount = 4;
  static const _rollbackDuration = Motion.quick;

  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: widget.task.weight.holdDuration,
    reverseDuration: _rollbackDuration,
  )
    ..addListener(_hapticTick)
    ..addStatusListener(_onStatus);

  int _lastTick = 0;

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  // Light ticks that build as the hold continues (§7.2, §8.3).
  void _hapticTick() {
    final tick = (_progress.value * _tickCount).floor();
    if (_progress.status == AnimationStatus.forward && tick > _lastTick) {
      tick >= _tickCount - 1
          ? HapticFeedback.mediumImpact()
          : HapticFeedback.selectionClick();
    }
    _lastTick = tick;
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _land();
  }

  void _land() {
    widget.task.weight == Weight.light
        ? HapticFeedback.lightImpact()
        : HapticFeedback.heavyImpact();
    widget.onStrike();
  }

  void _start() {
    if (!widget.task.isDone) _progress.forward();
  }

  void _cancel() {
    if (_progress.status != AnimationStatus.completed) _progress.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final content = AnimatedBuilder(
      animation: _progress,
      builder: (context, _) => _TaskRow(task: task, progress: _progress.value),
    );

    if (task.isDone) return content;
    if (widget.tapMode) {
      return Semantics(
        button: true,
        label: 'Complete ${task.title}',
        child: GestureDetector(onTap: _land, child: content),
      );
    }
    return Semantics(
      button: true,
      label: 'Hold to complete ${task.title}',
      child: Listener(
        onPointerDown: (_) => _start(),
        onPointerUp: (_) => _cancel(),
        onPointerCancel: (_) => _cancel(),
        child: content,
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, required this.progress});

  final Task task;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AnimatedOpacity(
      opacity: task.isDone ? 0.35 : 1,
      duration: kSlowFade,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: kSurface,
          border: Border.all(color: kAshDim.withValues(alpha: 0.3)),
        ),
        child: Stack(
          children: [
            // Ember fill grows across the row during the hold.
            Positioned.fill(
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: task.isDone ? 1 : progress,
                child: ColoredBox(
                  color: kEmber.withValues(alpha: task.isDone ? 0.08 : 0.25),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: text.bodyMedium?.copyWith(
                        decoration:
                            task.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  Text(task.weight.label, style: text.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
