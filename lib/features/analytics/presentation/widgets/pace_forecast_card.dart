import 'package:flutter/material.dart';

import '../../../../core/calculation_engine/consumption_calculator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';

/// Blue hero summarising where consumption is heading this month: the
/// projection, the daily rate, and progress against the combined threshold.
class PaceForecastCard extends StatelessWidget {
  const PaceForecastCard({
    super.key,
    required this.forecast,
    required this.unit,
    this.currentUnits,
  });

  final PaceForecast forecast;
  final String unit;
  final double? currentUnits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final limit = forecast.targetLimit;
    final current = currentUnits;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0058BE), Color(0xFF2170E4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pace Forecast',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${Formatters.units(forecast.projectedUnits)} $unit',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Projected month-end usage',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.query_stats_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Daily pace: ${Formatters.units(forecast.dailyRate)} $unit',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  _zoneLabel,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (limit != null && current != null) ...[
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (current / limit).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: AlwaysStoppedAnimation(_zoneColor),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current: ${Formatters.units(current)} $unit',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  Text(
                    'Threshold: ${Formatters.units(limit)} $unit',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ],
            if (forecast.isWillExceed && forecast.daysToCrossMax != null) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      forecast.daysToCrossMax == 0
                          ? 'Threshold already crossed.'
                          : 'Crosses the threshold in '
                              '${forecast.daysToCrossMax} '
                              '${forecast.daysToCrossMax == 1 ? 'day' : 'days'} '
                              'at this rate.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String get _zoneLabel => switch (forecast.zone) {
        UsageZone.green => 'On Track',
        UsageZone.orange => 'Watch',
        UsageZone.red => 'Over Budget',
      };

  Color get _zoneColor => switch (forecast.zone) {
        UsageZone.green => const Color(0xFF4CD7F6),
        UsageZone.orange => const Color(0xFFFFB74D),
        UsageZone.red => const Color(0xFFFF8A80),
      };
}
