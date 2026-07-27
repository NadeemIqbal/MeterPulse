import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
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
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.4,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.speed_rounded,
                size: 56,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No active meters yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add your utility meters to start tracking consumption, projections, and bills.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: () async {
                await context.push(RouteNames.newMeter);
                _reload();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Meter'),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => context.read<DashboardCubit>().addDemoData(),
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Add Sample Meters & Data'),
            ),
          ],
        ),
      ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Meters',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: () async {
                    await context.push(RouteNames.meters);
                    _reload();
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'VIEW ALL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, size: 18),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ),
        footer: const SizedBox(height: 90), // clear the bottom nav bar
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

/// Stitch-style hero overview header with multi-color gradient and glassmorphic stats grid.
class _OverviewStrip extends StatelessWidget {
  const _OverviewStrip({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final highest = state.highestConsumer;
    final activeMeterCount = state.summaries.length;
    final totalAlerts = state.summaries.fold<int>(
      0,
      (sum, s) => sum + s.alerts.length,
    );

    // The shadow lives on an outer DecoratedBox and the rounding on an inner
    // ClipRRect. Putting both on one Container (clipBehavior + boxShadow)
    // clips the shadow away and leaves the whole list stuck in NEEDS-PAINT.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0058BE).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0058BE), Color(0xFF2170E4), Color(0xFF57DFFE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Background decorative icon
              Positioned(
                right: -16,
                top: -16,
                child: Icon(
                  Icons.bolt_rounded,
                  size: 140,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Label + Alert Pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL CONSUMPTION',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        if (totalAlerts > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.errorContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size: 14,
                                  color: scheme.onErrorContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$totalAlerts Alert${totalAlerts > 1 ? 's' : ''}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: scheme.onErrorContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Large Display Number
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          Formatters.units(state.totalUnitsUsed),
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'units',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 2-Column Glassmorphic Stats Grid
                    Row(
                      children: [
                        Expanded(
                          child: _glassBox(
                            context,
                            label: 'ACTIVE METERS',
                            value: '$activeMeterCount Units',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _glassBox(
                            context,
                            label: 'TOP CONSUMER',
                            value:
                                highest != null && (highest.unitsUsed ?? 0) > 0
                                ? highest.meter.name
                                : '—',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassBox(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
