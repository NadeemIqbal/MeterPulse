import 'package:flutter/material.dart';

import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the light and dark [ThemeData] for MeterPulse.
///
/// Both are derived from a Material 3 [ColorScheme]. When the device supplies a
/// dynamic (Material You) scheme it is used directly; otherwise we fall back to
/// a scheme generated from [seedColor]. All shape/spacing choices reference the
/// tokens in `app_spacing.dart` so the rounded, minimal look stays consistent.
abstract final class AppTheme {
  /// Stitch Brand Seed Color (Deep Electric Blue).
  static const Color seedColor = Color(0xFF0058BE);

  static ThemeData light(ColorScheme? dynamicScheme) {
    final baseScheme = dynamicScheme ?? ColorScheme.fromSeed(seedColor: seedColor);
    final stitchScheme = baseScheme.copyWith(
      primary: const Color(0xFF0058BE),
      primaryContainer: const Color(0xFF2170E4),
      secondary: const Color(0xFF00687A),
      secondaryContainer: const Color(0xFF57DFFE),
      surface: const Color(0xFFF9F9FF),
      surfaceContainerLow: const Color(0xFFF0F3FF),
      surfaceContainerHighest: const Color(0xFFDCE2F3),
      error: const Color(0xFFBA1A1A),
      errorContainer: const Color(0xFFFFDAD6),
    );
    return _build(stitchScheme);
  }

  static ThemeData dark(ColorScheme? dynamicScheme) => _build(
        dynamicScheme ??
            ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.dark,
            ),
      );

  static ThemeData _build(ColorScheme scheme) {
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);

    return base.copyWith(
      textTheme: AppTypography.applyTo(base.textTheme),
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        scrolledUnderElevation: 3,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: const OutlineInputBorder(
          borderRadius: AppRadius.fieldRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.fieldRadius,
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        space: AppSpacing.lg,
      ),
    );
  }
}
