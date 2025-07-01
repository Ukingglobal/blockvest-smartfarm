import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wallet.dart';

abstract class WalletRepository {
  Future<Either<Failure, Wallet>> getWallet();
  Future<Either<Failure, String>> createWallet();
  Future<Either<Failure, String>> connectWallet();
  Future<Either<Failure, void>> disconnectWallet();
  Future<Either<Failure, double>> getBalance();
  Future<Either<Failure, double>> getBlockvestBalance();
  Future<Either<Failure, List<Transaction>>> getTransactionHistory();
  Future<Either<Failure, String>> investInProject({
    required String projectId,
    required double amount,
  });
  Future<Either<Failure, String>> withdrawFunds({
    required String projectId,
    required double amount,
  });
  Future<Either<Failure, Transaction>> getTransactionStatus(String transactionHash);
  Future<Either<Failure, List<Investment>>> getInvestments();
}
