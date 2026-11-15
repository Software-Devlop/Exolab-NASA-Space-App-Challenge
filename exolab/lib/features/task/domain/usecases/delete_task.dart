import 'package:dartz/dartz.dart';

import 'package:exolab/core/failureHandlers/failureHandler.dart';
import 'package:exolab/features/task/domain/abstractRepos/task_repository.dart';

class DeleteTask {
  final TaskRepository repository;

  const DeleteTask(this.repository);

  Future<Either<Failure, void>> call(int id) {
    return repository.deleteTask(id);
  }
}
