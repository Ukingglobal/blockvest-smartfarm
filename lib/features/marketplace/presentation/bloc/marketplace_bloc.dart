import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/project.dart';
import '../../data/datasources/mock_project_data.dart';

// Events
abstract class MarketplaceEvent extends Equatable {
  const MarketplaceEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjects extends MarketplaceEvent {
  const LoadProjects();
}

class SearchProjects extends MarketplaceEvent {
  final String query;

  const SearchProjects({required this.query});

  @override
  List<Object?> get props => [query];
}

class FilterProjects extends MarketplaceEvent {
  final ProjectCategory? category;
  final ProjectStatus? status;
  final RiskLevel? riskLevel;
  final double? minInvestment;
  final double? maxInvestment;

  const FilterProjects({
    this.category,
    this.status,
    this.riskLevel,
    this.minInvestment,
    this.maxInvestment,
  });

  @override
  List<Object?> get props => [category, status, riskLevel, minInvestment, maxInvestment];
}

class SortProjects extends MarketplaceEvent {
  final ProjectSortOption sortOption;

  const SortProjects({required this.sortOption});

  @override
  List<Object?> get props => [sortOption];
}

class ClearFilters extends MarketplaceEvent {
  const ClearFilters();
}

// Sort Options
enum ProjectSortOption {
  newest,
  oldest,
  highestFunding,
  lowestFunding,
  highestReturn,
  lowestReturn,
  endingSoon,
}

// States
abstract class MarketplaceState extends Equatable {
  const MarketplaceState();

  @override
  List<Object?> get props => [];
}

class MarketplaceInitial extends MarketplaceState {
  const MarketplaceInitial();
}

class MarketplaceLoading extends MarketplaceState {
  const MarketplaceLoading();
}

class MarketplaceLoaded extends MarketplaceState {
  final List<Project> projects;
  final List<Project> filteredProjects;
  final String searchQuery;
  final ProjectCategory? selectedCategory;
  final ProjectStatus? selectedStatus;
  final RiskLevel? selectedRiskLevel;
  final double? minInvestment;
  final double? maxInvestment;
  final ProjectSortOption sortOption;

  const MarketplaceLoaded({
    required this.projects,
    required this.filteredProjects,
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedStatus,
    this.selectedRiskLevel,
    this.minInvestment,
    this.maxInvestment,
    this.sortOption = ProjectSortOption.newest,
  });

  MarketplaceLoaded copyWith({
    List<Project>? projects,
    List<Project>? filteredProjects,
    String? searchQuery,
    ProjectCategory? selectedCategory,
    ProjectStatus? selectedStatus,
    RiskLevel? selectedRiskLevel,
    double? minInvestment,
    double? maxInvestment,
    ProjectSortOption? sortOption,
    bool clearCategory = false,
    bool clearStatus = false,
    bool clearRiskLevel = false,
    bool clearMinInvestment = false,
    bool clearMaxInvestment = false,
  }) {
    return MarketplaceLoaded(
      projects: projects ?? this.projects,
      filteredProjects: filteredProjects ?? this.filteredProjects,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      selectedRiskLevel: clearRiskLevel ? null : (selectedRiskLevel ?? this.selectedRiskLevel),
      minInvestment: clearMinInvestment ? null : (minInvestment ?? this.minInvestment),
      maxInvestment: clearMaxInvestment ? null : (maxInvestment ?? this.maxInvestment),
      sortOption: sortOption ?? this.sortOption,
    );
  }

  @override
  List<Object?> get props => [
        projects,
        filteredProjects,
        searchQuery,
        selectedCategory,
        selectedStatus,
        selectedRiskLevel,
        minInvestment,
        maxInvestment,
        sortOption,
      ];
}

class MarketplaceError extends MarketplaceState {
  final String message;

  const MarketplaceError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  MarketplaceBloc() : super(const MarketplaceInitial()) {
    on<LoadProjects>(_onLoadProjects);
    on<SearchProjects>(_onSearchProjects);
    on<FilterProjects>(_onFilterProjects);
    on<SortProjects>(_onSortProjects);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadProjects(LoadProjects event, Emitter<MarketplaceState> emit) async {
    emit(const MarketplaceLoading());
    
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      final projects = MockProjectData.projects;
      emit(MarketplaceLoaded(
        projects: projects,
        filteredProjects: projects,
      ));
    } catch (e) {
      emit(MarketplaceError(message: 'Failed to load projects: ${e.toString()}'));
    }
  }

