import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';

/// Line chart of meter reading values over time (shows the meter climbing).
class ReadingTrendChart extends StatelessWidget {
  const ReadingTrendChart({
    super.key,
    required this.values,
    required this.accent,
  });

  /// Reading values in chronological order (oldest first).
  final List<double> values;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    if (values.length < 2) return const SizedBox.shrink();

    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final pad = (maxValue - minValue) * 0.1;
    final spots = [
      for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
    ];

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: minValue - (pad == 0 ? 1 : pad),
          maxY: maxValue + (pad == 0 ? 1 : pad),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: accent,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: accent.withValues(alpha: 0.12),
              ),
            ),
          ],
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: scheme.outlineVariant.withValues(alpha: 0.4),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (value, meta) => Text(
                  Formatters.units(value),
                  style: AppTypography.numeric(theme.textTheme.labelSmall)
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => scheme.inverseSurface,
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        Formatters.reading(s.y),
                        theme.textTheme.labelMedium!
                            .copyWith(color: scheme.onInverseSurface),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
