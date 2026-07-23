import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../app_theme_mode_x.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/theme_cubit.dart';

/// App settings: appearance (theme), reading/bill reminders, navigation to
/// meter management and about, and placeholders for later-phase features.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsCubit>(
      create: (_) => sl<SettingsCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: AppSpacing.page,
          children: [
            _sectionLabel(context, 'Appearance'),
            _themeCard(),
            const SizedBox(height: AppSpacing.lg),
            _sectionLabel(context, 'Notifications'),
            const _NotificationsCard(),
            const SizedBox(height: AppSpacing.lg),
            _sectionLabel(context, 'General'),
            _generalCard(context),
            const SizedBox(height: AppSpacing.lg),
            _sectionLabel(context, 'Coming soon'),
            _comingSoonCard(),
          ],
        ),
      ),
    );
  }

  Widget _themeCard() {
    return AppCard(
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
                onSelectionChanged: (selection) =>
                    context.read<ThemeCubit>().setThemeMode(selection.first),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _generalCard(BuildContext context) {
    return AppCard(
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
    );
  }

  Widget _comingSoonCard() {
    return const AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
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

class _NotificationsCard extends StatelessWidget {
  const _NotificationsCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: BlocBuilder<SettingsCubit, AppSettings>(
        builder: (context, settings) {
          final enabled = settings.notificationsEnabled ?? false;
          final minutes = settings.reminderTimeMinutes ?? 8 * 60;
          final time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

          return Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_rounded),
                title: const Text('Reading & bill reminders'),
                subtitle:
                    const Text('Get nudged when a reading or bill is due'),
                value: enabled,
                onChanged: (v) =>
                    context.read<SettingsCubit>().setNotificationsEnabled(v),
              ),
              if (enabled) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.schedule_rounded),
                  title: const Text('Reminder time'),
                  subtitle: Text(time.format(context)),
                  onTap: () async {
                    final cubit = context.read<SettingsCubit>();
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: time,
                    );
                    if (picked != null) {
                      cubit.setReminderTime(picked.hour * 60 + picked.minute);
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_active_rounded),
                  title: const Text('Send a test notification'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    final cubit = context.read<SettingsCubit>();
                    final messenger = ScaffoldMessenger.of(context);
                    await cubit.sendTest();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Test notification sent')),
                    );
                  },
                ),
              ],
            ],
          );
        },
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
