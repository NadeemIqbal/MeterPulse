import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

/// Per-utility accent colours and the harmonisation helper.
///
/// A meter's accent tints its card header, icon and (in Phase 2) its chart
/// series. Custom colours are always run through [harmonize] so a user-picked
/// hue still reads as part of the active Material You palette in light *and*
/// dark. The mapping from a `MeterType` to one of these defaults lives in the
/// meters feature (presentation), keeping `core` free of feature imports.
abstract final class MeterPalette {
  static const Color electricity = Color(0xFFF9A825); // amber
  static const Color gas = Color(0xFFEF6C00); // deep orange
  static const Color water = Color(0xFF0288D1); // blue
  static const Color other = Color(0xFF7E57C2); // violet

  /// Swatches offered in the meter colour picker.
  static const List<Color> swatches = [
    electricity,
    gas,
    water,
    other,
    Color(0xFF2E7D32), // green
    Color(0xFFC2185B), // pink
    Color(0xFF00838F), // teal
    Color(0xFF5D4037), // brown
  ];

  /// Blends [accent] toward [scheme]'s primary so custom accents never clash
  /// with the surrounding scheme. Backed by `material_color_utilities` via the
  /// `dynamic_color` package.
  static Color harmonize(Color accent, ColorScheme scheme) =>
      accent.harmonizeWith(scheme.primary);
}
