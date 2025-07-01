import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/mock_project_data.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl();

  @override
  Future<Either<Failure, List<Project>>> getProjects() async {
    try {
      final projects = MockProjectData.getAllProjects();
      return Right(projects);
    } catch (e) {
      return Left(ServerFailure('Failed to get projects'));
    }
  }

  @override
  Future<Either<Failure, Project>> getProjectById(String id) async {
    try {
      final project = MockProjectData.getProjectById(id);
      if (project != null) {
        return Right(project);
      } else {
        return Left(ServerFailure('Project not found'));
      }
    } catch (e) {
      return Left(ServerFailure('Failed to get project'));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> searchProjects(String query) async {
    try {
      final projects = MockProjectData.searchProjects(query);
      return Right(projects);
    } catch (e) {
      return Left(ServerFailure('Failed to search projects'));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getProjectsByCategory(
    String category,
  ) async {
    try {
      // Convert string to ProjectCategory enum
      ProjectCategory? categoryEnum;
      switch (category.toLowerCase()) {
        case 'crops':
          categoryEnum = ProjectCategory.crops;
          break;
        case 'livestock':
          categoryEnum = ProjectCategory.livestock;
          break;
        case 'aquaculture':
          categoryEnum = ProjectCategory.aquaculture;
          break;
        case 'forestry':
          categoryEnum = ProjectCategory.forestry;
          break;
        case 'agritech':
          categoryEnum = ProjectCategory.agritech;
          break;
        case 'processing':
          categoryEnum = ProjectCategory.processing;
          break;
        default:
          return Right([]); // Return empty list for unknown categories
      }

      final projects = MockProjectData.getProjectsByCategory(categoryEnum);
      return Right(projects);
    } catch (e) {
      return Left(ServerFailure('Failed to get projects by category'));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getProjectsByLocation(
    String location,
  ) async {
    try {
      final projects = MockProjectData.getProjectsByLocation(location);
      return Right(projects);
    } catch (e) {
      return Left(ServerFailure('Failed to get projects by location'));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getFeaturedProjects() async {
    try {
      final projects = MockProjectData.getFeaturedProjects();
      return Right(projects);
    } catch (e) {
      return Left(ServerFailure('Failed to get featured projects'));
    }
  }
}
