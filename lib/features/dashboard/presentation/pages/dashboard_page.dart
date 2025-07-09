import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DashboardAppBar(
        title: 'Dashboard',
        onNotificationTap: () {
          // TODO: Navigate to notifications
        },
        onProfileTap: () => _showProfileMenu(context),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go(AppRouter.login);
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            // Dispatch event to reload user data, which might include KYC status
            context.read<AuthBloc>().add(const LoadUserRequested());
            // TODO: Dispatch events to refresh portfolio, project counts, etc.
            // This might require new events in existing Blocs or a dedicated DashboardBloc.
            // For now, we primarily refresh AuthBloc related data.
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Welcome section
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
                                    'Welcome back,',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.7),
                                        ),
                                  ),
                                  Text(
                                    state.user.fullName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  if (!state.user.isKycVerified)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
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
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 16),

              // New Dashboard Summary Card
              Card(
                // Card styling will come from AppTheme.mainTheme.cardTheme
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL), // Use AppTheme spacing
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Summary', // Title for the card
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              // color will be AppTheme.textIconColor via theme
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      Center( // Center the large balance display
                        child: Column(
                          children: [
                            Text(
                              'Total Balance',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                            ),
                            const SizedBox(height: AppTheme.spacingXS),
                            Text(
                              '₦1,200,000.75', // Placeholder value
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                // titleLarge is configured for large display numbers (light weight)
                                // color will be AppTheme.textIconColor
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryDetail(context, 'Total Invested', '₦850,000.00'),
                          _buildSummaryDetail(context, 'Total Earnings', '₦350,000.75'),
                        ],
                      ),
                      // Add a CTA button if needed, e.g., "View Details" or "Add Funds"
                      // const SizedBox(height: AppTheme.spacingM),
                      // Align(
                      //   alignment: Alignment.centerRight,
                      //   child: TertiaryButton(
                      //     text: 'View Full Report',
                      //     onPressed: () { /* TODO: Navigate to full report */ },
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Quick actions
              Text(
                'Quick Actions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: 'Browse Projects',
                      icon: Icons.search,
                      onPressed: () => context.go(AppRouter.marketplace),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SecondaryButton(
                      text: 'My Wallet',
                      icon: Icons.account_balance_wallet,
                      onPressed: () => context.go(AppRouter.wallet),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TertiaryButton(
                      text: 'Governance',
                      icon: Icons.how_to_vote,
                      onPressed: () => context.go(AppRouter.governance),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TertiaryButton(
                      text: 'Settings',
                      icon: Icons.settings,
                      onPressed: () => context.go(AppRouter.settings),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile & Settings'),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRouter.settings);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(const SignOutRequested());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryDetail(BuildContext context, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
        ),
        const SizedBox(height: AppTheme.spacingXS),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600, // Make the value a bit more prominent
            // color will be AppTheme.textIconColor via theme
          ),
        ),
      ],
    );
  }
}
