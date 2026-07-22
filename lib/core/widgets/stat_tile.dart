import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A compact "label + big number" tile, used across the dashboard and meter
/// detail to present a single metric (units used, avg/day, projected, …).
///
/// The value uses tabular figures so animated/changing numbers stay aligned.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
    this.accent,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final String? unit;
  final IconData? icon;

  /// Optional accent applied to the icon and value (e.g. a meter's colour).
  final Color? accent;

  /// When true the value is rendered larger (for the headline metric).
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final valueColor = accent ?? scheme.onSurface;

    final valueStyle = (emphasized
            ? theme.textTheme.headlineMedium
            : theme.textTheme.titleLarge)
        ?.copyWith(color: valueColor, fontWeight: FontWeight.w700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: accent ?? scheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.xs),
            ],
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                value,
                style: AppTypography.numeric(valueStyle),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (unit != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                unit!,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
