import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Versatile info card widget following BlockVest design system
/// Provides consistent styling for displaying information with various layouts
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    this.title,
    this.subtitle,
    this.content,
    this.leading,
    this.trailing,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.elevation,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.showBorder = false,
    this.isSelected = false,
    this.isDisabled = false,
  });

  final String? title;
  final String? subtitle;
  final Widget? content;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool showBorder;
  final bool isSelected;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.all(AppTheme.spacingS),
      child: Material(
        color: backgroundColor ?? 
            (isDark ? AppTheme.surfaceDark : AppTheme.surfaceWhite),
        elevation: elevation ?? AppTheme.elevationLow,
        borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusL),
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusL),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusL),
              border: showBorder || isSelected
                  ? Border.all(
                      color: isSelected
                          ? AppTheme.primaryDarkGreen
                          : (borderColor ?? AppTheme.textDisabled),
                      width: isSelected ? 2 : 1,
                    )
                  : null,
            ),
            padding: padding ?? const EdgeInsets.all(AppTheme.spacingM),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppTheme.spacingM),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: AppTheme.titleMedium.copyWith(
                            color: isDisabled
                                ? AppTheme.textDisabled
                                : (isDark ? Colors.white : AppTheme.textPrimary),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppTheme.spacingXS),
                        Text(
                          subtitle!,
                          style: AppTheme.bodyMedium.copyWith(
                            color: isDisabled
                                ? AppTheme.textDisabled
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                      if (content != null) ...[
                        if (title != null || subtitle != null)
                          const SizedBox(height: AppTheme.spacingS),
                        content!,
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppTheme.spacingM),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Specialized card for displaying statistics or metrics
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.trend,
    this.trendColor,
    this.onTap,
    this.backgroundColor,
    this.valueColor,
    this.width,
    this.height,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final String? trend;
  final Color? trendColor;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? valueColor;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InfoCard(
      width: width,
      height: height,
      onTap: onTap,
      backgroundColor: backgroundColor,
      leading: icon != null
          ? Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: AppTheme.primaryDarkGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryDarkGreen,
                size: 24,
              ),
            )
          : null,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            value,
            style: AppTheme.headlineSmall.copyWith(
              color: valueColor ?? 
                  (isDark ? Colors.white : AppTheme.textPrimary),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              subtitle!,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          if (trend != null) ...[
            const SizedBox(height: AppTheme.spacingXS),
            Row(
              children: [
                Icon(
                  trendColor == AppTheme.successColor
                      ? Icons.trending_up
                      : trendColor == AppTheme.errorRed
                          ? Icons.trending_down
                          : Icons.trending_flat,
                  size: 16,
                  color: trendColor ?? AppTheme.textSecondary,
                ),
                const SizedBox(width: AppTheme.spacingXS),
                Text(
                  trend!,
                  style: AppTheme.bodySmall.copyWith(
                    color: trendColor ?? AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Specialized card for displaying investment information
class InvestmentCard extends StatelessWidget {
  const InvestmentCard({
    super.key,
    required this.title,
    required this.amount,
    required this.status,
    this.description,
    this.imageUrl,
    this.progress,
    this.onTap,
    this.onActionTap,
    this.actionText,
    this.width,
    this.height,
  });

  final String title;
  final String amount;
  final String status;
  final String? description;
  final String? imageUrl;
  final double? progress;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;
  final String? actionText;
  final double? width;
  final double? height;

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'active':
        return AppTheme.activeInvestment;
      case 'completed':
        return AppTheme.completedInvestment;
      case 'pending':
        return AppTheme.pendingInvestment;
      case 'failed':
        return AppTheme.failedInvestment;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      width: width,
      height: height,
      onTap: onTap,
      padding: const EdgeInsets.all(AppTheme.spacingM),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  child: Image.network(
                    imageUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: const Icon(
                        Icons.agriculture,
                        color: AppTheme.primaryDarkGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Row(
                      children: [
                        Text(
                          amount,
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.primaryDarkGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingS,
                            vertical: AppTheme.spacingXS,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusS),
                          ),
                          child: Text(
                            status,
                            style: AppTheme.labelSmall.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: AppTheme.spacingS),
            Text(
              description!,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (progress != null) ...[
            const SizedBox(height: AppTheme.spacingS),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.backgroundLight,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 4,
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              '${(progress! * 100).toInt()}% Complete',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          if (actionText != null && onActionTap != null) ...[
            const SizedBox(height: AppTheme.spacingM),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onActionTap,
                child: Text(actionText!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
