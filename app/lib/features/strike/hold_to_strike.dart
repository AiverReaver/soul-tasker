import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/enums.dart';
import '../../data/providers.dart';
import '../../ui/dust_vanish.dart';
import '../../ui/hold_button.dart';
import '../../ui/strike_result_sheet.dart';
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
    this.onTried,
    this.tapMode = false,
    this.onOpenActions,
    this.deadline,
    this.bossName,
  });

  final String title;
  final Weight weight;
  final bool isDone;
  final VoidCallback onStrike;

  /// When set, a finished hold first asks Strike or Tried; Tried calls this.
  /// When null, a finished hold strikes at once.
  final VoidCallback? onTried;
  final bool tapMode;

  /// Tapping the row away from the hold button.
  final VoidCallback? onOpenActions;

  /// Opens the meta line: "{bossName} · +N embers".
  final String? bossName;

  /// The commitment's chip, when the task is promised today.
  final Widget? deadline;

  @override
  ConsumerState<HoldToStrike> createState() => _HoldToStrikeState();
}

class _HoldToStrikeState extends ConsumerState<HoldToStrike>
    with TickerProviderStateMixin {
  /// The charge is full past this much of the hold: the button's edge turns bone.
  static const readyAt = 0.8;

  static const _rollbackDuration = Motion.quick;

  /// The landing sweep (§7.2); its length is set per strike.
  late final AnimationController _sweep = AnimationController(vsync: this);

  /// The task dissolving into dust once struck.
  late final AnimationController _dust = AnimationController(vsync: this);

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
    _dust.dispose();
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
    if (widget.onTried == null) return _strike();
    _playThenAsk();
  }

  /// The beats play first, then the sheet asks; nothing is written until
  /// the player chooses (D8).
  Future<void> _playThenAsk() async {
    await _play();
    if (!mounted) return;
    final clean = await showStrikeResultSheet(context, widget.title);
    if (!mounted) return;
    switch (clean) {
      case true:
        widget.onStrike();
      case false:
        _progress.value = 0;
        widget.onTried?.call();
      case null:
        _progress.value = 0;
    }
  }

  Future<void> _play() async {
    final sweepLength = motionOf(context, sweepDuration(widget.weight));
    if (sweepLength == Duration.zero) return;
    _dust
      ..duration = sweepLength * 3
      ..forward(from: 0);
    _sweep.duration = sweepLength;
    await _sweep.forward(from: 0).orCancel.catchError((_) {});
  }

  void _strike() {
    _play();
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

  /// How long the landing sweep has run.
  Duration get _strikeClock => _sweep.isAnimating
      ? (_sweep.duration ?? Duration.zero) * _sweep.value
      : Duration.zero;

  RowPhase get _phase {
    if (_sweep.isAnimating) {
      return switch (strikeBeatAt(_strikeClock)) {
        StrikeBeat.hit => RowPhase.hit,
        StrikeBeat.shatter => RowPhase.shatter,
        StrikeBeat.settle => RowPhase.settle,
        StrikeBeat.idle => RowPhase.idle,
      };
    }
    return !widget.isDone && _progress.value > 0
        ? RowPhase.charge
        : RowPhase.idle;
  }

  Widget _button(BuildContext context) {
    final label = widget.tapMode
        ? 'Complete ${widget.title}'
        : 'Hold to strike: ${widget.title}';
    final button = HoldButton(
      progress: _progress.value,
      isReady: !widget.isDone && _progress.value >= readyAt,
      semanticLabel: label,
    );
    if (widget.tapMode) {
      return GestureDetector(onTap: _land, child: button);
    }
    return Listener(
      onPointerDown: (e) => _start(e.position),
      onPointerMove: (e) => _onMove(e.position),
      onPointerUp: (_) => _cancel(),
      onPointerCancel: (_) => _cancel(),
      child: button,
    );
  }

  @override
  Widget build(BuildContext context) {
    final weight = widget.weight;
    final embers = '+${weight.embers} embers';
    final lead = widget.isDone ? 'Struck' : widget.bossName;
    return AnimatedBuilder(
      animation: Listenable.merge([_progress, _sweep, _dust]),
      // The shatter throws the row; a light strike throws it less.
      builder: (context, _) => Transform.translate(
        key: kStrikeShakeKey,
        offset: rowShakeAt(_strikeClock) * (weight == Weight.light ? 0.6 : 1),
        child: TaskRowTile(
          title: widget.title,
          pips: weight.index + 1,
          meta: lead == null ? embers : '$lead · $embers',
          isDone: widget.isDone,
          phase: _phase,
          sweep: _sweep.isAnimating || _dust.isAnimating
              ? Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (_dust.isAnimating)
                      Positioned.fill(
                        child: DustVanish(
                          progress: _dust.value,
                          seed: widget.title.hashCode,
                          motes: 24,
                          child: const SizedBox.shrink(),
                        ),
                      ),
                    if (_sweep.isAnimating)
                      Positioned.fill(
                        child: StrikeSweepView(
                          key: kStrikeSweepKey,
                          progress: _sweep.value,
                          isBossTier: weight == Weight.bossTier,
                        ),
                      ),
                  ],
                )
              : null,
          onTap: widget.onOpenActions,
          deadline: widget.deadline,
          trailing: _button(context),
        ),
      ),
    );
  }
}
