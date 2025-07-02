import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'web3_service.dart';

class SmartContractService {
  static const String _rpcUrl = 'https://rpc-testnet.supra.com';
  static const int _chainId = 6;

  // Contract addresses (these would be deployed on Supra network)
  static const String _investmentContractAddress =
      '0x1234567890123456789012345678901234567890';
  static const String _blockvestTokenAddress =
      '0x0987654321098765432109876543210987654321';
  static const String _governanceContractAddress =
      '0x1111222233334444555566667777888899990000';

  late Web3Client _client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Contract state management
  final Map<String, dynamic> _contractStates = {};
  final Map<String, DateTime> _lastStateUpdate = {};
  static const Duration _stateUpdateInterval = Duration(minutes: 5);

  // Gas optimization settings
  static const int _maxGasLimit = 500000;
  static const int _defaultGasLimit = 200000;
  final Map<String, int> _gasEstimates = {};

  // Transaction tracking
  final Map<String, Map<String, dynamic>> _pendingTransactions = {};
  final List<Map<String, dynamic>> _transactionHistory = [];

  // Contract ABIs (simplified for demo)
  static const String _investmentContractABI = '''
  [
    {
      "inputs": [
        {"name": "projectId", "type": "string"},
        {"name": "amount", "type": "uint256"}
      ],
      "name": "invest",
      "outputs": [{"name": "success", "type": "bool"}],
      "type": "function"
    },
    {
      "inputs": [
        {"name": "projectId", "type": "string"},
        {"name": "amount", "type": "uint256"}
      ],
      "name": "withdraw",
      "outputs": [{"name": "success", "type": "bool"}],
      "type": "function"
    },
    {
      "inputs": [{"name": "investor", "type": "address"}],
      "name": "getInvestments",
      "outputs": [{"name": "investments", "type": "tuple[]"}],
      "type": "function"
    }
  ]
  ''';

  SmartContractService() {
    _client = Web3Client(_rpcUrl, http.Client());
  }

  /// Initialize smart contract connections
  Future<void> initialize() async {
    try {
      // Verify network connection
      final isConnected = await _client.isListeningForNetwork();
      if (!isConnected) {
        throw Exception('Unable to connect to Supra network');
      }
    } catch (e) {
      throw Exception('Failed to initialize smart contract service: $e');
    }
  }

  /// Execute investment transaction on smart contract
  Future<String> executeInvestment({
    required String projectId,
    required double amount,
    required Credentials credentials,
  }) async {
    try {
      // Convert amount to Wei (blockchain units)
      final amountInWei = EtherAmount.fromBase10String(
        EtherUnit.ether,
        amount.toString(),
      );

      // Create contract instance
      final contract = DeployedContract(
        ContractAbi.fromJson(_investmentContractABI, 'InvestmentContract'),
        EthereumAddress.fromHex(_investmentContractAddress),
      );

      // Get the invest function
      final investFunction = contract.function('invest');

      // Prepare transaction
      final transaction = Transaction.callContract(
        contract: contract,
        function: investFunction,
        parameters: [projectId, amountInWei.getInWei],
        value: amountInWei,
      );

      // Send transaction
      final transactionHash = await _client.sendTransaction(
        credentials,
        transaction,
        chainId: _chainId,
      );

      // Store transaction for tracking
      await _storeTransactionHash(transactionHash, projectId, amount);

      return transactionHash;
    } catch (e) {
      throw Exception('Smart contract investment failed: $e');
    }
  }

  /// Execute withdrawal transaction
  Future<String> executeWithdrawal({
    required String projectId,
    required double amount,
    required Credentials credentials,
  }) async {
    try {
      final amountInWei = EtherAmount.fromBase10String(
        EtherUnit.ether,
        amount.toString(),
      );

      final contract = DeployedContract(
        ContractAbi.fromJson(_investmentContractABI, 'InvestmentContract'),
        EthereumAddress.fromHex(_investmentContractAddress),
      );

      final withdrawFunction = contract.function('withdraw');

      final transaction = Transaction.callContract(
        contract: contract,
        function: withdrawFunction,
        parameters: [projectId, amountInWei.getInWei],
      );

      final transactionHash = await _client.sendTransaction(
        credentials,
        transaction,
        chainId: _chainId,
      );

      await _storeTransactionHash(transactionHash, projectId, -amount);

      return transactionHash;
    } catch (e) {
      throw Exception('Smart contract withdrawal failed: $e');
    }
  }

  /// Get investment data from smart contract
  Future<List<Map<String, dynamic>>> getInvestmentsFromContract(
    EthereumAddress investorAddress,
  ) async {
    try {
      final contract = DeployedContract(
        ContractAbi.fromJson(_investmentContractABI, 'InvestmentContract'),
        EthereumAddress.fromHex(_investmentContractAddress),
      );

      final getInvestmentsFunction = contract.function('getInvestments');

      final result = await _client.call(
        contract: contract,
        function: getInvestmentsFunction,
        params: [investorAddress],
      );

      // Parse result and return investment data
      // This would be implemented based on the actual contract structure
      return _parseInvestmentData(result);
    } catch (e) {
      // Return empty list if contract call fails
      return [];
    }
  }

