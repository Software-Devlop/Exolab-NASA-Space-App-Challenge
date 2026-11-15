import 'package:dartz/dartz.dart';

import 'package:exolab/core/failureHandlers/failureHandler.dart';
import 'package:exolab/features/task/domain/entities/task.dart';
import 'package:exolab/features/task/domain/abstractRepos/task_repository.dart';

class UpdateTask {
  final TaskRepository repository;

  const UpdateTask(this.repository);

  Future<Either<Failure, void>> call(TaskEntity task) {
    if (task.id == null) {
      return Future.value(
        Left(UnexpectedFailure('Cannot update a task without an id.')),
      );
    }

    if (task.title.trim().isEmpty) {
      return Future.value(Left(UnexpectedFailure('Title cannot be empty.')));
    }

    return repository.updateTask(task);
  }
}
