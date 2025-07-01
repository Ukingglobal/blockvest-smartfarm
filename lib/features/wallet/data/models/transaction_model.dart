import '../../domain/entities/wallet.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.from,
    required super.to,
    required super.amount,
    required super.currency,
    required super.type,
    required super.status,
    required super.timestamp,
    super.projectId,
    super.projectName,
    super.gasUsed,
    super.fee,
    super.blockHash,
    super.blockNumber,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['hash'] ?? json['id'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'SUPRA',
      type: _parseTransactionType(json['type']),
      status: _parseTransactionStatus(json['status']),
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      projectId: json['projectId'],
      projectName: json['projectName'],
      gasUsed: json['gasUsed']?.toDouble(),
      fee: (json['fee'] ?? 0.0).toDouble(),
      blockHash: json['blockHash'],
      blockNumber: json['blockNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'amount': amount,
      'currency': currency,
      'type': type.name,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'projectId': projectId,
      'projectName': projectName,
      'gasUsed': gasUsed,
      'blockHash': blockHash,
      'blockNumber': blockNumber,
    };
  }

  static TransactionType _parseTransactionType(String? type) {
    switch (type?.toLowerCase()) {
      case 'investment':
        return TransactionType.investment;
      case 'withdrawal':
        return TransactionType.withdrawal;
      case 'profit':
        return TransactionType.profit;
      case 'staking':
        return TransactionType.staking;
      case 'governance':
        return TransactionType.governance;
      case 'transfer':
        return TransactionType.transfer;
      default:
        return TransactionType.transfer;
    }
  }

  static TransactionStatus _parseTransactionStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return TransactionStatus.pending;
      case 'confirmed':
        return TransactionStatus.confirmed;
      case 'failed':
        return TransactionStatus.failed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.pending;
    }
  }

  @override
  TransactionModel copyWith({
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
    return TransactionModel(
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
}
