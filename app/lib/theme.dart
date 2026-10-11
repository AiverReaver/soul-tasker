import 'package:flutter/material.dart';

// Palette from design doc §8.1: near-black, ash-grey text, one ember-gold accent.
const Color kBackground = Color(0xFF0B0A09);
const Color kSurface = Color(0xFF161412);
const Color kAsh = Color(0xFFB8B2A7);
const Color kAshDim = Color(0xFF5E5A54);
const Color kEmber = Color(0xFFD9A441);
const Color kBossHealth = Color(0xFF8A2F22);

const Duration kSlowFade = Duration(milliseconds: 600);

ThemeData buildTheme() {
  const display = TextStyle(fontFamily: 'serif', color: kAsh);
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBackground,
    colorScheme: const ColorScheme.dark(
      primary: kEmber,
      surface: kSurface,
      onSurface: kAsh,
    ),
    textTheme: TextTheme(
      displaySmall: display.copyWith(fontSize: 32, letterSpacing: 1.5),
      titleMedium: display.copyWith(fontSize: 20),
      bodyMedium: const TextStyle(color: kAsh, fontSize: 15),
      bodySmall: const TextStyle(color: kAshDim, fontSize: 13),
    ),
  );
}
