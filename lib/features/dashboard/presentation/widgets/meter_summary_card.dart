import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../analytics/presentation/widgets/alert_banner.dart';
import '../../../meters/presentation/meter_type_ui.dart';
import '../../domain/entities/meter_summary.dart';
import '../status_ui.dart';
import 'status_pill.dart';

/// Rich dashboard card for one meter: accent header, status pills, the headline
/// "units used this cycle", supporting stats, and quick actions. Tapping the
/// body opens the meter detail (shared-element Hero on the accent avatar).
class MeterSummaryCard extends StatelessWidget {
  const MeterSummaryCard({super.key, required this.summary, this.onChanged});

  final MeterSummary summary;

  /// Called after returning from a sub-screen so the dashboard can refresh.
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final meter = summary.meter;
    final accent = meter.accent(scheme);

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => _go(context, RouteNames.meterDetail(meter.id!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context, accent),
                const SizedBox(height: AppSpacing.md),
                _statusRow(scheme),
                if (summary.topAlert != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  AlertBanner(alert: summary.topAlert!, dense: true),
                ],
                const SizedBox(height: AppSpacing.lg),
                _headlineUsage(context, accent),
                const SizedBox(height: AppSpacing.lg),
                _statsRow(context),
                const SizedBox(height: AppSpacing.sm),
                _footer(context),
              ],
            ),
          ),
          const Divider(height: 1),
          _actions(context),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, Color accent) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Hero(
          tag: 'meter-avatar-${summary.meter.id}',
          child: CircleAvatar(
            radius: 24,
            backgroundColor: accent.withValues(alpha: 0.16),
            child: Icon(summary.meter.displayIcon, color: accent),
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
        if (summary.alerts.isNotEmpty)
          Icon(
            summary.highUsageExceeded
                ? Icons.warning_amber_rounded
                : Icons.info_outline_rounded,
            color: summary.highUsageExceeded
                ? theme.colorScheme.error
                : theme.colorScheme.tertiary,
          ),
      ],
    );
  }

  Widget _statusRow(ColorScheme scheme) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        StatusPill(
          label: summary.readingStatus.label,
          icon: summary.readingStatus.icon,
          color: summary.readingStatus.color(scheme),
        ),
        StatusPill(
          label: summary.billStatus.label,
          icon: summary.billStatus.icon,
          color: summary.billStatus.color(scheme),
        ),
      ],
    );
  }

  Widget _headlineUsage(BuildContext context, Color accent) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Used this cycle',
          style: theme.textTheme.labelMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              Formatters.units(summary.unitsUsed),
              style: AppTypography.numeric(
                theme.textTheme.displaySmall
                    ?.copyWith(color: accent, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                summary.meter.unit,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ],
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
            'Current',
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
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.numeric(
            theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final parts = <Widget>[];

    if (summary.daysUntilReading != null) {
      parts.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
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
              size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          Text('Bill ${Formatters.relativeDays(summary.daysUntilBill!)}',
              style: muted),
        ],
      ));
    }
    if (parts.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: AppSpacing.lg, runSpacing: AppSpacing.xs, children: parts);
  }

  Widget _actions(BuildContext context) {
    final id = summary.meter.id!;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: () => _go(context, RouteNames.takeReading(id)),
              icon: const Icon(Icons.camera_alt_rounded, size: 18),
              label: const Text('Reading'),
            ),
          ),
          IconButton(
            tooltip: 'Capture bill',
            onPressed: () => _go(context, RouteNames.newBill(id)),
            icon: const Icon(Icons.receipt_long_rounded),
          ),
          IconButton(
            tooltip: 'History',
            onPressed: () => _go(context, RouteNames.history(id)),
            icon: const Icon(Icons.timeline_rounded),
          ),
          IconButton(
            tooltip: 'Statistics',
            onPressed: () => _go(context, RouteNames.stats(id)),
            icon: const Icon(Icons.insights_rounded),
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
