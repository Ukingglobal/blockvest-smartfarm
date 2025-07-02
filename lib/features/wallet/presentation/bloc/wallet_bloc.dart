import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;

  WalletBloc({required this.walletRepository}) : super(const WalletInitial()) {
    on<LoadWalletEvent>(_onLoadWallet);
    on<ConnectWalletEvent>(_onConnectWallet);
    on<CreateWalletEvent>(_onCreateWallet);
    on<DisconnectWalletEvent>(_onDisconnectWallet);
    on<RefreshBalanceEvent>(_onRefreshBalance);
    on<LoadTransactionHistoryEvent>(_onLoadTransactionHistory);
    on<LoadInvestmentsEvent>(_onLoadInvestments);
    on<ImportWalletEvent>(_onImportWallet);
  }

  Future<void> _onLoadWallet(
    LoadWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());

    try {
      final walletResult = await walletRepository.getWallet();

      await walletResult.fold(
        (failure) async {
          emit(const WalletDisconnected());
        },
        (wallet) async {
          if (!wallet.isConnected) {
            emit(const WalletDisconnected());
            return;
          }

          // Load investments
          final investmentsResult = await walletRepository.getInvestments();

          await investmentsResult.fold(
            (failure) async {
              emit(
                WalletLoaded(
                  wallet: wallet,
                  investments: [],
                  totalInvestmentValue: 0.0,
                  totalProfitLoss: 0.0,
                ),
              );
            },
            (investments) async {
              final totalInvestmentValue = investments.fold<double>(
                0.0,
                (sum, investment) => sum + investment.currentValue,
              );

              final totalProfitLoss = investments.fold<double>(
                0.0,
                (sum, investment) => sum + investment.profitLoss,
              );

              emit(
                WalletLoaded(
                  wallet: wallet,
                  investments: investments,
                  totalInvestmentValue: totalInvestmentValue,
                  totalProfitLoss: totalProfitLoss,
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      emit(WalletError(message: 'Failed to load wallet: ${e.toString()}'));
    }
  }

  Future<void> _onConnectWallet(
    ConnectWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletConnecting());

    try {
      final result = await walletRepository.connectWallet();

      await result.fold(
        (failure) async {
          emit(const WalletError(message: 'Failed to connect wallet'));
        },
        (address) async {
          // Load the wallet after successful connection
          add(const LoadWalletEvent());
        },
      );
    } catch (e) {
      emit(WalletError(message: 'Connection failed: ${e.toString()}'));
    }
  }

  Future<void> _onCreateWallet(
    CreateWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletCreating());

    try {
      final result = await walletRepository.createWallet();

      await result.fold(
        (failure) async {
          emit(const WalletError(message: 'Failed to create wallet'));
        },
        (address) async {
          emit(WalletCreated(address: address));
          // Load the wallet after successful creation
          add(const LoadWalletEvent());
        },
      );
    } catch (e) {
      emit(WalletError(message: 'Wallet creation failed: ${e.toString()}'));
    }
  }

  Future<void> _onDisconnectWallet(
    DisconnectWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    try {
      await walletRepository.disconnectWallet();
      emit(const WalletDisconnected());
    } catch (e) {
      emit(
        WalletError(message: 'Failed to disconnect wallet: ${e.toString()}'),
      );
    }
  }

  Future<void> _onRefreshBalance(
    RefreshBalanceEvent event,
    Emitter<WalletState> emit,
  ) async {
    if (state is WalletLoaded) {
      final currentState = state as WalletLoaded;

      try {
        final balanceResult = await walletRepository.getBalance();
        final blockvestBalanceResult = await walletRepository
            .getBlockvestBalance();

        await balanceResult.fold(
          (failure) async {
            // Keep current state if balance refresh fails
          },
          (balance) async {
            await blockvestBalanceResult.fold(
              (failure) async {
                // Keep current state if BLOCKVEST balance refresh fails
              },
              (blockvestBalance) async {
                final updatedWallet = currentState.wallet.copyWith(
                  balance: balance,
                  blockvestBalance: blockvestBalance,
                );

                emit(
                  WalletLoaded(
                    wallet: updatedWallet,
                    investments: currentState.investments,
                    totalInvestmentValue: currentState.totalInvestmentValue,
                    totalProfitLoss: currentState.totalProfitLoss,
                  ),
                );
              },
            );
          },
        );
      } catch (e) {
        // Keep current state if refresh fails
      }
    }
  }

  Future<void> _onLoadTransactionHistory(
    LoadTransactionHistoryEvent event,
    Emitter<WalletState> emit,
  ) async {
    if (state is WalletLoaded) {
      final currentState = state as WalletLoaded;

      try {
        final result = await walletRepository.getTransactionHistory();

        await result.fold(
          (failure) async {
            // Keep current state if loading fails
          },
          (transactions) async {
            final updatedWallet = currentState.wallet.copyWith(
              transactions: transactions,
            );

            emit(
              WalletLoaded(
                wallet: updatedWallet,
                investments: currentState.investments,
                totalInvestmentValue: currentState.totalInvestmentValue,
                totalProfitLoss: currentState.totalProfitLoss,
              ),
            );
          },
        );
      } catch (e) {
        // Keep current state if loading fails
      }
    }
  }

  Future<void> _onLoadInvestments(
    LoadInvestmentsEvent event,
    Emitter<WalletState> emit,
  ) async {
    if (state is WalletLoaded) {
      final currentState = state as WalletLoaded;

      try {
        final result = await walletRepository.getInvestments();

        await result.fold(
          (failure) async {
            // Keep current state if loading fails
          },
          (investments) async {
            final totalInvestmentValue = investments.fold<double>(
              0.0,
              (sum, investment) => sum + investment.currentValue,
            );

            final totalProfitLoss = investments.fold<double>(
              0.0,
              (sum, investment) => sum + investment.profitLoss,
            );

            emit(
              WalletLoaded(
                wallet: currentState.wallet,
                investments: investments,
                totalInvestmentValue: totalInvestmentValue,
                totalProfitLoss: totalProfitLoss,
              ),
            );
          },
        );
      } catch (e) {
        // Keep current state if loading fails
      }
    }
  }

  Future<void> _onImportWallet(
    ImportWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());

    try {
      final result = await walletRepository.importWallet(
        privateKey: event.privateKey,
        mnemonic: event.mnemonic,
      );

      await result.fold(
        (failure) async {
          emit(WalletError(message: failure.message));
        },
        (wallet) async {
          emit(
            WalletLoaded(
              wallet: wallet,
              investments: [],
              totalInvestmentValue: 0.0,
              totalProfitLoss: 0.0,
            ),
          );
          // Load wallet data after successful import
          add(const LoadWalletEvent());
        },
      );
    } catch (e) {
      emit(WalletError(message: 'Failed to import wallet: ${e.toString()}'));
    }
  }
}
