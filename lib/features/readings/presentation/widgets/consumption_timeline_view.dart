import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../meters/domain/entities/meter.dart';
import '../../../meters/presentation/meter_type_ui.dart';
import '../../domain/entities/consumption_timeline.dart';

/// Renders one billing cycle as a consumption timeline: a header with the cycle
/// range and total, then each reading (oldest first) with the units consumed
/// since the previous reading.
class ConsumptionTimelineView extends StatelessWidget {
  const ConsumptionTimelineView({
    super.key,
    required this.timeline,
    required this.meter,
  });

  final CycleTimeline timeline;
  final Meter meter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = meter.accent(scheme);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context, accent),
          const SizedBox(height: AppSpacing.md),
          if (timeline.entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'No readings in this cycle yet.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            )
          else
            for (var i = 0; i < timeline.entries.length; i++)
              _entryRow(context, timeline.entries[i], accent, isLast: i == timeline.entries.length - 1),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, Color accent) {
    final theme = Theme.of(context);
    final cycle = timeline.cycle;
    final rangeLabel = timeline.isCurrent
        ? 'Current cycle · from ${Formatters.shortDate(cycle.cycleStartDate)}'
        : '${Formatters.shortDate(cycle.cycleStartDate)} – ${cycle.cycleEndDate == null ? '' : Formatters.shortDate(cycle.cycleEndDate!)}';

    return Row(
      children: [
        Expanded(
          child: Text(
            rangeLabel,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.chip)),
          ),
          child: Text(
            '${Formatters.units(timeline.totalUnits)} ${meter.unit}',
            style: AppTypography.numeric(
              theme.textTheme.labelLarge
                  ?.copyWith(color: accent, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _entryRow(
    BuildContext context,
    TimelineEntry entry,
    Color accent, {
    required bool isLast,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail: dot + connecting line.
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: entry.isBaseline ? scheme.surface : accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: accent, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: accent.withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Formatters.reading(entry.reading.readingValue),
                          style: AppTypography.numeric(
                            theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          Formatters.date(entry.reading.readingDate),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  _deltaChip(context, entry, accent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deltaChip(BuildContext context, TimelineEntry entry, Color accent) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (entry.isBaseline) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.chip)),
        ),
        child: Text('Baseline', style: theme.textTheme.labelSmall),
      );
    }

    final consumed = entry.consumedSincePrevious;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.chip)),
      ),
      child: Text(
        consumed == null ? '—' : '+${Formatters.units(consumed)} ${meter.unit}',
        style: AppTypography.numeric(
          theme.textTheme.labelMedium
              ?.copyWith(color: accent, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
