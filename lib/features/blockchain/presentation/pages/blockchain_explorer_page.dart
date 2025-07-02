import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/blockchain_explorer_service.dart';
import '../widgets/network_stats_card.dart';
import '../widgets/recent_blocks_list.dart';
import '../widgets/transaction_search_widget.dart';

class BlockchainExplorerPage extends StatefulWidget {
  const BlockchainExplorerPage({super.key});

  @override
  State<BlockchainExplorerPage> createState() => _BlockchainExplorerPageState();
}

class _BlockchainExplorerPageState extends State<BlockchainExplorerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BlockchainExplorerService _explorerService = BlockchainExplorerService();
  
  bool _isLoading = true;
  Map<String, dynamic> _networkStats = {};
  List<Map<String, dynamic>> _recentBlocks = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeExplorer();
  }

  Future<void> _initializeExplorer() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      await _explorerService.initialize();
      
      // Load initial data
      final stats = await _explorerService.getNetworkStatistics();
      final blocks = await _explorerService.getRecentBlocks(count: 10);
      
      setState(() {
        _networkStats = stats;
        _recentBlocks = blocks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize blockchain explorer: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _explorerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blockchain Explorer'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.view_module), text: 'Blocks'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Transactions'),
            Tab(icon: Icon(Icons.account_balance), text: 'Contracts'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildBlocksTab(),
                    _buildTransactionsTab(),
                    _buildContractsTab(),
                  ],
                ),
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
            'Explorer Error',
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
            onPressed: _initializeExplorer,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _initializeExplorer,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetworkStatsCard(networkStats: _networkStats),
            const SizedBox(height: 16),
            _buildQuickStatsGrid(),
            const SizedBox(height: 16),
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildRecentActivityList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBlocksTab() {
    return RefreshIndicator(
      onRefresh: () async {
        final blocks = await _explorerService.getRecentBlocks(count: 20);
        setState(() {
          _recentBlocks = blocks;
        });
      },
      child: RecentBlocksList(
        blocks: _recentBlocks,
        onBlockTap: _showBlockDetails,
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TransactionSearchWidget(
            onSearch: _searchTransactions,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildTransactionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContractsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildContractSearchBar(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildContractsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Current Block',
          '${_networkStats['currentBlockNumber'] ?? 0}',
          Icons.view_module,
          Colors.blue,
        ),
        _buildStatCard(
          'Total Transactions',
          '${_networkStats['totalTransactions'] ?? 0}',
          Icons.receipt_long,
          Colors.green,
        ),
        _buildStatCard(
          'Active Nodes',
          '${_networkStats['activeNodes'] ?? 0}',
          Icons.hub,
          Colors.orange,
        ),
        _buildStatCard(
          'Avg Block Time',
          '${_networkStats['averageBlockTime'] ?? 0}s',
          Icons.timer,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityList() {
    if (_recentBlocks.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('No recent activity'),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentBlocks.take(5).length,
      itemBuilder: (context, index) {
        final block = _recentBlocks[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.view_module, color: Colors.white),
            ),
            title: Text('Block #${block['number']}'),
            subtitle: Text('${block['transactionCount']} transactions'),
            trailing: Text(
              _formatTimestamp(block['timestamp']),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () => _showBlockDetails(block),
          ),
        );
      },
    );
  }

  Widget _buildTransactionsList() {
    // Mock transaction data for demonstration
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            ),
            title: Text('0x${_generateMockHash(8)}...'),
            subtitle: Text('${(index + 1) * 0.5} SUPRA'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                Text(
                  '${index + 1}m ago',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            onTap: () => _showTransactionDetails('0x${_generateMockHash(64)}'),
          ),
        );
      },
    );
  }

  Widget _buildContractSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search contract address...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onSubmitted: _searchContract,
    );
  }

  Widget _buildContractsList() {
    final contracts = [
      {
        'name': 'Investment Contract',
        'address': '0x1234567890123456789012345678901234567890',
        'type': 'Investment',
        'verified': true,
      },
      {
        'name': 'BlockVest Token',
        'address': '0x0987654321098765432109876543210987654321',
        'type': 'Token',
        'verified': true,
      },
      {
        'name': 'Governance Contract',
        'address': '0x1111222233334444555566667777888899990000',
        'type': 'Governance',
        'verified': false,
      },
    ];

    return ListView.builder(
      itemCount: contracts.length,
      itemBuilder: (context, index) {
        final contract = contracts[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: contract['verified'] as bool
                  ? Colors.green
                  : Colors.orange,
              child: Icon(
                contract['verified'] as bool
                    ? Icons.verified
                    : Icons.warning,
                color: Colors.white,
              ),
            ),
            title: Text(contract['name'] as String),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${(contract['address'] as String).substring(0, 10)}...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
                Text(contract['type'] as String),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => _copyToClipboard(contract['address'] as String),
            ),
            onTap: () => _showContractDetails(contract),
          ),
        );
      },
    );
  }

  // Helper methods
  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _generateMockHash(int length) {
    const chars = '0123456789abcdef';
    return List.generate(length, (index) => chars[index % chars.length]).join();
  }

  void _showBlockDetails(Map<String, dynamic> block) {
    // Navigate to block details page
    Navigator.pushNamed(context, '/block-details', arguments: block);
  }

  void _showTransactionDetails(String txHash) {
    // Navigate to transaction details page
    Navigator.pushNamed(context, '/transaction-details', arguments: txHash);
  }

  void _showContractDetails(Map<String, dynamic> contract) {
    // Navigate to contract details page
    Navigator.pushNamed(context, '/contract-details', arguments: contract);
  }

  void _searchTransactions(String query) {
    // Implement transaction search
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching for: $query')),
    );
  }

  void _searchContract(String address) {
    // Implement contract search
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching contract: $address')),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }
}
