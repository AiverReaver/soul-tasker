import 'package:flutter/material.dart';

import 'boss_health_bar.dart';
import 'fallen_screen.dart';
import 'hold_to_strike.dart';
import 'models.dart';
import 'theme.dart';

class BossScreen extends StatefulWidget {
  const BossScreen({super.key});

  @override
  State<BossScreen> createState() => _BossScreenState();
}

class _BossScreenState extends State<BossScreen> {
  Boss _boss = sampleBoss();
  bool _tapMode = false;
  String? _flash;

  void _strike(int phase, int task) {
    setState(() {
      _boss = _boss.strike(phase, task);
      _flash = _boss.health == 0 ? 'Foe vanquished.' : 'It is done.';
    });
  }

  Future<void> _fall() async {
    final lesson = await FallenScreen.show(context);
    if (!mounted) return;
    setState(() {
      _boss = _boss.fall(lesson);
      _flash = null;
    });
  }

  void _reset() => setState(() {
        _boss = sampleBoss();
        _flash = null;
      });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final attemptLine = _boss.lastLesson == null
        ? 'Attempt ${_boss.attempt}.'
        : 'Attempt ${_boss.attempt}. Last time: ${_boss.lastLesson}';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
          children: [
            Text(_boss.title, style: text.displaySmall),
            const SizedBox(height: 20),
            BossHealthBar(boss: _boss),
            const SizedBox(height: 16),
            Text(attemptLine, style: text.bodySmall),
            SizedBox(
              height: 36,
              child: AnimatedSwitcher(
                duration: kSlowFade,
                child: Text(
                  _flash ?? '',
                  key: ValueKey('${_boss.doneTasks}-$_flash'),
                  style: text.titleMedium?.copyWith(color: kEmber),
                ),
              ),
            ),
            for (var p = 0; p < _boss.phases.length; p++) ...[
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 6),
                child: Text(
                  _boss.phases[p].name.toUpperCase(),
                  style: text.bodySmall?.copyWith(letterSpacing: 2),
                ),
              ),
              for (var t = 0; t < _boss.phases[p].tasks.length; t++)
                HoldToStrike(
                  key: ValueKey('$p-$t'),
                  task: _boss.phases[p].tasks[t],
                  tapMode: _tapMode,
                  onStrike: () => _strike(p, t),
                ),
            ],
            const SizedBox(height: 40),
            OutlinedButton(
              onPressed: _fall,
              style: OutlinedButton.styleFrom(
                foregroundColor: kAsh,
                side: const BorderSide(color: kAshDim),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('This attempt failed'),
            ),
            SwitchListTile(
              value: _tapMode,
              onChanged: (v) => setState(() => _tapMode = v),
              activeThumbColor: kEmber,
              contentPadding: EdgeInsets.zero,
              title: Text('Tap instead of hold', style: text.bodySmall),
            ),
            TextButton(
              onPressed: _reset,
              child: Text('Reset prototype', style: text.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}
