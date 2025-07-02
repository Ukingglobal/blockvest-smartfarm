import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

/// Primary button widget following BlockVest design system
/// Provides consistent styling, accessibility, and interaction patterns
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.elevation,
    this.padding,
    this.textStyle,
    this.loadingText,
    this.hapticFeedback = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final String? loadingText;
  final bool hapticFeedback;

  @override
  Widget build(BuildContext context) {
    final isDisabled = !isEnabled || isLoading || onPressed == null;
    
    return SizedBox(
      width: width,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isDisabled
            ? null
            : () {
                if (hapticFeedback) {
                  HapticFeedback.lightImpact();
                }
                onPressed?.call();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.accentGold,
          foregroundColor: foregroundColor ?? AppTheme.textOnAccent,
          disabledBackgroundColor: AppTheme.textDisabled,
          disabledForegroundColor: AppTheme.textSecondary,
          elevation: elevation ?? AppTheme.elevationMedium,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusM),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingL,
                vertical: AppTheme.spacingM,
              ),
          minimumSize: const Size(88, 48),
          textStyle: textStyle ??
              AppTheme.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
        ),
        child: AnimatedSwitcher(
          duration: AppTheme.animationFast,
          child: isLoading
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          foregroundColor ?? AppTheme.textOnAccent,
                        ),
                      ),
                    ),
                    if (loadingText != null) ...[
                      const SizedBox(width: AppTheme.spacingS),
                      Text(loadingText!),
                    ],
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: AppTheme.spacingS),
                    ],
                    Text(text),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Secondary button variant with outline style
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height,
    this.borderColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.loadingText,
    this.hapticFeedback = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? height;
  final Color? borderColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final String? loadingText;
  final bool hapticFeedback;

  @override
  Widget build(BuildContext context) {
    final isDisabled = !isEnabled || isLoading || onPressed == null;
    
    return SizedBox(
      width: width,
      height: height ?? 48,
      child: OutlinedButton(
        onPressed: isDisabled
            ? null
            : () {
                if (hapticFeedback) {
                  HapticFeedback.lightImpact();
                }
                onPressed?.call();
              },
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor ?? AppTheme.primaryDarkGreen,
          disabledForegroundColor: AppTheme.textDisabled,
          side: BorderSide(
            color: isDisabled
                ? AppTheme.textDisabled
                : (borderColor ?? AppTheme.primaryDarkGreen),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusM),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingL,
                vertical: AppTheme.spacingM,
              ),
          minimumSize: const Size(88, 48),
          textStyle: textStyle ??
              AppTheme.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
        ),
        child: AnimatedSwitcher(
          duration: AppTheme.animationFast,
          child: isLoading
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          foregroundColor ?? AppTheme.primaryDarkGreen,
                        ),
                      ),
                    ),
                    if (loadingText != null) ...[
                      const SizedBox(width: AppTheme.spacingS),
                      Text(loadingText!),
                    ],
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: AppTheme.spacingS),
                    ],
                    Text(text),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Text button variant for less prominent actions
class TertiaryButton extends StatelessWidget {
  const TertiaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.loadingText,
    this.hapticFeedback = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? height;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final String? loadingText;
  final bool hapticFeedback;

  @override
  Widget build(BuildContext context) {
    final isDisabled = !isEnabled || isLoading || onPressed == null;
    
    return SizedBox(
      width: width,
      height: height ?? 40,
      child: TextButton(
        onPressed: isDisabled
            ? null
            : () {
                if (hapticFeedback) {
                  HapticFeedback.lightImpact();
                }
                onPressed?.call();
              },
        style: TextButton.styleFrom(
          foregroundColor: foregroundColor ?? AppTheme.primaryDarkGreen,
          disabledForegroundColor: AppTheme.textDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusS),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
          minimumSize: const Size(64, 40),
          textStyle: textStyle ??
              AppTheme.labelLarge.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
        ),
        child: AnimatedSwitcher(
          duration: AppTheme.animationFast,
          child: isLoading
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          foregroundColor ?? AppTheme.primaryDarkGreen,
                        ),
                      ),
                    ),
                    if (loadingText != null) ...[
                      const SizedBox(width: AppTheme.spacingS),
                      Text(loadingText!),
                    ],
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 16),
                      const SizedBox(width: AppTheme.spacingXS),
                    ],
                    Text(text),
                  ],
                ),
        ),
      ),
    );
  }
}
