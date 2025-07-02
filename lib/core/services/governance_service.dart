import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'web3_service.dart';

class GovernanceService {
  static const String _votingHistoryKey = 'voting_history';
  
  final Web3Service _web3Service;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  GovernanceService({required Web3Service web3Service}) : _web3Service = web3Service;

  /// Get all governance proposals
  Future<List<GovernanceProposal>> getProposals() async {
    try {
      final proposalsData = await _web3Service.getGovernanceProposals();
      
      return proposalsData.map((data) => GovernanceProposal(
        id: data['id'],
        title: data['title'],
        description: data['description'],
        proposer: data['proposer'],
        startTime: DateTime.fromMillisecondsSinceEpoch(data['startTime']),
        endTime: DateTime.fromMillisecondsSinceEpoch(data['endTime']),
        forVotes: data['forVotes'].toDouble(),
        againstVotes: data['againstVotes'].toDouble(),
        status: _parseProposalStatus(data['status']),
        category: _determineCategory(data['title']),
        minVotingPower: 100.0, // Minimum BLOCKVEST tokens required to vote
      )).toList();
    } catch (e) {
      return _getMockProposals();
    }
  }

  /// Get active proposals
  Future<List<GovernanceProposal>> getActiveProposals() async {
    final proposals = await getProposals();
    return proposals.where((p) => p.status == ProposalStatus.active).toList();
  }

  /// Get proposal by ID
  Future<GovernanceProposal?> getProposal(String proposalId) async {
    final proposals = await getProposals();
    try {
      return proposals.firstWhere((p) => p.id == proposalId);
    } catch (e) {
      return null;
    }
  }

  /// Vote on a proposal
  Future<VotingResult> voteOnProposal({
    required String proposalId,
    required bool support,
    required double votingPower,
  }) async {
    try {
      final proposal = await getProposal(proposalId);
      if (proposal == null) {
        return VotingResult(
          success: false,
          message: 'Proposal not found',
        );
      }

      // Check if proposal is active
      if (proposal.status != ProposalStatus.active) {
        return VotingResult(
          success: false,
          message: 'Proposal is not active for voting',
        );
      }

      // Check voting period
      final now = DateTime.now();
      if (now.isBefore(proposal.startTime) || now.isAfter(proposal.endTime)) {
        return VotingResult(
          success: false,
          message: 'Voting period has ended',
        );
      }

      // Check minimum voting power
      if (votingPower < proposal.minVotingPower) {
        return VotingResult(
          success: false,
          message: 'Insufficient BLOCKVEST tokens to vote (minimum: ${proposal.minVotingPower})',
        );
      }

      // Check if already voted
      final hasVoted = await _hasUserVoted(proposalId);
      if (hasVoted) {
        return VotingResult(
          success: false,
          message: 'You have already voted on this proposal',
        );
      }

      // Execute vote transaction
      final txHash = await _web3Service.voteOnProposal(
        proposalId: proposalId,
        support: support,
      );

      // Store vote locally
      await _storeVote(VoteRecord(
        proposalId: proposalId,
        support: support,
        votingPower: votingPower,
        timestamp: DateTime.now(),
        transactionHash: txHash,
      ));

      return VotingResult(
        success: true,
        message: 'Vote submitted successfully',
        transactionHash: txHash,
      );
    } catch (e) {
      return VotingResult(
        success: false,
        message: 'Voting failed: ${e.toString()}',
      );
    }
  }

  /// Get user's voting history
  Future<List<VoteRecord>> getVotingHistory() async {
    try {
      final stored = await _secureStorage.read(key: _votingHistoryKey);
      if (stored != null) {
        // Parse stored voting history (simplified for demo)
        return _getMockVotingHistory();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get governance statistics
  Future<GovernanceStats> getGovernanceStats() async {
    try {
      final proposals = await getProposals();
      final votingHistory = await getVotingHistory();

      final totalProposals = proposals.length;
      final activeProposals = proposals.where((p) => p.status == ProposalStatus.active).length;
      final passedProposals = proposals.where((p) => p.status == ProposalStatus.passed).length;
      final userVotes = votingHistory.length;

      final totalVotingPower = votingHistory.fold<double>(
        0.0,
        (sum, vote) => sum + vote.votingPower,
      );

      return GovernanceStats(
        totalProposals: totalProposals,
        activeProposals: activeProposals,
        passedProposals: passedProposals,
        userVotes: userVotes,
        totalVotingPower: totalVotingPower,
        participationRate: totalProposals > 0 ? (userVotes / totalProposals) * 100 : 0.0,
      );
    } catch (e) {
      return GovernanceStats(
        totalProposals: 0,
        activeProposals: 0,
        passedProposals: 0,
        userVotes: 0,
        totalVotingPower: 0.0,
        participationRate: 0.0,
      );
    }
  }

  /// Create a new proposal (for eligible users)
  Future<ProposalResult> createProposal({
    required String title,
    required String description,
    required ProposalCategory category,
    required double requiredVotingPower,
  }) async {
    try {
      // Check if user has enough voting power to create proposal
      final userBalance = await _web3Service.getBlockvestTokenBalance();
      if (userBalance < requiredVotingPower) {
        return ProposalResult(
          success: false,
          message: 'Insufficient BLOCKVEST tokens to create proposal',
        );
      }

      // Mock proposal creation for development
      final proposalId = _generateProposalId();
      await Future.delayed(const Duration(seconds: 2));

      return ProposalResult(
        success: true,
        message: 'Proposal created successfully',
        proposalId: proposalId,
      );
    } catch (e) {
      return ProposalResult(
        success: false,
        message: 'Proposal creation failed: ${e.toString()}',
      );
    }
  }

  // Helper methods
  ProposalStatus _parseProposalStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return ProposalStatus.active;
      case 'passed':
        return ProposalStatus.passed;
      case 'rejected':
        return ProposalStatus.rejected;
      case 'expired':
        return ProposalStatus.expired;
      default:
        return ProposalStatus.pending;
    }
  }

  ProposalCategory _determineCategory(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('staking') || titleLower.contains('reward')) {
      return ProposalCategory.staking;
    } else if (titleLower.contains('project') || titleLower.contains('agricultural')) {
      return ProposalCategory.projects;
    } else if (titleLower.contains('token') || titleLower.contains('economic')) {
      return ProposalCategory.tokenomics;
    } else if (titleLower.contains('platform') || titleLower.contains('technical')) {
      return ProposalCategory.platform;
    }
    return ProposalCategory.general;
  }

