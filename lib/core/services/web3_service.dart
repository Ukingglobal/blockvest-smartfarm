import 'dart:convert';
import 'dart:math';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class Web3Service {
  static const String _privateKeyKey = 'wallet_private_key';
  static const String _addressKey = 'wallet_address';

  late Web3Client _client;
  late Credentials _credentials;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isInitialized = false;
  String? _walletAddress;

  // Supra blockchain configuration
  static const String _rpcUrl = 'https://rpc-testnet.supra.com'; // Testnet RPC
  static const int _chainId = 6; // Supra testnet chain ID

  // Smart contract addresses (these would be deployed contracts)
  static const String _blockvestTokenAddress =
      '0x1234567890123456789012345678901234567890';
  static const String _investmentContractAddress =
      '0x0987654321098765432109876543210987654321';

  Web3Service() {
    _client = Web3Client(_rpcUrl, http.Client());
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Try to load existing wallet
      final privateKeyHex = await _secureStorage.read(key: _privateKeyKey);
      final address = await _secureStorage.read(key: _addressKey);

      if (privateKeyHex != null && address != null) {
        _credentials = EthPrivateKey.fromHex(privateKeyHex);
        _walletAddress = address;
      }

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize Web3 service: $e');
    }
  }

  Future<String> createWallet() async {
    try {
      // Generate a new private key
      final random = Random.secure();
      final privateKey = EthPrivateKey.createRandom(random);

      _credentials = privateKey;
      _walletAddress = _credentials.address.hex;

      // Store securely
      await _secureStorage.write(
        key: _privateKeyKey,
        value: privateKey.privateKeyInt.toRadixString(16),
      );
      await _secureStorage.write(key: _addressKey, value: _walletAddress!);

      return _walletAddress!;
    } catch (e) {
      throw Exception('Failed to create wallet: $e');
    }
  }

  Future<String?> getWalletAddress() async {
    await initialize();
    return _walletAddress;
  }

  Future<bool> isWalletConnected() async {
    await initialize();
    return _walletAddress != null;
  }

  Future<double> getBalance() async {
    if (_walletAddress == null) return 0.0;

    try {
      final address = EthereumAddress.fromHex(_walletAddress!);
      final balance = await _client.getBalance(address);

      // Convert from Wei to Ether (or SUPRA tokens)
      return balance.getValueInUnit(EtherUnit.ether).toDouble();
    } catch (e) {
      // Return mock balance for development
      return 1.5; // Mock balance
    }
  }

  Future<double> getBlockvestTokenBalance() async {
    if (_walletAddress == null) return 0.0;

    try {
      // This would call the BLOCKVEST token contract
      // For now, return mock data
      return 1000.0; // Mock BLOCKVEST token balance
    } catch (e) {
      return 1000.0; // Mock balance
    }
  }

  Future<String> investInProject({
    required String projectId,
    required double amount,
    required String projectContractAddress,
  }) async {
    if (_walletAddress == null || !_isInitialized) {
      throw Exception('Wallet not connected');
    }

    try {
      // Validate investment amount
      if (amount <= 0) {
        throw Exception('Investment amount must be greater than 0');
      }

      // Check wallet balance
      final balance = await getBalance();
      final estimatedGasFee = await _estimateGasFee(amount);
      final totalRequired = amount + estimatedGasFee;

      if (balance < totalRequired) {
        throw Exception(
          'Insufficient balance. Required: $totalRequired, Available: $balance',
        );
      }

      // Create investment transaction
      final transactionHash = await _executeInvestmentTransaction(
        projectId: projectId,
        amount: amount,
        projectContractAddress: projectContractAddress,
      );

      // Store transaction locally for tracking
      await _storeTransactionLocally(
        transactionHash: transactionHash,
        projectId: projectId,
        amount: amount,
        type: 'investment',
      );

      return transactionHash;
    } catch (e) {
      throw Exception('Investment transaction failed: $e');
    }
  }

  Future<double> _estimateGasFee(double amount) async {
    try {
      // In production, this would call the smart contract to estimate gas
      // For now, return a percentage-based fee
      return amount * 0.001; // 0.1% fee
    } catch (e) {
      return 0.001; // Default minimal fee
    }
  }

  Future<String> _executeInvestmentTransaction({
    required String projectId,
    required double amount,
    required String projectContractAddress,
  }) async {
    try {
      // In production, this would:
      // 1. Create the transaction data for the smart contract
      // 2. Sign the transaction with the private key
      // 3. Broadcast to the Supra network
      // 4. Return the transaction hash

      // For development, simulate the process
      final transactionHash = _generateMockTransactionHash();

      // Simulate network delay for realistic UX
      await Future.delayed(const Duration(seconds: 2));

      return transactionHash;
    } catch (e) {
      throw Exception('Failed to execute investment transaction: $e');
    }
  }

  Future<void> _storeTransactionLocally({
    required String transactionHash,
    required String projectId,
    required double amount,
    required String type,
  }) async {
    try {
      final transactionData = {
        'hash': transactionHash,
        'projectId': projectId,
        'amount': amount,
        'type': type,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'pending',
        'walletAddress': _walletAddress,
      };

      // Store in secure storage for local tracking
      final existingTransactions =
          await _secureStorage.read(key: 'local_transactions') ?? '[]';
      final transactions = List<Map<String, dynamic>>.from(
        (existingTransactions.isNotEmpty
            ? (existingTransactions != '[]'
                  ? List<dynamic>.from(
                      Map<String, dynamic>.from({
                            'transactions': [],
                          })['transactions'] ??
                          [],
                    )
                  : <dynamic>[])
            : <dynamic>[]),
      );

      transactions.add(transactionData);
      await _secureStorage.write(
        key: 'local_transactions',
        value: transactions.toString(),
      );
    } catch (e) {
      // Non-critical error, don't fail the transaction
      print('Warning: Failed to store transaction locally: $e');
    }
  }

  Future<String> withdrawFunds({
    required String projectId,
    required double amount,
  }) async {
    if (_walletAddress == null || !_isInitialized) {
      throw Exception('Wallet not connected');
    }

    try {
      // Mock transaction for development
      final transactionHash = _generateMockTransactionHash();

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      return transactionHash;
    } catch (e) {
      throw Exception('Withdrawal transaction failed: $e');
    }
  }

  Future<Map<String, dynamic>> getTransactionStatus(
    String transactionHash,
  ) async {
    try {
      // Check local storage first for recent transactions
      final localStatus = await _getLocalTransactionStatus(transactionHash);
      if (localStatus != null) {
        return localStatus;
      }

      // In production, this would query the Supra blockchain
      // For development, simulate realistic transaction progression
      await Future.delayed(const Duration(milliseconds: 500));

      // Simulate transaction confirmation process
      final random = Random();
      final confirmationStage = random.nextInt(100);

      String status;
      if (confirmationStage < 10) {
        status = 'pending';
      } else if (confirmationStage < 95) {
        status = 'confirmed';
        // Update local storage when confirmed
        await _updateLocalTransactionStatus(transactionHash, 'confirmed');
      } else {
        status = 'failed';
        await _updateLocalTransactionStatus(transactionHash, 'failed');
      }

      return {
        'status': status,
        'blockNumber': status == 'confirmed'
            ? Random().nextInt(1000000) + 1000000
            : null,
        'gasUsed': status == 'confirmed'
            ? Random().nextInt(50000) + 21000
            : null,
        'blockHash': status == 'confirmed'
            ? _generateMockTransactionHash()
            : null,
        'confirmations': status == 'confirmed' ? Random().nextInt(50) + 1 : 0,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get transaction status: $e');
    }
  }

  Future<Map<String, dynamic>?> _getLocalTransactionStatus(
    String transactionHash,
  ) async {
    try {
      final existingTransactions =
          await _secureStorage.read(key: 'local_transactions') ?? '[]';
      if (existingTransactions == '[]') return null;

      // Parse stored transactions (simplified for demo)
      // In production, use proper JSON parsing
      return null; // Simplified for now
    } catch (e) {
      return null;
    }
  }

  Future<void> _updateLocalTransactionStatus(
    String transactionHash,
    String status,
  ) async {
    try {
      // Update local transaction status
      // Implementation simplified for demo
      // In production, properly update the stored transaction data
    } catch (e) {
      // Non-critical error
    }
  }

  Future<List<Map<String, dynamic>>> getTransactionHistory() async {
    if (_walletAddress == null) return [];

    try {
      // Mock transaction history for development
      return _generateMockTransactionHistory();
    } catch (e) {
      return [];
    }
  }

  Future<void> disconnectWallet() async {
    try {
      await _secureStorage.delete(key: _privateKeyKey);
      await _secureStorage.delete(key: _addressKey);

      _walletAddress = null;
      _isInitialized = false;
    } catch (e) {
      throw Exception('Failed to disconnect wallet: $e');
    }
  }

  String _generateMockTransactionHash() {
    final random = Random();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return '0x${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
  }

  List<Map<String, dynamic>> _generateMockTransactionHistory() {
    final random = Random();
    final now = DateTime.now();

    return List.generate(10, (index) {
      final isInvestment = random.nextBool();
      final amount = (random.nextDouble() * 1000 + 50).toDouble();

      return {
        'hash': _generateMockTransactionHash(),
        'from': _walletAddress,
        'to': isInvestment ? _investmentContractAddress : _walletAddress,
        'amount': amount,
        'type': isInvestment ? 'investment' : 'profit',
        'status': 'confirmed',
        'timestamp': now.subtract(Duration(days: index)).toIso8601String(),
        'blockNumber': random.nextInt(1000000) + 1000000,
        'gasUsed': random.nextInt(50000) + 21000,
      };
    });
  }

  Future<bool> importWallet(String privateKey) async {
    try {
      // Validate private key format
      if (!privateKey.startsWith('0x')) {
        privateKey = '0x$privateKey';
      }

      // Create credentials from private key
      _credentials = EthPrivateKey.fromHex(privateKey);

      // Get wallet address
      final address = _credentials.address;
      _walletAddress = address.hex;

      // Store credentials securely
      await _secureStorage.write(key: _privateKeyKey, value: privateKey);
      await _secureStorage.write(key: _addressKey, value: _walletAddress!);

      _isInitialized = true;
      return true;
    } catch (e) {
      throw Exception('Invalid private key format: ${e.toString()}');
    }
  }

  Future<bool> connectExternalWallet({
    required String address,
    String? privateKey,
  }) async {
    try {
      // Validate address format
      if (!address.startsWith('0x')) {
        address = '0x$address';
      }

      _walletAddress = address;

      // If private key is provided, store it for transaction signing
      if (privateKey != null) {
        if (!privateKey.startsWith('0x')) {
          privateKey = '0x$privateKey';
        }
        _credentials = EthPrivateKey.fromHex(privateKey);
        await _secureStorage.write(key: _privateKeyKey, value: privateKey);
      }

      // Store wallet address
      await _secureStorage.write(key: _addressKey, value: address);

      _isInitialized = true;
      return true;
    } catch (e) {
      throw Exception('Failed to connect external wallet: ${e.toString()}');
    }
  }

  void dispose() {
    _client.dispose();
  }
}
