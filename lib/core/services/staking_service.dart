import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'web3_service.dart';

class StakingService {
  static const String _stakingDataKey = 'staking_data';
  
  final Web3Service _web3Service;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  StakingService({required Web3Service web3Service}) : _web3Service = web3Service;

  /// Get available staking plans
  List<StakingPlan> getStakingPlans() {
    return [
      StakingPlan(
        id: 'plan_30',
        name: '30 Days Staking',
        durationDays: 30,
        apy: 8.0,
        minAmount: 100.0,
        maxAmount: 10000.0,
        description: 'Short-term staking with flexible withdrawal',
        features: ['Flexible withdrawal', 'Daily rewards', 'Low risk'],
      ),
      StakingPlan(
        id: 'plan_90',
        name: '90 Days Staking',
        durationDays: 90,
        apy: 12.0,
        minAmount: 500.0,
        maxAmount: 50000.0,
        description: 'Medium-term staking with higher rewards',
        features: ['Higher APY', 'Weekly rewards', 'Medium risk'],
      ),
      StakingPlan(
        id: 'plan_180',
        name: '180 Days Staking',
        durationDays: 180,
        apy: 18.0,
        minAmount: 1000.0,
        maxAmount: 100000.0,
        description: 'Long-term staking with premium rewards',
        features: ['Premium APY', 'Monthly rewards', 'Higher returns'],
      ),
      StakingPlan(
        id: 'plan_365',
        name: '1 Year Staking',
        durationDays: 365,
        apy: 25.0,
        minAmount: 2000.0,
        maxAmount: 500000.0,
        description: 'Maximum rewards for long-term commitment',
        features: ['Maximum APY', 'Quarterly rewards', 'Best returns'],
      ),
    ];
  }

  /// Stake BLOCKVEST tokens
  Future<StakingResult> stakeTokens({
    required String planId,
    required double amount,
  }) async {
    try {
      final plan = getStakingPlans().firstWhere((p) => p.id == planId);
      
      // Validate amount
      if (amount < plan.minAmount || amount > plan.maxAmount) {
        return StakingResult(
          success: false,
          message: 'Amount must be between ${plan.minAmount} and ${plan.maxAmount} BLOCKVEST',
        );
      }

      // Check balance
      final balance = await _web3Service.getBlockvestTokenBalance();
      if (balance < amount) {
        return StakingResult(
          success: false,
          message: 'Insufficient BLOCKVEST balance',
        );
      }

      // Execute staking transaction
      final txHash = await _web3Service.stakeTokens(
        amount: amount,
        stakingPeriodDays: plan.durationDays,
      );

      // Store staking data locally
      final stakingData = StakingData(
        id: _generateStakingId(),
        planId: planId,
        amount: amount,
        apy: plan.apy,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: plan.durationDays)),
        transactionHash: txHash,
        status: StakingStatus.active,
      );

      await _saveStakingData(stakingData);

