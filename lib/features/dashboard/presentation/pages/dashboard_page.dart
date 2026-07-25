import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/meter_summary_card.dart';

/// Home screen: an overview strip plus one [MeterSummaryCard] per active meter.
/// Reloads whenever it is re-shown or the app resumes so "days remaining" and
/// status stay current.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardCubit>(
      create: (_) => sl<DashboardCubit>()..load(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reload();
  }

  void _reload() => context.read<DashboardCubit>().load();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MeterPulse'),
        actions: [
          IconButton(
            tooltip: 'Manage meters',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () async {
              await context.push(RouteNames.meters);
              _reload();
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push(RouteNames.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(RouteNames.newMeter);
          _reload();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add meter'),
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return switch (state.status) {
            DashboardStatus.loading => const LoadingView(),
            DashboardStatus.error => ErrorView(
                message: state.error ?? 'Could not load your meters.',
                onRetry: _reload,
              ),
            DashboardStatus.loaded =>
              state.isEmpty ? _empty(context) : _content(context, state),
          };
        },
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return EmptyState(
      icon: Icons.speed_rounded,
      title: 'No meters yet',
      message: 'Add your first meter to start tracking readings and usage.',
      actionLabel: 'Add meter',
      onAction: () async {
        await context.push(RouteNames.newMeter);
        _reload();
      },
    );
  }

  Widget _content(BuildContext context, DashboardState state) {
    final summaries = state.summaries;

    return RefreshIndicator(
      onRefresh: () => context.read<DashboardCubit>().load(),
      child: ReorderableListView.builder(
        padding: AppSpacing.page,
        header: Column(
          children: [
            _OverviewStrip(state: state),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
        footer: const SizedBox(height: 80), // clear the FAB
        itemCount: summaries.length,
        onReorder: (oldIndex, newIndex) {
          context.read<DashboardCubit>().reorderSummaries(oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          final summary = summaries[index];
          return Padding(
            key: ValueKey('meter-card-${summary.meter.id}'),
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: MeterSummaryCard(
              summary: summary,
              onChanged: _reload,
              index: index,
            ),
          );
        },
      ),
    );
  }
}

/// Compact "this month" overview above the meter cards.
class _OverviewStrip extends StatelessWidget {
  const _OverviewStrip({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final highest = state.highestConsumer;

    return AppCard(
      color: scheme.primaryContainer,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total used this cycle',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: scheme.onPrimaryContainer),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  Formatters.units(state.totalUnitsUsed),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (highest != null && (highest.unitsUsed ?? 0) > 0) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Top: ${highest.meter.name}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onPrimaryContainer),
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.insights_rounded, size: 40, color: scheme.onPrimaryContainer),
        ],
      ),
    );
  }
}
