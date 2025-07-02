import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/wallet/domain/entities/wallet.dart';

class PortfolioService {
  static const String _portfolioKey = 'user_portfolio';
  static const String _investmentHistoryKey = 'investment_history';
  static const String _profitLossKey = 'profit_loss_data';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Calculate real-time portfolio performance
  Future<Map<String, dynamic>> calculatePortfolioPerformance(
    List<Investment> investments,
  ) async {
    if (investments.isEmpty) {
      return {
        'totalInvested': 0.0,
        'currentValue': 0.0,
        'totalProfitLoss': 0.0,
        'profitLossPercentage': 0.0,
        'dailyChange': 0.0,
        'dailyChangePercentage': 0.0,
        'bestPerformer': null,
        'worstPerformer': null,
      };
    }

    double totalInvested = 0.0;
    double currentValue = 0.0;
    double dailyChange = 0.0;
    
    Investment? bestPerformer;
    Investment? worstPerformer;
    double bestPerformance = double.negativeInfinity;
    double worstPerformance = double.infinity;

    for (final investment in investments) {
      totalInvested += investment.amount;
      
      // Simulate real-time value updates
      final updatedValue = await _calculateCurrentValue(investment);
      currentValue += updatedValue;
      
      // Calculate daily change (simulated)
      final dailyChangeForInvestment = await _calculateDailyChange(investment);
      dailyChange += dailyChangeForInvestment;
      
      // Track best and worst performers
      final performance = (updatedValue - investment.amount) / investment.amount;
      if (performance > bestPerformance) {
        bestPerformance = performance;
        bestPerformer = investment;
      }
      if (performance < worstPerformance) {
        worstPerformance = performance;
        worstPerformer = investment;
      }
    }

    final totalProfitLoss = currentValue - totalInvested;
    final profitLossPercentage = totalInvested > 0 
        ? (totalProfitLoss / totalInvested) * 100 
        : 0.0;
    final dailyChangePercentage = totalInvested > 0 
        ? (dailyChange / totalInvested) * 100 
        : 0.0;

    return {
      'totalInvested': totalInvested,
      'currentValue': currentValue,
      'totalProfitLoss': totalProfitLoss,
      'profitLossPercentage': profitLossPercentage,
      'dailyChange': dailyChange,
      'dailyChangePercentage': dailyChangePercentage,
      'bestPerformer': bestPerformer,
      'worstPerformer': worstPerformer,
    };
  }

  /// Calculate current value of an investment with market simulation
  Future<double> _calculateCurrentValue(Investment investment) async {
    try {
      // Simulate market fluctuations based on project type and time
      final daysSinceInvestment = DateTime.now().difference(investment.investmentDate).inDays;
      final random = Random();
      
      // Base growth rate (annual)
      double baseGrowthRate = investment.expectedReturn;
      
      // Add market volatility
      final volatility = 0.02; // 2% daily volatility
      final dailyChange = (random.nextDouble() - 0.5) * 2 * volatility;
      
      // Calculate compound growth with volatility
      final dailyGrowthRate = baseGrowthRate / 365;
      final growthFactor = pow(1 + dailyGrowthRate + dailyChange, daysSinceInvestment);
      
      return investment.amount * growthFactor;
    } catch (e) {
      return investment.currentValue; // Fallback to stored value
    }
  }

  /// Calculate daily change for an investment
  Future<double> _calculateDailyChange(Investment investment) async {
    try {
      final random = Random();
      final volatility = 0.015; // 1.5% daily volatility
      final dailyChangePercentage = (random.nextDouble() - 0.5) * 2 * volatility;
      
      return investment.currentValue * dailyChangePercentage;
    } catch (e) {
      return 0.0;
    }
  }

  /// Store investment performance data
  Future<void> storeInvestmentPerformance({
    required String investmentId,
    required double currentValue,
    required double profitLoss,
    required DateTime timestamp,
  }) async {
    try {
      final performanceData = {
        'investmentId': investmentId,
        'currentValue': currentValue,
        'profitLoss': profitLoss,
        'timestamp': timestamp.toIso8601String(),
      };

      final existingData = await _secureStorage.read(key: _profitLossKey) ?? '[]';
      final List<dynamic> performanceHistory = json.decode(existingData);
      
      performanceHistory.add(performanceData);
      
      // Keep only last 30 days of data
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      performanceHistory.removeWhere((data) {
        final timestamp = DateTime.parse(data['timestamp']);
        return timestamp.isBefore(thirtyDaysAgo);
      });

      await _secureStorage.write(
        key: _profitLossKey,
        value: json.encode(performanceHistory),
      );
    } catch (e) {
      // Non-critical error
    }
  }

