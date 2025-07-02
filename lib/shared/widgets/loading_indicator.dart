import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Loading indicator widget following BlockVest design system
/// Provides consistent loading states across the application
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.size = 24.0,
    this.strokeWidth = 2.0,
    this.color,
    this.backgroundColor,
  });

  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppTheme.primaryDarkGreen,
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }
}

/// Full screen loading overlay with optional message
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    this.message,
    this.showBackground = true,
    this.backgroundColor,
    this.child,
  });

  final String? message;
  final bool showBackground;
  final Color? backgroundColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Stack(
      children: [
        if (child != null) child!,
        if (showBackground)
          Container(
            color: backgroundColor ??
                (isDark 
                    ? Colors.black.withOpacity(0.7)
                    : Colors.white.withOpacity(0.8)),
          ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LoadingIndicator(size: 32, strokeWidth: 3),
                if (message != null) ...[
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    message!,
                    style: AppTheme.bodyMedium.copyWith(
                      color: isDark ? Colors.white : AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Shimmer loading effect for content placeholders
class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.enabled = true,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final bool enabled;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (!widget.enabled) {
      return widget.child;
    }

    final baseColor = widget.baseColor ??
        (isDark ? Colors.grey[800]! : Colors.grey[300]!);
    final highlightColor = widget.highlightColor ??
        (isDark ? Colors.grey[700]! : Colors.grey[100]!);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Skeleton loading placeholder for cards
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({
    super.key,
    this.width,
    this.height = 120,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.all(AppTheme.spacingS),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusL),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[400],
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[700] : Colors.grey[400],
                            borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        Container(
                          width: 120,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[700] : Colors.grey[400],
                            borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),
              Container(
                width: double.infinity,
                height: 12,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[400],
                  borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Container(
                width: 200,
                height: 12,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[400],
                  borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton loading placeholder for list items
class SkeletonListItem extends StatelessWidget {
  const SkeletonListItem({
    super.key,
    this.height = 72,
    this.showAvatar = true,
    this.showTrailing = true,
  });

  final double height;
  final bool showAvatar;
  final bool showTrailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return ShimmerLoading(
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        child: Row(
          children: [
            if (showAvatar) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[400],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[400],
                      borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Container(
                    width: 150,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[400],
                      borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                    ),
                  ),
                ],
              ),
            ),
            if (showTrailing) ...[
              const SizedBox(width: AppTheme.spacingM),
              Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[400],
                  borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