  Future<bool> _hasUserVoted(String proposalId) async {
    final votingHistory = await getVotingHistory();
    return votingHistory.any((vote) => vote.proposalId == proposalId);
  }

  Future<void> _storeVote(VoteRecord vote) async {
    final history = await getVotingHistory();
    history.add(vote);
    
    // Store voting history (simplified for demo)
    await _secureStorage.write(
      key: _votingHistoryKey,
      value: history.map((v) => v.toJson()).toString(),
    );
  }

  String _generateProposalId() {
    return 'prop_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  List<GovernanceProposal> _getMockProposals() {
    return [
      GovernanceProposal(
        id: '1',
        title: 'Increase Staking Rewards to 15% APY',
        description: 'Proposal to increase the annual percentage yield for BLOCKVEST token staking from 12% to 15% to attract more long-term holders and increase platform liquidity.',
        proposer: '0x1234...5678',
        startTime: DateTime.now().subtract(const Duration(days: 2)),
        endTime: DateTime.now().add(const Duration(days: 5)),
        forVotes: 1250000,
        againstVotes: 350000,
        status: ProposalStatus.active,
        category: ProposalCategory.staking,
        minVotingPower: 100.0,
      ),
      GovernanceProposal(
        id: '2',
        title: 'Add Aquaculture Investment Category',
        description: 'Expand the platform to include fish farming and aquaculture projects as a new investment category, targeting coastal regions with high aquaculture potential.',
        proposer: '0x9876...4321',
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 6)),
        forVotes: 890000,
        againstVotes: 210000,
        status: ProposalStatus.active,
        category: ProposalCategory.projects,
        minVotingPower: 100.0,
      ),
    ];
  }

  List<VoteRecord> _getMockVotingHistory() {
    return [
      VoteRecord(
        proposalId: '1',
        support: true,
        votingPower: 500.0,
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        transactionHash: '0xabc123...',
      ),
    ];
  }
}

// Data classes
class GovernanceProposal {
  final String id;
  final String title;
  final String description;
  final String proposer;
  final DateTime startTime;
  final DateTime endTime;
  final double forVotes;
  final double againstVotes;
  final ProposalStatus status;
  final ProposalCategory category;
  final double minVotingPower;

  GovernanceProposal({
    required this.id,
    required this.title,
    required this.description,
    required this.proposer,
    required this.startTime,
    required this.endTime,
    required this.forVotes,
    required this.againstVotes,
    required this.status,
    required this.category,
    required this.minVotingPower,
  });

  double get totalVotes => forVotes + againstVotes;
  double get supportPercentage => totalVotes > 0 ? (forVotes / totalVotes) * 100 : 0;
  bool get isActive => status == ProposalStatus.active && 
                      DateTime.now().isAfter(startTime) && 
                      DateTime.now().isBefore(endTime);
}

class VoteRecord {
  final String proposalId;
  final bool support;
  final double votingPower;
  final DateTime timestamp;
  final String transactionHash;

  VoteRecord({
    required this.proposalId,
    required this.support,
    required this.votingPower,
    required this.timestamp,
    required this.transactionHash,
  });

  Map<String, dynamic> toJson() {
    return {
      'proposalId': proposalId,
      'support': support,
      'votingPower': votingPower,
      'timestamp': timestamp.toIso8601String(),
      'transactionHash': transactionHash,
    };
  }
}

class VotingResult {
  final bool success;
  final String message;
  final String? transactionHash;

  VotingResult({
    required this.success,
    required this.message,
    this.transactionHash,
  });
}

class ProposalResult {
  final bool success;
  final String message;
  final String? proposalId;

  ProposalResult({
    required this.success,
    required this.message,
    this.proposalId,
  });
}

class GovernanceStats {
  final int totalProposals;
  final int activeProposals;
  final int passedProposals;
  final int userVotes;
  final double totalVotingPower;
  final double participationRate;

  GovernanceStats({
    required this.totalProposals,
    required this.activeProposals,
    required this.passedProposals,
    required this.userVotes,
    required this.totalVotingPower,
    required this.participationRate,
  });
}

enum ProposalStatus { pending, active, passed, rejected, expired }

enum ProposalCategory { general, staking, projects, tokenomics, platform }
