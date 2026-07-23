import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/usage_alert.dart';

/// Tonal banner for a [UsageAlert]. Error colours for high severity, tertiary
/// (theme-aware) for warnings.
class AlertBanner extends StatelessWidget {
  const AlertBanner({super.key, required this.alert, this.dense = false});

  final UsageAlert alert;

  /// When true, shows only the title on one line (used on compact cards).
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final high = alert.isHigh;
    final background = high ? scheme.errorContainer : scheme.tertiaryContainer;
    final foreground =
        high ? scheme.onErrorContainer : scheme.onTertiaryContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.field)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            high ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
            color: foreground,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
                ),
                if (!dense) ...[
                  const SizedBox(height: 2),
                  Text(
                    alert.message,
                    style: theme.textTheme.bodySmall?.copyWith(color: foreground),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
