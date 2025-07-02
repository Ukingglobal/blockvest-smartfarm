import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/staking_service.dart';

class StakingStatsCard extends StatelessWidget {
  final StakingStats stats;

  const StakingStatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
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
              AppTheme.primaryGreen,
              AppTheme.primaryGreen.withOpacity(0.8),
            ],
          ),
        ),
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Staking Statistics',
                        style: AppTheme.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Your staking performance overview',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Staked',
                    '${NumberFormat.compact().format(stats.totalStaked)} BV',
                    Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: _buildStatItem(
                    'Total Rewards',
                    '${NumberFormat.compact().format(stats.totalRewards)} BV',
                    Icons.trending_up,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Active Positions',
                    stats.activePositions.toString(),
                    Icons.play_circle_outline,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: _buildStatItem(
                    'Average APY',
                    '${stats.averageApy.toStringAsFixed(1)}%',
                    Icons.percent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Performance Indicator
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: AppTheme.secondaryGold,
                    size: 24,
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance Rating',
                          style: AppTheme.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _getPerformanceRating(),
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.secondaryGold,
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
                      _getPerformanceScore(),
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            value,
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getPerformanceRating() {
    if (stats.totalStaked >= 10000) {
      return 'Platinum Staker';
    } else if (stats.totalStaked >= 5000) {
      return 'Gold Staker';
    } else if (stats.totalStaked >= 1000) {
      return 'Silver Staker';
    } else if (stats.totalStaked > 0) {
      return 'Bronze Staker';
    } else {
      return 'New Staker';
    }
  }

  String _getPerformanceScore() {
    if (stats.totalStaked >= 10000) {
      return 'A+';
    } else if (stats.totalStaked >= 5000) {
      return 'A';
    } else if (stats.totalStaked >= 1000) {
      return 'B+';
    } else if (stats.totalStaked > 0) {
      return 'B';
    } else {
      return 'C';
    }
  }
}
