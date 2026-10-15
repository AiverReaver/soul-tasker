import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/deadlines.dart';
import '../../data/enums.dart';
import '../../data/health_dao.dart';
import '../../data/providers.dart';
import '../../ui/away_summary.dart';
import '../../ui/flask_choice.dart';
import '../fallen/fallen_screen.dart';
import '../fallen/health_fall.dart';
import 'reminder_coordinator.dart';

/// Settles passed deadlines and judges the days that ended, on start, on
/// resume (Stage 3 plan D1) and every minute while open (Stage 4 plan D18).
/// Wraps the home screen; shows nothing unless something passed. Missed days
/// write nothing until the user has answered, so an interrupted flow is
/// offered again; deadlines are settled first, from their stored times.
class DayResolver extends ConsumerStatefulWidget {
  const DayResolver({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<DayResolver> createState() => _DayResolverState();
}

class _DayResolverState extends ConsumerState<DayResolver>
    with WidgetsBindingObserver {
  bool _isBusy = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reminderCoordinatorProvider).rearm();
      _check(isTick: false);
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(kDeadlineTick, (_) => _check(isTick: true));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _startTimer();
        _check(isTick: false);
      case AppLifecycleState.paused || AppLifecycleState.hidden:
        _timer?.cancel();
      case _:
    }
  }

  Future<void> _check({required bool isTick}) async {
    if (_isBusy || !mounted) return;
    _isBusy = true;
    try {
      await _resolve(isTick: isTick);
    } finally {
      _isBusy = false;
    }
  }

  Future<void> _resolve({required bool isTick}) async {
    final due = await ref.read(healthDaoProvider).resolveDue();
    if (!mounted) return;
    if (due.settled.isNotEmpty) {
      // While open a miss is a quiet line; after time away, one summary.
      isTick ? _sayPassed(due.settled) : await _showAway(due.settled);
      if (!mounted) return;
    }

    final days = ref.read(dayDaoProvider);
    final pending = await days.pending();
    if (!mounted) return;
    final hasMissed = pending.days.isNotEmpty && pending.bosses.isNotEmpty;
    if (!hasMissed && due.deaths.isEmpty) {
      // Nobody to fall: just move the day on.
      if (pending.days.isNotEmpty) await days.resolve();
      return;
    }

    var spend = 0;
    if (hasMissed && pending.flasks > 0) {
      final useFlask = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialog) => FlaskChoice(
          daysMissed: pending.days.length,
          flasks: pending.flasks,
          onUseFlask: () => Navigator.pop(dialog, true),
          onLetFall: () => Navigator.pop(dialog, false),
        ),
      );
      if (!mounted) return;
      if (useFlask ?? false) spend = min(pending.flasks, pending.days.length);
    }

    // One bad stretch, one fallen moment and one lesson (Stage 4 plan D14).
    String? lesson;
    if (due.deaths.isNotEmpty) {
      lesson = await showHealthFall(
        context,
        ref,
        due.deaths.last.day,
        attemptIds: [for (final d in due.deaths) d.attemptId],
      );
    } else if (spend < pending.days.length) {
      lesson = await FallenScreen.show(context, ref.read(hapticsProvider));
    }
    if (!mounted) return;
    if (pending.days.isNotEmpty) {
      await days.resolve(lesson: lesson, flasksToSpend: spend);
    }
  }

  void _sayPassed(List<SettledDeadline> settled) {
    final message = settled.length == 1
        ? 'A deadline passed: ${settled.single.taskTitle}.'
        : '${countWord(settled.length)} deadlines passed.';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showAway(List<SettledDeadline> settled) async {
    final done = <String>{};
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialog) => StatefulBuilder(
        builder: (dialog, setState) => AwaySummary(
          rows: [
            for (final s in settled)
              AwayRow(
                id: s.commitmentId,
                title: s.taskTitle,
                cost: s.outcome == CommitmentOutcome.frozen
                    ? 'frozen'
                    : '−${formatHealth(s.loss)} health',
                isDone: done.contains(s.commitmentId),
              ),
          ],
          onDoneLate: (id) async {
            final s = settled.firstWhere((s) => s.commitmentId == id);
            await ref.read(attemptDaoProvider).strike(s.taskId);
            setState(() => done.add(id));
          },
          onClose: () => Navigator.pop(dialog),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
