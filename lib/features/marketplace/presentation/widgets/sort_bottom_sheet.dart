import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/marketplace_bloc.dart';

class SortBottomSheet extends StatelessWidget {
  const SortBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketplaceBloc, MarketplaceState>(
      builder: (context, state) {
        ProjectSortOption currentSortOption = ProjectSortOption.newest;
        if (state is MarketplaceLoaded) {
          currentSortOption = state.sortOption;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Sort Projects',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Sort Options
              ...ProjectSortOption.values.map((option) {
                final isSelected = currentSortOption == option;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Radio<ProjectSortOption>(
                    value: option,
                    groupValue: currentSortOption,
                    onChanged: (ProjectSortOption? value) {
                      if (value != null) {
                        context.read<MarketplaceBloc>().add(
                          SortProjects(sortOption: value),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  title: Text(
                    _getSortOptionDisplayName(option),
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary 
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    _getSortOptionDescription(option),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    context.read<MarketplaceBloc>().add(
                      SortProjects(sortOption: option),
                    );
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),

              const SizedBox(height: 10),
              
              // Add bottom padding for safe area
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  String _getSortOptionDisplayName(ProjectSortOption option) {
    switch (option) {
      case ProjectSortOption.newest:
        return 'Newest First';
      case ProjectSortOption.oldest:
        return 'Oldest First';
      case ProjectSortOption.highestFunding:
        return 'Highest Funding Progress';
      case ProjectSortOption.lowestFunding:
        return 'Lowest Funding Progress';
      case ProjectSortOption.highestReturn:
        return 'Highest Expected Return';
      case ProjectSortOption.lowestReturn:
        return 'Lowest Expected Return';
      case ProjectSortOption.endingSoon:
        return 'Ending Soon';
    }
  }

  String _getSortOptionDescription(ProjectSortOption option) {
    switch (option) {
      case ProjectSortOption.newest:
        return 'Recently added projects first';
      case ProjectSortOption.oldest:
        return 'Older projects first';
      case ProjectSortOption.highestFunding:
        return 'Projects with most funding progress';
      case ProjectSortOption.lowestFunding:
        return 'Projects with least funding progress';
      case ProjectSortOption.highestReturn:
        return 'Projects with highest expected returns';
      case ProjectSortOption.lowestReturn:
        return 'Projects with lowest expected returns';
      case ProjectSortOption.endingSoon:
        return 'Projects ending soonest first';
    }
  }
}
