import 'package:dartz/dartz.dart';

import 'package:exolab/core/failureHandlers/failureHandler.dart';
import '../entities/task.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<TaskEntity>>> getTasks();

  Future<Either<Failure, TaskEntity>> addTask(TaskEntity task);

  Future<Either<Failure, void>> updateTask(TaskEntity task);

  Future<Either<Failure, void>> deleteTask(int id);

  Future<Either<Failure, bool>> suggestionExists(String suggestionId);
}
