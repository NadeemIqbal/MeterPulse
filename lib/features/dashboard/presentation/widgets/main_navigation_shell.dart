import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../meters/domain/entities/meter.dart';
import '../../../meters/domain/repositories/meter_repository.dart';
import '../../../meters/presentation/meter_type_ui.dart';
import '../../../../core/di/service_locator.dart';

/// Translucent Stitch-style bottom navigation bar shell wrapping top-level pages.
///
/// The bar deliberately uses a near-opaque fill rather than a live
/// [BackdropFilter]: under the Impeller/Vulkan backend a blur in the
/// `bottomNavigationBar` slot stops the Scaffold body painting entirely — the
/// body still lays out at full size but never draws, leaving a blank screen.
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  final Widget child;
  final String currentLocation;

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _calculateSelectedIndex() {
    final location = widget.currentLocation;
    if (location == RouteNames.dashboard) return 0;
    if (location.startsWith(RouteNames.allStats)) return 1;
    if (location.startsWith(RouteNames.allBills)) return 3;
    if (location.startsWith(RouteNames.settings)) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selectedIndex = _calculateSelectedIndex();

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 68,
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                scheme.surface.withValues(alpha: 0.92),
                scheme.surfaceContainerLow,
              ),
              border: Border(
                top: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  context,
                  icon: Icons.dashboard_rounded,
                  label: 'Home',
                  isSelected: selectedIndex == 0,
                  onTap: () => context.go(RouteNames.dashboard),
                ),
                _navItem(
                  context,
                  icon: Icons.insights_rounded,
                  label: 'Stats',
                  isSelected: selectedIndex == 1,
                  onTap: () => context.go(RouteNames.allStats),
                ),
                const SizedBox(width: 56), // Gap for center camera FAB
                _navItem(
                  context,
                  icon: Icons.receipt_long_rounded,
                  label: 'Bills',
                  isSelected: selectedIndex == 3,
                  onTap: () => context.go(RouteNames.allBills),
                ),
                _navItem(
                  context,
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: selectedIndex == 4,
                  onTap: () => context.go(RouteNames.settings),
                ),
              ],
            ),
          ),

          // Center Floating Camera Action Button
          Positioned(
            top: -24,
            child: GestureDetector(
              onTap: () => _captureReading(context),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_a_photo_rounded,
                  color: scheme.onPrimary,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A reading belongs to one meter, so the centre FAB asks which when there is
  /// more than one rather than silently defaulting.
  Future<void> _captureReading(BuildContext context) async {
    final meters = await sl<MeterRepository>().getMeters();
    if (!context.mounted) return;

    if (meters.isEmpty) {
      await context.push(RouteNames.newMeter);
      return;
    }

    final meter =
        meters.length == 1 ? meters.first : await _pickMeter(context, meters);
    if (meter == null || !context.mounted) return;

    await context.push(RouteNames.takeReading(meter.id!), extra: meter);
  }

  Future<Meter?> _pickMeter(BuildContext context, List<Meter> meters) {
    return showModalBottomSheet<Meter>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Which meter are you reading?',
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            for (final meter in meters)
              ListTile(
                leading: Icon(meter.displayIcon),
                title: Text(meter.name),
                subtitle: Text(meter.unit),
                onTap: () => Navigator.of(sheetContext).pop(meter),
              ),
          ],
        ),
      ),
    );
  }
}
