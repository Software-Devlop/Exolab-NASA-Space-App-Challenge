import 'package:exolab/core/failureHandlers/exception.dart';
import '../../../../core/database/app_database.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> insertTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(int id);
  Future<bool> hasSuggestion(String suggestionId);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final AppDatabase appDatabase;
  const TaskLocalDataSourceImpl(this.appDatabase);

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final db = await appDatabase.database;
      final rows = await db.query(
        AppDatabase.tasksTable,
        orderBy: 'is_done ASC, is_important DESC, date_time_created DESC',
      );
      return rows.map(TaskModel.fromMap).toList();
    } catch (e) {
      throw LocalDatabaseException('Failed to load tasks: $e');
    }
  }

  @override
  Future<TaskModel> insertTask(TaskModel task) async {
    try {
      final db = await appDatabase.database;
      final id = await db.insert(AppDatabase.tasksTable, task.toMap());
      return TaskModel.fromEntity(task.copyWith(id: id));
    } catch (e) {
      throw LocalDatabaseException('Failed to add task: $e');
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      final db = await appDatabase.database;
      await db.update(
        AppDatabase.tasksTable,
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    } catch (e) {
      throw LocalDatabaseException('Failed to update task: $e');
    }
  }

  @override
  Future<void> deleteTask(int id) async {
    try {
      final db = await appDatabase.database;
      await db.delete(AppDatabase.tasksTable, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw LocalDatabaseException('Failed to delete task: $e');
    }
  }

  Future<bool> hasSuggestion(String suggestionId) async {
    final db = await appDatabase.database;
    final result = await db.query(
      'tasks', // your database table name
      where: 'suggestion_id = ?',
      whereArgs: [suggestionId],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
