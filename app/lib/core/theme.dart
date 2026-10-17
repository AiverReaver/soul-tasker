import 'package:material_ui/material_ui.dart';

import '../ui/silk_page_transition.dart';

// Design tokens. Source of truth: /DESIGN.md. Contrast ratios are against kBackground.

// Color: Pharloom night. Violet-black ground, bone text, one thread of silk
// crimson (Hearthrise design system). Names predate the restyle: kEmber is
// the single accent, kAsh the primary text.
const Color kBackground = Color(0xFF09060C); // void
const Color kSurface = Color(0xFF130E17);
const Color kSelected = Color(0xFF221828); // selected segment or chip fill
const Color kAsh = Color(0xFFE6DDCB); // bone: primary text, 13:1
const Color kTextMuted = Color(0xFFA79BA6); // bone muted: secondary, 6.6:1
const Color kAshDim = Color(
  0xFF5F5463,
); // borders and decoration only, never text
const Color kEmber = Color(0xFFE8566D); // thread: the single accent, 5.3:1
const Color kBossHealth = Color(0xFFE9DFCB); // mask shards (UI component)

// Decoration only, never text: carved edges, the backdrop's cold violet
// tint and the lavender motes drifting up through it.
const Color kWine = Color(0xFF7A2638);
const Color kPharloom = Color(0xFF140B1C);
const Color kMote = Color(0xFFB7A8D6);

/// Ink outline for hand-drawn art.
const Color kInk = Color(0xFF050307);

// Spacing: 4 pt grid.
abstract final class Space {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 40;
  static const double xxl = 56;
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
const _body = 'Inter';

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

ThemeData buildTheme() {
  const pages = SilkPageTransitions();
  return ThemeData(
    brightness: Brightness.dark,
    // Clear: the Pharloom backdrop (features/shell) shows through.
    scaffoldBackgroundColor: const Color(0x00000000),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0x00000000),
      surfaceTintColor: Color(0x00000000),
      scrolledUnderElevation: 0,
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
    colorScheme: const ColorScheme.dark(
      primary: kEmber,
      onPrimary: kBackground,
      // Selected segments and chips: a quiet raised surface, not a new hue.
      secondaryContainer: kSelected,
      onSecondaryContainer: kAsh,
      outline: kAshDim,
      outlineVariant: kAshDim,
      surface: kSurface,
      onSurface: kAsh,
      error: kBossHealth,
    ),
    textTheme: TextTheme(
      // Display serif: boss names and major moments only.
      displayMedium: _font(_display, 44, 500, kDust, spacing: 1, height: 1.1),
      displaySmall: _font(_display, 34, 500, kDust, spacing: 1, height: 1.15),
      titleMedium: _font(_display, 22, 500, kDust, height: 1.3),
      // Body sans: everything else.
      bodyLarge: _font(_body, 16, 400, kAsh, height: 1.5),
      bodyMedium: _font(_body, 15, 400, kAsh, height: 1.45),
      bodySmall: _font(_body, 14, 400, kTextMuted, height: 1.45),
      labelSmall: _font(_body, 13, 500, kAsh, spacing: 2),
    ),
  );
}

/// Porcelain: titles, boss names, glints, lit frame brackets, the silk slash
/// and the dust of a struck task. The one exception to "no pure white" in
/// DESIGN.md.
const Color kDust = Color(0xFFF4EBDD);
