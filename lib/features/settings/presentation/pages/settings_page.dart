import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/widgets.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SettingsBloc>().add(const LoadSettingsEvent());
            },
            tooltip: 'Refresh Settings',
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go(AppRouter.login);
          }
        },
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            if (settingsState is SettingsLoading) {
              return const Center(child: LoadingIndicator());
            }

            if (settingsState is SettingsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load settings',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      settingsState.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: 'Retry',
                      onPressed: () {
                        context.read<SettingsBloc>().add(
                          const LoadSettingsEvent(),
                        );
                      },
                    ),
                  ],
                ),
              );
            }

            final settings = settingsState is SettingsLoaded
                ? settingsState
                : null;

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Profile section
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                child: Text(
                                  state.user.fullName.isNotEmpty
                                      ? state.user.fullName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.user.fullName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      state.user.email,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.7),
                                          ),
                                    ),
                                    if (!state.user.isKycVerified)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          'KYC Pending',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // TODO: Navigate to profile edit
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 16),

                // Settings sections
                _buildSettingsSection(context, 'Account', [
                  _buildSettingsTile(
                    context,
                    'Complete KYC',
                    'Verify your identity',
                    Icons.verified_user,
                    () => context.go(AppRouter.kyc),
                  ),
                  _buildSettingsTile(
                    context,
                    'Security',
                    'Biometric, KYC, and MFA settings',
                    Icons.security,
                    () => context.go(AppRouter.securitySettings),
                  ),
                ]),
                const SizedBox(height: 16),

                _buildSettingsSection(context, 'Preferences', [
                  _buildThemeSettingsTile(context, settings),
                  _buildLanguageSettingsTile(context, settings),
                  _buildNotificationSettingsTile(context, settings),
                ]),
                const SizedBox(height: 16),

                _buildSettingsSection(context, 'Support', [
                  _buildSettingsTile(
                    context,
                    'Help Center',
                    'Get help and support',
                    Icons.help,
                    () {
                      // TODO: Navigate to help center
                    },
                  ),
                  _buildSettingsTile(
                    context,
                    'About',
                    'App version and info',
                    Icons.info,
                    () {
                      // TODO: Show about dialog
                    },
                  ),
                ]),
                const SizedBox(height: 32),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text(
                            'Are you sure you want to logout?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                context.read<AuthBloc>().add(
                                  const SignOutRequested(),
                                );
                              },
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildThemeSettingsTile(
    BuildContext context,
    SettingsLoaded? settings,
  ) {
    final currentTheme = settings?.themeDisplayName ?? 'System Default';

    return ListTile(
      leading: const Icon(Icons.palette),
      title: const Text('Theme'),
      subtitle: Text(currentTheme),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeSelector(context, settings),
    );
  }

  Widget _buildLanguageSettingsTile(
    BuildContext context,
    SettingsLoaded? settings,
  ) {
    final currentLanguage = settings?.languageDisplayName ?? 'English';

    return ListTile(
      leading: const Icon(Icons.language),
      title: const Text('Language'),
      subtitle: Text(currentLanguage),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguageSelector(context, settings),
    );
  }

  Widget _buildNotificationSettingsTile(
    BuildContext context,
    SettingsLoaded? settings,
  ) {
    return ListTile(
      leading: const Icon(Icons.notifications),
      title: const Text('Notifications'),
      subtitle: const Text('Manage notification preferences'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showNotificationSettings(context, settings),
    );
  }

  void _showThemeSelector(BuildContext context, SettingsLoaded? settings) {
    final currentTheme = settings?.themeMode ?? 'system';

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Theme', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildThemeOption(context, 'Light Mode', 'light', currentTheme),
            _buildThemeOption(context, 'Dark Mode', 'dark', currentTheme),
            _buildThemeOption(
              context,
              'System Default',
              'system',
              currentTheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    String value,
    String currentValue,
  ) {
    return ListTile(
      title: Text(title),
      leading: Radio<String>(
        value: value,
        groupValue: currentValue,
        onChanged: (newValue) {
          if (newValue != null) {
            context.read<SettingsBloc>().add(
              ChangeThemeEvent(themeMode: newValue),
            );
            Navigator.pop(context);
          }
        },
      ),
      onTap: () {
        context.read<SettingsBloc>().add(ChangeThemeEvent(themeMode: value));
        Navigator.pop(context);
      },
    );
  }

  void _showLanguageSelector(BuildContext context, SettingsLoaded? settings) {
    final currentLanguage = settings?.locale.languageCode ?? 'en';

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Language',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildLanguageOption(context, 'English', 'en', currentLanguage),
            _buildLanguageOption(context, 'Español', 'es', currentLanguage),
            _buildLanguageOption(context, 'Français', 'fr', currentLanguage),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String title,
    String value,
    String currentValue,
  ) {
    return ListTile(
      title: Text(title),
      leading: Radio<String>(
        value: value,
        groupValue: currentValue,
        onChanged: (newValue) {
          if (newValue != null) {
            context.read<SettingsBloc>().add(
              ChangeLanguageEvent(languageCode: newValue),
            );
            Navigator.pop(context);
          }
        },
      ),
      onTap: () {
        context.read<SettingsBloc>().add(
          ChangeLanguageEvent(languageCode: value),
        );
        Navigator.pop(context);
      },
    );
  }

  void _showNotificationSettings(
    BuildContext context,
    SettingsLoaded? settings,
  ) {
    final notificationSettings = settings?.notificationSettings ?? {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildNotificationToggle(
                    context,
                    'Push Notifications',
                    'Receive push notifications on your device',
                    'push_notifications',
                    notificationSettings['push_notifications'] ?? true,
                  ),
                  _buildNotificationToggle(
                    context,
                    'Email Notifications',
                    'Receive notifications via email',
                    'email_notifications',
                    notificationSettings['email_notifications'] ?? true,
                  ),
                  _buildNotificationToggle(
                    context,
                    'Investment Updates',
                    'Get notified about investment opportunities',
                    'investment_updates',
                    notificationSettings['investment_updates'] ?? true,
                  ),
                  _buildNotificationToggle(
                    context,
                    'Price Alerts',
                    'Receive alerts for price changes',
                    'price_alerts',
                    notificationSettings['price_alerts'] ?? true,
                  ),
                  _buildNotificationToggle(
                    context,
                    'Security Alerts',
                    'Important security notifications',
                    'security_alerts',
                    notificationSettings['security_alerts'] ?? true,
                  ),
                  _buildNotificationToggle(
                    context,
                    'Transaction Notifications',
                    'Get notified about transactions',
                    'transaction_notifications',
                    notificationSettings['transaction_notifications'] ?? true,
                  ),
                  _buildNotificationToggle(
                    context,
                    'KYC Updates',
                    'Receive KYC verification updates',
                    'kyc_updates',
                    notificationSettings['kyc_updates'] ?? true,
                  ),
                  _buildNotificationToggle(
                    context,
                    'Marketing Notifications',
                    'Promotional and marketing content',
                    'marketing_notifications',
                    notificationSettings['marketing_notifications'] ?? false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: 'Done',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(
    BuildContext context,
    String title,
    String subtitle,
    String key,
    bool value,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: (newValue) {
        context.read<SettingsBloc>().add(
          ToggleNotificationEvent(notificationType: key, enabled: newValue),
        );
      },
    );
  }
}
