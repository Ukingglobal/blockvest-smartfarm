import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/project.dart';
import '../bloc/marketplace_bloc.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  ProjectCategory? selectedCategory;
  ProjectStatus? selectedStatus;
  RiskLevel? selectedRiskLevel;
  double minInvestment = 0;
  double maxInvestment = 1000000;
  RangeValues investmentRange = const RangeValues(0, 1000000);

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  void _initializeFilters() {
    final state = context.read<MarketplaceBloc>().state;
    if (state is MarketplaceLoaded) {
      selectedCategory = state.selectedCategory;
      selectedStatus = state.selectedStatus;
      selectedRiskLevel = state.selectedRiskLevel;
      minInvestment = state.minInvestment ?? 0;
      maxInvestment = state.maxInvestment ?? 1000000;
      investmentRange = RangeValues(minInvestment, maxInvestment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Projects',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _clearAllFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Category Filter
          Text(
            'Category',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ProjectCategory.values.map((category) {
              final isSelected = selectedCategory == category;
              return FilterChip(
                label: Text(_getCategoryDisplayName(category)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    selectedCategory = selected ? category : null;
                  });
                },
                selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                checkmarkColor: Theme.of(context).colorScheme.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Status Filter
          Text(
            'Status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ProjectStatus.values.map((status) {
              final isSelected = selectedStatus == status;
              return FilterChip(
                label: Text(_getStatusDisplayName(status)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    selectedStatus = selected ? status : null;
                  });
                },
                selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                checkmarkColor: Theme.of(context).colorScheme.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Risk Level Filter
          Text(
            'Risk Level',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: RiskLevel.values.map((riskLevel) {
              final isSelected = selectedRiskLevel == riskLevel;
              return FilterChip(
                label: Text(_getRiskLevelDisplayName(riskLevel)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    selectedRiskLevel = selected ? riskLevel : null;
                  });
                },
                selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                checkmarkColor: Theme.of(context).colorScheme.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Investment Range Filter
          Text(
            'Minimum Investment Range',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: investmentRange,
            min: 0,
            max: 1000000,
            divisions: 20,
            labels: RangeLabels(
              '₦${(investmentRange.start / 1000).toStringAsFixed(0)}K',
              '₦${(investmentRange.end / 1000).toStringAsFixed(0)}K',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                investmentRange = values;
                minInvestment = values.start;
                maxInvestment = values.end;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₦${(investmentRange.start / 1000).toStringAsFixed(0)}K',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '₦${(investmentRange.end / 1000).toStringAsFixed(0)}K',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
          
          // Add bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      selectedCategory = null;
      selectedStatus = null;
      selectedRiskLevel = null;
      investmentRange = const RangeValues(0, 1000000);
      minInvestment = 0;
      maxInvestment = 1000000;
    });
  }

  void _applyFilters() {
    context.read<MarketplaceBloc>().add(
      FilterProjects(
        category: selectedCategory,
        status: selectedStatus,
        riskLevel: selectedRiskLevel,
        minInvestment: minInvestment > 0 ? minInvestment : null,
        maxInvestment: maxInvestment < 1000000 ? maxInvestment : null,
      ),
    );
    Navigator.of(context).pop();
  }

  String _getCategoryDisplayName(ProjectCategory category) {
    switch (category) {
      case ProjectCategory.crops:
        return 'Crops';
      case ProjectCategory.livestock:
        return 'Livestock';
      case ProjectCategory.aquaculture:
        return 'Aquaculture';
      case ProjectCategory.forestry:
        return 'Forestry';
      case ProjectCategory.agritech:
        return 'AgriTech';
      case ProjectCategory.processing:
        return 'Processing';
    }
  }

  String _getStatusDisplayName(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.upcoming:
        return 'Upcoming';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.funded:
        return 'Funded';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getRiskLevelDisplayName(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'Medium Risk';
      case RiskLevel.high:
        return 'High Risk';
    }
  }
}
