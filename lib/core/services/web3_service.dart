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
  static const String _blockvestTokenAddress = '0x1234567890123456789012345678901234567890';
  static const String _investmentContractAddress = '0x0987654321098765432109876543210987654321';
  
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
      _walletAddress = (await _credentials.extractAddress()).hex;
      
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
      // Mock transaction for development
      // In production, this would interact with the smart contract
      final transactionHash = _generateMockTransactionHash();
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      return transactionHash;
    } catch (e) {
      throw Exception('Investment transaction failed: $e');
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
  
  Future<Map<String, dynamic>> getTransactionStatus(String transactionHash) async {
    try {
      // Mock transaction status for development
      await Future.delayed(const Duration(milliseconds: 500));
      
      return {
        'status': 'confirmed',
        'blockNumber': Random().nextInt(1000000) + 1000000,
        'gasUsed': Random().nextInt(50000) + 21000,
        'blockHash': _generateMockTransactionHash(),
      };
    } catch (e) {
      throw Exception('Failed to get transaction status: $e');
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
  
  void dispose() {
    _client.dispose();
  }
}
