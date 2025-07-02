import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/staking_service.dart';
import '../../../../shared/widgets/blockvest_button.dart';

class StakingPlanCard extends StatelessWidget {
  final StakingPlan plan;
  final VoidCallback onStake;

  const StakingPlanCard({
    super.key,
    required this.plan,
    required this.onStake,
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
              Colors.white,
              AppTheme.primaryGreen.withOpacity(0.05),
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
                      color: _getPlanColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: Icon(
                      _getPlanIcon(),
                      color: _getPlanColor(),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: AppTheme.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          plan.description,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
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
                      '${plan.apy.toStringAsFixed(1)}% APY',
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingL),

              // Plan Details
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      'Duration',
                      '${plan.durationDays} days',
                      Icons.schedule,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      'Min Amount',
                      '${NumberFormat.compact().format(plan.minAmount)} BV',
                      Icons.trending_up,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      'Max Amount',
                      '${NumberFormat.compact().format(plan.maxAmount)} BV',
                      Icons.trending_down,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingL),

              // Features
              Text(
                'Features',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Wrap(
                spacing: AppTheme.spacingS,
                runSpacing: AppTheme.spacingS,
                children: plan.features.map((feature) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
                    border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    feature,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: AppTheme.spacingL),

              // Stake Button
              BlockVestButton.primary(
                text: 'Stake Now',
                onPressed: onStake,
                isFullWidth: true,
                icon: Icons.add_circle_outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryGreen,
          size: 20,
        ),
        const SizedBox(height: AppTheme.spacingXS),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getPlanColor() {
    switch (plan.durationDays) {
      case 30:
        return AppTheme.accentGreen;
      case 90:
        return AppTheme.primaryGreen;
      case 180:
        return AppTheme.secondaryGold;
      case 365:
        return AppTheme.errorColor;
      default:
        return AppTheme.primaryGreen;
    }
  }

  IconData _getPlanIcon() {
    switch (plan.durationDays) {
      case 30:
        return Icons.flash_on;
      case 90:
        return Icons.trending_up;
      case 180:
        return Icons.star;
      case 365:
        return Icons.diamond;
      default:
        return Icons.account_balance_wallet;
    }
  }
}
