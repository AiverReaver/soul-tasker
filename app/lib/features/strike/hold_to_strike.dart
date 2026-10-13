import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/enums.dart';

/// Hold to complete (design doc §7). Release early rolls progress back.
/// [tapMode] turns the hold into a single tap for accessibility (§7.5).
class HoldToStrike extends StatefulWidget {
  const HoldToStrike({
    super.key,
    required this.title,
    required this.weight,
    required this.isDone,
    required this.onStrike,
    this.tapMode = false,
    this.trailing,
  });

  final String title;
  final Weight weight;
  final bool isDone;
  final VoidCallback onStrike;
  final bool tapMode;

  /// Shown after the weight label, e.g. the task's action menu.
  final Widget? trailing;

  @override
  State<HoldToStrike> createState() => _HoldToStrikeState();
}

class _HoldToStrikeState extends State<HoldToStrike>
    with SingleTickerProviderStateMixin {
  static const _tickCount = 4;
  static const _rollbackDuration = Motion.quick;

  late final AnimationController _progress =
      AnimationController(
          vsync: this,
          duration: widget.weight.holdDuration,
          reverseDuration: _rollbackDuration,
        )
        ..addListener(_hapticTick)
        ..addStatusListener(_onStatus);

  int _lastTick = 0;

  @override
  void didUpdateWidget(HoldToStrike old) {
    super.didUpdateWidget(old);
    _progress.duration = widget.weight.holdDuration;
    // A reset reopened this task: clear the finished fill.
    if (old.isDone && !widget.isDone) _progress.value = 0;
  }

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
    widget.weight == Weight.light
        ? HapticFeedback.lightImpact()
        : HapticFeedback.heavyImpact();
    widget.onStrike();
  }

  void _start() {
    if (!widget.isDone) _progress.forward();
  }

  void _cancel() {
    if (_progress.status != AnimationStatus.completed) _progress.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final content = AnimatedBuilder(
      animation: _progress,
      builder: (context, _) => _TaskRow(
        title: widget.title,
        weight: widget.weight,
        isDone: widget.isDone,
        progress: _progress.value,
        trailing: widget.trailing,
      ),
    );

    if (widget.isDone) return content;
    if (widget.tapMode) {
      return Semantics(
        button: true,
        label: 'Complete ${widget.title}',
        child: GestureDetector(onTap: _land, child: content),
      );
    }
    return Semantics(
      button: true,
      label: 'Hold to complete ${widget.title}',
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
  const _TaskRow({
    required this.title,
    required this.weight,
    required this.isDone,
    required this.progress,
    this.trailing,
  });

  final String title;
  final Weight weight;
  final bool isDone;
  final double progress;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AnimatedOpacity(
      opacity: isDone ? 0.35 : 1,
      duration: motionOf(context, kSlowFade),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: const BoxConstraints(minHeight: kMinTarget),
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
                widthFactor: isDone ? 1 : progress,
                child: ColoredBox(
                  color: kEmber.withValues(alpha: isDone ? 0.08 : 0.25),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: trailing == null ? 16 : 0,
                top: trailing == null ? 14 : 0,
                bottom: trailing == null ? 14 : 0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: text.bodyMedium?.copyWith(
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  Text(weight.label, style: text.bodySmall),
                  ?trailing,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
