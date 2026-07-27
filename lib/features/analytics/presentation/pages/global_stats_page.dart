import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../meters/domain/entities/meter_type.dart';
import '../../../meters/presentation/meter_type_ui.dart';
import '../../domain/entities/global_stats.dart';
import '../cubit/global_stats_cubit.dart';
import '../widgets/consumption_bar_chart.dart';
import '../widgets/pace_forecast_card.dart';
import '../widgets/reading_trend_chart.dart';

/// Portfolio-wide analytics for one meter type. Reached from the "Stats" tab.
class GlobalStatsPage extends StatelessWidget {
  const GlobalStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GlobalStatsCubit>(
      create: (_) => sl<GlobalStatsCubit>()..load(),
      child: const _GlobalStatsView(),
    );
  }
}

class _GlobalStatsView extends StatelessWidget {
  const _GlobalStatsView();

  static final DateFormat _monthLabel = DateFormat('MMM');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usage Analytics')),
      body: BlocBuilder<GlobalStatsCubit, GlobalStatsState>(
        builder: (context, state) {
          return switch (state.status) {
            GlobalStatsStatus.loading => const LoadingView(),
            GlobalStatsStatus.error => ErrorView(
                message: state.error ?? 'Could not load analytics.',
                onRetry: () => context.read<GlobalStatsCubit>().load(),
              ),
            GlobalStatsStatus.loaded => _content(context, state),
          };
        },
      ),
    );
  }

  Widget _content(BuildContext context, GlobalStatsState state) {
    if (!state.hasMeters) {
      return const EmptyState(
        icon: Icons.insights_rounded,
        title: 'Nothing to analyse yet',
        message: 'Add a meter and record readings to see usage trends.',
      );
    }

    final stats = state.stats;
    final theme = Theme.of(context);
    final accent = state.selectedType?.defaultColor ?? theme.colorScheme.primary;

    return RefreshIndicator(
      onRefresh: () => context.read<GlobalStatsCubit>().load(),
      child: ListView(
        padding: AppSpacing.page,
        children: [
          Text(
            'PERFORMANCE OVERVIEW',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (stats != null) _headline(context, stats),
          if (state.availableTypes.length > 1) ...[
            const SizedBox(height: AppSpacing.md),
            _TypeSelector(
              types: state.availableTypes,
              selected: state.selectedType,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (stats == null || !stats.hasData)
            const EmptyState(
              icon: Icons.timeline_rounded,
              title: 'Not enough readings',
              message:
                  'Record at least two readings for this meter type to see '
                  'consumption trends.',
            )
          else ...[
            _statGrid(context, stats),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cardTitle(context, 'Units Per Month', Icons.bar_chart_rounded),
                  const SizedBox(height: AppSpacing.md),
                  ConsumptionBarChart(
                    data: [
                      for (final m in _recent(stats.monthlyUsage))
                        (label: _monthLabel.format(m.month), value: m.units),
                    ],
                    accent: accent,
                  ),
                ],
              ),
            ),
            if (stats.paceForecast != null) ...[
              const SizedBox(height: AppSpacing.lg),
              PaceForecastCard(
                forecast: stats.paceForecast!,
                unit: stats.unit,
                currentUnits: stats.currentCycleUnits,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cardTitle(
                    context,
                    'Consumption Flow',
                    Icons.show_chart_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ReadingTrendChart(
                    values: [
                      for (final m in _recent(stats.monthlyUsage)) m.units,
                    ],
                    accent: accent,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Units consumed per month, oldest first.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 90), // clear the bottom nav bar
        ],
      ),
    );
  }

  Widget _headline(BuildContext context, GlobalStats stats) {
    final theme = Theme.of(context);
    final change = stats.previousPeriodChangePercent;

    final message = switch (change) {
      null => 'Tracking ${stats.meterCount} '
          '${stats.meterCount == 1 ? 'meter' : 'meters'} of this type.',
      final c when c < 0 =>
        'Your consumption is ${c.abs().toStringAsFixed(0)}% lower than the '
            'previous month. Keep it up!',
      final c when c > 0 =>
        'Your consumption is ${c.toStringAsFixed(0)}% higher than the '
            'previous month.',
      _ => 'Your consumption is level with the previous month.',
    };

    return Text(message, style: theme.textTheme.bodyLarge);
  }

  Widget _statGrid(BuildContext context, GlobalStats stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 2.1,
      children: [
        AppCard(
          child: StatTile(
            label: 'Total',
            icon: Icons.bolt_rounded,
            value: Formatters.units(stats.totalUnits),
            unit: '${stats.unit} overall',
          ),
        ),
        AppCard(
          child: StatTile(
            label: 'Monthly',
            icon: Icons.calendar_month_rounded,
            value: Formatters.units(stats.averageMonthlyUnits),
            unit: '${stats.unit} avg',
          ),
        ),
        AppCard(
          child: StatTile(
            label: 'Peak',
            icon: Icons.trending_up_rounded,
            value: Formatters.units(stats.peakMonthlyUnits),
            unit: stats.peakMonth == null
                ? '${stats.unit} highest'
                : Formatters.monthYear(stats.peakMonth!),
          ),
        ),
        AppCard(
          child: StatTile(
            label: 'Log',
            icon: Icons.receipt_long_rounded,
            value: Formatters.whole(stats.readingCount),
            unit: 'readings',
          ),
        ),
      ],
    );
  }

  Widget _cardTitle(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
      ],
    );
  }

  /// Charts stay readable at about a year of history.
  List<MonthlyUsage> _recent(List<MonthlyUsage> months) =>
      months.length <= 12 ? months : months.sublist(months.length - 12);
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.types, required this.selected});

  final List<MeterType> types;
  final MeterType? selected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        for (final type in types)
          ChoiceChip(
            avatar: Icon(type.icon, size: 16),
            label: Text(type.label),
            selected: type == selected,
            showCheckmark: false,
            onSelected: (_) =>
                context.read<GlobalStatsCubit>().selectType(type),
          ),
      ],
    );
  }
}
