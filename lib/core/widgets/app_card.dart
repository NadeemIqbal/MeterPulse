import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Rounded, low-elevation tonal card — the base surface for meter cards, bill
/// cards and stat groupings. Wrapping [Card] + [InkWell] here keeps ripple
/// clipping and corner radius consistent everywhere instead of being re-set at
/// each call site.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = AppSpacing.card,
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardRadius,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
