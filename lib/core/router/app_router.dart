import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import all pages
import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/kyc_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/marketplace/presentation/pages/marketplace_page.dart';
import '../../features/marketplace/presentation/pages/project_details_page.dart';
import '../../features/wallet/presentation/pages/wallet_page.dart';
import '../../features/governance/presentation/pages/governance_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/security/presentation/pages/security_settings_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String kyc = '/kyc';
  static const String dashboard = '/dashboard';
  static const String marketplace = '/marketplace';
  static const String farmDetails = '/farm-details';
  static const String wallet = '/wallet';
  static const String governance = '/governance';
  static const String settings = '/settings';
  static const String securitySettings = '/security-settings';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: kyc,
        name: 'kyc',
        builder: (context, state) => const KycPage(),
      ),
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: marketplace,
        name: 'marketplace',
        builder: (context, state) => const MarketplacePage(),
        routes: [
          GoRoute(
            path: 'project/:projectId',
            name: 'project-details',
            builder: (context, state) {
              final projectId = state.pathParameters['projectId']!;
              return ProjectDetailsPage(projectId: projectId);
            },
          ),
        ],
      ),

      GoRoute(
        path: wallet,
        name: 'wallet',
        builder: (context, state) => const WalletPage(),
      ),
      GoRoute(
        path: governance,
        name: 'governance',
        builder: (context, state) => const GovernancePage(),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: securitySettings,
        name: 'security-settings',
        builder: (context, state) => const SecuritySettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(dashboard),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
}
