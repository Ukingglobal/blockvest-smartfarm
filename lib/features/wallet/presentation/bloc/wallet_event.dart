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
  const ConnectWalletEvent();
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
