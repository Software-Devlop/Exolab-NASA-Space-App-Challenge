import 'package:dartz/dartz.dart';

import 'package:exolab/core/failureHandlers/failureHandler.dart';
import 'package:exolab/features/task/domain/abstractRepos/task_repository.dart';
import 'package:exolab/features/task/domain/entities/task.dart';

class AddTask {
  final TaskRepository repository;

  const AddTask(this.repository);

  Future<Either<Failure, TaskEntity>> call(TaskEntity task) {
    if (task.title.trim().isEmpty) {
      return Future.value(Left(UnexpectedFailure('Title cannot be empty.')));
    }

    return repository.addTask(task);
  }
}
