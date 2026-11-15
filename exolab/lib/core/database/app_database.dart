import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  static const String _dbName = 'tasks_manager.db';
  static const int _dbVersion = 1;

  static const String tasksTable = 'tasks';

  Future<Database>? _database;

  String? _databasePath;

  String? get databasePath => _databasePath;

  Future<Database> get database => _database ??= _open();

  Future<Database> _open() async {
    _databasePath = kIsWeb
        ? _dbName
        : p.join(await getDatabasesPath(), _dbName);

    debugPrint('Database location: $_databasePath');

    return openDatabase(
      _databasePath!,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tasksTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            date_time_created TEXT NOT NULL,
            is_important INTEGER NOT NULL DEFAULT 0,
            is_repeated INTEGER NOT NULL DEFAULT 0,
            dates TEXT NOT NULL DEFAULT '[]',
            times TEXT NOT NULL DEFAULT '[]',
            is_done INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<void> close() async {
    final db = await _database;
    await db?.close();
    _database = null;
    _databasePath = null;
  }
}
