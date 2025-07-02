import 'package:flutter/material.dart';

class TransactionSearchWidget extends StatefulWidget {
  final Function(String) onSearch;

  const TransactionSearchWidget({
    super.key,
    required this.onSearch,
  });

  @override
  State<TransactionSearchWidget> createState() => _TransactionSearchWidgetState();
}

class _TransactionSearchWidgetState extends State<TransactionSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  bool _isAdvancedSearch = false;

  final List<Map<String, String>> _filterOptions = [
    {'value': 'all', 'label': 'All Transactions'},
    {'value': 'sent', 'label': 'Sent'},
    {'value': 'received', 'label': 'Received'},
    {'value': 'failed', 'label': 'Failed'},
    {'value': 'pending', 'label': 'Pending'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Transaction Search',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isAdvancedSearch = !_isAdvancedSearch;
                    });
                  },
                  icon: Icon(
                    _isAdvancedSearch ? Icons.expand_less : Icons.expand_more,
                  ),
                  label: Text(_isAdvancedSearch ? 'Simple' : 'Advanced'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Search input
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter transaction hash or address...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: _scanQRCode,
                      tooltip: 'Scan QR Code',
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() {}),
              onSubmitted: (value) => _performSearch(),
            ),
            const SizedBox(height: 16),
            
            // Quick filter chips
            Wrap(
              spacing: 8,
              children: _filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter['value'];
                return FilterChip(
                  label: Text(filter['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = filter['value']!;
                    });
                    _performSearch();
                  },
                  backgroundColor: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : null,
                  selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                );
              }).toList(),
            ),
            
            // Advanced search options
            if (_isAdvancedSearch) ...[
              const SizedBox(height: 16),
              _buildAdvancedSearchOptions(),
            ],
            
            const SizedBox(height: 16),
            
            // Search button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _searchController.text.isNotEmpty ? _performSearch : null,
                icon: const Icon(Icons.search),
                label: const Text('Search Transactions'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSearchOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advanced Filters',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Date range
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'From Date',
                  hintText: 'YYYY-MM-DD',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDate(context, true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'To Date',
                  hintText: 'YYYY-MM-DD',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDate(context, false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Amount range
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Min Amount',
                  hintText: '0.0',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Max Amount',
                  hintText: '1000.0',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Transaction type
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Transaction Type',
            prefixIcon: const Icon(Icons.category),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          value: null,
          items: const [
            DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
            DropdownMenuItem(value: 'contract', child: Text('Contract Call')),
            DropdownMenuItem(value: 'investment', child: Text('Investment')),
            DropdownMenuItem(value: 'withdrawal', child: Text('Withdrawal')),
          ],
          onChanged: (value) {
            // Handle transaction type selection
          },
        ),
      ],
    );
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      widget.onSearch('$query|$_selectedFilter');
    }
  }

  void _scanQRCode() {
    // Implement QR code scanning
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Code scanner not implemented yet'),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      // Handle date selection
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${isFromDate ? 'From' : 'To'} date selected: ${picked.toString().split(' ')[0]}',
          ),
        ),
      );
    }
  }
}
