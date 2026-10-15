import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/enums.dart';
import '../../data/providers.dart';
import '../../ui/strike_sweep_view.dart';
import '../../ui/task_row_tile.dart';
import 'strike_sweep.dart';

/// Hold to complete (design doc §7). Release early rolls progress back.
/// [tapMode] turns the hold into a single tap for accessibility (§7.5).
class HoldToStrike extends ConsumerStatefulWidget {
  const HoldToStrike({
    super.key,
    required this.title,
    required this.weight,
    required this.isDone,
    required this.onStrike,
    this.tapMode = false,
    this.trailing,
    this.deadline,
  });

  final String title;
  final Weight weight;
  final bool isDone;
  final VoidCallback onStrike;
  final bool tapMode;

  /// Shown after the weight label, e.g. the task's action menu.
  final Widget? trailing;

  /// The commitment's chip, when the task is promised today.
  final Widget? deadline;

  @override
  ConsumerState<HoldToStrike> createState() => _HoldToStrikeState();
}

class _HoldToStrikeState extends ConsumerState<HoldToStrike>
    with TickerProviderStateMixin {
  static const _rollbackDuration = Motion.quick;

  /// The landing sweep (§7.2); its length is set per strike.
  late final AnimationController _sweep = AnimationController(vsync: this);

  late final AnimationController _progress =
      AnimationController(
          vsync: this,
          duration: widget.weight.holdDuration,
          reverseDuration: _rollbackDuration,
        )
        ..addListener(_hapticTick)
        ..addStatusListener(_onStatus);

  int _lastBeat = 0;

  /// Where the current press began; null once it has turned into a scroll.
  Offset? _downAt;

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
    _sweep.dispose();
    super.dispose();
  }

  // Ticks that build as the hold continues (§7.2, §8.3). Beat n fires when
  // the hold passes n / (beats + 1); the strike is the last step.
  void _hapticTick() {
    final weight = widget.weight;
    final beats = weight.buildUpTicks + (weight.hasBuildUpPulse ? 1 : 0);
    final beat = (_progress.value * (beats + 1)).floor();
    if (_progress.status == AnimationStatus.forward &&
        beat > _lastBeat &&
        beat <= beats) {
      final haptics = ref.read(hapticsProvider);
      beat == beats && weight.hasBuildUpPulse
          ? haptics.medium()
          : haptics.tick();
    }
    _lastBeat = beat;
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _land();
  }

  void _land() {
    final haptics = ref.read(hapticsProvider);
    switch (widget.weight) {
      case Weight.light:
        haptics.light();
      case Weight.heavy:
        haptics.heavy();
      case Weight.bossTier:
        haptics.doubleHeavy();
    }
    final sweepLength = motionOf(context, sweepDuration(widget.weight));
    if (sweepLength > Duration.zero) {
      _sweep
        ..duration = sweepLength
        ..forward(from: 0);
    }
    widget.onStrike();
  }

  void _start(Offset position) {
    _downAt = position;
    if (!widget.isDone) _progress.forward();
  }

  // A finger that travels past touch slop is scrolling, not holding (§7.1).
  void _onMove(Offset position) {
    final downAt = _downAt;
    if (downAt != null && (position - downAt).distance > kTouchSlop) {
      _downAt = null;
      _cancel();
    }
  }

  void _cancel() {
    if (_progress.status != AnimationStatus.completed) _progress.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final content = AnimatedBuilder(
      animation: Listenable.merge([_progress, _sweep]),
      builder: (context, _) => TaskRowTile(
        title: widget.title,
        weightLabel: widget.weight.label,
        isDone: widget.isDone,
        progress: _progress.value,
        sweep: _sweep.isAnimating
            ? StrikeSweepView(
                key: kStrikeSweepKey,
                progress: _sweep.value,
                isBossTier: widget.weight == Weight.bossTier,
              )
            : null,
        trailing: widget.trailing,
        deadline: widget.deadline,
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
        onPointerDown: (e) => _start(e.position),
        onPointerMove: (e) => _onMove(e.position),
        onPointerUp: (_) => _cancel(),
        onPointerCancel: (_) => _cancel(),
        child: content,
      ),
    );
  }
}
