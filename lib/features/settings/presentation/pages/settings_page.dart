import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../app_theme_mode_x.dart';
import '../cubit/theme_cubit.dart';

/// App settings: appearance (theme), navigation to meter management and about,
/// and placeholders for features arriving in later phases.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          _sectionLabel(context, 'Appearance'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Theme'),
                const SizedBox(height: AppSpacing.md),
                BlocBuilder<ThemeCubit, AppThemeMode>(
                  builder: (context, mode) {
                    return SegmentedButton<AppThemeMode>(
                      segments: AppThemeMode.values
                          .map(
                            (m) => ButtonSegment<AppThemeMode>(
                              value: m,
                              label: Text(m.label),
                              icon: Icon(m.icon),
                            ),
                          )
                          .toList(),
                      selected: {mode},
                      onSelectionChanged: (selection) => context
                          .read<ThemeCubit>()
                          .setThemeMode(selection.first),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _sectionLabel(context, 'General'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.tune_rounded),
                  title: const Text('Manage meters'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(RouteNames.meters),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('About MeterPulse'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(RouteNames.about),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _sectionLabel(context, 'Coming soon'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: const [
                _ComingSoonTile(
                  icon: Icons.notifications_rounded,
                  title: 'Reminders & alerts',
                ),
                Divider(height: 1),
                _ComingSoonTile(
                  icon: Icons.file_download_rounded,
                  title: 'Export to CSV',
                ),
                Divider(height: 1),
                _ComingSoonTile(
                  icon: Icons.backup_rounded,
                  title: 'Backup & restore',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.xs),
      child: Text(
        text,
        style: theme.textTheme.titleSmall
            ?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }
}

class _ComingSoonTile extends StatelessWidget {
  const _ComingSoonTile({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      enabled: false,
      leading: Icon(icon, color: scheme.onSurfaceVariant),
      title: Text(title),
      trailing: Text(
        'Soon',
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}
