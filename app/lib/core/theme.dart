import 'package:material_ui/material_ui.dart';

import '../ui/silk_page_transition.dart';

import 'package:flutter/services.dart';

import 'palette.dart';

// Design tokens. Source of truth: /DESIGN.md. Colors live in palette.dart.

export 'palette.dart';

// Spacing: 4 pt grid.
abstract final class Space {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 40;
  static const double xxl = 56;
}

// Shape: one radius, three sizes. Same in every biome, so it stays const.
abstract final class Cut {
  static const double lg = 8; // panels, sheets
  static const double md = 6; // rows, buttons, fields
  static const double sm = 4; // tags
}

// Motion: slow, no bounce (§8.1). Exits faster than entrances.
abstract final class Motion {
  static const Duration quick = Duration(
    milliseconds: 250,
  ); // rollback, small state
  static const Duration fade = Duration(milliseconds: 600); // standard fade
  static const Duration drain = Duration(
    milliseconds: 900,
  ); // health segment drain
  static const Duration dim = Duration(milliseconds: 1400); // fallen screen dim
  static const Curve ease = Curves.easeInOut;
}

const Duration kSlowFade = Motion.fade;

/// [duration], or zero when the system asks for reduced motion.
Duration motionOf(BuildContext context, Duration duration) =>
    MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;

/// Minimum touch target (DESIGN.md accessibility checklist).
const double kMinTarget = 48;

const _display = 'CormorantGaramond';
const _body = 'HankenGrotesk';

// Variable fonts need the wght axis set explicitly to render the weight.
TextStyle _font(
  String family,
  double size,
  int weight,
  Color color, {
  double spacing = 0,
  double height = 1.4,
}) => TextStyle(
  fontFamily: family,
  fontSize: size,
  fontWeight: FontWeight.values[weight ~/ 100 - 1],
  fontVariations: [FontVariation.weight(weight.toDouble())],
  color: color,
  letterSpacing: spacing,
  height: height,
);

ThemeData buildTheme([Biome biome = Biome.pharloom]) {
  const pages = SilkPageTransitions();
  final p = biome.palette;
  const clear = Colors.transparent;
  final base = biome.brightness == Brightness.dark
      ? const ColorScheme.dark()
      : const ColorScheme.light();
  return ThemeData(
    brightness: biome.brightness,
    extensions: [p],
    // Clear: the backdrop (features/shell) shows through.
    scaffoldBackgroundColor: clear,
    appBarTheme: AppBarTheme(
      backgroundColor: clear,
      surfaceTintColor: clear,
      scrolledUnderElevation: 0,
      systemOverlayStyle: biome.brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: pages,
        TargetPlatform.iOS: pages,
        TargetPlatform.macOS: pages,
        TargetPlatform.linux: pages,
        TargetPlatform.windows: pages,
      },
    ),
    fontFamily: _body,
    colorScheme: base.copyWith(
      primary: p.silk,
      onPrimary: p.onSilk,
      // Selected segments and chips: a quiet raised surface, not a new hue.
      secondaryContainer: p.raised,
      onSecondaryContainer: p.text,
      outline: p.seam,
      outlineVariant: p.seam,
      surface: p.shell,
      onSurface: p.text,
      error: p.shard,
    ),
    textTheme: TextTheme(
      // Display serif: boss names and major moments only.
      displayMedium: _font(_display, 44, 500, p.bone, spacing: 1, height: 1.1),
      displaySmall: _font(_display, 34, 500, p.bone, spacing: 1, height: 1.15),
      titleMedium: _font(_display, 22, 500, p.bone, height: 1.3),
      // Body sans: everything else.
      bodyLarge: _font(_body, 16, 400, p.text, height: 1.5),
      bodyMedium: _font(_body, 15, 400, p.text, height: 1.45),
      bodySmall: _font(_body, 14, 400, p.ash, height: 1.45),
      // Uppercase is a convention at the call site; it only labels a meter.
      labelSmall: _font(_body, 12, 600, p.ash, spacing: 1.6),
    ),
  );
}
