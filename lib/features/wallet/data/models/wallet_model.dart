import '../../domain/entities/wallet.dart';
import 'transaction_model.dart';

class WalletModel extends Wallet {
  const WalletModel({
    required super.address,
    required super.balance,
    required super.blockvestBalance,
    required super.isConnected,
    super.privateKey,
    super.transactions,
    super.investments,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      address: json['address'] ?? '',
      balance: (json['balance'] ?? 0.0).toDouble(),
      blockvestBalance: (json['blockvestBalance'] ?? 0.0).toDouble(),
      isConnected: json['isConnected'] ?? false,
      privateKey: json['privateKey'],
      transactions:
          (json['transactions'] as List<dynamic>?)
              ?.map((tx) => TransactionModel.fromJson(tx))
              .toList() ??
          [],
      investments: [], // TODO: Add investment model parsing
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'balance': balance,
      'blockvestBalance': blockvestBalance,
      'isConnected': isConnected,
      'privateKey': privateKey,
      'transactions': transactions
          .map((tx) => (tx as TransactionModel).toJson())
          .toList(),
    };
  }

  @override
  WalletModel copyWith({
    String? address,
    double? balance,
    double? blockvestBalance,
    bool? isConnected,
    String? privateKey,
    List<Transaction>? transactions,
    List<Investment>? investments,
  }) {
    return WalletModel(
      address: address ?? this.address,
      balance: balance ?? this.balance,
      blockvestBalance: blockvestBalance ?? this.blockvestBalance,
      isConnected: isConnected ?? this.isConnected,
      privateKey: privateKey ?? this.privateKey,
      transactions: transactions ?? this.transactions,
      investments: investments ?? this.investments,
    );
  }
}
