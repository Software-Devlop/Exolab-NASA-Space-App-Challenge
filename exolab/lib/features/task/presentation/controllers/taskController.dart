import 'package:exolab/core/database/app_database.dart';
import 'package:exolab/core/statics/extensions.dart';
import 'package:exolab/features/task/domain/usecases/addTaskSuggestionUC.dart';
import 'package:exolab/features/task/data/datasources/task_local_data_source.dart';
import 'package:exolab/features/task/data/repositories/task_repository_impl.dart';
import 'package:exolab/features/task/domain/abstractRepos/task_repository.dart';
import 'package:exolab/features/task/domain/entities/task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/toggle_task_done.dart';

class TaskController {
  final List<TaskEntity> tasks;
  final bool isLoading;
  final String? errorMessage;

  const TaskController({
    this.tasks = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  TaskController copyWith({
    List<TaskEntity>? tasks,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TaskController(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class TaskControllerManager extends Notifier<TaskController> {
  late final GetTasks _getTasks;
  late final AddTask _addTask;
  late final UpdateTask _updateTask;
  late final DeleteTask _deleteTask;
  late final ToggleTaskDone _toggleTaskDone;
  late final AddTaskSuggestionUseCase _addSuggestedTask;

  @override
  TaskController build() {
    _getTasks = ref.read(getTasksProvider);
    _addTask = ref.read(addTaskProvider);
    _updateTask = ref.read(updateTaskProvider);
    _deleteTask = ref.read(deleteTaskProvider);
    _toggleTaskDone = ref.read(toggleTaskDoneProvider);
    _addSuggestedTask = ref.read(addTaskSuggestionUCProvider);

    return const TaskController();
  }

  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getTasks();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (tasks) {
        state = state.copyWith(
          tasks: tasks,
          isLoading: false,
          clearError: true,
        );
      },
    );
  }

  Future<void> addTask(TaskEntity task) async {
    final result = await _addTask(task);

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (newTask) {
        state = state.copyWith(
          tasks: [...state.tasks, newTask],
          clearError: true,
        );
      },
    );
  }

  Future<void> updateTask(TaskEntity task) async {
    print("HEREEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE:\n${task}");
    final result = await _updateTask(task);

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        state = state.copyWith(
          tasks: [
            for (final existingTask in state.tasks)
              if (existingTask.id == task.id) task else existingTask,
          ],
          clearError: true,
        );
      },
    );
  }

  Future<void> toggleDone(TaskEntity task) async {
    final result = await _toggleTaskDone(task);

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (updatedTask) {
        state = state.copyWith(
          tasks: [
            for (final existingTask in state.tasks)
              if (existingTask.id == updatedTask.id)
                updatedTask
              else
                existingTask,
          ],
          clearError: true,
        );
      },
    );
  }

  Future<void> deleteTask(int id) async {
    final result = await _deleteTask(id);

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        state = state.copyWith(
          tasks: state.tasks.where((task) => task.id != id).toList(),
          clearError: true,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> addTaskSuggestion(Uri uri) async {
    final result = await _addSuggestedTask.call(uri);

    if (result.isLeft()) {
      final failure = result.getLeft();
      state = state.copyWith(errorMessage: failure.message);
    } else {
      final newTask = result.getRight();
      state = state.copyWith(
        tasks: [...state.tasks, newTask],
        clearError: true,
      );
    }
  }
}

final taskControllerProvider =
    NotifierProvider<TaskControllerManager, TaskController>(
      TaskControllerManager.new,
    );

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  return TaskLocalDataSourceImpl(ref.read(appDatabaseProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.read(taskLocalDataSourceProvider));
});

final getTasksProvider = Provider<GetTasks>((ref) {
  return GetTasks(ref.read(taskRepositoryProvider));
});

final addTaskProvider = Provider<AddTask>((ref) {
  return AddTask(ref.read(taskRepositoryProvider));
});

final updateTaskProvider = Provider<UpdateTask>((ref) {
  return UpdateTask(ref.read(taskRepositoryProvider));
});

final deleteTaskProvider = Provider<DeleteTask>((ref) {
  return DeleteTask(ref.read(taskRepositoryProvider));
});

final toggleTaskDoneProvider = Provider<ToggleTaskDone>((ref) {
  return ToggleTaskDone(ref.read(taskRepositoryProvider));
});

// Use cases
final addTaskSuggestionUCProvider = Provider<AddTaskSuggestionUseCase>(
  (ref) => AddTaskSuggestionUseCase(ref.watch(taskRepositoryProvider)),
  isAutoDispose: true,
);
