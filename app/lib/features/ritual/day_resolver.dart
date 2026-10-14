import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/providers.dart';
import '../../ui/flask_choice.dart';
import '../fallen/fallen_screen.dart';

/// Judges the days that ended while the app was closed, on start and on
/// resume (Stage 3 plan D1). Wraps the home screen; shows nothing unless a
/// day was missed. Nothing is written until the user has answered, so an
/// interrupted flow is simply offered again.
class DayResolver extends ConsumerStatefulWidget {
  const DayResolver({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<DayResolver> createState() => _DayResolverState();
}

class _DayResolverState extends ConsumerState<DayResolver>
    with WidgetsBindingObserver {
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    if (_isBusy || !mounted) return;
    _isBusy = true;
    try {
      await _resolve();
    } finally {
      _isBusy = false;
    }
  }

  Future<void> _resolve() async {
    final days = ref.read(dayDaoProvider);
    final pending = await days.pending();
    if (!mounted) return;
    // Nobody to fall: just move the day on.
    if (pending.bosses.isEmpty) {
      await days.resolve();
      return;
    }

    var spend = 0;
    if (pending.flasks > 0) {
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

    String? lesson;
    if (spend < pending.days.length) {
      lesson = await FallenScreen.show(context, ref.read(hapticsProvider));
      if (!mounted) return;
    }
    await days.resolve(lesson: lesson, flasksToSpend: spend);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
