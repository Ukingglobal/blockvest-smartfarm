import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final String address;
  final double balance;
  final double blockvestBalance;
  final bool isConnected;
  final String? privateKey;
  final List<Transaction> transactions;
  final List<Investment> investments;

  const Wallet({
    required this.address,
    required this.balance,
    required this.blockvestBalance,
    required this.isConnected,
    this.privateKey,
    this.transactions = const [],
    this.investments = const [],
  });

  Wallet copyWith({
    String? address,
    double? balance,
    double? blockvestBalance,
    bool? isConnected,
    String? privateKey,
    List<Transaction>? transactions,
    List<Investment>? investments,
  }) {
    return Wallet(
      address: address ?? this.address,
      balance: balance ?? this.balance,
      blockvestBalance: blockvestBalance ?? this.blockvestBalance,
      isConnected: isConnected ?? this.isConnected,
      privateKey: privateKey ?? this.privateKey,
      transactions: transactions ?? this.transactions,
      investments: investments ?? this.investments,
    );
  }

  @override
  List<Object?> get props => [
    address,
    balance,
    blockvestBalance,
    isConnected,
    privateKey,
    transactions,
    investments,
  ];
}

class Transaction extends Equatable {
  final String id;
  final String from;
  final String to;
  final double amount;
  final String currency;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime timestamp;
  final String? projectId;
  final String? projectName;
  final double? gasUsed;
  final double fee;
  final String? blockHash;
  final int? blockNumber;

  const Transaction({
    required this.id,
    required this.from,
    required this.to,
    required this.amount,
    required this.currency,
    required this.type,
    required this.status,
    required this.timestamp,
    this.projectId,
    this.projectName,
    this.gasUsed,
    this.fee = 0.0,
    this.blockHash,
    this.blockNumber,
  });

  Transaction copyWith({
    String? id,
    String? from,
    String? to,
    double? amount,
    String? currency,
    TransactionType? type,
    TransactionStatus? status,
    DateTime? timestamp,
    String? projectId,
    String? projectName,
    double? gasUsed,
    double? fee,
    String? blockHash,
    int? blockNumber,
  }) {
    return Transaction(
      id: id ?? this.id,
      from: from ?? this.from,
      to: to ?? this.to,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      gasUsed: gasUsed ?? this.gasUsed,
      fee: fee ?? this.fee,
      blockHash: blockHash ?? this.blockHash,
      blockNumber: blockNumber ?? this.blockNumber,
    );
  }

  @override
  List<Object?> get props => [
    id,
    from,
    to,
    amount,
    currency,
    type,
    status,
    timestamp,
    projectId,
    projectName,
    gasUsed,
    fee,
    blockHash,
    blockNumber,
  ];
}

enum TransactionType {
  investment,
  withdrawal,
  profit,
  staking,
  governance,
  transfer,
}

enum TransactionStatus { pending, confirmed, failed, cancelled }

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.investment:
        return 'Investment';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.profit:
        return 'Profit Distribution';
      case TransactionType.staking:
        return 'Staking';
      case TransactionType.governance:
        return 'Governance';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }

  String get icon {
    switch (this) {
      case TransactionType.investment:
        return '📈';
      case TransactionType.withdrawal:
        return '💸';
      case TransactionType.profit:
        return '💰';
      case TransactionType.staking:
        return '🔒';
      case TransactionType.governance:
        return '🗳️';
      case TransactionType.transfer:
        return '↔️';
    }
  }
}

extension TransactionStatusExtension on TransactionStatus {
  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.confirmed:
        return 'Confirmed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class Investment extends Equatable {
  final String id;
  final String projectId;
  final String projectName;
  final double amount;
  final double currentValue;
  final double expectedReturn;
  final DateTime investmentDate;
  final DateTime? maturityDate;
  final InvestmentStatus status;
  final List<Transaction> transactions;

  const Investment({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.amount,
    required this.currentValue,
    required this.expectedReturn,
    required this.investmentDate,
    this.maturityDate,
    required this.status,
    this.transactions = const [],
  });

  double get profitLoss => currentValue - amount;
  double get profitLossPercentage => ((currentValue - amount) / amount) * 100;

  Investment copyWith({
    String? id,
    String? projectId,
    String? projectName,
    double? amount,
    double? currentValue,
    double? expectedReturn,
    DateTime? investmentDate,
    DateTime? maturityDate,
    InvestmentStatus? status,
    List<Transaction>? transactions,
  }) {
    return Investment(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      amount: amount ?? this.amount,
      currentValue: currentValue ?? this.currentValue,
      expectedReturn: expectedReturn ?? this.expectedReturn,
      investmentDate: investmentDate ?? this.investmentDate,
      maturityDate: maturityDate ?? this.maturityDate,
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    projectName,
    amount,
    currentValue,
    expectedReturn,
    investmentDate,
    maturityDate,
    status,
    transactions,
  ];
}

enum InvestmentStatus { active, matured, withdrawn, defaulted }

extension InvestmentStatusExtension on InvestmentStatus {
  String get displayName {
    switch (this) {
      case InvestmentStatus.active:
        return 'Active';
      case InvestmentStatus.matured:
        return 'Matured';
      case InvestmentStatus.withdrawn:
        return 'Withdrawn';
      case InvestmentStatus.defaulted:
        return 'Defaulted';
    }
  }
}