  /// Get historical performance data for charts
  Future<List<Map<String, dynamic>>> getPerformanceHistory({
    String? investmentId,
    int days = 30,
  }) async {
    try {
      final existingData = await _secureStorage.read(key: _profitLossKey) ?? '[]';
      final List<dynamic> performanceHistory = json.decode(existingData);
      
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      
      return performanceHistory
          .where((data) {
            final timestamp = DateTime.parse(data['timestamp']);
            final matchesInvestment = investmentId == null || 
                data['investmentId'] == investmentId;
            return timestamp.isAfter(cutoffDate) && matchesInvestment;
          })
          .map((data) => Map<String, dynamic>.from(data))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Calculate investment risk metrics
  Future<Map<String, dynamic>> calculateRiskMetrics(
    List<Investment> investments,
  ) async {
    if (investments.isEmpty) {
      return {
        'portfolioRisk': 'Low',
        'diversificationScore': 0.0,
        'volatilityScore': 0.0,
        'recommendations': <String>[],
      };
    }

    // Calculate diversification score
    final projectTypes = investments.map((i) => i.projectName.split(' ').first).toSet();
    final diversificationScore = (projectTypes.length / investments.length) * 100;
    
    // Calculate volatility score based on performance variance
    final performanceVariance = await _calculatePerformanceVariance(investments);
    
    // Determine overall risk level
    String portfolioRisk;
    if (diversificationScore > 70 && performanceVariance < 0.1) {
      portfolioRisk = 'Low';
    } else if (diversificationScore > 50 && performanceVariance < 0.2) {
      portfolioRisk = 'Medium';
    } else {
      portfolioRisk = 'High';
    }

    // Generate recommendations
    final recommendations = <String>[];
    if (diversificationScore < 50) {
      recommendations.add('Consider diversifying across different project types');
    }
    if (performanceVariance > 0.2) {
      recommendations.add('High volatility detected - consider more stable investments');
    }
    if (investments.length < 3) {
      recommendations.add('Increase portfolio size for better risk distribution');
    }

    return {
      'portfolioRisk': portfolioRisk,
      'diversificationScore': diversificationScore,
      'volatilityScore': performanceVariance * 100,
      'recommendations': recommendations,
    };
  }

  Future<double> _calculatePerformanceVariance(List<Investment> investments) async {
    if (investments.length < 2) return 0.0;

    final performances = investments.map((investment) {
      return (investment.currentValue - investment.amount) / investment.amount;
    }).toList();

    final mean = performances.reduce((a, b) => a + b) / performances.length;
    final variance = performances
        .map((performance) => pow(performance - mean, 2))
        .reduce((a, b) => a + b) / performances.length;

    return variance;
  }

  /// Generate investment insights and recommendations
  Future<Map<String, dynamic>> generateInvestmentInsights(
    List<Investment> investments,
  ) async {
    final performance = await calculatePortfolioPerformance(investments);
    final riskMetrics = await calculateRiskMetrics(investments);
    
    final insights = <String>[];
    final recommendations = <String>[];

    // Performance insights
    if (performance['profitLossPercentage'] > 10) {
      insights.add('Your portfolio is performing excellently with ${performance['profitLossPercentage'].toStringAsFixed(1)}% returns');
    } else if (performance['profitLossPercentage'] > 0) {
      insights.add('Your portfolio is showing positive returns of ${performance['profitLossPercentage'].toStringAsFixed(1)}%');
    } else {
      insights.add('Your portfolio is currently down ${performance['profitLossPercentage'].abs().toStringAsFixed(1)}%');
      recommendations.add('Consider reviewing your investment strategy');
    }

    // Daily change insights
    if (performance['dailyChangePercentage'].abs() > 2) {
      insights.add('Significant daily movement detected: ${performance['dailyChangePercentage'].toStringAsFixed(2)}%');
    }

    // Add risk-based recommendations
    recommendations.addAll(riskMetrics['recommendations']);

    return {
      'insights': insights,
      'recommendations': recommendations,
      'performance': performance,
      'riskMetrics': riskMetrics,
    };
  }
}
