import 'package:material_ui/material_ui.dart';

// Design tokens. Source of truth: /DESIGN.md. Contrast ratios are against kBackground.

// Color: near-black, ash text, one ember-gold accent (§8.1).
const Color kBackground = Color(0xFF0B0A09);
const Color kSurface = Color(0xFF161412);
const Color kSelected = Color(0xFF2A2621); // selected segment or chip fill
const Color kAsh = Color(0xFFB8B2A7); // primary text, 9.4:1
const Color kTextMuted = Color(0xFF8F897F); // secondary text, 5.7:1
const Color kAshDim = Color(
  0xFF5E5A54,
); // borders and decoration only, never text
const Color kEmber = Color(0xFFD9A441); // the single accent, 8.8:1
const Color kBossHealth = Color(0xFFB0412F); // health bar, 3.4:1 (UI component)

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
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBackground,
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
      displayMedium: _font(_display, 44, 500, kAsh, spacing: 1, height: 1.1),
      displaySmall: _font(_display, 34, 500, kAsh, spacing: 1, height: 1.15),
      titleMedium: _font(_display, 22, 500, kAsh, height: 1.3),
      // Body sans: everything else.
      bodyLarge: _font(_body, 16, 400, kAsh, height: 1.5),
      bodyMedium: _font(_body, 15, 400, kAsh, height: 1.45),
      bodySmall: _font(_body, 14, 400, kTextMuted, height: 1.45),
      labelSmall: _font(_body, 13, 500, kAsh, spacing: 2),
    ),
  );
}

/// Soft white-gold for the dust and glow of ritual moments only: the strike
/// choice and a vanishing boss or task. The one exception to "no pure white"
/// in DESIGN.md.
const Color kDust = Color(0xFFF4EEDD);
