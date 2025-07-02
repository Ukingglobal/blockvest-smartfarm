import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/staking_service.dart';
import '../../../../shared/widgets/blockvest_button.dart';

class StakingPositionCard extends StatelessWidget {
  final StakingData position;
  final StakingService stakingService;
  final VoidCallback onUnstake;

  const StakingPositionCard({
    super.key,
    required this.position,
    required this.stakingService,
    required this.onUnstake,
  });

  @override
  Widget build(BuildContext context) {
    final currentRewards = stakingService.calculateRewards(
      amount: position.amount,
      apy: position.apy,
      startDate: position.startDate,
    );

    final progress = _calculateProgress();
    final daysRemaining = position.endDate.difference(DateTime.now()).inDays;
    final isMatured = DateTime.now().isAfter(position.endDate);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              _getStatusColor().withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingS),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      color: _getStatusColor(),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Staking Position',
                          style: AppTheme.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getStatusText(),
                          style: AppTheme.bodyMedium.copyWith(
                            color: _getStatusColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingM,
                      vertical: AppTheme.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryGold,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
                    ),
                    child: Text(
                      '${position.apy.toStringAsFixed(1)}% APY',
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingL),

              // Amount and Rewards
              Row(
                children: [
                  Expanded(
                    child: _buildAmountCard(
                      'Staked Amount',
                      '${NumberFormat.compact().format(position.amount)} BLOCKVEST',
                      Icons.account_balance_wallet,
                      AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _buildAmountCard(
                      'Current Rewards',
                      '${NumberFormat.compact().format(currentRewards)} BLOCKVEST',
                      Icons.trending_up,
                      AppTheme.successColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingL),

              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Staking Progress',
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        isMatured 
                            ? 'Matured'
                            : '$daysRemaining days remaining',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.dividerColor,
                    valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
                    minHeight: 8,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMM dd, yyyy').format(position.startDate),
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(position.endDate),
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingL),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: BlockVestButton.outline(
                      text: 'View Details',
                      onPressed: () => _showDetailsDialog(context),
                      icon: Icons.info_outline,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: BlockVestButton.primary(
                      text: isMatured ? 'Claim Rewards' : 'Unstake',
                      onPressed: onUnstake,
                      icon: isMatured ? Icons.redeem : Icons.remove_circle_outline,
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

  Widget _buildAmountCard(String label, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            amount,
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  double _calculateProgress() {
    final totalDuration = position.endDate.difference(position.startDate).inDays;
    final elapsed = DateTime.now().difference(position.startDate).inDays;
    
    if (elapsed <= 0) return 0.0;
    if (elapsed >= totalDuration) return 1.0;
    
    return elapsed / totalDuration;
  }

  Color _getStatusColor() {
    switch (position.status) {
      case StakingStatus.active:
        return DateTime.now().isAfter(position.endDate) 
            ? AppTheme.secondaryGold 
            : AppTheme.primaryGreen;
      case StakingStatus.completed:
        return AppTheme.successColor;
      case StakingStatus.cancelled:
        return AppTheme.errorColor;
    }
  }

  IconData _getStatusIcon() {
    switch (position.status) {
      case StakingStatus.active:
        return DateTime.now().isAfter(position.endDate) 
            ? Icons.star 
            : Icons.play_circle_outline;
      case StakingStatus.completed:
        return Icons.check_circle;
      case StakingStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText() {
    switch (position.status) {
      case StakingStatus.active:
        return DateTime.now().isAfter(position.endDate) 
            ? 'Matured - Ready to Claim' 
            : 'Active Staking';
      case StakingStatus.completed:
        return 'Completed';
      case StakingStatus.cancelled:
        return 'Cancelled';
    }
  }

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Staking Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Staking ID', position.id),
            _buildDetailRow('Plan ID', position.planId),
            _buildDetailRow('Amount', '${NumberFormat.compact().format(position.amount)} BLOCKVEST'),
            _buildDetailRow('APY', '${position.apy.toStringAsFixed(1)}%'),
            _buildDetailRow('Start Date', DateFormat('MMM dd, yyyy HH:mm').format(position.startDate)),
            _buildDetailRow('End Date', DateFormat('MMM dd, yyyy HH:mm').format(position.endDate)),
            _buildDetailRow('Transaction Hash', position.transactionHash),
            _buildDetailRow('Status', _getStatusText()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
