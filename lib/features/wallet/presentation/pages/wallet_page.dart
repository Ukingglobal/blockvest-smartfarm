import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/wallet_actions_row.dart';
import '../widgets/transaction_history_list.dart';
import '../widgets/portfolio_overview.dart';
import '../widgets/wallet_connection_status.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../../../shared/widgets/widgets.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          WalletBloc(walletRepository: GetIt.instance<WalletRepository>())
            ..add(const LoadWalletEvent()),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Wallet',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<WalletBloc>().add(const RefreshBalanceEvent());
              },
              tooltip: 'Refresh Balance',
            ),
            IconButton(
              icon: const Icon(Icons.explore),
              onPressed: () {
                context.push('/blockchain-explorer');
              },
              tooltip: 'Blockchain Explorer',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // TODO: Navigate to wallet settings
              },
              tooltip: 'Wallet Settings',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Transactions'),
              Tab(text: 'Portfolio'),
            ],
          ),
        ),
        body: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            if (state is WalletDisconnected) {
              return const WalletConnectionStatus();
            }

            if (state is WalletLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingIndicator(size: 48),
                    SizedBox(height: 16),
                    Text('Loading wallet...'),
                  ],
                ),
              );
            }

            if (state is WalletError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading wallet',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: 'Retry',
                      onPressed: () {
                        context.read<WalletBloc>().add(const LoadWalletEvent());
                      },
                    ),
                  ],
                ),
              );
            }

            if (state is WalletLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(context, state),
                  _buildTransactionsTab(context, state),
                  _buildPortfolioTab(context, state),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, WalletLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WalletConnectionStatus(),
          const SizedBox(height: 16),
          WalletBalanceCard(wallet: state.wallet),
          const SizedBox(height: 16),
          WalletActionsRow(
            onSend: () => _showSendDialog(context),
            onReceive: () => _showReceiveDialog(context),
            onBuy: () => _showBuyDialog(context),
          ),
          const SizedBox(height: 24),
          Text(
            'Recent Transactions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TransactionHistoryList(
            transactions: state.wallet.transactions.take(5).toList(),
            isCompact: true,
          ),
          const SizedBox(height: 16),
          TertiaryButton(
            text: 'View All Transactions',
            onPressed: () => _tabController.animateTo(1),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab(BuildContext context, WalletLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaction History',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TransactionHistoryList(
              transactions: state.wallet.transactions,
              isCompact: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioTab(BuildContext context, WalletLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Investment Portfolio',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          PortfolioOverview(wallet: state.wallet),
        ],
      ),
    );
  }

  void _showSendDialog(BuildContext context) {
    // TODO: Implement send dialog
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Send feature coming soon')));
  }

  void _showReceiveDialog(BuildContext context) {
    // TODO: Implement receive dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receive feature coming soon')),
    );
  }

  void _showBuyDialog(BuildContext context) {
    // TODO: Implement buy dialog
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Buy feature coming soon')));
  }

  void _showFilterDialog(BuildContext context) {
    // TODO: Implement filter dialog
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Filter feature coming soon')));
  }
}
