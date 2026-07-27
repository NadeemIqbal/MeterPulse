import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../backup/data/backup_service.dart';
import '../../../export/data/export_service.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../app_theme_mode_x.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/theme_cubit.dart';

/// App settings: appearance, the two reminder switches, currency, data
/// management and about.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const String appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsCubit>(
      create: (_) => sl<SettingsCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: AppSpacing.page,
          children: [
            _sectionLabel(context, 'Appearance', Icons.palette_outlined),
            _themeCard(),
            const SizedBox(height: AppSpacing.lg),
            _sectionLabel(
              context,
              'Notifications',
              Icons.notifications_none_rounded,
            ),
            const _NotificationsCard(),
            const SizedBox(height: AppSpacing.lg),
            _sectionLabel(context, 'Regional', Icons.language_rounded),
            const _CurrencyCard(),
            const SizedBox(height: AppSpacing.lg),
            _sectionLabel(context, 'Data Management', Icons.storage_rounded),
            const _DataCard(),
            const SizedBox(height: AppSpacing.lg),
            _sectionLabel(context, 'About', Icons.info_outline_rounded),
            _aboutCard(context),
            const SizedBox(height: AppSpacing.xl),
            _footer(context),
            const SizedBox(height: 90), // clear the bottom nav bar
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
          const Text('Theme Mode'),
          const SizedBox(height: AppSpacing.xs),
          Builder(
            builder: (context) => Text(
              'Select your visual preference',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
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

  Widget _aboutCard(BuildContext context) {
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
            title: const Text('Version'),
            subtitle: const Text('MeterPulse stable release'),
            trailing: Chip(
              label: const Text(appVersion),
              visualDensity: VisualDensity.compact,
            ),
            onTap: () => context.push(RouteNames.about),
          ),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          Icons.done_all_rounded,
          size: 32,
          color: theme.colorScheme.primary.withValues(alpha: 0.35),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '"Precision in every pulse."',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Made with care for your home resources.',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _sectionLabel(BuildContext context, String text, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            text.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
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
          final cubit = context.read<SettingsCubit>();
          final minutes = settings.reminderTimeMinutes ?? 8 * 60;
          final time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

          return Column(
            children: [
              SwitchListTile(
                title: const Text('Reading Reminders'),
                subtitle:
                    const Text("Get notified when it's time to log meters"),
                value: settings.readingRemindersOn,
                onChanged: cubit.setReadingRemindersEnabled,
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Bill Due Alerts'),
                subtitle: const Text('Reminders before a payment falls due'),
                value: settings.billAlertsOn,
                onChanged: cubit.setBillAlertsEnabled,
              ),
              if (settings.anyNotificationsOn) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.schedule_rounded),
                  title: const Text('Reminder time'),
                  subtitle: Text(time.format(context)),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: time,
                    );
                    if (picked != null) {
                      await cubit
                          .setReminderTime(picked.hour * 60 + picked.minute);
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_active_rounded),
                  title: const Text('Send a test notification'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
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

class _CurrencyCard extends StatelessWidget {
  const _CurrencyCard();

  /// Presets shown as pills. The stored value is the symbol; the code is only
  /// a label, so a user's existing custom symbol still round-trips.
  static const List<({String code, String symbol})> _presets = [
    (code: 'PKR', symbol: 'PKR'),
    (code: 'USD', symbol: r'$'),
    (code: 'EUR', symbol: '€'),
    (code: 'GBP', symbol: '£'),
    (code: 'INR', symbol: '₹'),
    (code: 'AED', symbol: 'AED'),
    (code: 'SAR', symbol: 'SAR'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: BlocBuilder<SettingsCubit, AppSettings>(
        builder: (context, settings) {
          final current = settings.currencySymbol.trim();
          final isPreset = _presets.any((p) => p.symbol == current);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Default Currency'),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final preset in _presets)
                    ChoiceChip(
                      label: Text(
                        preset.code == preset.symbol
                            ? preset.code
                            : '${preset.symbol} ${preset.code}',
                      ),
                      selected: current == preset.symbol,
                      showCheckmark: false,
                      onSelected: (_) => context
                          .read<SettingsCubit>()
                          .setCurrencySymbol(preset.symbol),
                    ),
                  ActionChip(
                    avatar: const Icon(Icons.edit_rounded, size: 15),
                    label: Text(isPreset ? 'Custom' : current),
                    onPressed: () => _showCurrencyDialog(context, current),
                  ),
                ],
              ),
              if (!isPreset && current.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Using custom symbol "$current".',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _showCurrencyDialog(BuildContext context, String current) async {
    final cubit = context.read<SettingsCubit>();
    final controller = TextEditingController(text: current);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Custom currency symbol'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: 'Symbol',
            hintText: r'e.g. $, €, PKR',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await cubit.setCurrencySymbol(result);
    }
    controller.dispose();
  }
}

class _DataCard extends StatelessWidget {
  const _DataCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _tile(
            context,
            icon: Icons.file_download_rounded,
            color: const Color(0xFF00687A),
            title: 'Export to CSV',
            subtitle: 'Download all meter readings',
            onTap: () => _export(context),
          ),
          const Divider(height: 1),
          _tile(
            context,
            icon: Icons.backup_rounded,
            color: const Color(0xFF6B38D4),
            title: 'Back up data',
            subtitle: 'Save a database backup (photos not included)',
            onTap: () => _backup(context),
          ),
          const Divider(height: 1),
          _tile(
            context,
            icon: Icons.restore_rounded,
            color: Theme.of(context).colorScheme.error,
            title: 'Restore data',
            subtitle: 'Replace all data from a backup file',
            onTap: () => _restore(context),
          ),
          // Only offered while the snapshot exists. It sits in app-private
          // storage the file picker cannot browse, so "Restore data" above can
          // never reach it — this is the only route to it.
          FutureBuilder<bool>(
            future: sl<BackupService>().hasPreRepairSnapshot(),
            builder: (context, snapshot) {
              if (snapshot.data != true) return const SizedBox.shrink();
              return Column(
                children: [
                  const Divider(height: 1),
                  _tile(
                    context,
                    icon: Icons.history_rounded,
                    color: Theme.of(context).colorScheme.error,
                    title: 'Undo data repair',
                    subtitle: 'Go back to the data as it was before the repair',
                    onTap: () => _restorePreRepair(context),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  Future<void> _export(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await sl<ExportService>().exportAll();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not export data.')),
      );
    }
  }

  Future<void> _backup(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await sl<BackupService>().backup();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not create a backup.')),
      );
    }
  }

  Future<void> _restorePreRepair(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Undo the data repair?'),
        content: const Text(
          'MeterPulse took a copy of your data before repairing bill readings. '
          'This restores that copy, bringing back any readings the repair '
          'removed and discarding changes made since.\n\n'
          'The automatic repair will not run again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final staged = await sl<BackupService>().stagePreRepairSnapshot();
      if (!context.mounted) return;
      if (!staged) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No pre-repair copy is available.')),
        );
        return;
      }
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Restart to finish'),
          content: const Text(
            'Your earlier data will be restored the next time you open '
            'MeterPulse. Please fully close and reopen the app.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not restore the earlier data.')),
      );
    }
  }

  Future<void> _restore(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore from backup?'),
        content: const Text(
          'This replaces all current meters, readings and bills with the '
          'backup. Photos are not restored. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Choose file'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final staged = await sl<BackupService>().stageRestore();
      if (!context.mounted) return;
      if (!staged) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No backup file selected.')),
        );
        return;
      }
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Restart to finish'),
          content: const Text(
            'Your backup will be restored the next time you open MeterPulse. '
            'Please fully close and reopen the app.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not restore the backup.')),
      );
    }
  }
}
