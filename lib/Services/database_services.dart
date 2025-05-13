import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();
  String _databaseName = "user_database.db";
  static const _databaseVersion = 1;
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  Future<int> rawInsert(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawInsert(sql, arguments);
  }

  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawUpdate(sql, arguments);
  }

  Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawDelete(sql, arguments);
  }

  Future<List<String>> executeQuery(String query) async {
    final db = await database;
    try {
      final lowered = query.trim().toLowerCase();
      if (lowered == 'tables') {
        final result = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';"
        );
        return result.isNotEmpty
            ? result.map((row) => row['name'].toString()).toList()
            : ['No tables found.'];
      } else if (lowered.startsWith('select')) {
        final result = await db.rawQuery(query);
        return result.isNotEmpty
            ? result.map((row) => _formatRow(row)).toList()
            : ['(No rows returned)'];
      } else if (lowered.startsWith('insert')) {
        final count = await db.rawInsert(query);
        return ['Insert executed successfully. Affected rows: ${count > 0 ? 1 : 0}'];
      } else if (lowered.startsWith('update')) {
        final count = await db.rawUpdate(query);
        return ['Update executed successfully. Affected rows: $count'];
      } else if (lowered.startsWith('delete')) {
        final count = await db.rawDelete(query);
        return ['Delete executed successfully. Affected rows: $count'];
      } else {
        await db.execute(query);
        return ['Query executed successfully.'];
      }
    } catch (e) {
      return ['Error: ${e.toString()}'];
    }
  }

  String _formatRow(Map<String, dynamic> row) {
    return row.entries.map((e) => '${e.key}: ${e.value}').join(' | ');
  }

  void changeDatabaseName(String name) {
    _databaseName = name;
    _database = null;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
