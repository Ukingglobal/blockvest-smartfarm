import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletLoaded extends WalletState {
  final Wallet wallet;
  final List<Investment> investments;
  final double totalInvestmentValue;
  final double totalProfitLoss;

  const WalletLoaded({
    required this.wallet,
    required this.investments,
    required this.totalInvestmentValue,
    required this.totalProfitLoss,
  });

  @override
  List<Object?> get props => [
        wallet,
        investments,
        totalInvestmentValue,
        totalProfitLoss,
      ];
}

class WalletError extends WalletState {
  final String message;

  const WalletError({required this.message});

  @override
  List<Object?> get props => [message];
}

class WalletDisconnected extends WalletState {
  const WalletDisconnected();
}

class WalletConnecting extends WalletState {
  const WalletConnecting();
}

class WalletCreating extends WalletState {
  const WalletCreating();
}

class WalletCreated extends WalletState {
  final String address;

  const WalletCreated({required this.address});

  @override
  List<Object?> get props => [address];
}