      return StakingResult(
        success: true,
        message: 'Staking successful',
        transactionHash: txHash,
        stakingData: stakingData,
      );
    } catch (e) {
      return StakingResult(
        success: false,
        message: 'Staking failed: ${e.toString()}',
      );
    }
  }

  /// Get user's staking positions
  Future<List<StakingData>> getStakingPositions() async {
    try {
      final stakingInfo = await _web3Service.getStakingInfo();
      final storedData = await _getStoredStakingData();

      // Combine blockchain data with stored data
      final positions = <StakingData>[];
      
      // Add active staking from blockchain
      if (stakingInfo['stakedAmount'] > 0) {
        final plan = _getPlanByDuration(stakingInfo['stakingPeriod'] ?? 90);
        positions.add(StakingData(
          id: 'blockchain_stake',
          planId: plan.id,
          amount: stakingInfo['stakedAmount'],
          apy: plan.apy,
          startDate: DateTime.fromMillisecondsSinceEpoch(
            (stakingInfo['startTime'] ?? 0) * 1000,
          ),
          endDate: DateTime.fromMillisecondsSinceEpoch(
            (stakingInfo['startTime'] ?? 0) * 1000,
          ).add(Duration(days: stakingInfo['stakingPeriod'] ?? 90)),
          transactionHash: 'blockchain',
          status: StakingStatus.active,
          currentRewards: stakingInfo['rewards'],
        ));
      }

      // Add stored staking data
      positions.addAll(storedData);

      return positions;
    } catch (e) {
      return [];
    }
  }

  /// Calculate staking rewards
  double calculateRewards({
    required double amount,
    required double apy,
    required DateTime startDate,
    DateTime? endDate,
  }) {
    final now = DateTime.now();
    final calculationDate = endDate != null && endDate.isBefore(now) ? endDate : now;
    final stakingDays = calculationDate.difference(startDate).inDays;
    
    if (stakingDays <= 0) return 0.0;

    // Calculate daily rewards
    final dailyRate = apy / 365 / 100;
    final rewards = amount * dailyRate * stakingDays;
    
    return rewards;
  }

  /// Get total staking statistics
  Future<StakingStats> getStakingStats() async {
    try {
      final positions = await getStakingPositions();
      
      double totalStaked = 0.0;
      double totalRewards = 0.0;
      int activePositions = 0;

      for (final position in positions) {
        if (position.status == StakingStatus.active) {
          totalStaked += position.amount;
          activePositions++;
          
          final rewards = calculateRewards(
            amount: position.amount,
            apy: position.apy,
            startDate: position.startDate,
          );
          totalRewards += rewards;
        }
      }

      return StakingStats(
        totalStaked: totalStaked,
        totalRewards: totalRewards,
        activePositions: activePositions,
        averageApy: positions.isNotEmpty 
            ? positions.map((p) => p.apy).reduce((a, b) => a + b) / positions.length
            : 0.0,
      );
    } catch (e) {
      return StakingStats(
        totalStaked: 0.0,
        totalRewards: 0.0,
        activePositions: 0,
        averageApy: 0.0,
      );
    }
  }

  /// Unstake tokens (if allowed)
  Future<StakingResult> unstakeTokens(String stakingId) async {
    try {
      final positions = await getStakingPositions();
      final position = positions.firstWhere((p) => p.id == stakingId);
      
      // Check if unstaking is allowed
      if (position.endDate.isAfter(DateTime.now())) {
        return StakingResult(
          success: false,
          message: 'Staking period not completed. Early withdrawal may incur penalties.',
        );
      }

      // Execute unstaking (mock for development)
      await Future.delayed(const Duration(seconds: 2));
      
      // Update position status
      position.status = StakingStatus.completed;
      await _updateStakingData(position);

      return StakingResult(
        success: true,
        message: 'Unstaking successful',
        transactionHash: _generateMockTransactionHash(),
      );
    } catch (e) {
      return StakingResult(
        success: false,
        message: 'Unstaking failed: ${e.toString()}',
      );
    }
  }

  // Helper methods
  String _generateStakingId() {
    return 'stake_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  String _generateMockTransactionHash() {
    final random = Random();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return '0x${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
  }

  StakingPlan _getPlanByDuration(int days) {
    final plans = getStakingPlans();
    return plans.firstWhere(
      (plan) => plan.durationDays == days,
      orElse: () => plans[1], // Default to 90-day plan
    );
  }

  Future<void> _saveStakingData(StakingData data) async {
    final stored = await _getStoredStakingData();
    stored.add(data);
    
    final jsonList = stored.map((s) => s.toJson()).toList();
    await _secureStorage.write(key: _stakingDataKey, value: jsonList.toString());
  }

  Future<void> _updateStakingData(StakingData data) async {
    final stored = await _getStoredStakingData();
    final index = stored.indexWhere((s) => s.id == data.id);
    
    if (index != -1) {
      stored[index] = data;
      final jsonList = stored.map((s) => s.toJson()).toList();
      await _secureStorage.write(key: _stakingDataKey, value: jsonList.toString());
    }
  }

  Future<List<StakingData>> _getStoredStakingData() async {
    try {
      final stored = await _secureStorage.read(key: _stakingDataKey);
      if (stored != null) {
        // Parse stored data (simplified for demo)
        return [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

// Data classes
class StakingPlan {
  final String id;
  final String name;
  final int durationDays;
  final double apy;
  final double minAmount;
  final double maxAmount;
  final String description;
  final List<String> features;

  StakingPlan({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.apy,
    required this.minAmount,
    required this.maxAmount,
    required this.description,
    required this.features,
  });
}

class StakingData {
  final String id;
  final String planId;
  final double amount;
  final double apy;
  final DateTime startDate;
  final DateTime endDate;
  final String transactionHash;
  StakingStatus status;
  final double? currentRewards;

  StakingData({
    required this.id,
    required this.planId,
    required this.amount,
    required this.apy,
    required this.startDate,
    required this.endDate,
    required this.transactionHash,
    required this.status,
    this.currentRewards,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planId': planId,
      'amount': amount,
      'apy': apy,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'transactionHash': transactionHash,
      'status': status.toString(),
      'currentRewards': currentRewards,
    };
  }
}

class StakingResult {
  final bool success;
  final String message;
  final String? transactionHash;
  final StakingData? stakingData;

  StakingResult({
    required this.success,
    required this.message,
    this.transactionHash,
    this.stakingData,
  });
}

class StakingStats {
  final double totalStaked;
  final double totalRewards;
  final int activePositions;
  final double averageApy;

  StakingStats({
    required this.totalStaked,
    required this.totalRewards,
    required this.activePositions,
    required this.averageApy,
  });
}

enum StakingStatus { active, completed, cancelled }
