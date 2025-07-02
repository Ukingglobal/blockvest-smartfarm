import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'web3_service.dart';

class BlockchainExplorerService {
  static const String _rpcUrl = 'https://rpc-testnet.supra.com';
  static const int _chainId = 6;

  late Web3Client _client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Cache for blockchain data
  final Map<String, dynamic> _blockCache = {};
  final Map<String, dynamic> _transactionCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 10);

  // Network statistics
  Map<String, dynamic> _networkStats = {};
  DateTime? _lastStatsUpdate;
  static const Duration _statsUpdateInterval = Duration(minutes: 5);

  BlockchainExplorerService() {
    _client = Web3Client(_rpcUrl, http.Client());
  }

  /// Initialize the blockchain explorer service
  Future<void> initialize() async {
    try {
      // Test connection to the network
      await _client.getBlockNumber();

      // Load cached network stats
      await _loadCachedNetworkStats();
    } catch (e) {
      throw NetworkException('Failed to initialize blockchain explorer: $e');
    }
  }

  /// Get current network statistics
  Future<Map<String, dynamic>> getNetworkStatistics() async {
    try {
      final now = DateTime.now();

      // Check if we need to refresh stats
      if (_lastStatsUpdate == null ||
          now.difference(_lastStatsUpdate!) > _statsUpdateInterval) {
        await _refreshNetworkStats();
      }

      return Map<String, dynamic>.from(_networkStats);
    } catch (e) {
      // Return cached stats or defaults if refresh fails
      return _networkStats.isNotEmpty
          ? _networkStats
          : _getDefaultNetworkStats();
    }
  }

  /// Refresh network statistics from blockchain
  Future<void> _refreshNetworkStats() async {
    try {
      final blockNumber = await _client.getBlockNumber();

      // Calculate network statistics using mock data for now
      // TODO: Update when Supra blockchain API is fully integrated
      final stats = {
        'currentBlockNumber': blockNumber,
        'blockTime': DateTime.now().millisecondsSinceEpoch,
        'networkHashRate': _calculateMockHashRate(),
        'totalTransactions': _calculateMockTotalTransactions(blockNumber),
        'averageBlockTime': 12.5, // Supra average block time
        'networkDifficulty': _calculateMockDifficulty(),
        'activeNodes': _calculateMockActiveNodes(),
        'lastUpdate': DateTime.now().toIso8601String(),
      };

      _networkStats = stats;
      _lastStatsUpdate = DateTime.now();

      // Cache the stats
      await _secureStorage.write(
        key: 'network_stats',
        value: json.encode(stats),
      );
    } catch (e) {
      // Use mock data if real data fails
      _networkStats = _getDefaultNetworkStats();
    }
  }

  /// Get block information by block number
  Future<Map<String, dynamic>> getBlockInfo(int blockNumber) async {
    try {
      final cacheKey = 'block_$blockNumber';

      // Check cache first
      if (_blockCache.containsKey(cacheKey) && _isCacheValid(cacheKey)) {
        return _blockCache[cacheKey];
      }

      // Generate mock block data for now
      // TODO: Update when Supra blockchain API is fully integrated
      final blockData = {
        'number': blockNumber,
        'hash': '0x${_generateMockHash()}',
        'parentHash': '0x${_generateMockHash()}',
        'timestamp': DateTime.now()
            .subtract(
              Duration(
                seconds:
                    (DateTime.now().millisecondsSinceEpoch ~/ 1000) -
                    blockNumber * 12,
              ),
            )
            .millisecondsSinceEpoch,
        'gasLimit': 30000000,
        'gasUsed': 15000000 + (blockNumber % 10000000),
        'transactionCount': 50 + (blockNumber % 200),
        'transactions': List.generate(
          50 + (blockNumber % 200),
          (i) => '0x${_generateMockHash()}',
        ),
        'miner': '0x${_generateMockHash().substring(0, 40)}',
        'difficulty': _calculateMockDifficulty(),
        'size': _calculateMockBlockSize(50 + (blockNumber % 200)),
      };

      // Cache the result
      _blockCache[cacheKey] = blockData;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return blockData;
    } catch (e) {
      throw Web3Exception('Failed to get block info: $e');
    }
  }

  /// Get transaction details by hash
  Future<Map<String, dynamic>> getTransactionDetails(
    String transactionHash,
  ) async {
    try {
      final cacheKey = 'tx_$transactionHash';

      // Check cache first
      if (_transactionCache.containsKey(cacheKey) && _isCacheValid(cacheKey)) {
        return _transactionCache[cacheKey];
      }

      // Generate mock transaction data for now
      // TODO: Update when Supra blockchain API is fully integrated
      final random = Random();
      final txData = {
        'hash': transactionHash,
        'blockNumber': 1000000 + random.nextInt(100000),
        'blockHash': '0x${_generateMockHash()}',
        'from': '0x${_generateMockHash().substring(0, 40)}',
        'to': '0x${_generateMockHash().substring(0, 40)}',
        'value': random.nextDouble() * 10,
        'gasPrice': 20 + random.nextInt(100),
        'gasLimit': 21000 + random.nextInt(200000),
        'gasUsed': 21000 + random.nextInt(100000),
        'status': random.nextBool(),
        'nonce': random.nextInt(1000),
        'input': '0x${_generateMockHash().substring(0, 20)}',
        'timestamp': DateTime.now()
            .subtract(Duration(hours: random.nextInt(24)))
            .millisecondsSinceEpoch,
        'confirmations': random.nextInt(100) + 1,
      };

      // Cache the result
      _transactionCache[cacheKey] = txData;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return txData;
    } catch (e) {
      throw Web3Exception('Failed to get transaction details: $e');
    }
  }

  /// Get recent blocks
  Future<List<Map<String, dynamic>>> getRecentBlocks({int count = 10}) async {
    try {
      final currentBlock = await _client.getBlockNumber();
      final blocks = <Map<String, dynamic>>[];

      for (int i = 0; i < count; i++) {
        final blockNumber = currentBlock - i;
        if (blockNumber >= 0) {
          try {
            final blockInfo = await getBlockInfo(blockNumber);
            blocks.add(blockInfo);
          } catch (e) {
            // Skip failed blocks
            continue;
          }
        }
      }

      return blocks;
    } catch (e) {
      return [];
    }
  }

  /// Search transactions by address
  Future<List<Map<String, dynamic>>> searchTransactionsByAddress(
    String address, {
    int limit = 20,
  }) async {
    try {
      // In production, this would query an indexer or scan recent blocks
      // For now, return mock transaction data
      return _generateMockTransactionHistory(address, limit);
    } catch (e) {
      return [];
    }
  }

  /// Get contract interaction history
  Future<List<Map<String, dynamic>>> getContractInteractions(
    String contractAddress, {
    int limit = 20,
  }) async {
    try {
      // In production, this would parse contract events and transactions
      // For now, return mock contract interaction data
      return _generateMockContractInteractions(contractAddress, limit);
    } catch (e) {
      return [];
    }
  }

  /// Helper methods for mock data generation
  Map<String, dynamic> _getDefaultNetworkStats() {
    return {
      'currentBlockNumber': 1000000,
      'blockTime': DateTime.now().millisecondsSinceEpoch,
      'networkHashRate': '125.5 TH/s',
      'totalTransactions': 15000000,
      'averageBlockTime': 12.5,
      'networkDifficulty': '25.5T',
      'activeNodes': 1250,
      'lastUpdate': DateTime.now().toIso8601String(),
    };
  }

  String _calculateMockHashRate() {
    final random = Random();
    final hashRate = 120 + random.nextDouble() * 20;
    return '${hashRate.toStringAsFixed(1)} TH/s';
  }

  int _calculateMockTotalTransactions(int blockNumber) {
    return blockNumber * 15; // Approximate transactions per block
  }

  String _calculateMockDifficulty() {
    final random = Random();
    final difficulty = 25 + random.nextDouble() * 5;
    return '${difficulty.toStringAsFixed(1)}T';
  }

  int _calculateMockActiveNodes() {
    final random = Random();
    return 1200 + random.nextInt(100);
  }

  int _calculateMockBlockSize(int transactionCount) {
    return transactionCount * 250; // Approximate bytes per transaction
  }

  Future<int> _calculateConfirmations(int blockNumber) async {
    try {
      final currentBlock = await _client.getBlockNumber();
      return currentBlock - blockNumber;
    } catch (e) {
      return 0;
    }
  }

  bool _isCacheValid(String cacheKey) {
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  Future<void> _loadCachedNetworkStats() async {
    try {
      final cachedStats = await _secureStorage.read(key: 'network_stats');
      if (cachedStats != null) {
        _networkStats = json.decode(cachedStats);
        _lastStatsUpdate = DateTime.parse(_networkStats['lastUpdate']);
      }
    } catch (e) {
      // Ignore cache loading errors
    }
  }

  List<Map<String, dynamic>> _generateMockTransactionHistory(
    String address,
    int limit,
  ) {
    final random = Random();
    final transactions = <Map<String, dynamic>>[];

    for (int i = 0; i < limit; i++) {
      transactions.add({
        'hash':
            '0x${List.generate(64, (i) => random.nextInt(16).toRadixString(16)).join()}',
        'from': i % 2 == 0
            ? address
            : '0x${List.generate(40, (i) => random.nextInt(16).toRadixString(16)).join()}',
        'to': i % 2 == 1
            ? address
            : '0x${List.generate(40, (i) => random.nextInt(16).toRadixString(16)).join()}',
        'value': random.nextDouble() * 10,
        'timestamp': DateTime.now()
            .subtract(Duration(hours: i))
            .millisecondsSinceEpoch,
        'status': random.nextBool(),
        'gasUsed': 21000 + random.nextInt(100000),
      });
    }

    return transactions;
  }

  List<Map<String, dynamic>> _generateMockContractInteractions(
    String contractAddress,
    int limit,
  ) {
    final random = Random();
    final interactions = <Map<String, dynamic>>[];
    final methods = [
      'invest',
      'withdraw',
      'distributeProfits',
      'updateProject',
    ];

    for (int i = 0; i < limit; i++) {
      interactions.add({
        'hash':
            '0x${List.generate(64, (i) => random.nextInt(16).toRadixString(16)).join()}',
        'method': methods[random.nextInt(methods.length)],
        'from':
            '0x${List.generate(40, (i) => random.nextInt(16).toRadixString(16)).join()}',
        'value': random.nextDouble() * 5,
        'timestamp': DateTime.now()
            .subtract(Duration(hours: i))
            .millisecondsSinceEpoch,
        'status': random.nextBool(),
        'gasUsed': 50000 + random.nextInt(200000),
      });
    }

    return interactions;
  }

  String _generateMockHash() {
    final random = Random();
    return List.generate(
      64,
      (i) => random.nextInt(16).toRadixString(16),
    ).join();
  }

  void dispose() {
    _client.dispose();
  }
}
