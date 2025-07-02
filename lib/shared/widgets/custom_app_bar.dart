import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

/// Custom AppBar widget following BlockVest design system
/// Provides consistent styling and accessibility features across the app
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = true,
    this.showBackButton = true,
    this.onBackPressed,
    this.systemOverlayStyle,
    this.titleStyle,
    this.subtitle,
    this.bottom,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final TextStyle? titleStyle;
  final String? subtitle;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AppBar(
      title: subtitle != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: titleStyle ??
                      AppTheme.titleMedium.copyWith(
                        color: foregroundColor ?? AppTheme.textOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AppTheme.bodySmall.copyWith(
                    color: (foregroundColor ?? AppTheme.textOnPrimary)
                        .withOpacity(0.8),
                  ),
                ),
              ],
            )
          : Text(
              title,
              style: titleStyle ??
                  AppTheme.titleLarge.copyWith(
                    color: foregroundColor ?? AppTheme.textOnPrimary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.15,
                  ),
            ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppTheme.primaryDarkGreen,
      foregroundColor: foregroundColor ?? AppTheme.textOnPrimary,
      elevation: elevation ?? AppTheme.elevationNone,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: systemOverlayStyle ??
          (isDark ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light),
      leading: leading ??
          (showBackButton && Navigator.of(context).canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                  tooltip: 'Back',
                  splashRadius: 20,
                )
              : null),
      actions: actions?.map((action) {
        // Wrap actions in proper touch targets for accessibility
        if (action is IconButton) {
          return action;
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXS),
          child: action,
        );
      }).toList(),
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}

/// Specialized AppBar for dashboard screens with enhanced features
class DashboardAppBar extends CustomAppBar {
  const DashboardAppBar({
    super.key,
    required super.title,
    this.showNotifications = true,
    this.showProfile = true,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.onProfileTap,
    super.subtitle,
  }) : super(
          showBackButton: false,
          actions: const [], // Will be overridden in build
        );

  final bool showNotifications;
  final bool showProfile;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    if (showNotifications) {
      actions.add(
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: onNotificationTap,
              tooltip: 'Notifications',
              splashRadius: 20,
            ),
            if (notificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppTheme.errorRed,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    notificationCount > 99 ? '99+' : notificationCount.toString(),
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.textOnPrimary,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (showProfile) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          onPressed: onProfileTap,
          tooltip: 'Profile',
          splashRadius: 20,
        ),
      );
    }

    return CustomAppBar(
      title: title,
      subtitle: subtitle,
      showBackButton: false,
      actions: actions,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      titleStyle: titleStyle,
      systemOverlayStyle: systemOverlayStyle,
    );
  }
}

/// Specialized AppBar for forms and detail screens
class FormAppBar extends CustomAppBar {
  const FormAppBar({
    super.key,
    required super.title,
    this.showSave = false,
    this.showCancel = false,
    this.onSave,
    this.onCancel,
    this.saveEnabled = true,
    super.subtitle,
  });

  final bool showSave;
  final bool showCancel;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final bool saveEnabled;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    if (showCancel) {
      actions.add(
        TextButton(
          onPressed: onCancel,
          child: Text(
            'Cancel',
            style: AppTheme.labelLarge.copyWith(
              color: foregroundColor ?? AppTheme.textOnPrimary,
            ),
          ),
        ),
      );
    }

    if (showSave) {
      actions.add(
        TextButton(
          onPressed: saveEnabled ? onSave : null,
          child: Text(
            'Save',
            style: AppTheme.labelLarge.copyWith(
              color: saveEnabled
                  ? (foregroundColor ?? AppTheme.textOnPrimary)
                  : AppTheme.textDisabled,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return CustomAppBar(
      title: title,
      subtitle: subtitle,
      actions: actions,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      showBackButton: showBackButton,
      onBackPressed: onBackPressed,
      titleStyle: titleStyle,
      systemOverlayStyle: systemOverlayStyle,
    );
  }
}
