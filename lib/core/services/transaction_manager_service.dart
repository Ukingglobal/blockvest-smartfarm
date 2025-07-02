import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart';
import 'web3_service.dart';
import 'blockchain_explorer_service.dart';

enum TransactionStatus {
  pending,
  confirmed,
  failed,
  cancelled,
  expired,
}

enum TransactionPriority {
  low,
  medium,
  high,
  urgent,
}

class TransactionManagerService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final BlockchainExplorerService _explorerService = BlockchainExplorerService();
  
  // Transaction tracking
  final Map<String, TransactionTracker> _activeTransactions = {};
  final List<Map<String, dynamic>> _transactionHistory = [];
  
  // Status monitoring
  Timer? _statusMonitorTimer;
  static const Duration _monitoringInterval = Duration(seconds: 30);
  
  // Receipt generation
  static const String _receiptStorageKey = 'transaction_receipts';

  /// Initialize the transaction manager
  Future<void> initialize() async {
    try {
      await _explorerService.initialize();
      await _loadTransactionHistory();
      _startStatusMonitoring();
    } catch (e) {
      throw Web3Exception('Failed to initialize transaction manager: $e');
    }
  }

  /// Submit a new transaction for tracking
  Future<String> submitTransaction({
    required String transactionHash,
    required String type,
    required double amount,
    required String fromAddress,
    required String toAddress,
    String? projectId,
    String? projectName,
    TransactionPriority priority = TransactionPriority.medium,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final tracker = TransactionTracker(
        hash: transactionHash,
        type: type,
        amount: amount,
        fromAddress: fromAddress,
        toAddress: toAddress,
        projectId: projectId,
        projectName: projectName,
        priority: priority,
        metadata: metadata ?? {},
        submittedAt: DateTime.now(),
      );
      
      _activeTransactions[transactionHash] = tracker;
      
      // Add to history
      await _addToHistory(tracker.toMap());
      
      // Start monitoring this transaction
      _monitorTransaction(transactionHash);
      
      return transactionHash;
    } catch (e) {
      throw TransactionException('Failed to submit transaction: $e');
    }
  }

  /// Get transaction status
  Future<Map<String, dynamic>> getTransactionStatus(String transactionHash) async {
    try {
      final tracker = _activeTransactions[transactionHash];
      if (tracker == null) {
        // Check if it's in history
        final historyItem = _transactionHistory.firstWhere(
          (tx) => tx['hash'] == transactionHash,
          orElse: () => {},
        );
        
        if (historyItem.isNotEmpty) {
          return {
            'status': historyItem['status'],
            'hash': transactionHash,
            'timestamp': historyItem['timestamp'],
            'confirmations': historyItem['confirmations'] ?? 0,
          };
        }
        
        throw TransactionException('Transaction not found: $transactionHash');
      }
      
      // Get latest status from blockchain
      try {
        final blockchainStatus = await _explorerService.getTransactionDetails(transactionHash);
        tracker.updateFromBlockchain(blockchainStatus);
      } catch (e) {
        // Continue with cached status if blockchain query fails
      }
      
      return tracker.getStatusInfo();
    } catch (e) {
      throw TransactionException('Failed to get transaction status: $e');
    }
  }

  /// Generate transaction receipt
  Future<Map<String, dynamic>> generateReceipt(String transactionHash) async {
    try {
      final status = await getTransactionStatus(transactionHash);
      final blockchainDetails = await _explorerService.getTransactionDetails(transactionHash);
      
      final receipt = {
        'receiptId': _generateReceiptId(),
        'transactionHash': transactionHash,
        'timestamp': DateTime.now().toIso8601String(),
        'status': status['status'],
        'amount': status['amount'],
        'fromAddress': status['fromAddress'],
        'toAddress': status['toAddress'],
        'gasUsed': blockchainDetails['gasUsed'],
        'gasPrice': blockchainDetails['gasPrice'],
        'totalFee': (blockchainDetails['gasUsed'] * blockchainDetails['gasPrice']).toDouble(),
        'blockNumber': blockchainDetails['blockNumber'],
        'confirmations': blockchainDetails['confirmations'],
        'projectId': status['projectId'],
        'projectName': status['projectName'],
        'type': status['type'],
        'networkInfo': {
          'chainId': 6,
          'networkName': 'Supra Testnet',
          'explorerUrl': 'https://testnet-explorer.supra.com/tx/$transactionHash',
        },
      };
      
      // Store receipt
      await _storeReceipt(receipt);
      
      return receipt;
    } catch (e) {
      throw TransactionException('Failed to generate receipt: $e');
    }
  }

  /// Get transaction history with filtering
  Future<List<Map<String, dynamic>>> getTransactionHistory({
    String? type,
    String? projectId,
    TransactionStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 50,
  }) async {
    try {
      var filteredHistory = List<Map<String, dynamic>>.from(_transactionHistory);
      
      // Apply filters
      if (type != null) {
        filteredHistory = filteredHistory.where((tx) => tx['type'] == type).toList();
      }
      
      if (projectId != null) {
        filteredHistory = filteredHistory.where((tx) => tx['projectId'] == projectId).toList();
      }
      
      if (status != null) {
        filteredHistory = filteredHistory.where((tx) => tx['status'] == status.name).toList();
      }
      
      if (fromDate != null) {
        filteredHistory = filteredHistory.where((tx) {
          final txDate = DateTime.parse(tx['timestamp']);
          return txDate.isAfter(fromDate);
        }).toList();
      }
      
      if (toDate != null) {
        filteredHistory = filteredHistory.where((tx) {
          final txDate = DateTime.parse(tx['timestamp']);
          return txDate.isBefore(toDate);
        }).toList();
      }
      
      // Sort by timestamp (newest first)
      filteredHistory.sort((a, b) {
        final dateA = DateTime.parse(a['timestamp']);
        final dateB = DateTime.parse(b['timestamp']);
        return dateB.compareTo(dateA);
      });
      
      return filteredHistory.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get pending transactions
  List<Map<String, dynamic>> getPendingTransactions() {
    return _activeTransactions.values
        .where((tracker) => tracker.status == TransactionStatus.pending)
        .map((tracker) => tracker.toMap())
        .toList();
  }

  /// Cancel a pending transaction (if possible)
  Future<bool> cancelTransaction(String transactionHash) async {
    try {
      final tracker = _activeTransactions[transactionHash];
      if (tracker == null || tracker.status != TransactionStatus.pending) {
        return false;
      }
      
      // In production, this would attempt to cancel the transaction
      // For now, just mark as cancelled
      tracker.status = TransactionStatus.cancelled;
      tracker.updatedAt = DateTime.now();
      
      await _updateHistoryItem(transactionHash, {'status': 'cancelled'});
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Start monitoring transaction statuses
  void _startStatusMonitoring() {
    _statusMonitorTimer?.cancel();
    _statusMonitorTimer = Timer.periodic(_monitoringInterval, (timer) {
      _monitorAllTransactions();
    });
  }

  /// Monitor all active transactions
  Future<void> _monitorAllTransactions() async {
    final pendingHashes = _activeTransactions.keys
        .where((hash) => _activeTransactions[hash]!.status == TransactionStatus.pending)
        .toList();
    
    for (final hash in pendingHashes) {
      await _monitorTransaction(hash);
    }
  }

  /// Monitor a specific transaction
  Future<void> _monitorTransaction(String transactionHash) async {
    try {
      final tracker = _activeTransactions[transactionHash];
      if (tracker == null) return;
      
      final blockchainDetails = await _explorerService.getTransactionDetails(transactionHash);
      tracker.updateFromBlockchain(blockchainDetails);
      
      // Update history
      await _updateHistoryItem(transactionHash, tracker.toMap());
      
      // Remove from active tracking if confirmed or failed
      if (tracker.status == TransactionStatus.confirmed || 
          tracker.status == TransactionStatus.failed) {
        _activeTransactions.remove(transactionHash);
      }
    } catch (e) {
      // Continue monitoring even if individual transaction fails
    }
  }

  /// Helper methods
  Future<void> _loadTransactionHistory() async {
    try {
      final historyData = await _secureStorage.read(key: 'transaction_history');
      if (historyData != null) {
        final decoded = json.decode(historyData);
        _transactionHistory.clear();
        _transactionHistory.addAll(List<Map<String, dynamic>>.from(decoded));
      }
    } catch (e) {
      // Ignore loading errors
    }
  }

  Future<void> _addToHistory(Map<String, dynamic> transaction) async {
    _transactionHistory.insert(0, transaction);
    await _saveTransactionHistory();
  }

  Future<void> _updateHistoryItem(String hash, Map<String, dynamic> updates) async {
    final index = _transactionHistory.indexWhere((tx) => tx['hash'] == hash);
    if (index != -1) {
      _transactionHistory[index] = {..._transactionHistory[index], ...updates};
      await _saveTransactionHistory();
    }
  }

  Future<void> _saveTransactionHistory() async {
    try {
      await _secureStorage.write(
        key: 'transaction_history',
        value: json.encode(_transactionHistory),
      );
    } catch (e) {
      // Ignore save errors
    }
  }

  Future<void> _storeReceipt(Map<String, dynamic> receipt) async {
    try {
      final receiptsData = await _secureStorage.read(key: _receiptStorageKey) ?? '[]';
      final receipts = List<Map<String, dynamic>>.from(json.decode(receiptsData));
      receipts.insert(0, receipt);
      
      // Keep only last 100 receipts
      if (receipts.length > 100) {
        receipts.removeRange(100, receipts.length);
      }
      
      await _secureStorage.write(
        key: _receiptStorageKey,
        value: json.encode(receipts),
      );
    } catch (e) {
      // Ignore storage errors
    }
  }

  String _generateReceiptId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = random.nextInt(9999).toString().padLeft(4, '0');
    return 'RCP-$timestamp-$randomSuffix';
  }

  void dispose() {
    _statusMonitorTimer?.cancel();
    _explorerService.dispose();
  }
}

class TransactionTracker {
  final String hash;
  final String type;
  final double amount;
  final String fromAddress;
  final String toAddress;
  final String? projectId;
  final String? projectName;
  final TransactionPriority priority;
  final Map<String, dynamic> metadata;
  final DateTime submittedAt;
  
  TransactionStatus status = TransactionStatus.pending;
  DateTime updatedAt;
  int confirmations = 0;
  double? gasUsed;
  double? gasPrice;
  int? blockNumber;

  TransactionTracker({
    required this.hash,
    required this.type,
    required this.amount,
    required this.fromAddress,
    required this.toAddress,
    this.projectId,
    this.projectName,
    required this.priority,
    required this.metadata,
    required this.submittedAt,
  }) : updatedAt = DateTime.now();

  void updateFromBlockchain(Map<String, dynamic> blockchainData) {
    confirmations = blockchainData['confirmations'] ?? 0;
    gasUsed = blockchainData['gasUsed']?.toDouble();
    gasPrice = blockchainData['gasPrice']?.toDouble();
    blockNumber = blockchainData['blockNumber'];
    
    if (blockchainData['status'] == true) {
      status = confirmations >= 3 ? TransactionStatus.confirmed : TransactionStatus.pending;
    } else if (blockchainData['status'] == false) {
      status = TransactionStatus.failed;
    }
    
    updatedAt = DateTime.now();
  }

  Map<String, dynamic> getStatusInfo() {
    return {
      'hash': hash,
      'status': status.name,
      'confirmations': confirmations,
      'amount': amount,
      'fromAddress': fromAddress,
      'toAddress': toAddress,
      'projectId': projectId,
      'projectName': projectName,
      'type': type,
      'priority': priority.name,
      'submittedAt': submittedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'gasUsed': gasUsed,
      'gasPrice': gasPrice,
      'blockNumber': blockNumber,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'hash': hash,
      'type': type,
      'amount': amount,
      'fromAddress': fromAddress,
      'toAddress': toAddress,
      'projectId': projectId,
      'projectName': projectName,
      'priority': priority.name,
      'status': status.name,
      'confirmations': confirmations,
      'gasUsed': gasUsed,
      'gasPrice': gasPrice,
      'blockNumber': blockNumber,
      'timestamp': submittedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}
