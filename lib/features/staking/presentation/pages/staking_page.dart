import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/staking_service.dart';
import '../../../../core/services/web3_service.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../shared/widgets/blockvest_button.dart';
import '../widgets/staking_plan_card.dart';
import '../widgets/staking_position_card.dart';
import '../widgets/staking_stats_card.dart';

class StakingPage extends StatefulWidget {
  const StakingPage({super.key});

  @override
  State<StakingPage> createState() => _StakingPageState();
}

class _StakingPageState extends State<StakingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late StakingService _stakingService;
  
  bool _isLoading = false;
  List<StakingPlan> _stakingPlans = [];
  List<StakingData> _stakingPositions = [];
  StakingStats? _stakingStats;
  double _blockvestBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _stakingService = StakingService(web3Service: di.sl<Web3Service>());
    _loadStakingData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStakingData() async {
    setState(() => _isLoading = true);
    
    try {
      final plans = _stakingService.getStakingPlans();
      final positions = await _stakingService.getStakingPositions();
      final stats = await _stakingService.getStakingStats();
      final balance = await di.sl<Web3Service>().getBlockvestTokenBalance();

      setState(() {
        _stakingPlans = plans;
        _stakingPositions = positions;
        _stakingStats = stats;
        _blockvestBalance = balance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load staking data: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLOCKVEST Staking'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStakingData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppTheme.secondaryGold,
          tabs: const [
            Tab(text: 'Stake', icon: Icon(Icons.add_circle_outline)),
            Tab(text: 'Positions', icon: Icon(Icons.account_balance_wallet)),
            Tab(text: 'Stats', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStakeTab(),
                _buildPositionsTab(),
                _buildStatsTab(),
              ],
            ),
    );
  }

  Widget _buildStakeTab() {
    return RefreshIndicator(
      onRefresh: _loadStakingData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryGreen,
                      AppTheme.primaryGreen.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                ),
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available Balance',
                                style: AppTheme.titleMedium.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                '${NumberFormat.compact().format(_blockvestBalance)} BLOCKVEST',
                                style: AppTheme.headlineMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Staking Plans
            Text(
              'Choose Your Staking Plan',
              style: AppTheme.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            
            ..._stakingPlans.map((plan) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
              child: StakingPlanCard(
                plan: plan,
                onStake: () => _showStakeDialog(plan),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionsTab() {
    if (_stakingPositions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'No Staking Positions',
              style: AppTheme.titleLarge.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Start staking BLOCKVEST tokens to earn rewards',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingL),
            BlockVestButton.primary(
              text: 'Start Staking',
              onPressed: () => _tabController.animateTo(0),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStakingData,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        itemCount: _stakingPositions.length,
        itemBuilder: (context, index) {
          final position = _stakingPositions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
            child: StakingPositionCard(
              position: position,
              stakingService: _stakingService,
              onUnstake: () => _handleUnstake(position),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsTab() {
    if (_stakingStats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadStakingData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: [
            StakingStatsCard(stats: _stakingStats!),
            const SizedBox(height: AppTheme.spacingL),
            
            // Additional stats cards can be added here
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Staking Benefits',
                      style: AppTheme.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    _buildBenefitItem(
                      'Passive Income',
                      'Earn rewards automatically while holding BLOCKVEST tokens',
                      Icons.trending_up,
                    ),
                    _buildBenefitItem(
                      'Governance Rights',
                      'Participate in platform decisions and vote on proposals',
                      Icons.how_to_vote,
                    ),
                    _buildBenefitItem(
                      'Platform Growth',
                      'Support the BlockVest ecosystem and agricultural innovation',
                      Icons.agriculture,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
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
                Text(
                  description,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStakeDialog(StakingPlan plan) {
    showDialog(
      context: context,
      builder: (context) => StakeDialog(
        plan: plan,
        stakingService: _stakingService,
        availableBalance: _blockvestBalance,
        onSuccess: () {
          _showSuccessSnackBar('Staking initiated successfully!');
          _loadStakingData();
        },
      ),
    );
  }

  void _handleUnstake(StakingData position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unstake Tokens'),
        content: Text(
          'Are you sure you want to unstake ${NumberFormat.compact().format(position.amount)} BLOCKVEST tokens?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          BlockVestButton.primary(
            text: 'Unstake',
            onPressed: () async {
              Navigator.of(context).pop();
              final result = await _stakingService.unstakeTokens(position.id);
              if (result.success) {
                _showSuccessSnackBar(result.message);
                _loadStakingData();
              } else {
                _showErrorSnackBar(result.message);
              }
            },
          ),
        ],
      ),
    );
  }
}

// Stake Dialog Widget
class StakeDialog extends StatefulWidget {
  final StakingPlan plan;
  final StakingService stakingService;
  final double availableBalance;
  final VoidCallback onSuccess;

  const StakeDialog({
    super.key,
    required this.plan,
    required this.stakingService,
    required this.availableBalance,
    required this.onSuccess,
  });

  @override
  State<StakeDialog> createState() => _StakeDialogState();
}

class _StakeDialogState extends State<StakeDialog> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  double _amount = 0.0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Stake ${widget.plan.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount to Stake',
              suffixText: 'BLOCKVEST',
              helperText: 'Min: ${widget.plan.minAmount}, Max: ${widget.plan.maxAmount}',
            ),
            onChanged: (value) {
              setState(() {
                _amount = double.tryParse(value) ?? 0.0;
              });
            },
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Estimated Annual Rewards: ${(_amount * widget.plan.apy / 100).toStringAsFixed(2)} BLOCKVEST',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        BlockVestButton.primary(
          text: 'Stake',
          isLoading: _isLoading,
          onPressed: _amount >= widget.plan.minAmount && _amount <= widget.plan.maxAmount
              ? _handleStake
              : null,
        ),
      ],
    );
  }

  void _handleStake() async {
    setState(() => _isLoading = true);
    
    final result = await widget.stakingService.stakeTokens(
      planId: widget.plan.id,
      amount: _amount,
    );

    setState(() => _isLoading = false);

    if (result.success) {
      Navigator.of(context).pop();
      widget.onSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}
