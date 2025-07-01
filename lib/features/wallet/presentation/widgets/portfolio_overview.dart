import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/wallet.dart';

class PortfolioOverview extends StatelessWidget {
  final Wallet wallet;

  const PortfolioOverview({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    final investments = wallet.investments;

    if (investments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No investments yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Start investing in agricultural projects to build your portfolio',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to marketplace
              },
              child: const Text('Explore Projects'),
            ),
          ],
        ),
      );
    }

    final totalInvested = investments.fold<double>(
      0,
      (sum, investment) => sum + investment.amount,
    );

    final totalCurrentValue = investments.fold<double>(
      0,
      (sum, investment) => sum + investment.currentValue,
    );

    final totalProfitLoss = totalCurrentValue - totalInvested;
    final profitLossPercentage = totalInvested > 0
        ? (totalProfitLoss / totalInvested) * 100
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPortfolioSummary(
          context,
          totalInvested,
          totalCurrentValue,
          totalProfitLoss,
          profitLossPercentage,
        ),
        const SizedBox(height: 24),
        Text(
          'Your Investments',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...investments.map(
          (investment) => _buildInvestmentCard(context, investment),
        ),
      ],
    );
  }

  Widget _buildPortfolioSummary(
    BuildContext context,
    double totalInvested,
    double totalCurrentValue,
    double totalProfitLoss,
    double profitLossPercentage,
  ) {
    final isProfit = totalProfitLoss >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Summary',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Invested',
                  NumberFormat.currency(symbol: '₦').format(totalInvested),
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  'Current Value',
                  NumberFormat.currency(symbol: '₦').format(totalCurrentValue),
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isProfit
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isProfit ? Icons.trending_up : Icons.trending_down,
                  color: isProfit ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total P&L',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        '${isProfit ? '+' : ''}${NumberFormat.currency(symbol: '₦').format(totalProfitLoss)}',
                        style: TextStyle(
                          color: isProfit ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isProfit ? '+' : ''}${profitLossPercentage.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: isProfit ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentCard(BuildContext context, Investment investment) {
    final profitLoss = investment.currentValue - investment.amount;
    final profitLossPercentage = investment.amount > 0
        ? (profitLoss / investment.amount) * 100
        : 0.0;
    final isProfit = profitLoss >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  investment.projectName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(investment.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  investment.status.name.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(investment.status),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInvestmentDetail(
                  'Invested',
                  NumberFormat.currency(symbol: '₦').format(investment.amount),
                ),
              ),
              Expanded(
                child: _buildInvestmentDetail(
                  'Current Value',
                  NumberFormat.currency(
                    symbol: '₦',
                  ).format(investment.currentValue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInvestmentDetail(
                  'Date',
                  DateFormat('MMM dd, yyyy').format(investment.investmentDate),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      isProfit ? Icons.trending_up : Icons.trending_down,
                      color: isProfit ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isProfit ? '+' : ''}${profitLossPercentage.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: isProfit ? Colors.green : Colors.red,
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
    );
  }

  Widget _buildInvestmentDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Color _getStatusColor(InvestmentStatus status) {
    switch (status) {
      case InvestmentStatus.active:
        return Colors.green;
      case InvestmentStatus.matured:
        return Colors.blue;
      case InvestmentStatus.withdrawn:
        return Colors.orange;
      case InvestmentStatus.defaulted:
        return Colors.red;
    }
  }
}
