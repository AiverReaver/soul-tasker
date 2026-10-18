import 'package:hearthrise/core/theme.dart';
import 'package:material_ui/material_ui.dart';

/// A themed app around [child] for glass widget tests.
Widget glassHost(
  Widget child, {
  Biome biome = Biome.pharloom,
  double text = 1,
}) => MaterialApp(
  theme: buildTheme(biome),
  home: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(text)),
    child: Scaffold(body: Center(child: child)),
  ),
);
