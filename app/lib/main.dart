import 'package:flutter/material.dart';

import 'boss_screen.dart';
import 'theme.dart';

void main() => runApp(const HearthriseApp());

class HearthriseApp extends StatelessWidget {
  const HearthriseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hearthrise',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const BossScreen(),
    );
  }
}
