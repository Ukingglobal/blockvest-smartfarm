import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum BlockVestButtonType {
  primary,
  secondary,
  outline,
  text,
  danger,
}

enum BlockVestButtonSize {
  small,
  medium,
  large,
}

class BlockVestButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final BlockVestButtonType type;
  final BlockVestButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Widget? child;

  const BlockVestButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = BlockVestButtonType.primary,
    this.size = BlockVestButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
  });

  const BlockVestButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = BlockVestButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
  }) : type = BlockVestButtonType.primary;

  const BlockVestButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = BlockVestButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
  }) : type = BlockVestButtonType.secondary;

  const BlockVestButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.size = BlockVestButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
  }) : type = BlockVestButtonType.outline;

  const BlockVestButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.size = BlockVestButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
  }) : type = BlockVestButtonType.text;

  const BlockVestButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.size = BlockVestButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
  }) : type = BlockVestButtonType.danger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: _buildButton(context, theme),
    );
  }

  Widget _buildButton(BuildContext context, ThemeData theme) {
    final buttonStyle = _getButtonStyle(theme);
    final buttonChild = _buildButtonChild();

    switch (type) {
      case BlockVestButtonType.primary:
      case BlockVestButtonType.secondary:
      case BlockVestButtonType.danger:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
      case BlockVestButtonType.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
      case BlockVestButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
    }
  }

  Widget _buildButtonChild() {
    if (isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getLoadingColor(),
          ),
        ),
      );
    }

    if (child != null) {
      return child!;
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: AppTheme.spacingS),
          Text(text),
        ],
      );
    }

    return Text(text);
  }

  ButtonStyle _getButtonStyle(ThemeData theme) {
    final padding = _getPadding();
    final textStyle = _getTextStyle();
    
    switch (type) {
      case BlockVestButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          padding: padding,
          textStyle: textStyle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          elevation: 2,
        );
      case BlockVestButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppTheme.secondaryGold,
          foregroundColor: AppTheme.textPrimary,
          padding: padding,
          textStyle: textStyle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          elevation: 2,
        );
      case BlockVestButtonType.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryGreen,
          padding: padding,
          textStyle: textStyle,
          side: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        );
      case BlockVestButtonType.text:
        return TextButton.styleFrom(
          foregroundColor: AppTheme.primaryGreen,
          padding: padding,
          textStyle: textStyle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        );
      case BlockVestButtonType.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: AppTheme.errorColor,
          foregroundColor: Colors.white,
          padding: padding,
          textStyle: textStyle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          elevation: 2,
        );
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case BlockVestButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        );
      case BlockVestButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingL,
          vertical: AppTheme.spacingM,
        );
      case BlockVestButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingXL,
          vertical: AppTheme.spacingL,
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case BlockVestButtonSize.small:
        return const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        );
      case BlockVestButtonSize.medium:
        return const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        );
      case BlockVestButtonSize.large:
        return const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        );
    }
  }

  double _getIconSize() {
    switch (size) {
      case BlockVestButtonSize.small:
        return 16;
      case BlockVestButtonSize.medium:
        return 20;
      case BlockVestButtonSize.large:
        return 24;
    }
  }

  Color _getLoadingColor() {
    switch (type) {
      case BlockVestButtonType.primary:
      case BlockVestButtonType.danger:
        return Colors.white;
      case BlockVestButtonType.secondary:
        return AppTheme.textPrimary;
      case BlockVestButtonType.outline:
      case BlockVestButtonType.text:
        return AppTheme.primaryGreen;
    }
  }
}
