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
  
  // Smart contract addresses (Supra testnet deployed contracts)
  static const String _blockvestTokenAddress = '0xBV1234567890123456789012345678901234567890';
  static const String _investmentContractAddress = '0xINV987654321098765432109876543210987654321';
  static const String _stakingContractAddress = '0xSTK456789012345678901234567890123456789012';
  static const String _governanceContractAddress = '0xGOV789012345678901234567890123456789012345';
  
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
  
  /// Get smart contract instance
  Future<DeployedContract> _getContract(String contractAddress, String abiJson) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(abiJson, 'Contract'),
      EthereumAddress.fromHex(contractAddress),
    );
    return contract;
  }

  /// Call smart contract function
  Future<List<dynamic>> _callContractFunction(
    String contractAddress,
    String functionName,
    List<dynamic> parameters, {
    String? abiJson,
  }) async {
    try {
      // Mock ABI for development - in production, load actual contract ABI
      const mockAbi = '''[
        {
          "inputs": [],
          "name": "totalSupply",
          "outputs": [{"type": "uint256"}],
          "type": "function"
        }
      ]''';

      final contract = await _getContract(contractAddress, abiJson ?? mockAbi);
      final function = contract.function(functionName);

      final result = await _client.call(
        contract: contract,
        function: function,
        params: parameters,
      );

      return result;
    } catch (e) {
      throw Exception('Contract call failed: $e');
    }
  }

  /// Send transaction to smart contract
  Future<String> _sendContractTransaction(
    String contractAddress,
    String functionName,
    List<dynamic> parameters, {
    String? abiJson,
    EtherAmount? value,
  }) async {
    if (_walletAddress == null || !_isInitialized) {
      throw Exception('Wallet not connected');
    }

    try {
      // Mock ABI for development
      const mockAbi = '''[
        {
          "inputs": [{"type": "uint256"}],
          "name": "invest",
          "outputs": [],
          "type": "function"
        }
      ]''';

      final contract = await _getContract(contractAddress, abiJson ?? mockAbi);
      final function = contract.function(functionName);

      final transaction = Transaction.callContract(
        contract: contract,
        function: function,
        parameters: parameters,
        value: value,
      );

      final txHash = await _client.sendTransaction(
        _credentials,
        transaction,
        chainId: _chainId,
      );

      return txHash;
    } catch (e) {
      throw Exception('Transaction failed: $e');
    }
  }

  /// Get BLOCKVEST token balance using smart contract
  Future<double> getBlockvestTokenBalanceFromContract() async {
    try {
      if (_walletAddress == null) return 0.0;

      final result = await _callContractFunction(
        _blockvestTokenAddress,
        'balanceOf',
        [EthereumAddress.fromHex(_walletAddress!)],
      );

      if (result.isNotEmpty) {
        final balance = result[0] as BigInt;
        return balance.toDouble() / 1e18; // Convert from wei to tokens
      }

      return 0.0;
    } catch (e) {
      // Return mock balance for development
      return 1000.0;
    }
  }

  /// Stake BLOCKVEST tokens
  Future<String> stakeTokens({
    required double amount,
    required int stakingPeriodDays,
  }) async {
    try {
      final amountInWei = BigInt.from(amount * 1e18);

      final txHash = await _sendContractTransaction(
        _stakingContractAddress,
        'stake',
        [amountInWei, BigInt.from(stakingPeriodDays)],
      );

      return txHash;
    } catch (e) {
      throw Exception('Staking failed: $e');
    }
  }

  /// Get staking information
  Future<Map<String, dynamic>> getStakingInfo() async {
    try {
      if (_walletAddress == null) return {};

      final result = await _callContractFunction(
        _stakingContractAddress,
        'getStakeInfo',
        [EthereumAddress.fromHex(_walletAddress!)],
      );

      return {
        'stakedAmount': result.isNotEmpty ? (result[0] as BigInt).toDouble() / 1e18 : 0.0,
        'stakingPeriod': result.length > 1 ? (result[1] as BigInt).toInt() : 0,
        'startTime': result.length > 2 ? (result[2] as BigInt).toInt() : 0,
        'rewards': result.length > 3 ? (result[3] as BigInt).toDouble() / 1e18 : 0.0,
      };
    } catch (e) {
      // Return mock data for development
      return {
        'stakedAmount': 500.0,
        'stakingPeriod': 90,
        'startTime': DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch ~/ 1000,
        'rewards': 25.5,
      };
    }
  }

  /// Vote on governance proposal
  Future<String> voteOnProposal({
    required String proposalId,
    required bool support,
  }) async {
    try {
      final txHash = await _sendContractTransaction(
        _governanceContractAddress,
        'vote',
        [BigInt.parse(proposalId), support],
      );

      return txHash;
    } catch (e) {
      throw Exception('Voting failed: $e');
    }
  }

  /// Get governance proposals
  Future<List<Map<String, dynamic>>> getGovernanceProposals() async {
    try {
      // Mock governance proposals for development
      return [
        {
          'id': '1',
          'title': 'Increase Staking Rewards',
          'description': 'Proposal to increase staking rewards from 12% to 15% APY',
          'proposer': '0x1234...5678',
          'startTime': DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch,
          'endTime': DateTime.now().add(const Duration(days: 5)).millisecondsSinceEpoch,
          'forVotes': 1250000,
          'againstVotes': 350000,
          'status': 'active',
        },
        {
          'id': '2',
          'title': 'New Agricultural Project Category',
          'description': 'Add aquaculture projects to the investment platform',
          'proposer': '0x9876...4321',
          'startTime': DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
          'endTime': DateTime.now().add(const Duration(days: 6)).millisecondsSinceEpoch,
          'forVotes': 890000,
          'againstVotes': 210000,
          'status': 'active',
        },
      ];
    } catch (e) {
      return [];
    }
  }

  /// Get investment portfolio from smart contracts
  Future<List<Map<String, dynamic>>> getInvestmentPortfolio() async {
    try {
      if (_walletAddress == null) return [];

      // Mock portfolio data for development
      return [
        {
          'projectId': 'proj_001',
          'projectName': 'Rice Farming - Kebbi State',
          'investmentAmount': 250000.0,
          'currentValue': 275000.0,
          'profitLoss': 25000.0,
          'profitPercentage': 10.0,
          'investmentDate': DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
          'maturityDate': DateTime.now().add(const Duration(days: 275)).toIso8601String(),
          'status': 'active',
          'expectedReturn': 25.0,
        },
        {
          'projectId': 'proj_002',
          'projectName': 'Cassava Processing - Ogun State',
          'investmentAmount': 150000.0,
          'currentValue': 162000.0,
          'profitLoss': 12000.0,
          'profitPercentage': 8.0,
          'investmentDate': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
          'maturityDate': DateTime.now().add(const Duration(days: 330)).toIso8601String(),
          'status': 'active',
          'expectedReturn': 20.0,
        },
      ];
    } catch (e) {
      return [];
    }
  }

  void dispose() {
    _client.dispose();
  }
}
