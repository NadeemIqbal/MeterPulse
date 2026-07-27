import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/calculation_engine/consumption_calculator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../analytics/presentation/widgets/alert_banner.dart';
import '../../../meters/presentation/meter_type_ui.dart';
import '../../domain/entities/meter_summary.dart';
import '../status_ui.dart';
import 'status_pill.dart';

/// Modern, decluttered dashboard card for one meter.
/// Features clear visual hierarchy, a threshold progress bar, pace indicators,
/// and a prominent primary action for taking readings.
class MeterSummaryCard extends StatelessWidget {
  const MeterSummaryCard({
    super.key,
    required this.summary,
    this.onChanged,
    this.index,
  });

  final MeterSummary summary;
  final VoidCallback? onChanged;
  final int? index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final meter = summary.meter;
    final accent = meter.accent(scheme);
    final forecast = summary.paceForecast;

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => _go(context, RouteNames.meterDetail(meter.id!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header: Avatar, Meter Name, Status Badges & Drag handle
                _header(context, accent, scheme),
                const SizedBox(height: AppSpacing.md),

                // 2. Alert Banner (if any urgent alert)
                if (summary.topAlert != null) ...[
                  AlertBanner(alert: summary.topAlert!, dense: true),
                  const SizedBox(height: AppSpacing.md),
                ],

                // 3. Headline Usage + Progress Bar
                _headlineUsageWithProgress(context, accent, scheme, forecast),
                const SizedBox(height: AppSpacing.md),

                // 4. Pace Indicator (Compact Inline Row)
                if (forecast != null) ...[
                  _paceForecastRow(context, forecast, scheme),
                  const SizedBox(height: AppSpacing.md),
                ],

                // 5. Mini Stats Row (Avg/day, Est. Month End, Current Reading)
                _statsRow(context),
                const SizedBox(height: AppSpacing.xs),

                // 6. Footer (Due dates info)
                _footer(context),
              ],
            ),
          ),
          const Divider(height: 1),

          // 7. Streamlined Action Bar
          _actions(context, scheme),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, Color accent, ColorScheme scheme) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Hero(
          tag: 'meter-avatar-${summary.meter.id}',
          child: CircleAvatar(
            radius: 22,
            backgroundColor: accent.withValues(alpha: 0.16),
            child: Icon(summary.meter.displayIcon, color: accent, size: 22),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summary.meter.name,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                summary.meter.meterNumber?.isNotEmpty == true
                    ? '${summary.meter.type.label} · ${summary.meter.meterNumber}'
                    : summary.meter.type.label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        _statusBadges(scheme),
        if (index != null)
          ReorderableDragStartListener(
            index: index!,
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs),
              child: Icon(
                Icons.drag_indicator_rounded,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
      ],
    );
  }

  Widget _statusBadges(ColorScheme scheme) {
    final forecast = summary.paceForecast;
    return Wrap(
      spacing: AppSpacing.xs,
      alignment: WrapAlignment.end,
      children: [
        if (forecast != null) _zonePill(scheme, forecast),
        if (summary.readingStatus != ReadingStatus.upToDate)
          StatusPill(
            label: summary.readingStatus.label,
            icon: summary.readingStatus.icon,
            color: summary.readingStatus.color(scheme),
          ),
      ],
    );
  }

  StatusPill _zonePill(ColorScheme scheme, PaceForecast forecast) {
    return switch (forecast.zone) {
      UsageZone.green => const StatusPill(
          label: 'Green',
          icon: Icons.check_circle_outline_rounded,
          color: Colors.green,
        ),
      UsageZone.orange => StatusPill(
          label: forecast.percentOfLimit != null
              ? '${forecast.percentOfLimit!.toStringAsFixed(0)}%'
              : 'Orange',
          icon: Icons.warning_amber_rounded,
          color: Colors.orange,
        ),
      UsageZone.red => StatusPill(
          label: forecast.daysToCrossMax != null && forecast.daysToCrossMax! > 0
              ? 'Max in ${forecast.daysToCrossMax}d'
              : 'Over Max',
          icon: Icons.error_outline_rounded,
          color: scheme.error,
        ),
    };
  }

  Widget _headlineUsageWithProgress(
    BuildContext context,
    Color accent,
    ColorScheme scheme,
    PaceForecast? forecast,
  ) {
    final theme = Theme.of(context);
    final targetLimit = forecast?.targetLimit ?? summary.meter.highUsageThreshold ?? summary.meter.expectedMonthlyUnits;
    final unitsUsed = summary.unitsUsed ?? 0.0;
    final progressRatio = (targetLimit != null && targetLimit > 0)
        ? (unitsUsed / targetLimit).clamp(0.0, 1.0)
        : null;

    final progressColor = forecast?.zone == UsageZone.red
        ? scheme.error
        : forecast?.zone == UsageZone.orange
            ? Colors.orange
            : accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Used this cycle',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      Formatters.units(summary.unitsUsed),
                      style: AppTypography.numeric(
                        theme.textTheme.headlineMedium
                            ?.copyWith(color: accent, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      summary.meter.unit,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
            if (targetLimit != null)
              Text(
                'Max: ${Formatters.units(targetLimit)} ${summary.meter.unit}',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
          ],
        ),
        if (progressRatio != null) ...[
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 6,
              backgroundColor: progressColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ],
    );
  }

  Widget _paceForecastRow(
    BuildContext context,
    PaceForecast forecast,
    ColorScheme scheme,
  ) {
    final theme = Theme.of(context);
    final isRed = forecast.zone == UsageZone.red;
    final isOrange = forecast.zone == UsageZone.orange;

    final icon = isRed
        ? Icons.trending_up_rounded
        : isOrange
            ? Icons.warning_amber_rounded
            : Icons.auto_graph_rounded;

    final color = isRed
        ? scheme.error
        : isOrange
            ? Colors.orange.shade800
            : scheme.onSurfaceVariant;

    String message;
    if (forecast.daysToCrossMax != null && forecast.daysToCrossMax! > 0) {
      final maxVal = forecast.targetLimit != null ? Formatters.units(forecast.targetLimit) : '';
      message = 'Will cross max ($maxVal ${summary.meter.unit}) in ${forecast.daysToCrossMax} days (${Formatters.shortDate(forecast.dateToCrossMax!)})';
    } else if (forecast.daysToCrossMax == 0) {
      message = 'Crossed max limit threshold (${Formatters.units(forecast.targetLimit)} ${summary.meter.unit})';
    } else {
      message = 'Pace: ${Formatters.units(forecast.dailyRate)} ${summary.meter.unit}/day · Est: ${Formatters.units(forecast.projectedUnits)} ${summary.meter.unit}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _miniStat(
            context,
            'Avg / day',
            Formatters.units(summary.averagePerDay),
          ),
        ),
        Expanded(
          child: _miniStat(
            context,
            'Est. month end',
            Formatters.units(summary.projectedMonthEndUnits),
          ),
        ),
        Expanded(
          child: _miniStat(
            context,
            'Current reading',
            summary.currentReading == null
                ? '—'
                : Formatters.reading(summary.currentReading!.readingValue),
          ),
        ),
      ],
    );
  }

  Widget _miniStat(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 11),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.numeric(
            theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 13.5),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _footer(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 11.5);
    final parts = <Widget>[];

    if (summary.daysUntilReading != null) {
      parts.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_rounded, size: 13, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xxs),
          Text('Reading ${Formatters.relativeDays(summary.daysUntilReading!)}',
              style: muted),
        ],
      ));
    }
    if (summary.daysUntilBill != null) {
      parts.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.request_quote_rounded,
              size: 13, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xxs),
          Text('Bill ${Formatters.relativeDays(summary.daysUntilBill!)}',
              style: muted),
        ],
      ));
    }
    if (parts.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: AppSpacing.md, runSpacing: AppSpacing.xs, children: parts);
  }

  Widget _actions(BuildContext context, ColorScheme scheme) {
    final id = summary.meter.id!;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          // Primary action: prominent Tonal Reading button
          FilledButton.tonalIcon(
            onPressed: () => _go(context, RouteNames.takeReading(id)),
            icon: const Icon(Icons.camera_alt_rounded, size: 18),
            label: const Text('Take Reading'),
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              // The theme's Size.fromHeight(52) sets minWidth to infinity,
              // which a Row (unbounded main axis) cannot satisfy. Size to
              // content instead.
              minimumSize: const Size(0, 40),
            ),
          ),
          const Spacer(),
          // Secondary actions: compact IconButtons
          IconButton(
            tooltip: 'Bills',
            onPressed: () => _go(context, RouteNames.bills(id)),
            icon: const Icon(Icons.receipt_long_rounded, size: 20),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            tooltip: 'History',
            onPressed: () => _go(context, RouteNames.history(id)),
            icon: const Icon(Icons.timeline_rounded, size: 20),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            tooltip: 'Statistics',
            onPressed: () => _go(context, RouteNames.stats(id)),
            icon: const Icon(Icons.insights_rounded, size: 20),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Future<void> _go(BuildContext context, String location) async {
    await context.push(location, extra: summary.meter);
    onChanged?.call();
  }
}
