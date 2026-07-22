import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Skeleton placeholder with a subtle left-to-right shimmer, shown during a
/// screen's first data load. Renders card-shaped bones so the transition to
/// real content has no layout jump and no blank-white flash.
class LoadingView extends StatefulWidget {
  const LoadingView({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: AppSpacing.page,
      itemCount: widget.itemCount,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) =>
            _SkeletonCard(progress: _controller.value),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.progress});

  /// Animation position in the range 0.0–1.0.
  final double progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest;
    final highlight = Color.alphaBlend(
      scheme.surface.withValues(alpha: 0.6),
      base,
    );
    // Sweep the highlight band across the card as progress advances.
    final dx = progress * 2 - 1;

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (rect) => LinearGradient(
        begin: Alignment(dx - 0.3, 0),
        end: Alignment(dx + 0.3, 0),
        colors: [base, highlight, base],
      ).createShader(rect),
      child: Card(
        child: Padding(
          padding: AppSpacing.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bone(width: 150, height: 16),
              const SizedBox(height: AppSpacing.md),
              _bone(width: 210, height: 34),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  _bone(width: 72, height: 30),
                  const SizedBox(width: AppSpacing.sm),
                  _bone(width: 72, height: 30),
                  const SizedBox(width: AppSpacing.sm),
                  _bone(width: 72, height: 30),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bone({required double width, required double height}) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          // Colour is irrelevant — the ShaderMask paints over it; only the
          // shape/opacity matters here.
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      );
}