  void _onSearchProjects(SearchProjects event, Emitter<MarketplaceState> emit) {
    if (state is MarketplaceLoaded) {
      final currentState = state as MarketplaceLoaded;
      final filteredProjects = _applyFiltersAndSearch(
        projects: currentState.projects,
        searchQuery: event.query,
        category: currentState.selectedCategory,
        status: currentState.selectedStatus,
        riskLevel: currentState.selectedRiskLevel,
        minInvestment: currentState.minInvestment,
        maxInvestment: currentState.maxInvestment,
        sortOption: currentState.sortOption,
      );

      emit(currentState.copyWith(
        searchQuery: event.query,
        filteredProjects: filteredProjects,
      ));
    }
  }

  void _onFilterProjects(FilterProjects event, Emitter<MarketplaceState> emit) {
    if (state is MarketplaceLoaded) {
      final currentState = state as MarketplaceLoaded;
      final filteredProjects = _applyFiltersAndSearch(
        projects: currentState.projects,
        searchQuery: currentState.searchQuery,
        category: event.category,
        status: event.status,
        riskLevel: event.riskLevel,
        minInvestment: event.minInvestment,
        maxInvestment: event.maxInvestment,
        sortOption: currentState.sortOption,
      );

      emit(currentState.copyWith(
        selectedCategory: event.category,
        selectedStatus: event.status,
        selectedRiskLevel: event.riskLevel,
        minInvestment: event.minInvestment,
        maxInvestment: event.maxInvestment,
        filteredProjects: filteredProjects,
      ));
    }
  }

  void _onSortProjects(SortProjects event, Emitter<MarketplaceState> emit) {
    if (state is MarketplaceLoaded) {
      final currentState = state as MarketplaceLoaded;
      final filteredProjects = _applyFiltersAndSearch(
        projects: currentState.projects,
        searchQuery: currentState.searchQuery,
        category: currentState.selectedCategory,
        status: currentState.selectedStatus,
        riskLevel: currentState.selectedRiskLevel,
        minInvestment: currentState.minInvestment,
        maxInvestment: currentState.maxInvestment,
        sortOption: event.sortOption,
      );

      emit(currentState.copyWith(
        sortOption: event.sortOption,
        filteredProjects: filteredProjects,
      ));
    }
  }

  void _onClearFilters(ClearFilters event, Emitter<MarketplaceState> emit) {
    if (state is MarketplaceLoaded) {
      final currentState = state as MarketplaceLoaded;
      emit(MarketplaceLoaded(
        projects: currentState.projects,
        filteredProjects: currentState.projects,
        searchQuery: '',
        sortOption: ProjectSortOption.newest,
      ));
    }
  }

  List<Project> _applyFiltersAndSearch({
    required List<Project> projects,
    required String searchQuery,
    ProjectCategory? category,
    ProjectStatus? status,
    RiskLevel? riskLevel,
    double? minInvestment,
    double? maxInvestment,
    required ProjectSortOption sortOption,
  }) {
    var filtered = projects.where((project) {
      // Search filter
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!project.title.toLowerCase().contains(query) &&
            !project.description.toLowerCase().contains(query) &&
            !project.location.toLowerCase().contains(query) &&
            !project.farmerName.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Category filter
      if (category != null && project.category != category) {
        return false;
      }

      // Status filter
      if (status != null && project.status != status) {
        return false;
      }

      // Risk level filter
      if (riskLevel != null && project.riskLevel != riskLevel) {
        return false;
      }

      // Investment amount filters
      if (minInvestment != null && project.minimumInvestment < minInvestment) {
        return false;
      }

      if (maxInvestment != null && project.minimumInvestment > maxInvestment) {
        return false;
      }

      return true;
    }).toList();

    // Apply sorting
    switch (sortOption) {
      case ProjectSortOption.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ProjectSortOption.oldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case ProjectSortOption.highestFunding:
        filtered.sort((a, b) => b.fundingProgress.compareTo(a.fundingProgress));
        break;
      case ProjectSortOption.lowestFunding:
        filtered.sort((a, b) => a.fundingProgress.compareTo(b.fundingProgress));
        break;
      case ProjectSortOption.highestReturn:
        filtered.sort((a, b) => b.expectedReturn.compareTo(a.expectedReturn));
        break;
      case ProjectSortOption.lowestReturn:
        filtered.sort((a, b) => a.expectedReturn.compareTo(b.expectedReturn));
        break;
      case ProjectSortOption.endingSoon:
        filtered.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
        break;
    }

    return filtered;
  }
}
