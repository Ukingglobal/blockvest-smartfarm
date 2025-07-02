import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/portfolio_service.dart';
import '../../domain/entities/wallet.dart';

class EnhancedPortfolioOverview extends StatefulWidget {
  final Wallet wallet;

  const EnhancedPortfolioOverview({super.key, required this.wallet});

  @override
  State<EnhancedPortfolioOverview> createState() => _EnhancedPortfolioOverviewState();
}

class _EnhancedPortfolioOverviewState extends State<EnhancedPortfolioOverview> {
  final PortfolioService _portfolioService = PortfolioService();
  Map<String, dynamic>? _portfolioData;
  Map<String, dynamic>? _insights;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPortfolioData();
  }

  Future<void> _loadPortfolioData() async {
    try {
      final portfolioData = await _portfolioService.calculatePortfolioPerformance(
        widget.wallet.investments,
      );
      final insights = await _portfolioService.generateInvestmentInsights(
        widget.wallet.investments,
      );

      setState(() {
        _portfolioData = portfolioData;
        _insights = insights;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (widget.wallet.investments.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadPortfolioData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPortfolioSummary(),
            const SizedBox(height: 16),
            _buildPerformanceMetrics(),
            const SizedBox(height: 16),
            _buildInsightsCard(),
            const SizedBox(height: 16),
            _buildInvestmentsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No investments yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
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
              // Navigate to marketplace
            },
            child: const Text('Explore Projects'),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSummary() {
    final data = _portfolioData!;
    final totalInvested = data['totalInvested'] as double;
    final currentValue = data['currentValue'] as double;
    final totalProfitLoss = data['totalProfitLoss'] as double;
    final profitLossPercentage = data['profitLossPercentage'] as double;
    final isProfit = totalProfitLoss >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isProfit 
              ? [Colors.green[400]!, Colors.green[600]!]
              : [Colors.red[400]!, Colors.red[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isProfit ? Colors.green : Colors.red).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Portfolio Value',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                isProfit ? Icons.trending_up : Icons.trending_down,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(symbol: '₦').format(currentValue),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${isProfit ? '+' : ''}${NumberFormat.currency(symbol: '₦').format(totalProfitLoss)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${isProfit ? '+' : ''}${profitLossPercentage.toStringAsFixed(2)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Invested',
                  NumberFormat.currency(symbol: '₦').format(totalInvested),
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Daily Change',
                  '${(data['dailyChangePercentage'] as double) >= 0 ? '+' : ''}${(data['dailyChangePercentage'] as double).toStringAsFixed(2)}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetrics() {
    final data = _portfolioData!;
    final bestPerformer = data['bestPerformer'] as Investment?;
    final worstPerformer = data['worstPerformer'] as Investment?;

    return Row(
      children: [
        if (bestPerformer != null)
          Expanded(
            child: _buildPerformanceCard(
              'Best Performer',
              bestPerformer.projectName,
              ((bestPerformer.currentValue - bestPerformer.amount) / bestPerformer.amount * 100),
              Colors.green,
              Icons.trending_up,
            ),
          ),
        if (bestPerformer != null && worstPerformer != null)
          const SizedBox(width: 12),
        if (worstPerformer != null)
          Expanded(
            child: _buildPerformanceCard(
              'Needs Attention',
              worstPerformer.projectName,
              ((worstPerformer.currentValue - worstPerformer.amount) / worstPerformer.amount * 100),
              Colors.orange,
              Icons.trending_down,
            ),
          ),
      ],
    );
  }

  Widget _buildPerformanceCard(
    String title,
    String projectName,
    double percentage,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
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
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            projectName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage >= 0 ? '+' : ''}${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard() {
    if (_insights == null) return const SizedBox.shrink();

    final insights = _insights!['insights'] as List<String>;
    final recommendations = _insights!['recommendations'] as List<String>;

    if (insights.isEmpty && recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Portfolio Insights',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (insights.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $insight',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 14,
                ),
              ),
            )),
          ],
          if (recommendations.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Recommendations:',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            ...recommendations.map((recommendation) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $recommendation',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontSize: 13,
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildInvestmentsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Investments',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.wallet.investments.map(
          (investment) => _buildInvestmentCard(investment),
        ),
      ],
    );
  }

  Widget _buildInvestmentCard(Investment investment) {
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
                  NumberFormat.currency(symbol: '₦').format(investment.currentValue),
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
