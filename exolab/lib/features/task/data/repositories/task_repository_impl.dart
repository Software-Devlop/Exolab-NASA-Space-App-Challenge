import 'package:dartz/dartz.dart';

import 'package:exolab/core/failureHandlers/exception.dart';
import 'package:exolab/core/failureHandlers/failureHandler.dart';
import 'package:exolab/features/task/domain/abstractRepos/task_repository.dart';
import 'package:exolab/features/task/domain/entities/task.dart';

import '../datasources/task_local_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  const TaskRepositoryImpl(this.localDataSource);

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on LocalDatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks() =>
      _guard(() => localDataSource.getTasks());

  @override
  Future<Either<Failure, TaskEntity>> addTask(TaskEntity task) =>
      _guard(() => localDataSource.insertTask(TaskModel.fromEntity(task)));

  @override
  Future<Either<Failure, void>> updateTask(TaskEntity task) =>
      _guard(() => localDataSource.updateTask(TaskModel.fromEntity(task)));

  @override
  Future<Either<Failure, void>> deleteTask(int id) =>
      _guard(() => localDataSource.deleteTask(id));

  @override
  Future<Either<Failure, bool>> suggestionExists(String suggestionId) async {
    try {
      final exists = await localDataSource.hasSuggestion(suggestionId);
      return Right(exists);
    } catch (e) {
      return Left(DatabaseFailure('Failed to check suggestion existence: $e'));
    }
  }
}
