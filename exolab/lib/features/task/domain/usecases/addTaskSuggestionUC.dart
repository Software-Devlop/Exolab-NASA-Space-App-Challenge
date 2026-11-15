import 'package:exolab/core/failureHandlers/failureHandler.dart';
import 'package:exolab/core/statics/extensions.dart';
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:exolab/features/task/domain/abstractRepos/task_repository.dart';
import 'package:exolab/features/task/domain/entities/task.dart';

class AddTaskSuggestionUseCase {
  final TaskRepository _taskRepository;

  AddTaskSuggestionUseCase(this._taskRepository);

  Future<Either<Failure, TaskEntity>> call(Uri uri) async {
    print("I reached here succussfully");
    final task = _parseTaskSuggestion(uri);

    print(task.toString());
    if (task == null) {
      return Left(
        InvalidInputFailure('Invalid task suggestion deep link or parameters.'),
      );
    }
    return await _taskRepository.addTask(task);
  }

  TaskEntity? _parseTaskSuggestion(Uri uri) {
    try {
      // Decode the URI string first in case query parameters were percent-encoded
      final decodedString = Uri.decodeComponent(uri.toString());
      final parsedUri = Uri.parse(decodedString);

      if (parsedUri.scheme != 'app' ||
          parsedUri.host != 'tasks' ||
          !parsedUri.path.startsWith('/create')) {
        return null;
      }

      final params = parsedUri.queryParameters;

      final title = params['title'];
      if (title == null || title.trim().isEmpty) return null;

      final dates = parsedUri.queryParametersAll['dates'] ?? [];
      final times = parsedUri.queryParametersAll['time'] ?? [];

      final parsedTimes = times.map((value) {
        final parts = value.split(':');

        if (parts.length != 2) {
          throw FormatException('Invalid time format');
        }

        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
          throw FormatException('Invalid time range');
        }

        return TimeOfDay(hour: hour, minute: minute);
      }).toList();

      return TaskEntity(
        title: title,
        description: params['description'],
        dateTimeCreated: DateTime.now().dateOnly,
        isImportant: params['isImportant'] == 'true',
        isRepeated: params['isRepeated'] == 'true',
        dates: dates,
        time: parsedTimes,
        isDone: false,
      );
    } catch (e) {
      debugPrint('Failed to parse task suggestion: $e');
      return null;
    }
  }
}
