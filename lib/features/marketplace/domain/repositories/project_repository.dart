import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/project.dart';

abstract class ProjectRepository {
  Future<Either<Failure, List<Project>>> getProjects();
  Future<Either<Failure, Project>> getProjectById(String id);
  Future<Either<Failure, List<Project>>> searchProjects(String query);
  Future<Either<Failure, List<Project>>> getProjectsByCategory(String category);
  Future<Either<Failure, List<Project>>> getProjectsByLocation(String location);
  Future<Either<Failure, List<Project>>> getFeaturedProjects();
}
