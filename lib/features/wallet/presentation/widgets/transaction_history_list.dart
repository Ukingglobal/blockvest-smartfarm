import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/wallet.dart';

class TransactionHistoryList extends StatelessWidget {
  final List<Transaction> transactions;
  final bool isCompact;

  const TransactionHistoryList({
    super.key,
    required this.transactions,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Your transaction history will appear here',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: isCompact,
      physics: isCompact ? const NeverScrollableScrollPhysics() : null,
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionItem(context, transaction);
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    final isIncoming =
        transaction.type == TransactionType.profit ||
        transaction.type == TransactionType.investment;

    final statusColor = _getStatusColor(transaction.status);
    final typeIcon = _getTypeIcon(transaction.type);
    final typeColor = _getTypeColor(transaction.type);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isCompact ? 0 : 16,
        vertical: 8,
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: typeColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(typeIcon, color: typeColor, size: 20),
      ),
      title: Text(
        _getTransactionTitle(transaction.type),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  transaction.status.name.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat(
                  'MMM dd, yyyy • HH:mm',
                ).format(transaction.timestamp),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          if (!isCompact &&
              transaction.blockHash != null &&
              transaction.blockHash!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Hash: ${transaction.blockHash!.substring(0, 8)}...${transaction.blockHash!.substring(transaction.blockHash!.length - 8)}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isIncoming ? '+' : '-'}${NumberFormat.currency(symbol: '₦').format(transaction.amount)}',
            style: TextStyle(
              color: isIncoming ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (transaction.fee > 0) ...[
            const SizedBox(height: 2),
            Text(
              'Fee: ${NumberFormat.currency(symbol: '₦').format(transaction.fee)}',
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
          ],
        ],
      ),
      onTap: isCompact
          ? null
          : () => _showTransactionDetails(context, transaction),
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.confirmed:
        return Colors.green;
      case TransactionStatus.failed:
        return Colors.red;
      case TransactionStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.transfer:
        return Icons.swap_horiz;
      case TransactionType.withdrawal:
        return Icons.arrow_upward;
      case TransactionType.profit:
        return Icons.arrow_downward;
      case TransactionType.investment:
        return Icons.agriculture;
      case TransactionType.staking:
        return Icons.lock;
      case TransactionType.governance:
        return Icons.how_to_vote;
    }
  }

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.transfer:
        return Colors.orange;
      case TransactionType.withdrawal:
        return Colors.red;
      case TransactionType.profit:
        return Colors.green;
      case TransactionType.investment:
        return Colors.blue;
      case TransactionType.staking:
        return Colors.purple;
      case TransactionType.governance:
        return Colors.indigo;
    }
  }

  String _getTransactionTitle(TransactionType type) {
    switch (type) {
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.profit:
        return 'Profit';
      case TransactionType.investment:
        return 'Investment';
      case TransactionType.staking:
        return 'Staking';
      case TransactionType.governance:
        return 'Governance';
    }
  }

  void _showTransactionDetails(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getTransactionTitle(transaction.type)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              'Amount',
              NumberFormat.currency(symbol: '₦').format(transaction.amount),
            ),
            _buildDetailRow(
              'Fee',
              NumberFormat.currency(symbol: '₦').format(transaction.fee),
            ),
            _buildDetailRow('Status', transaction.status.name.toUpperCase()),
            _buildDetailRow(
              'Date',
              DateFormat(
                'MMM dd, yyyy • HH:mm:ss',
              ).format(transaction.timestamp),
            ),
            if (transaction.blockHash != null &&
                transaction.blockHash!.isNotEmpty)
              _buildDetailRow('Hash', transaction.blockHash!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }
}
