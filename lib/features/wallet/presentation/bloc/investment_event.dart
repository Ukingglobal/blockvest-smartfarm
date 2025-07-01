import 'package:equatable/equatable.dart';

abstract class InvestmentEvent extends Equatable {
  const InvestmentEvent();

  @override
  List<Object?> get props => [];
}

class StartInvestmentEvent extends InvestmentEvent {
  final String projectId;
  final double amount;

  const StartInvestmentEvent({
    required this.projectId,
    required this.amount,
  });

  @override
  List<Object?> get props => [projectId, amount];
}

class ConfirmInvestmentEvent extends InvestmentEvent {
  final String projectId;
  final double amount;

  const ConfirmInvestmentEvent({
    required this.projectId,
    required this.amount,
  });

  @override
  List<Object?> get props => [projectId, amount];
}

class CancelInvestmentEvent extends InvestmentEvent {
  const CancelInvestmentEvent();
}

class CheckTransactionStatusEvent extends InvestmentEvent {
  final String transactionHash;

  const CheckTransactionStatusEvent({required this.transactionHash});

  @override
  List<Object?> get props => [transactionHash];
}

class RetryInvestmentEvent extends InvestmentEvent {
  final String projectId;
  final double amount;

  const RetryInvestmentEvent({
    required this.projectId,
    required this.amount,
  });

  @override
  List<Object?> get props => [projectId, amount];
}
