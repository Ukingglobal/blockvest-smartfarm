import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWalletEvent extends WalletEvent {
  const LoadWalletEvent();
}

class ConnectWalletEvent extends WalletEvent {
  final String address;
  final String? privateKey;

  const ConnectWalletEvent({required this.address, this.privateKey});

  @override
  List<Object?> get props => [address, privateKey];
}

class CreateWalletEvent extends WalletEvent {
  const CreateWalletEvent();
}

class DisconnectWalletEvent extends WalletEvent {
  const DisconnectWalletEvent();
}

class RefreshBalanceEvent extends WalletEvent {
  const RefreshBalanceEvent();
}

class LoadTransactionHistoryEvent extends WalletEvent {
  const LoadTransactionHistoryEvent();
}

class LoadInvestmentsEvent extends WalletEvent {
  const LoadInvestmentsEvent();
}

class ImportWalletEvent extends WalletEvent {
  final String privateKey;
  final String? mnemonic;

  const ImportWalletEvent({required this.privateKey, this.mnemonic});

  @override
  List<Object?> get props => [privateKey, mnemonic];
}
