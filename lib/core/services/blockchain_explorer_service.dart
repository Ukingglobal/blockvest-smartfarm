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
      return _networkStats.isNotEmpty ? _networkStats : _getDefaultNetworkStats();
    }
  }

  /// Refresh network statistics from blockchain
  Future<void> _refreshNetworkStats() async {
    try {
      final blockNumber = await _client.getBlockNumber();
      final latestBlock = await _client.getBlockInformation(blockNumber: blockNumber);
      
      // Calculate network statistics
      final stats = {
        'currentBlockNumber': blockNumber,
        'blockTime': latestBlock.timestamp.millisecondsSinceEpoch,
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
      
      // Fetch from blockchain
      final blockInfo = await _client.getBlockInformation(blockNumber: blockNumber);
      
      final blockData = {
        'number': blockInfo.number,
        'hash': blockInfo.hash,
        'parentHash': blockInfo.parentHash,
        'timestamp': blockInfo.timestamp.millisecondsSinceEpoch,
        'gasLimit': blockInfo.gasLimit.toInt(),
        'gasUsed': blockInfo.gasUsed.toInt(),
        'transactionCount': blockInfo.transactions.length,
        'transactions': blockInfo.transactions.map((tx) => tx.hash).toList(),
        'miner': blockInfo.miner?.hex ?? 'Unknown',
        'difficulty': _calculateMockDifficulty(),
        'size': _calculateMockBlockSize(blockInfo.transactions.length),
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
  Future<Map<String, dynamic>> getTransactionDetails(String transactionHash) async {
    try {
      final cacheKey = 'tx_$transactionHash';
      
      // Check cache first
      if (_transactionCache.containsKey(cacheKey) && _isCacheValid(cacheKey)) {
        return _transactionCache[cacheKey];
      }
      
      // Fetch transaction info
      final txInfo = await _client.getTransactionByHash(transactionHash);
      final txReceipt = await _client.getTransactionReceipt(transactionHash);
      
      if (txInfo == null) {
        throw Web3Exception('Transaction not found: $transactionHash');
      }
      
      final txData = {
        'hash': txInfo.hash,
        'blockNumber': txInfo.blockNumber?.blockNum ?? 0,
        'blockHash': txInfo.blockHash ?? '',
        'from': txInfo.from.hex,
        'to': txInfo.to?.hex ?? '',
        'value': txInfo.value.getValueInUnit(EtherUnit.ether),
        'gasPrice': txInfo.gasPrice?.getValueInUnit(EtherUnit.gwei) ?? 0,
        'gasLimit': txInfo.gas ?? 0,
        'gasUsed': txReceipt?.gasUsed?.toInt() ?? 0,
        'status': txReceipt?.status ?? false,
        'nonce': txInfo.nonce ?? 0,
        'input': txInfo.data,
        'timestamp': DateTime.now().millisecondsSinceEpoch, // Would get from block
        'confirmations': await _calculateConfirmations(txInfo.blockNumber?.blockNum ?? 0),
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

  List<Map<String, dynamic>> _generateMockTransactionHistory(String address, int limit) {
    final random = Random();
    final transactions = <Map<String, dynamic>>[];
    
    for (int i = 0; i < limit; i++) {
      transactions.add({
        'hash': '0x${List.generate(64, (i) => random.nextInt(16).toRadixString(16)).join()}',
        'from': i % 2 == 0 ? address : '0x${List.generate(40, (i) => random.nextInt(16).toRadixString(16)).join()}',
        'to': i % 2 == 1 ? address : '0x${List.generate(40, (i) => random.nextInt(16).toRadixString(16)).join()}',
        'value': random.nextDouble() * 10,
        'timestamp': DateTime.now().subtract(Duration(hours: i)).millisecondsSinceEpoch,
        'status': random.nextBool(),
        'gasUsed': 21000 + random.nextInt(100000),
      });
    }
    
    return transactions;
  }

  List<Map<String, dynamic>> _generateMockContractInteractions(String contractAddress, int limit) {
    final random = Random();
    final interactions = <Map<String, dynamic>>[];
    final methods = ['invest', 'withdraw', 'distributeProfits', 'updateProject'];
    
    for (int i = 0; i < limit; i++) {
      interactions.add({
        'hash': '0x${List.generate(64, (i) => random.nextInt(16).toRadixString(16)).join()}',
        'method': methods[random.nextInt(methods.length)],
        'from': '0x${List.generate(40, (i) => random.nextInt(16).toRadixString(16)).join()}',
        'value': random.nextDouble() * 5,
        'timestamp': DateTime.now().subtract(Duration(hours: i)).millisecondsSinceEpoch,
        'status': random.nextBool(),
        'gasUsed': 50000 + random.nextInt(200000),
      });
    }
    
    return interactions;
  }

  void dispose() {
    _client.dispose();
  }
}
