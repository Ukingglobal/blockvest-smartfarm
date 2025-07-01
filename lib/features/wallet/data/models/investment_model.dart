import '../../domain/entities/wallet.dart';
import 'transaction_model.dart';

class InvestmentModel extends Investment {
  const InvestmentModel({
    required super.id,
    required super.projectId,
    required super.projectName,
    required super.amount,
    required super.currentValue,
    required super.expectedReturn,
    required super.investmentDate,
    super.maturityDate,
    required super.status,
    super.transactions,
  });

  factory InvestmentModel.fromJson(Map<String, dynamic> json) {
    return InvestmentModel(
      id: json['id'] ?? '',
      projectId: json['projectId'] ?? '',
      projectName: json['projectName'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      currentValue: (json['currentValue'] ?? 0.0).toDouble(),
      expectedReturn: (json['expectedReturn'] ?? 0.0).toDouble(),
      investmentDate: DateTime.parse(json['investmentDate'] ?? DateTime.now().toIso8601String()),
      maturityDate: json['maturityDate'] != null 
          ? DateTime.parse(json['maturityDate']) 
          : null,
      status: _parseInvestmentStatus(json['status']),
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((tx) => TransactionModel.fromJson(tx))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'projectName': projectName,
      'amount': amount,
      'currentValue': currentValue,
      'expectedReturn': expectedReturn,
      'investmentDate': investmentDate.toIso8601String(),
      'maturityDate': maturityDate?.toIso8601String(),
      'status': status.name,
      'transactions': transactions
          .map((tx) => (tx as TransactionModel).toJson())
          .toList(),
    };
  }

  static InvestmentStatus _parseInvestmentStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return InvestmentStatus.active;
      case 'matured':
        return InvestmentStatus.matured;
      case 'withdrawn':
        return InvestmentStatus.withdrawn;
      case 'defaulted':
        return InvestmentStatus.defaulted;
      default:
        return InvestmentStatus.active;
    }
  }

  InvestmentModel copyWith({
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
    return InvestmentModel(
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
}
