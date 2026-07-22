import 'package:flutter/material.dart';

/// MeterPulse typography tweaks layered on top of the Material 3 text theme.
///
/// The important change: numeric-heavy styles use tabular (monospaced) figures
/// so digits keep a fixed width. This stops reading values from jittering
/// horizontally during count-up animations and keeps history rows aligned.
abstract final class AppTypography {
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  /// Returns [base] with tabular figures and slightly heavier weights applied
  /// to the styles used for prominent numbers and titles.
  static TextTheme applyTo(TextTheme base) {
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontFeatures: _tabular,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontFeatures: _tabular,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: base.headlineSmall?.copyWith(fontFeatures: _tabular),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  /// Applies tabular figures to any [style] used to render a raw number.
  static TextStyle? numeric(TextStyle? style) =>
      style?.copyWith(fontFeatures: _tabular);
}
