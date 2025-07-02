import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransactionDetailsPage extends StatefulWidget {
  final String transactionHash;

  const TransactionDetailsPage({super.key, required this.transactionHash});

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _transactionData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransactionDetails();
  }

  Future<void> _loadTransactionDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock transaction data
      _transactionData = {
        'hash': widget.transactionHash,
        'status': 'confirmed',
        'blockNumber': 1234567,
        'blockHash':
            '0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
        'transactionIndex': 42,
        'from': '0x1234567890123456789012345678901234567890',
        'to': '0x0987654321098765432109876543210987654321',
        'value': '2.5',
        'gasLimit': 21000,
        'gasUsed': 21000,
        'gasPrice': '20',
        'totalGasFee': '0.00042',
        'nonce': 156,
        'timestamp': DateTime.now()
            .subtract(const Duration(minutes: 15))
            .millisecondsSinceEpoch,
        'confirmations': 12,
        'type': 'transfer',
        'data': '0x',
        'logs': [],
      };

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load transaction details: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactionDetails,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareTransaction,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget()
          : _buildTransactionDetails(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Transaction Not Found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadTransactionDetails,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails() {
    if (_transactionData == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildTransactionOverview(),
          const SizedBox(height: 16),
          _buildTransactionInfo(),
          const SizedBox(height: 16),
          _buildGasInformation(),
          const SizedBox(height: 16),
          _buildBlockInformation(),
          if (_transactionData!['logs'].isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildEventLogs(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = _transactionData!['status'] as String;
    final confirmations = _transactionData!['confirmations'] as int;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Confirmed';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Pending';
        break;
      case 'failed':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Failed';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'Unknown';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(statusIcon, color: statusColor, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (status == 'confirmed')
                    Text(
                      '$confirmations confirmations',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Overview',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Hash', _transactionData!['hash'], copyable: true),
            _buildDetailRow('Value', '${_transactionData!['value']} SUPRA'),
            _buildDetailRow('From', _transactionData!['from'], copyable: true),
            _buildDetailRow('To', _transactionData!['to'], copyable: true),
            _buildDetailRow(
              'Timestamp',
              _formatTimestamp(_transactionData!['timestamp']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Details',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Type',
              _transactionData!['type'].toString().toUpperCase(),
            ),
            _buildDetailRow('Nonce', _transactionData!['nonce'].toString()),
            _buildDetailRow(
              'Transaction Index',
              _transactionData!['transactionIndex'].toString(),
            ),
            if (_transactionData!['data'] != '0x')
              _buildDetailRow(
                'Input Data',
                _transactionData!['data'],
                copyable: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGasInformation() {
    final gasUsed = _transactionData!['gasUsed'] as int;
    final gasLimit = _transactionData!['gasLimit'] as int;
    final gasPrice = _transactionData!['gasPrice'] as String;
    final totalGasFee = _transactionData!['totalGasFee'] as String;
    final gasUtilization = (gasUsed / gasLimit) * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gas Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Gas Used', '$gasUsed'),
            _buildDetailRow('Gas Limit', '$gasLimit'),
            _buildDetailRow('Gas Price', '$gasPrice Gwei'),
            _buildDetailRow('Total Gas Fee', '$totalGasFee SUPRA'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gas Utilization',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${gasUtilization.toStringAsFixed(1)}%',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: gasUtilization / 100,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.outline.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                gasUtilization > 80 ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockInformation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Block Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Block Number',
              _transactionData!['blockNumber'].toString(),
            ),
            _buildDetailRow(
              'Block Hash',
              _transactionData!['blockHash'],
              copyable: true,
            ),
            _buildDetailRow(
              'Confirmations',
              _transactionData!['confirmations'].toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventLogs() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Logs',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('No event logs for this transaction'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: copyable ? 'monospace' : null,
              ),
            ),
          ),
          if (copyable)
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () => _copyToClipboard(value),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareTransaction() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality not implemented yet')),
    );
  }
}
