import '../../../../core/services/web3_service.dart';
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';
import '../models/investment_model.dart';
import '../../domain/entities/wallet.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> getWallet();
  Future<String> createWallet();
  Future<String> connectWallet();
  Future<void> disconnectWallet();
  Future<double> getBalance();
  Future<double> getBlockvestBalance();
  Future<List<TransactionModel>> getTransactionHistory();
  Future<String> investInProject({
    required String projectId,
    required double amount,
  });
  Future<String> withdrawFunds({
    required String projectId,
    required double amount,
  });
  Future<TransactionModel> getTransactionStatus(String transactionHash);
  Future<List<InvestmentModel>> getInvestments();
  Future<WalletModel> importWallet({
    required String privateKey,
    String? mnemonic,
  });
  Future<WalletModel> connectExternalWallet({
    required String address,
    String? privateKey,
  });
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final Web3Service web3Service;

  WalletRemoteDataSourceImpl({required this.web3Service});

  @override
  Future<WalletModel> getWallet() async {
    await web3Service.initialize();

    final address = await web3Service.getWalletAddress();
    final isConnected = await web3Service.isWalletConnected();
    final balance = await web3Service.getBalance();
    final blockvestBalance = await web3Service.getBlockvestTokenBalance();
    final transactionHistory = await getTransactionHistory();

    return WalletModel(
      address: address ?? '',
      balance: balance,
      blockvestBalance: blockvestBalance,
      isConnected: isConnected,
      transactions: transactionHistory,
    );
  }

  @override
  Future<String> createWallet() async {
    return await web3Service.createWallet();
  }

  @override
  Future<String> connectWallet() async {
    final address = await web3Service.getWalletAddress();
    if (address != null) {
      return address;
    } else {
      return await web3Service.createWallet();
    }
  }

  @override
  Future<void> disconnectWallet() async {
    await web3Service.disconnectWallet();
  }

  @override
  Future<double> getBalance() async {
    return await web3Service.getBalance();
  }

  @override
  Future<double> getBlockvestBalance() async {
    return await web3Service.getBlockvestTokenBalance();
  }

  @override
  Future<List<TransactionModel>> getTransactionHistory() async {
    final transactions = await web3Service.getTransactionHistory();

    return transactions.map((tx) => TransactionModel.fromJson(tx)).toList();
  }

  @override
  Future<String> investInProject({
    required String projectId,
    required double amount,
  }) async {
    // In a real implementation, this would get the project's contract address
    const projectContractAddress = '0x1234567890123456789012345678901234567890';

    return await web3Service.investInProject(
      projectId: projectId,
      amount: amount,
      projectContractAddress: projectContractAddress,
    );
  }

  @override
  Future<String> withdrawFunds({
    required String projectId,
    required double amount,
  }) async {
    return await web3Service.withdrawFunds(
      projectId: projectId,
      amount: amount,
    );
  }

  @override
  Future<TransactionModel> getTransactionStatus(String transactionHash) async {
    final status = await web3Service.getTransactionStatus(transactionHash);

    return TransactionModel(
      id: transactionHash,
      from: status['from'] ?? '',
      to: status['to'] ?? '',
      amount: status['amount']?.toDouble() ?? 0.0,
      currency: 'SUPRA',
      type: TransactionType.investment,
      status: TransactionStatus.confirmed,
      timestamp: DateTime.now(),
      gasUsed: status['gasUsed']?.toDouble(),
      blockHash: status['blockHash'],
      blockNumber: status['blockNumber'],
    );
  }

  @override
  Future<List<InvestmentModel>> getInvestments() async {
    // Mock investment data for development
    return [
      InvestmentModel(
        id: 'inv_001',
        projectId: 'proj_001',
        projectName: 'Organic Rice Farming',
        amount: 500000.0,
        currentValue: 525000.0,
        expectedReturn: 0.25,
        investmentDate: DateTime.now().subtract(const Duration(days: 30)),
        maturityDate: DateTime.now().add(const Duration(days: 335)),
        status: InvestmentStatus.active,
        transactions: [],
      ),
      InvestmentModel(
        id: 'inv_002',
        projectId: 'proj_002',
        projectName: 'Smart Poultry Farm',
        amount: 300000.0,
        currentValue: 315000.0,
        expectedReturn: 0.20,
        investmentDate: DateTime.now().subtract(const Duration(days: 45)),
        maturityDate: DateTime.now().add(const Duration(days: 320)),
        status: InvestmentStatus.active,
        transactions: [],
      ),
    ];
  }

  @override
  Future<WalletModel> importWallet({
    required String privateKey,
    String? mnemonic,
  }) async {
    try {
      // Initialize Web3 service with imported credentials
      await web3Service.initialize();

      // Import wallet using private key
      final success = await web3Service.importWallet(privateKey);

      if (!success) {
        throw Exception('Failed to import wallet with provided private key');
      }

      // Get wallet information after successful import
      final address = await web3Service.getWalletAddress();
      final balance = await web3Service.getBalance();
      final blockvestBalance = await web3Service.getBlockvestTokenBalance();
      final transactionHistory = await getTransactionHistory();

      return WalletModel(
        address: address ?? '',
        balance: balance,
        blockvestBalance: blockvestBalance,
        isConnected: true,
        transactions: transactionHistory,
      );
    } catch (e) {
      throw Exception('Failed to import wallet: ${e.toString()}');
    }
  }

  @override
  Future<WalletModel> connectExternalWallet({
    required String address,
    String? privateKey,
  }) async {
    try {
      // Initialize Web3 service
      await web3Service.initialize();

      // Connect to external wallet
      final success = await web3Service.connectExternalWallet(
        address: address,
        privateKey: privateKey,
      );

      if (!success) {
        throw Exception('Failed to connect to external wallet');
      }

      // Get wallet information after successful connection
      final balance = await web3Service.getBalance();
      final blockvestBalance = await web3Service.getBlockvestTokenBalance();
      final transactionHistory = await getTransactionHistory();

      return WalletModel(
        address: address,
        balance: balance,
        blockvestBalance: blockvestBalance,
        isConnected: true,
        transactions: transactionHistory,
      );
    } catch (e) {
      throw Exception('Failed to connect external wallet: ${e.toString()}');
    }
  }
}
