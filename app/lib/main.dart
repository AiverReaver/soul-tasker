import 'package:flutter/material.dart';

import 'boss_screen.dart';
import 'theme.dart';

void main() => runApp(const SoulTrackerApp());

class SoulTrackerApp extends StatelessWidget {
  const SoulTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soul Tracker',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const BossScreen(),
    );
  }
}
