import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../bloc/investment_state.dart';

class InvestmentSuccessDialog extends StatelessWidget {
  final InvestmentSuccess state;

  const InvestmentSuccessDialog({
    super.key,
    required this.state,
  });

  void _copyTransactionHash(BuildContext context) {
    Clipboard.setData(ClipboardData(text: state.transactionHash));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction hash copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon with animation
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 50,
                color: Colors.green[600],
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Investment Successful!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              'Your investment has been confirmed on the blockchain',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Investment summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    'Investment Amount',
                    NumberFormat.currency(symbol: '₦').format(state.amount),
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Transaction Hash',
                    '${state.transactionHash.substring(0, 10)}...${state.transactionHash.substring(state.transactionHash.length - 8)}',
                    showCopy: true,
                    onCopy: () => _copyTransactionHash(context),
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Status',
                    'Confirmed',
                    valueColor: Colors.green[700],
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Date',
                    DateFormat('MMM dd, yyyy • HH:mm').format(state.transaction.timestamp),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Success message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can track your investment progress in the Portfolio section.',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      // Navigate to portfolio (you can implement this navigation)
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'View Portfolio',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                    },
                    child: const Text('Continue Browsing'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool showCopy = false,
    VoidCallback? onCopy,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: valueColor ?? Colors.black,
                fontFamily: label == 'Transaction Hash' ? 'monospace' : null,
              ),
            ),
            if (showCopy && onCopy != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onCopy,
                child: Icon(
                  Icons.copy,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