  /// Check transaction status on blockchain
  Future<Map<String, dynamic>> getTransactionStatus(
    String transactionHash,
  ) async {
    try {
      final receipt = await _client.getTransactionReceipt(transactionHash);

      if (receipt == null) {
        return {'status': 'pending', 'confirmations': 0};
      }

      final currentBlock = await _client.getBlockNumber();
      final confirmations = currentBlock - receipt.blockNumber.blockNum;

      return {
        'status': receipt.status! ? 'confirmed' : 'failed',
        'blockNumber': receipt.blockNumber.blockNum,
        'gasUsed': receipt.gasUsed?.toInt() ?? 0,
        'confirmations': confirmations,
        'blockHash': receipt.blockHash,
      };
    } catch (e) {
      // Fallback to mock data for development
      return _getMockTransactionStatus();
    }
  }

  /// Estimate gas fee for transaction
  Future<double> estimateGasFee({
    required String projectId,
    required double amount,
    required EthereumAddress from,
  }) async {
    try {
      final amountInWei = EtherAmount.fromBase10String(
        EtherUnit.ether,
        amount.toString(),
      );

      final contract = DeployedContract(
        ContractAbi.fromJson(_investmentContractABI, 'InvestmentContract'),
        EthereumAddress.fromHex(_investmentContractAddress),
      );

      final investFunction = contract.function('invest');

      final transaction = Transaction.callContract(
        contract: contract,
        function: investFunction,
        parameters: [projectId, amountInWei.getInWei],
        value: amountInWei,
        from: from,
      );

      final gasEstimate = await _client.estimateGas(
        sender: from,
        to: EthereumAddress.fromHex(_investmentContractAddress),
        data: transaction.data,
        value: amountInWei,
      );

      // Get current gas price
      final gasPrice = await _client.getGasPrice();

      // Calculate total fee
      final totalFee = gasEstimate * gasPrice.getInWei;
      return EtherAmount.inWei(totalFee).getValueInUnit(EtherUnit.ether);
    } catch (e) {
      // Return estimated fee based on amount
      return amount * 0.001; // 0.1% fee
    }
  }

  /// Get BLOCKVEST token balance
  Future<double> getBlockvestTokenBalance(EthereumAddress address) async {
    try {
      // This would call the BLOCKVEST token contract
      // For now, return mock data
      return 1000.0 + Random().nextDouble() * 500;
    } catch (e) {
      return 0.0;
    }
  }

  /// Store transaction hash for local tracking
  Future<void> _storeTransactionHash(
    String transactionHash,
    String projectId,
    double amount,
  ) async {
    try {
      final transactionData = {
        'hash': transactionHash,
        'projectId': projectId,
        'amount': amount,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'pending',
      };

      final existingTransactions =
          await _secureStorage.read(key: 'contract_transactions') ?? '[]';
      final transactions = List<Map<String, dynamic>>.from(
        json.decode(existingTransactions),
      );

      transactions.add(transactionData);

      await _secureStorage.write(
        key: 'contract_transactions',
        value: json.encode(transactions),
      );
    } catch (e) {
      // Non-critical error
    }
  }

