import 'package:flutter/material.dart';

import '../../../core/theme/meter_palette.dart';
import '../domain/entities/meter.dart';
import '../domain/entities/meter_type.dart';

/// Presentation-only mapping from a [MeterType] to its label, icon, default
/// accent and suggested unit. Kept in the presentation layer so the domain enum
/// stays free of Flutter.
extension MeterTypeUi on MeterType {
  String get label => switch (this) {
        MeterType.electricity => 'Electricity',
        MeterType.gas => 'Gas',
        MeterType.water => 'Water',
        MeterType.other => 'Other',
      };

  IconData get icon => switch (this) {
        MeterType.electricity => Icons.bolt_rounded,
        MeterType.gas => Icons.local_fire_department_rounded,
        MeterType.water => Icons.water_drop_rounded,
        MeterType.other => Icons.speed_rounded,
      };

  Color get defaultColor => switch (this) {
        MeterType.electricity => MeterPalette.electricity,
        MeterType.gas => MeterPalette.gas,
        MeterType.water => MeterPalette.water,
        MeterType.other => MeterPalette.other,
      };

  String get defaultUnit => switch (this) {
        MeterType.electricity => 'kWh',
        MeterType.gas => 'm³',
        MeterType.water => 'm³',
        MeterType.other => 'units',
      };
}

/// UI helpers for a concrete [Meter].
extension MeterUi on Meter {
  /// The meter's accent colour, harmonised into the active [scheme]. Uses the
  /// user-picked colour if set, else the type default.
  Color accent(ColorScheme scheme) {
    final base = colorValue != null ? Color(colorValue!) : type.defaultColor;
    return MeterPalette.harmonize(base, scheme);
  }

  /// Phase 1 always uses the type icon (custom icon codepoints are avoided to
  /// keep release-build icon tree-shaking working).
  IconData get displayIcon => type.icon;
}
