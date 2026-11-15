import 'package:dartz/dartz.dart';

import 'package:exolab/core/failureHandlers/failureHandler.dart';
import 'package:exolab/features/task/domain/entities/task.dart';
import 'package:exolab/features/task/domain/abstractRepos/task_repository.dart';

class ToggleTaskDone {
  final TaskRepository repository;

  const ToggleTaskDone(this.repository);

  Future<Either<Failure, TaskEntity>> call(TaskEntity task) {
    final updatedTask = task.copyWith(isDone: !task.isDone);

    return repository
        .updateTask(updatedTask)
        .then(
          (result) => result.fold(
            (failure) => Left(failure),
            (_) => Right(updatedTask),
          ),
        );
  }
}
