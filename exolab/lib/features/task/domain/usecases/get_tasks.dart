import 'package:dartz/dartz.dart';

import 'package:exolab/core/failureHandlers/failureHandler.dart';
import 'package:exolab/features/task/domain/entities/task.dart';
import 'package:exolab/features/task/domain/abstractRepos/task_repository.dart';

class GetTasks {
  final TaskRepository repository;

  const GetTasks(this.repository);

  Future<Either<Failure, List<TaskEntity>>> call() {
    return repository.getTasks();
  }
}
