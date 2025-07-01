import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet.dart';

abstract class InvestmentState extends Equatable {
  const InvestmentState();

  @override
  List<Object?> get props => [];
}

class InvestmentInitial extends InvestmentState {
  const InvestmentInitial();
}

class InvestmentLoading extends InvestmentState {
  final String message;

  const InvestmentLoading({this.message = 'Processing investment...'});

  @override
  List<Object?> get props => [message];
}

class InvestmentConfirmation extends InvestmentState {
  final String projectId;
  final String projectName;
  final double amount;
  final double estimatedGasFee;
  final double totalAmount;

  const InvestmentConfirmation({
    required this.projectId,
    required this.projectName,
    required this.amount,
    required this.estimatedGasFee,
    required this.totalAmount,
  });

  @override
  List<Object?> get props => [
        projectId,
        projectName,
        amount,
        estimatedGasFee,
        totalAmount,
      ];
}

class InvestmentProcessing extends InvestmentState {
  final String transactionHash;
  final String message;

  const InvestmentProcessing({
    required this.transactionHash,
    this.message = 'Transaction submitted. Waiting for confirmation...',
  });

  @override
  List<Object?> get props => [transactionHash, message];
}

class InvestmentSuccess extends InvestmentState {
  final String transactionHash;
  final String projectId;
  final double amount;
  final Transaction transaction;

  const InvestmentSuccess({
    required this.transactionHash,
    required this.projectId,
    required this.amount,
    required this.transaction,
  });

  @override
  List<Object?> get props => [transactionHash, projectId, amount, transaction];
}

class InvestmentFailure extends InvestmentState {
  final String message;
  final String? errorCode;
  final bool canRetry;

  const InvestmentFailure({
    required this.message,
    this.errorCode,
    this.canRetry = true,
  });

  @override
  List<Object?> get props => [message, errorCode, canRetry];
}

class InvestmentCancelled extends InvestmentState {
  const InvestmentCancelled();
}