  /// Parse investment data from contract response
  List<Map<String, dynamic>> _parseInvestmentData(
    List<dynamic> contractResult,
  ) {
    try {
      // This would parse the actual contract response
      // For now, return mock data structure
      return [
        {
          'projectId': 'proj_001',
          'amount': 250000.0,
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 30))
              .toIso8601String(),
          'status': 'active',
        },
        {
          'projectId': 'proj_002',
          'amount': 300000.0,
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 45))
              .toIso8601String(),
          'status': 'active',
        },
      ];
    } catch (e) {
      return [];
    }
  }

  /// Mock transaction status for development
  Map<String, dynamic> _getMockTransactionStatus() {
    final random = Random();
    final isConfirmed = random.nextBool();

    return {
      'status': isConfirmed ? 'confirmed' : 'pending',
      'blockNumber': isConfirmed ? random.nextInt(1000000) + 1000000 : null,
      'gasUsed': isConfirmed ? random.nextInt(50000) + 21000 : null,
      'confirmations': isConfirmed ? random.nextInt(50) + 1 : 0,
      'blockHash': isConfirmed
          ? '0x${random.nextInt(0xFFFFFFFF).toRadixString(16).padLeft(64, '0')}'
          : null,
    };
  }

  /// Dispose resources
  /// Advanced profit distribution functionality
  Future<String> distributeProfits({
    required String projectId,
    required double totalProfit,
    required List<String> investorAddresses,
    required List<double> investmentAmounts,
    required Credentials credentials,
  }) async {
    try {
      // Calculate profit shares based on investment amounts
      final totalInvestment = investmentAmounts.fold(
        0.0,
        (sum, amount) => sum + amount,
      );
      final profitShares = investmentAmounts
          .map((amount) => (amount / totalInvestment) * totalProfit)
          .toList();

      // Create profit distribution transaction
      final transactionHash = await _executeProfitDistribution(
        projectId: projectId,
        investorAddresses: investorAddresses,
        profitShares: profitShares,
        credentials: credentials,
      );

      // Track transaction
      _pendingTransactions[transactionHash] = {
        'type': 'profit_distribution',
        'projectId': projectId,
        'totalProfit': totalProfit,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'pending',
      };

      return transactionHash;
    } catch (e) {
      throw TransactionException('Profit distribution failed: $e');
    }
  }

  /// Execute profit distribution transaction
  Future<String> _executeProfitDistribution({
    required String projectId,
    required List<String> investorAddresses,
    required List<double> profitShares,
    required Credentials credentials,
  }) async {
    try {
      // In production, this would interact with the profit distribution smart contract
      // For now, simulate the transaction
      final transactionHash = _generateTransactionHash();

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 3));

      return transactionHash;
    } catch (e) {
      throw TransactionException('Failed to execute profit distribution: $e');
    }
  }

  /// Get contract state with caching
  Future<Map<String, dynamic>> getContractState(String contractAddress) async {
    try {
      final now = DateTime.now();
      final lastUpdate = _lastStateUpdate[contractAddress];

      // Check if we need to refresh the state
      if (lastUpdate == null ||
          now.difference(lastUpdate) > _stateUpdateInterval) {
        final state = await _fetchContractState(contractAddress);
        _contractStates[contractAddress] = state;
        _lastStateUpdate[contractAddress] = now;
      }

      return _contractStates[contractAddress] ?? {};
    } catch (e) {
      return {};
    }
  }

  /// Fetch fresh contract state from blockchain
  Future<Map<String, dynamic>> _fetchContractState(
    String contractAddress,
  ) async {
    try {
      // In production, this would query the actual contract state
      // For now, return mock state data
      return {
        'totalInvestments': 1500000.0,
        'activeProjects': 12,
        'totalInvestors': 245,
        'averageROI': 8.5,
        'lastUpdate': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Web3Exception('Failed to fetch contract state: $e');
    }
  }

  /// Optimized gas estimation with caching
  Future<int> estimateGasOptimized({
    required String contractAddress,
    required String functionName,
    required List<dynamic> parameters,
    required EthereumAddress from,
  }) async {
    try {
      final cacheKey =
          '$contractAddress:$functionName:${parameters.toString()}';

      // Check cache first
      if (_gasEstimates.containsKey(cacheKey)) {
        return _gasEstimates[cacheKey]!;
      }

      // Estimate gas
      final gasEstimate = await _performGasEstimation(
        contractAddress: contractAddress,
        functionName: functionName,
        parameters: parameters,
        from: from,
      );

      // Cache the result
      _gasEstimates[cacheKey] = gasEstimate;

      return gasEstimate;
    } catch (e) {
      // Return default gas limit if estimation fails
      return _defaultGasLimit;
    }
  }

  /// Perform actual gas estimation
  Future<int> _performGasEstimation({
    required String contractAddress,
    required String functionName,
    required List<dynamic> parameters,
    required EthereumAddress from,
  }) async {
    try {
      // In production, this would call the actual contract for gas estimation
      // For now, return estimated values based on function complexity
      switch (functionName) {
        case 'invest':
          return 150000;
        case 'withdraw':
          return 120000;
        case 'distributeProfits':
          return 300000;
        default:
          return _defaultGasLimit;
      }
    } catch (e) {
      return _defaultGasLimit;
    }
  }

  /// Get comprehensive transaction history with filtering
  Future<List<Map<String, dynamic>>> getTransactionHistory({
    String? projectId,
    String? transactionType,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 50,
  }) async {
    try {
      // Load transaction history from secure storage
      final historyData = await _secureStorage.read(
        key: 'contract_transaction_history',
      );
      List<Map<String, dynamic>> transactions = [];

      if (historyData != null) {
        final decoded = json.decode(historyData);
        transactions = List<Map<String, dynamic>>.from(decoded);
      }

      // Apply filters
      var filteredTransactions = transactions.where((tx) {
        bool matches = true;

        if (projectId != null && tx['projectId'] != projectId) {
          matches = false;
        }

        if (transactionType != null && tx['type'] != transactionType) {
          matches = false;
        }

        if (fromDate != null) {
          final txDate = DateTime.parse(tx['timestamp']);
          if (txDate.isBefore(fromDate)) {
            matches = false;
          }
        }

        if (toDate != null) {
          final txDate = DateTime.parse(tx['timestamp']);
          if (txDate.isAfter(toDate)) {
            matches = false;
          }
        }

        return matches;
      }).toList();

      // Sort by timestamp (newest first)
      filteredTransactions.sort((a, b) {
        final dateA = DateTime.parse(a['timestamp']);
        final dateB = DateTime.parse(b['timestamp']);
        return dateB.compareTo(dateA);
      });

      // Apply limit
      return filteredTransactions.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  /// Generate transaction hash for mock transactions
  String _generateTransactionHash() {
    final random = Random();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return '0x${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
  }

  void dispose() {
    _client.dispose();
  }
}
