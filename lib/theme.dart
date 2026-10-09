import 'package:flutter/material.dart';

/// Visual preset identifier — one of the ten canonical presets.
const String presetName = 'CYBERPUNK';

/// CYBERPUNK palette, hex values tuned to the brief (navy / electric blue /
/// violet / signal gold).
class AppColors {
  const AppColors._();

  static const Color bgBase = Color(0xFF10172F);
  static const Color bgDeep = Color(0xFF060A18);
  static const Color surface = Color(0xFF131C36);
  static const Color surfaceAlt = Color(0xFF16203E);
  static const Color hudBar = Color(0xFF0C142B);

  static const Color primary = Color(0xFF2F7EFF);
  static const Color secondary = Color(0xFF7C4BD2);
  static const Color signal = Color(0xFFF1C450);
  static const Color info = Color(0xFF35C5D0);

  static const Color textPrimary = Color(0xFFF4F6FF);
  static const Color textSecondary = Color(0xFF8D9BC4);
  static const Color textMuted = Color(0xFF6E7BA8);
}

/// Numerals are always tabular so HUD counters do not jitter.
const List<FontFeature> tabular = <FontFeature>[FontFeature.tabularFigures()];

ThemeData buildAppTheme() {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    tertiary: AppColors.info,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bgBase,
    canvasColor: AppColors.bgBase,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 38,
        fontWeight: FontWeight.w900,
        letterSpacing: 3.0,
        color: AppColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.4,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 3.0,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.2,
        color: AppColors.textMuted,
      ),
    ),
  );
}
