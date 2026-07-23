import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../analytics/presentation/widgets/consumption_bar_chart.dart';
import '../../../analytics/presentation/widgets/reading_trend_chart.dart';
import '../../../meters/domain/entities/meter.dart';
import '../../../meters/presentation/meter_type_ui.dart';
import '../cubit/reading_history_cubit.dart';

/// Aggregate statistics and usage charts for a meter.
class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key, required this.meter});

  final Meter meter;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReadingHistoryCubit>(
      create: (_) => sl<ReadingHistoryCubit>()..load(meter),
      child: Scaffold(
        appBar: AppBar(title: const Text('Statistics')),
        body: BlocBuilder<ReadingHistoryCubit, ReadingHistoryState>(
          builder: (context, state) {
            return switch (state.status) {
              HistoryStatus.loading => const LoadingView(),
              HistoryStatus.error => ErrorView(
                  message: state.error ?? 'Could not load statistics.',
                  onRetry: () => context.read<ReadingHistoryCubit>().load(meter),
                ),
              HistoryStatus.loaded => state.isEmpty
                  ? const EmptyState(
                      icon: Icons.insights_rounded,
                      title: 'Nothing to summarise yet',
                      message: 'Take a few readings to see usage statistics.',
                    )
                  : _stats(context, state),
            };
          },
        ),
      ),
    );
  }

  Widget _stats(BuildContext context, ReadingHistoryState state) {
    final stats = state.stats;
    final scheme = Theme.of(context).colorScheme;
    final accent = meter.accent(scheme);
    final unit = meter.unit;

    // Cycles oldest-first for the charts.
    final cyclesOldestFirst = state.timelines.reversed.toList();
    final barData = [
      for (final t in cyclesOldestFirst)
        (
          label: Formatters.shortDate(t.cycle.cycleStartDate),
          value: t.totalUnits ?? 0.0,
        ),
    ];
    final trendValues = [
      for (final t in cyclesOldestFirst)
        for (final e in t.entries) e.reading.readingValue,
    ];

    final tiles = <Widget>[
      _tile('Total consumed', Formatters.units(stats.totalUnits), unit),
      _tile('Avg / month', Formatters.units(stats.averageMonthly), unit),
      _tile('Avg / year', Formatters.units(stats.averageYearly), unit),
      _tile('Highest reading', Formatters.units(stats.highestReading), unit),
      _tile('Lowest reading', Formatters.units(stats.lowestReading), unit),
      _tile('Cycles tracked', Formatters.whole(stats.cycleCount), null),
      _tile('Readings taken', Formatters.whole(stats.readingCount), null),
    ];

    return ListView(
      padding: AppSpacing.page,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 240,
            mainAxisExtent: 96,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
          ),
          itemCount: tiles.length,
          itemBuilder: (context, index) => tiles[index],
        ),
        if (barData.any((d) => d.value > 0)) ...[
          const SizedBox(height: AppSpacing.lg),
          _chartCard(
            context,
            'Units per cycle',
            ConsumptionBarChart(data: barData, accent: accent),
          ),
        ],
        if (trendValues.length >= 2) ...[
          const SizedBox(height: AppSpacing.lg),
          _chartCard(
            context,
            'Reading trend',
            ReadingTrendChart(values: trendValues, accent: accent),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _tile(String label, String value, String? unit) {
    return AppCard(
      child: StatTile(label: label, value: value, unit: unit, icon: meter.type.icon),
    );
  }

  Widget _chartCard(BuildContext context, String title, Widget chart) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.md),
          chart,
        ],
      ),
    );
  }
}
