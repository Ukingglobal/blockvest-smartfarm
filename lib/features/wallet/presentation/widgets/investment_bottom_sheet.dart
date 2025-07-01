import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../marketplace/domain/entities/project.dart';
import '../bloc/investment_bloc.dart';
import '../bloc/investment_event.dart';
import '../bloc/investment_state.dart';
import 'investment_confirmation_dialog.dart';
import 'investment_processing_dialog.dart';
import 'investment_success_dialog.dart';

class InvestmentBottomSheet extends StatefulWidget {
  final Project project;

  const InvestmentBottomSheet({super.key, required this.project});

  @override
  State<InvestmentBottomSheet> createState() => _InvestmentBottomSheetState();
}

class _InvestmentBottomSheetState extends State<InvestmentBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  double? _investmentAmount;
  bool _isAmountValid = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final text = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(text);

    setState(() {
      _investmentAmount = amount;
      _isAmountValid =
          amount != null &&
          amount >= widget.project.minimumInvestment &&
          amount <= widget.project.targetAmount;
    });
  }

  void _onInvestPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<InvestmentBloc>().add(
        StartInvestmentEvent(
          projectId: widget.project.id,
          amount: _investmentAmount!,
        ),
      );
    }
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an investment amount';
    }

    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null) {
      return 'Please enter a valid amount';
    }

    if (amount < widget.project.minimumInvestment) {
      return 'Minimum investment: ${NumberFormat.currency(symbol: '₦').format(widget.project.minimumInvestment)}';
    }

    if (amount > widget.project.targetAmount) {
      return 'Maximum investment: ${NumberFormat.currency(symbol: '₦').format(widget.project.targetAmount)}';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InvestmentBloc, InvestmentState>(
      listener: (context, state) {
        if (state is InvestmentConfirmation) {
          Navigator.of(context).pop(); // Close bottom sheet
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => InvestmentConfirmationDialog(state: state),
          );
        } else if (state is InvestmentProcessing) {
          Navigator.of(context).pop(); // Close bottom sheet
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => InvestmentProcessingDialog(state: state),
          );
        } else if (state is InvestmentSuccess) {
          Navigator.of(context).pop(); // Close any open dialogs
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => InvestmentSuccessDialog(state: state),
          );
        } else if (state is InvestmentFailure) {
          Navigator.of(context).pop(); // Close any open dialogs
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              action: state.canRetry
                  ? SnackBarAction(
                      label: 'Retry',
                      textColor: Colors.white,
                      onPressed: () {
                        if (_investmentAmount != null) {
                          context.read<InvestmentBloc>().add(
                            RetryInvestmentEvent(
                              projectId: widget.project.id,
                              amount: _investmentAmount!,
                            ),
                          );
                        }
                      },
                    )
                  : null,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Invest in ${widget.project.title}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Project info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: Colors.green[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Expected Return: ${(widget.project.expectedReturn * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.green[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Duration: ${widget.project.daysRemaining} days',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Investment amount form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Investment Amount',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Enter amount in Naira',
                      prefixText: '₦ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: _validateAmount,
                  ),
                  const SizedBox(height: 8),

                  // Investment limits
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Min: ${NumberFormat.currency(symbol: '₦').format(widget.project.minimumInvestment)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Max: ${NumberFormat.currency(symbol: '₦').format(widget.project.targetAmount)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick amount buttons
            Text(
              'Quick Select',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              children: [50000, 100000, 250000, 500000].map((amount) {
                return ActionChip(
                  label: Text(NumberFormat.compact().format(amount)),
                  onPressed: () {
                    _amountController.text = NumberFormat(
                      '#,###',
                    ).format(amount);
                  },
                  backgroundColor: Colors.green[50],
                  side: BorderSide(color: Colors.green[200]!),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Invest button
            BlocBuilder<InvestmentBloc, InvestmentState>(
              builder: (context, state) {
                final isLoading = state is InvestmentLoading;

                return ElevatedButton(
                  onPressed: isLoading || !_isAmountValid
                      ? null
                      : _onInvestPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Proceed to Invest',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                );
              },
            ),

            // Safe area padding
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
