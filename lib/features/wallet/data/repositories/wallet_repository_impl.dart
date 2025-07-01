import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_data_source.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Wallet>> getWallet() async {
    try {
      final wallet = await remoteDataSource.getWallet();
      return Right(wallet);
    } on ServerException {
      return Left(ServerFailure('Failed to get wallet'));
    } catch (e) {
      return Left(ServerFailure('Failed to get wallet'));
    }
  }

  @override
  Future<Either<Failure, String>> createWallet() async {
    try {
      final address = await remoteDataSource.createWallet();
      return Right(address);
    } on ServerException {
      return Left(ServerFailure('Failed to create wallet'));
    } catch (e) {
      return Left(ServerFailure('Failed to create wallet'));
    }
  }

  @override
  Future<Either<Failure, String>> connectWallet() async {
    try {
      final address = await remoteDataSource.connectWallet();
      return Right(address);
    } on ServerException {
      return Left(ServerFailure('Failed to connect wallet'));
    } catch (e) {
      return Left(ServerFailure('Failed to connect wallet'));
    }
  }

  @override
  Future<Either<Failure, void>> disconnectWallet() async {
    try {
      await remoteDataSource.disconnectWallet();
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure('Failed to disconnect wallet'));
    } catch (e) {
      return Left(ServerFailure('Failed to disconnect wallet'));
    }
  }

  @override
  Future<Either<Failure, double>> getBalance() async {
    try {
      final balance = await remoteDataSource.getBalance();
      return Right(balance);
    } on ServerException {
      return Left(ServerFailure('Failed to get balance'));
    } catch (e) {
      return Left(ServerFailure('Failed to get balance'));
    }
  }

  @override
  Future<Either<Failure, double>> getBlockvestBalance() async {
    try {
      final balance = await remoteDataSource.getBlockvestBalance();
      return Right(balance);
    } on ServerException {
      return Left(ServerFailure('Failed to get BLOCKVEST balance'));
    } catch (e) {
      return Left(ServerFailure('Failed to get BLOCKVEST balance'));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionHistory() async {
    try {
      final transactions = await remoteDataSource.getTransactionHistory();
      return Right(transactions);
    } on ServerException {
      return Left(ServerFailure('Failed to get transaction history'));
    } catch (e) {
      return Left(ServerFailure('Failed to get transaction history'));
    }
  }

  @override
  Future<Either<Failure, String>> investInProject({
    required String projectId,
    required double amount,
  }) async {
    try {
      final transactionHash = await remoteDataSource.investInProject(
        projectId: projectId,
        amount: amount,
      );
      return Right(transactionHash);
    } on ServerException {
      return Left(ServerFailure('Failed to invest in project'));
    } catch (e) {
      return Left(ServerFailure('Failed to invest in project'));
    }
  }

  @override
  Future<Either<Failure, String>> withdrawFunds({
    required String projectId,
    required double amount,
  }) async {
    try {
      final transactionHash = await remoteDataSource.withdrawFunds(
        projectId: projectId,
        amount: amount,
      );
      return Right(transactionHash);
    } on ServerException {
      return Left(ServerFailure('Failed to withdraw funds'));
    } catch (e) {
      return Left(ServerFailure('Failed to withdraw funds'));
    }
  }

  @override
  Future<Either<Failure, Transaction>> getTransactionStatus(
    String transactionHash,
  ) async {
    try {
      final transaction = await remoteDataSource.getTransactionStatus(
        transactionHash,
      );
      return Right(transaction);
    } on ServerException {
      return Left(ServerFailure('Failed to get transaction status'));
    } catch (e) {
      return Left(ServerFailure('Failed to get transaction status'));
    }
  }

  @override
  Future<Either<Failure, List<Investment>>> getInvestments() async {
    try {
      final investments = await remoteDataSource.getInvestments();
      return Right(investments);
    } on ServerException {
      return Left(ServerFailure('Failed to get investments'));
    } catch (e) {
      return Left(ServerFailure('Failed to get investments'));
    }
  }
}
