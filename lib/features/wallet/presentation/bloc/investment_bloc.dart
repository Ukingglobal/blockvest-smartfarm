import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../../marketplace/domain/repositories/project_repository.dart';
import 'investment_event.dart';
import 'investment_state.dart';
import '../../domain/entities/wallet.dart';

class InvestmentBloc extends Bloc<InvestmentEvent, InvestmentState> {
  final WalletRepository walletRepository;
  final ProjectRepository projectRepository;

  InvestmentBloc({
    required this.walletRepository,
    required this.projectRepository,
  }) : super(const InvestmentInitial()) {
    on<StartInvestmentEvent>(_onStartInvestment);
    on<ConfirmInvestmentEvent>(_onConfirmInvestment);
    on<CancelInvestmentEvent>(_onCancelInvestment);
    on<CheckTransactionStatusEvent>(_onCheckTransactionStatus);
    on<RetryInvestmentEvent>(_onRetryInvestment);
  }

  Future<void> _onStartInvestment(
    StartInvestmentEvent event,
    Emitter<InvestmentState> emit,
  ) async {
    emit(const InvestmentLoading(message: 'Preparing investment...'));

    try {
      // Get project details
      final projectResult = await projectRepository.getProjectById(
        event.projectId,
      );

      await projectResult.fold(
        (failure) async {
          emit(
            const InvestmentFailure(
              message: 'Failed to load project details',
              canRetry: true,
            ),
          );
        },
        (project) async {
          // Calculate estimated gas fee (mock calculation)
          const estimatedGasFee = 0.001; // 0.001 SUPRA
          final totalAmount = event.amount + estimatedGasFee;

          // Check if user has sufficient balance
          final balanceResult = await walletRepository.getBalance();

          await balanceResult.fold(
            (failure) async {
              emit(
                const InvestmentFailure(
                  message: 'Failed to check wallet balance',
                  canRetry: true,
                ),
              );
            },
            (balance) async {
              if (balance < totalAmount) {
                emit(
                  const InvestmentFailure(
                    message: 'Insufficient balance for this investment',
                    canRetry: false,
                  ),
                );
                return;
              }

              emit(
                InvestmentConfirmation(
                  projectId: event.projectId,
                  projectName: project.title,
                  amount: event.amount,
                  estimatedGasFee: estimatedGasFee,
                  totalAmount: totalAmount,
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      emit(
        InvestmentFailure(
          message: 'An unexpected error occurred: ${e.toString()}',
          canRetry: true,
        ),
      );
    }
  }

  Future<void> _onConfirmInvestment(
    ConfirmInvestmentEvent event,
    Emitter<InvestmentState> emit,
  ) async {
    emit(
      const InvestmentLoading(message: 'Processing investment transaction...'),
    );

    try {
      final result = await walletRepository.investInProject(
        projectId: event.projectId,
        amount: event.amount,
      );

      await result.fold(
        (failure) async {
          emit(
            const InvestmentFailure(
              message: 'Investment transaction failed. Please try again.',
              canRetry: true,
            ),
          );
        },
        (transactionHash) async {
          emit(
            InvestmentProcessing(
              transactionHash: transactionHash,
              message:
                  'Transaction submitted. Waiting for blockchain confirmation...',
            ),
          );

          // Start monitoring transaction status
          add(CheckTransactionStatusEvent(transactionHash: transactionHash));
        },
      );
    } catch (e) {
      emit(
        InvestmentFailure(
          message: 'Investment failed: ${e.toString()}',
          canRetry: true,
        ),
      );
    }
  }

  Future<void> _onCancelInvestment(
    CancelInvestmentEvent event,
    Emitter<InvestmentState> emit,
  ) async {
    emit(const InvestmentCancelled());
  }

  Future<void> _onCheckTransactionStatus(
    CheckTransactionStatusEvent event,
    Emitter<InvestmentState> emit,
  ) async {
    try {
      // Wait a bit before checking status
      await Future.delayed(const Duration(seconds: 3));

      final result = await walletRepository.getTransactionStatus(
        event.transactionHash,
      );

      await result.fold(
        (failure) async {
          emit(
            const InvestmentFailure(
              message: 'Failed to check transaction status',
              canRetry: true,
            ),
          );
        },
        (transaction) async {
          if (transaction.status == TransactionStatus.confirmed) {
            emit(
              InvestmentSuccess(
                transactionHash: event.transactionHash,
                projectId: transaction.projectId ?? '',
                amount: transaction.amount,
                transaction: transaction,
              ),
            );
          } else if (transaction.status == TransactionStatus.failed) {
            emit(
              const InvestmentFailure(
                message: 'Transaction failed on blockchain',
                canRetry: true,
              ),
            );
          } else {
            // Still pending, check again after a delay
            await Future.delayed(const Duration(seconds: 5));
            add(
              CheckTransactionStatusEvent(
                transactionHash: event.transactionHash,
              ),
            );
          }
        },
      );
    } catch (e) {
      emit(
        InvestmentFailure(
          message: 'Error checking transaction status: ${e.toString()}',
          canRetry: true,
        ),
      );
    }
  }

  Future<void> _onRetryInvestment(
    RetryInvestmentEvent event,
    Emitter<InvestmentState> emit,
  ) async {
    add(StartInvestmentEvent(projectId: event.projectId, amount: event.amount));
  }
}
